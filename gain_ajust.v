`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/22 10:51:58
// Design Name: 
// Module Name: gain_ajust
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
module gain_ajust(
    input clk,
	input rst_n,
	input din_Valid,
	
	input signed [15:0] din,
    output signed[15:0] dout,
	output reg dout_Valid
  );
    reg signed[15:0]   dout_r;
    assign dout = dout_r;
    ////////////////////////////////////////////////////
    always @(posedge clk or negedge rst_n)
    begin
      if(~rst_n) begin
	    dout_r  <= 16'sd0;
		dout_Valid <= 1'b0;
	  end else begin
	    if(din_Valid) begin
		  dout_r <= (din <<< 0); //+ (dout_i0 <<< 1); // dout_i0 * 8 + dout_i0 * 2
		  dout_Valid <= 1'b1;
		end else begin
		  dout_r  <= 16'sd0;
		  dout_Valid <= 1'b0;
		end
	  end
    end	
endmodule
