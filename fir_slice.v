`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/23 16:29:57
// Design Name: 
// Module Name: fir_slice
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


module fir_slice(
    input clk,
    input rst_n,
    input valid_in,
    input[79:0] din,
    input[5:0] slice,
    output wire[31:0] dout,
    output wire[39:0] din_i,
    output wire[39:0] din_q,

    output wire[15:0] dout_i,
    output wire[15:0] dout_q,
    output reg valid_out
);

reg [39:0]din_i_r0,din_i_r1,din_i_r2;
reg [39:0]din_q_r0,din_q_r1,din_q_r2;
reg [15:0]dout_i_r0,dout_i_r1,dout_i_r2;
reg [15:0]dout_q_r0,dout_q_r1,dout_q_r2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        din_i_r0 <= 40'd0;
        din_i_r1 <= 40'd0;
        din_i_r2 <= 40'd0; 
    end
    else if (!valid_in)begin
        din_i_r0 <= 40'd0;
        din_i_r1 <= 40'd0;
        din_i_r2 <= 40'd0; 
    end
    else begin
        din_i_r0 <= din[79:40];
        din_i_r1 <= din_i_r0;
        din_i_r2 <= din_i_r1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        din_q_r0 <= 40'd0;
        din_q_r1 <= 40'd0;
        din_q_r2 <= 40'd0; 
    end
    else if (!valid_in)begin
        din_q_r0 <= 40'd0;
        din_q_r1 <= 40'd0;
        din_q_r2 <= 40'd0; 
    end
    else begin
        din_q_r0 <= din[39:0];
        din_q_r1 <= din_q_r0;
        din_q_r2 <= din_q_r1;
    end
end

assign din_i = din_i_r2;
assign din_q = din_q_r2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        dout_i_r0 <= 16'd0;
        dout_i_r1 <= 16'd0;
        dout_i_r2 <= 16'd0;
    end
    else if (!valid_in)begin
        dout_i_r0 <= 16'd0;
        dout_i_r1 <= 16'd0;
        dout_i_r2 <= 16'd0;
    end
    else begin
        dout_i_r0 <= din_i[slice+:16];
        dout_i_r1 <= dout_i_r0;
        dout_i_r2 <= dout_i_r1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        dout_q_r0 <= 16'd0;
        dout_q_r1 <= 16'd0;
        dout_q_r2 <= 16'd0;
        valid_out <= 1'b0;
    end
    else if (!valid_in)begin
        dout_q_r0 <= 16'd0;
        dout_q_r1 <= 16'd0;
        dout_q_r2 <= 16'd0;
        valid_out <= 1'b0;
    end
    else begin
        dout_q_r0 <= din_q[slice+:16];
        dout_q_r1 <= dout_q_r0;
        dout_q_r2 <= dout_q_r1;
        valid_out <= 1'b1;
    end
end

assign dout_i = dout_i_r2;
assign dout_q = dout_q_r2;
// assign dout_i = {din_i[39],din_i[29:15]};
// assign dout_q = {din_q[39],din_q[29:15]};

assign dout = {dout_i, dout_q};

endmodule
