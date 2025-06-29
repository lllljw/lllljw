`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/29 10:18:04
// Design Name: 
// Module Name: gain_adjust_1
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
module gain_ajust_1(
    input clk,
	input rst_n,
	input din_Valid,
    input [5:0] zengyi,
	
	input signed [17:0] din_I,
    input signed [17:0] din_Q,
    output signed[17:0] dout_I,
    output signed[17:0] dout_Q,
	output reg dout_Valid
  );
    reg signed[17:0]   dout_I_r;
    reg signed[17:0]   dout_Q_r;
    assign dout_I = dout_I_r;
    assign dout_Q = dout_Q_r;
    ////////////////////////////////////////////////////
    always @(posedge clk or negedge rst_n)
    begin
      if(~rst_n) begin
	    	dout_I_r  <= 18'sd0;
        	dout_Q_r  <= 18'sd0;
		    dout_Valid <= 1'b0;
	    end else begin
	      if(din_Valid) begin
		        dout_I_r <= (din_I <<< zengyi); //+ (dout_i0 <<< 1); // dout_i0 * 8 + dout_i0 * 2
            	dout_Q_r <= (din_Q <<< zengyi);
		        dout_Valid <= 1'b1;
		    end else begin
		        dout_I_r <= 18'sd0;
            	dout_Q_r <= 18'sd0;
		        dout_Valid <= 1'b0;
		    end
	  end 	
 	end	
endmodule
