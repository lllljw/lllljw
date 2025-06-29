`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/29 16:23:42
// Design Name: 
// Module Name: amp_top
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
module amp_top(
input              i_amp_clk    ,
input              i_amp_rst_n  ,
input    [15:0]    i_amp_dataI  ,
input    [15:0]    i_amp_dataQ  ,
output   [15:0]    o_amp_dataI  ,
output   [15:0]    o_amp_dataQ  ,
output   [15:0]    o_amp_data   
    );
 
 wire    [31:0]    w_amp_mult_I             ;
 wire    [31:0]    w_amp_mult_Q             ;
 wire    [31:0]    w_amp_mult_add           ;
 wire    [15:0]    w_amp_sq_data            ;
 wire              w_amp_sq_valid           ;
 wire    [15:0]    w_amp_sq_dataI           ;
 wire    [15:0]    w_amp_sq_dataQ           ;
 
 reg     [15:0]    r_amp_sq_data[0:255]      ;
 
 mult_gen_0 mult_I (
  .CLK(i_amp_clk),  // input wire CLK
  .A(i_amp_dataI),      // input wire [15 : 0] A
  .B(i_amp_dataI),      // input wire [15 : 0] B
  .CE(i_amp_rst_n),    // input wire CE
  .P(w_amp_mult_I)      // output wire [31 : 0] P
);

 mult_gen_0 mult_Q (
  .CLK(i_amp_clk),  // input wire CLK
  .A(i_amp_dataQ),      // input wire [15 : 0] A
  .B(i_amp_dataQ),      // input wire [15 : 0] B
  .CE(i_amp_rst_n),    // input wire CE
  .P(w_amp_mult_Q)      // output wire [31 : 0] P
);
 
c_addsub_2 c_addsub_2 (
  .A(w_amp_mult_I),      // input wire [31 : 0] A
  .B(w_amp_mult_Q),      // input wire [31 : 0] B
  .CLK(i_amp_clk),  // input wire CLK
  .CE(i_amp_rst_n),    // input wire CE
  .S(w_amp_mult_add)      // output wire [31 : 0] S
);

cordic_square cordic_square (
  .aclk(i_amp_clk),                                        // input wire aclk
  .aresetn(i_amp_rst_n),                                  // input wire aresetn
  .s_axis_cartesian_tvalid(1'd1),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(w_amp_mult_add),    // input wire [31 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(w_amp_sq_valid),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(w_amp_sq_data)              // output wire [15 : 0] m_axis_dout_tdata
);

cordic_square cordic_squareI(
  .aclk(i_amp_clk),                                        // input wire aclk
  .aresetn(i_amp_rst_n),                                  // input wire aresetn
  .s_axis_cartesian_tvalid(1'd1),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(w_amp_mult_I),    // input wire [31 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(w_amp_sq_dataI)              // output wire [15 : 0] m_axis_dout_tdata
);

cordic_square cordic_squareQ (
  .aclk(i_amp_clk),                                        // input wire aclk
  .aresetn(i_amp_rst_n),                                  // input wire aresetn
  .s_axis_cartesian_tvalid(1'd1),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(w_amp_mult_Q),    // input wire [31 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(w_amp_sq_dataQ)              // output wire [15 : 0] m_axis_dout_tdata
);

integer i, j; 

always@(posedge i_amp_clk)begin
    if(!i_amp_rst_n)
        for(i=0; i<=255; i=i+1)
            r_amp_sq_data[i] <= 'd0;
        else begin
            r_amp_sq_data[0] <= w_amp_sq_data;
            for (j=0; j<=255; j=j+1)
                r_amp_sq_data[j+1] <= r_amp_sq_data[j];
            end
end

reg signed [23:0] sum;

always @ (posedge i_amp_clk)begin
    if (!i_amp_rst_n) 
        sum <= 'd0;
    else 
        sum <= sum + {{8{w_amp_sq_data[15]}},w_amp_sq_data} - {{8{r_amp_sq_data[255][15]}},r_amp_sq_data[255]};   
end

assign o_amp_data = sum[23:8];  //����8bit��ЧΪ��256    


reg    [31:0]    r_amp_sq_dataI[0:63];
reg    [31:0]    r_amp_sq_dataQ[0:63];

integer a, b; 

always@(posedge i_amp_clk)begin
    if(!i_amp_rst_n)
        for(a=0; a<=63; a=a+1)begin
            r_amp_sq_dataI[a] <= 32'd0;
            r_amp_sq_dataQ[a] <= 32'd0;
        end
        else begin
            r_amp_sq_dataI[0] <= w_amp_sq_dataI;
            r_amp_sq_dataQ[0] <= w_amp_sq_dataQ;
            for (b=0; b<=63; b=b+1)begin
                r_amp_sq_dataI[b+1] <= r_amp_sq_dataI[b];
                r_amp_sq_dataQ[b+1] <= r_amp_sq_dataQ[b]; 
            end
        end
end

reg signed [21:0] sumI;
reg signed [21:0] sumQ;

always @ (posedge i_amp_clk)begin
    if (!i_amp_rst_n) begin
        sumI <= 32'd0;
        sumQ <= 32'd0;
    end
    else begin
        sumI <= sumI + {{6{w_amp_sq_dataI[15]}},w_amp_sq_dataI} - {{6{r_amp_sq_dataI[63][15]}},r_amp_sq_dataI[63]};   
        sumQ <= sumQ + {{6{w_amp_sq_dataQ[15]}},w_amp_sq_dataQ} - {{6{r_amp_sq_dataQ[63][15]}},r_amp_sq_dataQ[63]};
    end
end

assign o_amp_dataI = sumI[21:6];      
assign o_amp_dataQ = sumQ[21:6];      

endmodule