`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/21 14:42:45
// Design Name: 
// Module Name: AD9957
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module AD9957(
    output wire clk_124M,
    input clk_62M,
    input sysclk,
    input rst_n,

    inout ad9957_sdio,
    input ad9957_sdo,
    output ad9957_sck,
    output ad9957_cs,

    input wire[17:0] I_data,
    input wire[17:0] Q_data,
    input ad9957_valid,
    input ad9957_pclk,
    output wire ad9957_osk,// 输出移位键控，数字输入（高电平有效）。使用OSK（手动或自动）时，此引脚控制OSK功能。未使用OSK时，此引脚连到高电平。
    output wire ad9957_io_rst,// 输入/输出复位，数字输入（高电平有效）。通信周期出现故障期间变为高电平时，此引脚并不会复位整个器件，而是复位串行端口控制器的状态机并清空自上次I/O更新以来写入的任何I/O缓冲器。
    output wire ad9957_rt,// RAM触发器，数字输入（高电平有效）。此引脚为RAM幅度调整功能提供控制。
    output wire[2:0] ad9957_oe,
    output reg ad9957_m_rst,// 主机复位，数字输入（高电平有效）。此引脚将所有存储元件清0，寄存器设置为默认值。
    output reg ad9957_txenable,
    output reg ad9957_io_update,// 输入/输出更新；数字输入或输出（高电平有效），取决于内部I/O更新有效位。此引脚高电平表示I/O缓冲内容将传输到相应的内部寄存器。  
    output reg[2:0] ad9957_profile,// Profile选择引脚，数字输入（高电平有效）。这些引脚用于选择DDS内核的八个相位/频率特性之一（单音或载波音）。
                           // 通过改变其中一个引脚的状态，可将所有当前I/O缓冲内容传输到相应寄存器。要改变状态，需要参考SYNC_CLK引脚上的信号来建立信号。
    output reg[17:0] data, 
    output reg trigger,
    output reg trigger_r,
    output wire[35:0] din,
    output reg[35:0] din_r,
    output reg tx_start,

    output reg ad9957_init_done
);
wire wr_finish;
wire ad9957_dataDir;
wire ad9957_miso,ad9957_mosi;

reg start;
reg[63:0] value;
reg[7:0] address;
reg[6:0] len;

reg[1:0] dly;
reg[7:0] cnt;
reg ioupdate_pulse;
reg move,rmove;

reg[7:0] config_state;
reg[2:0] move_sync;

wire[71:0] wrFrameData64;
wire[55:0] wrFrameData48;
wire[39:0] wrFrameData32;
wire[23:0] wrFrameData16;
wire[63:0] rdByte64;
wire[47:0] rdByte48;
wire[31:0] rdByte32;
wire[15:0] rdByte16;

wire locked;

assign ad9957_miso = ad9957_sdio;
assign ad9957_sdio = ad9957_dataDir ? ad9957_mosi : 1'bz;

assign ad9957_io_rst = 1'b0;
assign ad9957_osk = 1'b0;
assign ad9957_rt = 1'b0;
assign ad9957_oe = 3'b000;
assign din = {I_data,Q_data};

 clk_wiz_1 clk_wiz_1
   (
    // Clock out ports
    .clk_out1(clk_124M),     // output clk_out1
    .resetn(ad9957_init_done), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(ad9957_pclk)      // input clk_in1
);

always@(posedge clk_124M)begin
  if (!ad9957_init_done)begin
    trigger <= 1'b0;
  end
  else if (ad9957_init_done)begin
    trigger <= ~trigger;
  end
end

always@(posedge clk_124M)begin
  if (!ad9957_init_done)
    trigger_r <= 1'b0;
  else if (ad9957_init_done)
    trigger_r <= trigger;
end

always @(posedge clk_124M) begin
    if (!ad9957_init_done) begin
      tx_start <= 1'b0;
      data <= 0;
    end 
    else if (trigger && ad9957_init_done) begin  
      data <= din[17:0];  // 读取I信号
      tx_start <= 1'b1;
    end
    else if (trigger_r && ad9957_init_done) begin
      data <= din_r[35:18];
    end
end

always@(posedge clk_62M)begin
  if (ad9957_init_done)
    din_r <= din;
end

localparam  
            //address
            CFR1	          =	8'h00,// Control Function Register #1 [31:0]
            CFR2            =   8'h01,// Control Function Register #2 [31:0]
            CFR3            =   8'h02,// Control Function Register #3 [31:0]
            AUXDAC          =   8'h03,// Auxilliary DAC Control Register [31:0]
            IOUPDATERATE    =   8'h04,// IO Update Rate Register [31:0]
        
            RAM0            =   8'h05,// QDUC RAM Segment  Register #0 [47:0]
            RAM1            =   8'h06,// QDUC RAM Segment  Register #1 [47:0]
            ASF             =   8'h09,// Amplitude Scale Factor (ASF) Register [31:0]
            MSYNC           =   8'h0A,// Multi-Chip Sync Register [31:0]
            PROFILE0        =   8'h0E,// QDUC Profile 0  Register [63:0]
            PROFILE1        =   8'h0F,// QDUC Profile 1  Register [63:0]
            PROFILE2        =   8'h10,// QDUC Profile 2  Register [63:0]
            PROFILE3        =   8'h11,// QDUC Profile 3  Register [63:0]
            PROFILE4        =   8'h12,// QDUC Profile 4  Register [63:0]
            PROFILE5        =   8'h13,// QDUC Profile 5  Register [63:0]
            PROFILE6        =   8'h14,// QDUC Profile 6  Register [63:0]
            PROFILE7        =   8'h15,// QDUC Profile 7  Register [63:0]
            RAM             =   8'h16,// RAM Register [31:0]
            GPIOCONFIG      =   8'h18,// GPIO Configuration Register [15:0]
            GPIODATA        =   8'h19;// GPIO Data Register	[15:0]

localparam
            len16           =   'd16,
            len32           =   'd32,
            len48           =   'd48,
            len64           =   'd64;  

always@(posedge sysclk or negedge rst_n)begin
    if (!rst_n)begin
        move <= 1'b0;
        rmove <= 1'b0;
        ad9957_m_rst <= 1'b1;
        // ad9957_init_done_r <= 3'b000;
    end
    else begin
        ad9957_m_rst <= 1'b0;
        if (config_state == 8'd9)
          rmove <= 1'b1;
        move <= !rmove;
        // dly <= {dly[0],ad9957_io_update};
        // ioupdate_pulse <= (~dly[1]) && dly[0];
        // if (ioupdate_pulse == 1'b1)begin
        //     rmove <= 1'b1;
        //     cout <= cout + 1'b1;
        //     ad9957_init_done_r <= {ad9957_init_done_r[1:0],1'b1};
        // end
        // if (rmove == 1'b1)begin
        //     if (cnt == 'd100)begin
        //         rmove <= 1'b0;
        //         cnt <= 1'b0;
        //     end
        //     else
        //         cnt <= cnt + 1'b1;
        // end
    end
end     


always@(negedge ad9957_pclk)begin
  if (!ad9957_valid && !ad9957_init_done)
    ad9957_txenable <= 1'b0;
  else if (tx_start && ad9957_init_done && ad9957_valid)
    ad9957_txenable <= 1'b1;
  else
    ad9957_txenable <= 1'b0;
end


always@(posedge sysclk or negedge rst_n)begin
  if (!rst_n)begin
    move_sync <= 3'b000;
  end
  else
    move_sync <= {move_sync[1:0], move};
end
 
  always @(posedge sysclk or negedge rst_n)
  begin
    if(~rst_n) begin
	    start <= 1'b0;
	    ad9957_init_done <= 1'b0;
	    config_state <= 8'd0;
        ad9957_io_update <= 1'b0;
        ad9957_profile <= 3'b000;
        len <= 1'b0;
	end else begin
	  case(config_state)
        8'd0:begin
          start <= 1'b0;
          address <= 8'h00;
          value <= 64'h0000;
          len <= 7'b0000000;
          ad9957_io_update <= 1'b0; 
          config_state <= config_state + 1'b1;	
        end
        8'd1:begin
          if (move)
            config_state <= config_state + 1'b1;
          else
            config_state <= config_state;
        end
	      8'd2:begin             
	        start <= 1'b1;
          value <= 64'h00_40_00_00;//QDUC模式40MHz
	        address <= CFR1;
          len <= len32;
          config_state <= config_state + 1'b1;		 
	      end
	      8'd3:begin
	        if(wr_finish) begin
	          start <= 1'b0; 
            config_state <= config_state + 1'b1;	
	        end
          else begin
	          start <= start; 
            config_state <= config_state;	
	        end		    
	      end
	      8'd4: begin           
	        start <= 1'b1;
          value <= 64'h00_40_28_00;//QDUC模式40MHz
		      address <= CFR2;
          len <= len32;
          config_state <= config_state + 1'b1;		  
		    end
		    8'd5: begin
		      if(wr_finish) begin
		        start <= 1'b0; 
            config_state <= config_state + 1'b1;	
		      end 
          else begin
		        start <= start; 
            config_state <= config_state;	
		      end		    
		    end
		    8'd6: begin            
		      start <= 1'b1;
          value <= 64'h37_00_C0_00;
		      address <= CFR3;
          len <= len32;
          config_state <= config_state + 1'b1;		  
		    end
		    8'd7: begin
		      if(wr_finish) begin
		        start <= 1'b0; 
            config_state <= config_state + 1'b1;	
		      end 
          else begin
		        start <= start; 
            config_state <= config_state;	
		      end
        end	
		    8'd8: begin             
		      start <= 1'b1;
          // value <= 64'h06FF_0000_2A6E_978D;
          value <= 64'h0AFF_0000_1800_0000;
		      address <= PROFILE0;
          len <= len64;
          config_state <= config_state + 1'b1;		  
		    end
		    8'd9: begin
		      if(wr_finish) begin
		        start <= 1'b0; 
            config_state <= config_state + 1'b1;	
		      end 
          else begin
		        start <= start; 
            config_state <= config_state;	
		      end
        end
        8'd10:begin
          config_state <= 'd0;
          ad9957_init_done <= 1'b1;
          ad9957_io_update <= 1'b1;
        end
        default: begin
	    	  config_state <= 'd0;
        end		  
	    endcase
	end
  end
  
AD9957_SPI AD9957_SPI(
    .sysclk(sysclk),
    .rst_n(rst_n),

    .ad9957_mosi(ad9957_mosi),
    .ad9957_cs(ad9957_cs),
    .ad9957_sck(ad9957_sck),
    .ad9957_miso(ad9957_miso),

    .len(len),
    .address(address),
    .value(value),

    .start(start),

    .wr_finish(wr_finish),
    .ad9957_dataDir(ad9957_dataDir),

    .wrFrameData64(wrFrameData64),
    .wrFrameData48(wrFrameData48),
    .wrFrameData32(wrFrameData32),
    .wrFrameData16(wrFrameData16),
    .rdByte64(rdByte64),
    .rdByte48(rdByte48),
    .rdByte32(rdByte32),
    .rdByte16(rdByte16)
);
endmodule
