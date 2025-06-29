`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/05 21:08:09
// Design Name: 
// Module Name: dds_32to18
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


module dds_32to18(
    input clk,
    input rst_n,

    input signed[31:0] data_in,
    input in_valid,
    output reg ad9957_valid,
    output reg signed[15:0] data_I,
    output reg signed[15:0] data_Q,
    output wire signed [17:0] ad9957_Data_I,
    output wire signed [17:0] ad9957_Data_Q
);

always@(posedge clk or negedge rst_n)begin
    if (!rst_n)begin
        ad9957_valid <= 1'b0;
    end
    else if (in_valid)begin
        ad9957_valid <= 1'b1;
    end
    else begin
        ad9957_valid <= 1'b0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        data_I <= 16'h0;
        data_Q <= 16'h0;
    end
    else if (in_valid)begin
        data_I <= data_in[31:16];
        data_Q <= data_in[15:0];
    end
    else begin
        data_I <= 16'h0;
        data_Q <= 16'h0;
    end
end

assign ad9957_Data_I = {{2{data_I[15]}},data_I};
assign ad9957_Data_Q = {{2{data_Q[15]}},data_Q};

endmodule
