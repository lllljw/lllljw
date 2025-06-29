`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/21 13:32:28
// Design Name: 
// Module Name: AD9652
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


module AD9652(
    input  adref_clk,
    input  sysclk,
    input  rst_n,
    ////////////////////////////
    inout ad9652_sdio,
    output ad9652_sck,
    output ad9652_cs,
    ////////////////////////////
    input ad9652_ORN,
    input ad9652_ORP,
    input ad9652_DCON,
    input ad9652_DCOP,
    output ad9652_PDWN,
    ////////////////////////////
    input[15:0] ad9652_DataN,
    input[15:0] ad9652_DataP,
    ///////////////////////////
    output wire ad9652_DCLK,
    output reg[15:0] adc_DataN,
    output reg[15:0] adc_DataP,

    output reg ad9652_init_done
);
wire ad9652_OR;

reg[23:0] value;
wire[7:0] rdByte;
wire[15:0] rdFrame;
wire[31:0] Data_r;

wire ad9652_miso;
wire ad9652_mosi;
wire ad9652_dataDir;
wire wr_finish;
wire delay_locked;

reg nRd;
reg start;
reg[7:0] config_state;

assign ad9652_PDWN = 1'b0;
assign ad9652_miso = ad9652_sdio;
assign ad9652_sdio = ad9652_dataDir ? ad9652_mosi : 1'bz;

selectio_wiz_0 selectio_wiz_0
 (
   .data_in_from_pins_p(ad9652_DataP), // input [15:0] data_in_from_pins_p
   .data_in_from_pins_n(ad9652_DataN), // input [15:0] data_in_from_pins_n
   .data_in_to_device(Data_r), // output [31:0] data_in_to_device
   .delay_locked(delay_locked), // output delay_locked                      
   .ref_clock(adref_clk), // input ref_clock
   .clk_in_p(ad9652_DCOP), // input clk_in_p                          
   .clk_in_n(ad9652_DCON), // input clk_in_n
   .clk_out(ad9652_DCLK), // output clk_out
   .io_reset(~rst_n) // input io_reset
); 

always@(posedge ad9652_DCLK or negedge rst_n)begin
    if (!rst_n)
        adc_DataP <= 'd0;
    else
        adc_DataP <= Data_r[15:0];//A
end
always@(negedge ad9652_DCLK or negedge rst_n)begin
    if (!rst_n)
        adc_DataN <= 'd0;
    else
        adc_DataN <= Data_r[31:16];//B
end

IBUFGDS 
 #(.DIFF_TERM("FALSE"))
 C1(
  .I      (ad9652_ORP),
  .IB     (ad9652_ORN),
  .O      (ad9652_OR)
);

localparam  
            VALUE0	   =	  24'h0_005_03,
            VALUE1     =    24'h0_00B_04,
            VALUE2     =    24'h0_00D_00,
            VALUE3     =    24'h0_00F_01,
            VALUE4     =    24'h0_014_01,
            VALUE5     =    24'h0_018_C5,
            VALUE6     =    24'h0_030_10,
            VALUE7     =    24'h0_045_01,
            VALUE8     =    24'h0_047_08,
            VALUE9     =    24'h0_049_00,
            VALUE10    =    24'h0_04A_02,
            VALUE11    =    24'h0_100_07,//
            VALUE12    =    24'h0_212_00,
            VALUE13    =    24'h0_22A_00,

            VALUE14    =    24'h0_0FF_01,
            VALUE15    =    24'h0_005_01,
            VALUE16    =    24'h0_010_A8,//AD9652_offsetA
            VALUE17    =    24'h0_0FF_01,
            VALUE18    =    24'h0_005_02,
            VALUE19    =    24'h0_010_A8,//AD9652_offsetB
            VALUE20    =    24'h0_0FF_01,
            VALUE21    =    24'h0_002_00;
always@(posedge sysclk or negedge rst_n)begin
    if (!rst_n)begin
      start <= 1'b0;
      nRd <= 1'b0;
      ad9652_init_done <= 1'b0;
      config_state <= 8'd0;
    end
    else begin
        case(config_state)
            'd0:begin             
              start <= 1'b1;
	            nRd <= 1'b1;
		          ad9652_init_done <= 1'b0;
		          value <= VALUE0;
              config_state <= config_state + 1'b1;	
            end
            'd1:begin
              if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd2:begin             
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE1;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd3:begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end		    
		        end
            8'd4:begin           
              start <= 1'b1;
              nRd <= 1'b1;
              value <= VALUE2;
              config_state <= config_state + 1'b1;		  
            end
            8'd5:begin
              if(wr_finish) begin
                start <= 1'b0; 
                config_state <= config_state + 1'b1;	
              end else begin
                start <= start; 
                config_state <= config_state;	
              end
            end
            8'd6: begin          
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE3;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd7: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd8: begin             
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE4;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd9: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd10: begin             
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE5;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd11: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd12: begin             
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE6;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd13: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd14: begin             
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE7;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd15: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd16: begin            
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE8;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd17: begin
		          if(wr_finish) begin
		          start <= 1'b0; 
              config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd18: begin             
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE9;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd19: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd20: begin             
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE10;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd21: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd22: begin             
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE11;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd23: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd24: begin             
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE12;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd25: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd26: begin            
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE13;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd27: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd28: begin            
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE14;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd29: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd30: begin             
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE15;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd31: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
		        8'd32: begin            
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE16;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd33: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd34: begin           
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE17;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd35: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
		        8'd36: begin            
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE18;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd37: begin
		          if(wr_finish) begin
		          start <= 1'b0; 
              config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd38: begin           
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE19;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd39: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd40: begin           
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE20;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd41: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            8'd42: begin           
		          start <= 1'b1;
	            nRd <= 1'b1;
		          value <= VALUE21;
              config_state <= config_state + 1'b1;		  
		        end
		        8'd43: begin
		          if(wr_finish) begin
		            start <= 1'b0; 
                config_state <= config_state + 1'b1;	
		          end else begin
		            start <= start; 
                config_state <= config_state;	
		          end
            end
            default: begin
		          ad9652_init_done <= 1'b1;
		          config_state <= config_state;
            end	
    endcase
    end
end

AD9652_SPI AD9652_SPI(
    .sysclk(sysclk)    ,
    .rst_n(rst_n)  ,
    .value(value),
    .ad9652_sck (ad9652_sck)  ,
    .ad9652_cs  (ad9652_cs)  ,
    .ad9652_miso(ad9652_miso),
    .ad9652_mosi(ad9652_mosi),
    .wr_finish(wr_finish),
    .start(start),
    .nRd(nRd),
    .rdByte(rdByte),
    .ad9652_dataDir(ad9652_dataDir),
    .ad9652_init_done(ad9652_init_done)
);
endmodule
