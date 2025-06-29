`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/16 15:05:05
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


module AD9516(
    input  sysclk,
    input  rst_n,
    ////////////////////////////
	input  ad9516_sdo,
	output  ad9516_sck,
	output ad9516_cs,	
	output ad9516_sdio,	
	/////////////////////////
	output ad9516_nPD,
	output ad9516_nRESET,
	output ad9516_nSync,
	
	output reg ad9516_init_done
);
wire wr_finish;
wire[5:0] Data_State;
wire[15:0] rdFrame;

reg start;
reg nRd;
reg[23:0] value;
reg[7:0] address;
reg[7:0] config_state;
reg[7:0] wrByte;
wire[7:0] rdByte;

assign ad9516_nPD = 1'b1;
assign ad9516_nRESET = 1'b1;
assign ad9516_nSync = 1'b1;  

localparam  
            VALUE72    =    24'h0_000_3C,
            //串行接口配置
            VALUE0	   =	24'h0_000_18,
            VALUE1     =    24'h0_001_00,
            VALUE2     =    24'h0_002_10,
            VALUE3     =    24'h0_003_C3,
            VALUE4     =    24'h0_004_00,
            //PLL
            VALUE5     =    24'h0_010_7C,//4.8mA 
            VALUE6     =    24'h0_011_05,//
            VALUE7     =    24'h0_012_00,
            VALUE8     =    24'h0_013_08,
            VALUE9     =    24'h0_014_17,
            VALUE10    =    24'h0_015_00,
            VALUE11    =    24'h0_016_06,
            VALUE12    =    24'h0_017_9C,
            VALUE13    =    24'h0_018_06,
            VALUE14    =    24'h0_019_00,
            VALUE15    =    24'h0_01A_00,
            VALUE16    =    24'h0_01B_27,
            VALUE17    =    24'h0_01C_82,
            VALUE18    =    24'h0_01D_00,
            VALUE19    =    24'h0_01E_00,
            VALUE20    =    24'h0_01F_0E,
            //OUT6 ~ OUT9的微调时延配置
            VALUE21    =    24'h0_0A0_01,//OUTPUT6 delay pass 置高
            VALUE22    =    24'h0_0A1_00,
            VALUE23    =    24'h0_0A2_00,
            VALUE24    =    24'h0_0A3_01,//OUTPUT7 delay pass 置高
            VALUE25    =    24'h0_0A4_00,
            VALUE26    =    24'h0_0A5_00,
            VALUE27    =    24'h0_0A6_01,//OUTPUT8 delay pass 置高
            VALUE28    =    24'h0_0A7_00,
            VALUE29    =    24'h0_0A8_00,
            VALUE30    =    24'h0_0A9_01,//OUTPUT9 delay pass 置高
            VALUE31    =    24'h0_0AA_00,
            VALUE32    =    24'h0_0AB_00,
            //LVPECL Outputs
            VALUE33    =    24'h0_0F0_08,//OUT0,1000b
            VALUE34    =    24'h0_0F1_08,//OUT1,1010b,将差分置高
            VALUE35    =    24'h0_0F2_0A,//OUT2
            VALUE36    =    24'h0_0F3_0A,//OUT3,1010b,将差分置高
            VALUE37    =    24'h0_0F4_0A,//OUT4
            VALUE38    =    24'h0_0F5_0A,//OUT5,1010b,将差分置高
            //LVDS/CMOS Outputs
            VALUE39    =    24'h0_140_43,//OUT6,0100_0011b,
            //[7:5]output polarity输出极性P71。
            //[4:4]0:关闭CMOS B的输出，1:打开。
            //[3:3]0:LVDS,1:CMOS。
            //[2:1]LVDS输出电流。
            //[0:0]LVDS/CMOS的输出，0:power on,1:power off
            VALUE40    =    24'h0_141_43,//OUT6
            VALUE41    =    24'h0_142_43,//OUT7
            VALUE42    =    24'h0_143_43,//OUT8
            //LVPECL Chnannel Dividers
            VALUE43    =    24'h0_190_00,
            VALUE44    =    24'h0_191_80,
            VALUE45    =    24'h0_192_00,
            VALUE46    =    24'h0_193_BB,
            VALUE47    =    24'h0_194_80,
            VALUE48    =    24'h0_195_00,
            VALUE49    =    24'h0_196_00,
            VALUE50    =    24'h0_197_80,
            VALUE51    =    24'h0_198_00,
            //LVDS/CMOS Channel Divider
            VALUE52    =    24'h0_199_22,
            VALUE53    =    24'h0_19A_00,
            VALUE54    =    24'h0_19B_11,
            VALUE55    =    24'h0_19C_30,
            VALUE56    =    24'h0_19D_00,
            VALUE57    =    24'h0_19E_22,
            VALUE58    =    24'h0_19F_00,
            VALUE59    =    24'h0_1A0_11,
            VALUE60    =    24'h0_1A1_30,
            VALUE61    =    24'h0_1A2_00,
            VALUE62    =    24'h0_1A3_00,
            //VCO divider 
            VALUE63    =    24'h0_1E0_01,
            VALUE64    =    24'h0_1E1_02,//00b:CLK为来源，VCO divider被选择。10b:VCO为来源，VCO divider被选择.
            VALUE65    =    24'h0_230_00,
            VALUE66    =    24'h0_231_00,
            VALUE67    =    24'h0_232_00,
            //更新寄存器。
            VALUE68    =    24'h0_018_06,
            VALUE69    =    24'h0_232_01,  
            VALUE70    =    24'h0_018_07,
            VALUE71    =    24'h0_232_01;
always@(posedge sysclk or negedge rst_n)begin
    if (!rst_n)begin
        start <= 1'b0;
        nRd <= 1'b0;
        ad9516_init_done <= 1'b0;
        config_state <= 8'd0;
    end
    else begin
        case(config_state)
            'd0:begin             
                start <= 1'b1;
	            nRd <= 1'b1;
		        ad9516_init_done <= 1'b0;
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
		        value <= VALUE4;
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
		        value <= VALUE5;
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
		        value <= VALUE6;
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
		        value <= VALUE7;
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
		        value <= VALUE8;
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
		        value <= VALUE9;
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
		        value <= VALUE10;
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
		        value <= VALUE11;
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
		        value <= VALUE12;
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
		        value <= VALUE13;
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
		        value <= VALUE14;
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
		        value <= VALUE15;
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
		        value <= VALUE16;
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
		        value <= VALUE17;
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
		        value <= VALUE18;
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
		        value <= VALUE19;
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
		        value <= VALUE20;
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
		        value <= VALUE21;
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
		        value <= VALUE22;
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
            8'd44: begin           
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE23;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd45: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd46: begin           
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE24;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd47: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd48: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE25;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd49: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd50: begin           
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE26;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd51: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd52: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE27;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd53: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd54: begin             
		        start <= 1'b1;
	            nRd <= 1'b1;		  
		        value <= VALUE28;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd55: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd56: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE29;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd57: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd58: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE30;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd59: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd60: begin             
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE31;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd61: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd62: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE32;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd63: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd64: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE33;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd65: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd66: begin         
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE34;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd67: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd68: begin             
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE35;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd69: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd70: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE36;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd71: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd72: begin        
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE37;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd73: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd74: begin           
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE38;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd75: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd76: begin           
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE39;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd77: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd78: begin          
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE40;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd79: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd80: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE41;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd81: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd82: begin          
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE42;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd83: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd84: begin       
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE43;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd85: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd86: begin          
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE44;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd87: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd88: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE45;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd89: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd90: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE46;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd91: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd92: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE47;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd93: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd94: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE48;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd95: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd96: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE49;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd97: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd98: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE50;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd99: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd100: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE51;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd101: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd102: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE52;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd103: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd104: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE53;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd105: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd106: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE54;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd107: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd108: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE55;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd109: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd110: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE56;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd111: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd112: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE57;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd113: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd114: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE58;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd115: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd116: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE59;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd117: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd118: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE60;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd119: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd120: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE61;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd121: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd122: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE62;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd123: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd124: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE63;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd125: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd126: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE64;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd127: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd128: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE65;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd129: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd130: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE66;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd131: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd132: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE67;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd133: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd134: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE68;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd135: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd136: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE69;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd137: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd138: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE70;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd139: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            8'd140: begin            
		        start <= 1'b1;
	            nRd <= 1'b1;
		        value <= VALUE71;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd141: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
			/*************** Read Rigsters ******************/
            8'd142: begin            
		        start <= 1'b1;
	            nRd <= 1'b0;
		        value <= VALUE3;
                config_state <= config_state + 1'b1;		  
		    end
		    8'd143: begin
		        if(wr_finish) begin
		          start <= 1'b0; 
                  config_state <= config_state + 1'b1;	
		        end else begin
		          start <= start; 
                  config_state <= config_state;	
		        end
            end
            default: begin
		        ad9516_init_done <= 1'b1;
		        config_state <= config_state;
            end	
    endcase
    end
end

AD9516_SPI AD9516_SPI(
    .sysclk(sysclk)    ,
    .rst_n(rst_n)  ,
    .value(value),
    .ad9516_sck (ad9516_sck)  ,
    .ad9516_cs  (ad9516_cs)  ,
    .ad9516_miso(ad9516_sdo),
    .ad9516_mosi(ad9516_sdio),
    .wr_finish(wr_finish),
    .start(start),
    .nRd(nRd),
    .rdByte(rdByte),
    .dataDir(dataDir),
    .Data_State(Data_State),
    .rdFrame(rdFrame)
);

endmodule
