`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/21 11:35:58
// Design Name: 
// Module Name: adc_top
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

module adc_top(
    input clk_6_2M,
    input clk_62M,
    input sysclk,
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
    input ad9957_valid,
    input wire[17:0] ad9957_Data_I,
    input wire[17:0] ad9957_Data_Q,
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
    output wire ad9957_txenable,
    output ad9957_io_update,
    output[2:0] ad9957_profile,

    output wire[17:0] ad9957_data,
    /////////////////////////////////////
    output ad9652_done,
    output ad9957_done,
    output ad9652_DCLK,
    output[15:0] adc_DataN,
    output[15:0] adc_DataP
);
wire[35:0] din;
wire[35:0] din_r;
wire tx_start;
wire ad9516_init_done;
wire ad9652_init_done;
wire ad9957_init_done;

reg timerDly1 = 1'b0;
reg ad9652_rst;
reg ad9957_rst;

assign ad9652_done = ad9652_init_done;
assign ad9957_done = ad9957_init_done;

wire trigger;
wire trigger_r;
ila_0 ila_0 (
	.clk(clk_248M), // input wire clk

	.probe0(ad9516_cs), // input wire [0:0]  probe0  
	.probe1(ad9516_sck), // input wire [0:0]  probe1 
	.probe2(ad9516_sdio), // input wire [0:0]  probe2 
	.probe3(ad9516_sdo), // input wire [0:0]  probe3 
	.probe4(ad9516_init_done), // input wire [0:0]  probe4 
	.probe5(ad9652_DCLK), // input wire [0:0]  probe5 
	.probe6(ad9652_sck), // input wire [0:0]  probe6 
	.probe7(adc_DataN), // input wire [15:0]  probe7 
	.probe8(adc_DataP), // input wire [15:0]  probe8 
	.probe9(tx_start), // input wire [0:0]  probe9 
	.probe10(ad9652_init_done), // input wire [0:0]  probe10 
	.probe11(ad9957_cs), // input wire [0:0]  probe11 
	.probe12(ad9957_sck), // input wire [0:0]  probe12 
	.probe13(ad9957_rst), // input wire [0:0]  probe13 
	.probe14(ad9652_sdio), // input wire [0:0]  probe14 
	.probe15(ad9957_pclk), // input wire [0:0]  probe15 
	.probe16(ad9957_init_done), // input wire [0:0]  probe16 
	.probe17(ad9957_data), // input wire [17:0]  probe17 
	.probe18(ad9957_Data_I), // input wire [17:0]  probe18 
	.probe19(ad9957_Data_Q), // input wire [17:0]  probe19
    .probe20(ad9957_txenable),
    .probe21(ad9957_valid)
);

AD9516 AD9516(
    .sysclk(clk_6_2M),
    .rst_n(1'b1),
    .ad9516_cs(ad9516_cs),
    .ad9516_sdio(ad9516_sdio),
    .ad9516_sdo(ad9516_sdo),
    .ad9516_sck(ad9516_sck),
    .ad9516_init_done(ad9516_init_done),
    .ad9516_nSync(ad9516_nSync),
    .ad9516_nPD(ad9516_nPD),
    .ad9516_nRESET(ad9516_nRESET)
);

always @(posedge clk_62M) begin
    if (!ad9516_init_done)begin
        ad9652_rst <= 1'b0;
    end
    else begin
        ad9652_rst <= 1'b1;
    end
end

wire ad9652_DCLK_r;

AD9652 AD9652(
    .adref_clk(sysclk),
    .sysclk(clk_6_2M),
    .rst_n(ad9652_rst),
    .ad9652_cs(ad9652_cs),
    .ad9652_sdio(ad9652_sdio),
    .ad9652_sck(ad9652_sck),
    .ad9652_DCON(ad9652_DCON),
    .ad9652_DCOP(ad9652_DCOP),
    .ad9652_ORN(ad9652_ORN),
    .ad9652_ORP(ad9652_ORP),
    .ad9652_DataN(ad9652_DataN),
    .ad9652_DataP(ad9652_DataP),
    .ad9652_init_done(ad9652_init_done),
    .ad9652_DCLK(ad9652_DCLK_r),
    .adc_DataN(adc_DataN), //B,用的是B通道
    .adc_DataP(adc_DataP), //A
    .ad9652_PDWN(ad9652_PDWN)
);

 BUFG BUFG_inst (
      .O(ad9652_DCLK), // 1-bit output: Clock output
      .I(ad9652_DCLK_r)  // 1-bit input: Clock input
   );

always @(posedge clk_62M) begin
    if (!ad9957_valid && (timerDly1 == 1'b0))begin
        timerDly1 <= timerDly1;
        ad9957_rst <= 1'b0;
    end
    else if (ad9957_valid && (timerDly1 == 1'b0))begin
        ad9957_rst <= 1'b1;
        timerDly1 <= timerDly1 + 1'b1;
    end
    else if (!ad9957_valid)begin
        ad9957_rst <= ad9957_rst;
        timerDly1 <= timerDly1;
    end
    else begin
        ad9957_rst <= ad9957_rst;
        timerDly1 <= timerDly1;
    end
end

AD9957 AD9957(
    .clk_124M(clk_124M),
    .clk_62M(clk_62M),
    .sysclk(clk_6_2M),
    .rst_n(ad9957_rst),

    .ad9957_sdio(ad9957_sdio),
    .ad9957_sdo(ad9957_sdo),
    .ad9957_sck(ad9957_sck),
    .ad9957_cs(ad9957_cs),

    .Q_data(ad9957_Data_Q),
    .I_data(ad9957_Data_I),
    .ad9957_valid(ad9957_valid),
    .ad9957_pclk(ad9957_pclk),
    .ad9957_osk(ad9957_osk),
    .ad9957_io_rst(ad9957_io_rst),
    .ad9957_rt(ad9957_rt),
    .ad9957_oe(ad9957_oe),
    .ad9957_m_rst(ad9957_m_rst),
    .ad9957_txenable(ad9957_txenable),
    .ad9957_io_update(ad9957_io_update),
    .ad9957_profile(ad9957_profile),
    .data(ad9957_data),
    .trigger(trigger),
    .din(din),
    .din_r(din_r),
    .trigger_r(trigger_r),
    .tx_start(tx_start),

    .ad9957_init_done(ad9957_init_done)
);
endmodule
