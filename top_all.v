`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/21 11:24:02
// Design Name: 
// Module Name: top_all
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


module top_all(
    input gt_adcclk_n,
    input gt_adcclk_p,
    input sysclk_n,
    input sysclk_p,
    /**********AD9516 Interface************/
    input ad9516_sdo,
    output ad9516_sdio,
    output ad9516_sck,
    output ad9516_cs,

    output ad9516_nPD,
    output ad9516_nRESET,
    output ad9516_nSync,
    /**********AD9652 Interface************/
    inout ad9652_sdio,
    output ad9652_sck,
    output ad9652_cs,

    input ad9652_ORN,
    input ad9652_ORP,
    input ad9652_DCON,
    input ad9652_DCOP,
    output ad9652_PDWN,

    input[15:0] ad9652_DataN,
    input[15:0] ad9652_DataP,
    /**********AD9957 Interface************/
    input ad9957_pclk,

    inout ad9957_sdio,
    input ad9957_sdo,
    output ad9957_sck,
    output ad9957_cs,

    output ad9957_osk,
    output ad9957_io_rst,
    output ad9957_rt,
    output[2:0] ad9957_oe,
    output ad9957_m_rst,
    output ad9957_txenable,
    output ad9957_io_update,
    output[2:0] ad9957_profile,

    output wire[17:0] ad9957_data,
    /**********gt Interface************/
    input        gt_adcrx_n ,
	input        gt_adcrx_p ,
	output       gt_adctx_n ,
	output       gt_adctx_p ,

    output [16:13]    fs_tp 
);

wire[17:0] data_I;
wire[17:0] data_Q;
wire sysclk;
wire clk_6_2M;
wire clk_62M;
wire[15:0] adc_fifo_0_tdata;
wire adc_fifo_0_tvalid;
wire adc_fifo_0_tready;
wire[15:0] adc_fifo_1_tdata;
wire adc_fifo_1_tvalid;
wire adc_fifo_1_tready;

wire resetn;
wire locked;
wire[15:0] adn_fifo_tdata;
wire[15:0] adp_fifo_tdata;

wire ad9957_valid;
wire rx_tvalid;

parameter integer COUNTER_MAX = 62000000;
reg resetn_clk;
reg [25:0] counter;

IBUFGDS 
 #(.DIFF_TERM("FALSE"))
 C0(
  .I      (sysclk_p),
  .IB     (sysclk_n),
  .O      (sysclk)
);
clk_wiz_0 clk_wiz_0
  (
   .clk_out1(clk_6_2M),
   .clk_out2(clk_62M),
   .reset(1'b0), // input resetn
   .locked(locked),       // output locked
   .clk_in1(sysclk)      // input clk_in1
);

always@(posedge clk_62M)begin
    if (~ad9652_done)begin
        counter <= 'd0;
        resetn_clk <= 1'b0;
    end
    else if (counter < COUNTER_MAX)begin
        counter <= counter + 1'b1;
        resetn_clk <= 1'b0;
    end
    else begin
        resetn_clk <= 1'b1;
    end
end

adc_top adc_top(
    .clk_6_2M(clk_6_2M),
    .clk_62M(clk_62M),
    .sysclk(sysclk),
    /**********AD9516 Interface************/
    .ad9516_sdo(ad9516_sdo),
    .ad9516_sdio(ad9516_sdio),
    .ad9516_sck(ad9516_sck),
    .ad9516_cs(ad9516_cs),

    .ad9516_nPD(ad9516_nPD),
    .ad9516_nRESET(ad9516_nRESET),
    .ad9516_nSync(ad9516_nSync),
    /**********AD9652 Interface************/
    .ad9652_sdio(ad9652_sdio),
    .ad9652_sck(ad9652_sck),
    .ad9652_cs(ad9652_cs),

    .ad9652_ORN(ad9652_ORN),
    .ad9652_ORP(ad9652_ORP),
    .ad9652_DCON(ad9652_DCON),
    .ad9652_DCOP(ad9652_DCOP),
    .ad9652_PDWN(ad9652_PDWN),

    .ad9652_DataN(ad9652_DataN),
    .ad9652_DataP(ad9652_DataP),
    /**********AD9957 Interface************/
    .ad9957_valid(ad9957_valid),
    .ad9957_Data_I(data_I),
    .ad9957_Data_Q(data_Q),
    .ad9957_pclk(ad9957_pclk),

    .ad9957_sdio(ad9957_sdio),
    .ad9957_sdo(ad9957_sdo),
    .ad9957_sck(ad9957_sck),
    .ad9957_cs(ad9957_cs),

    .ad9957_osk(ad9957_osk),
    .ad9957_io_rst(ad9957_io_rst),
    .ad9957_rt(ad9957_rt),
    .ad9957_oe(ad9957_oe),
    .ad9957_m_rst(ad9957_m_rst),
    .ad9957_txenable(ad9957_txenable),
    .ad9957_io_update(ad9957_io_update),
    .ad9957_profile(ad9957_profile),

    .ad9957_data(ad9957_data),
    .ad9652_done(ad9652_done),
    .ad9957_done(ad9957_done),
    .ad9652_DCLK(ad9652_DCLK),
    .adc_DataN(adn_fifo_tdata),
    .adc_DataP(adp_fifo_tdata)
);

assign adc_fifo_0_tvalid = resetn_clk;
assign adc_fifo_0_tdata = adp_fifo_tdata;

assign adc_fifo_1_tvalid = resetn_clk;
assign adc_fifo_1_tdata = adn_fifo_tdata;

design_1_wrapper design_1_wrapper(
    .clk_62M(clk_62M),
    .ad9957_Data_I(data_I),
    .ad9957_Data_Q(data_Q),
    .ad9957_valid(ad9957_valid),
    .ad_clk_0(~ad9652_DCLK),
    .ad_fifo_0_tdata(adc_fifo_0_tdata),
    .ad_fifo_0_tready(adc_fifo_0_tready),
    .ad_fifo_0_tvalid(adc_fifo_0_tvalid),
    .ad_fifo_1_tdata(adc_fifo_1_tdata),
    .ad_fifo_1_tready(adc_fifo_1_tready),
    .ad_fifo_1_tvalid(adc_fifo_1_tvalid),
    .channel_up(fs_tp[13]),
    .gt_ref_clk_n(gt_adcclk_n),
    .gt_ref_clk_p(gt_adcclk_p),
    .gt_rx0_rxn(gt_adcrx_n),
    .gt_rx0_rxp(gt_adcrx_p),
    .gt_tx0_txn(gt_adctx_n),
    .gt_tx0_txp(gt_adctx_p),
    .hard_err(fs_tp[14]),
    // .init_clk(sysclk),
    .lane_up(fs_tp[15]),
    .resetn(resetn),
    .resetn_clk(resetn_clk),
    .soft_err(fs_tp[16]),
    .rx_tvalid(rx_tvalid)
);

endmodule
