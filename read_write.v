module read_write(
	
input clk,
input rstn,
input signed [15:0] data_in,
input               m_axis_data_tvalid,
output reg                data_valid_o,
output wire signed [15:0] jidai_data_I,
output wire signed [15:0] jidai_data_Q 
);
///////////////////////////////

// fir_bandpass fir_bandpass (
//   .aresetn(~rst),                        // input wire aresetn
//   .aclk(clk),                              // input wire aclk
//   .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
//   .s_axis_data_tready(),  // output wire s_axis_data_tready
//   .s_axis_data_tdata(data_in),    // input wire [15 : 0] s_axis_data_tdata
//   .m_axis_data_tvalid(m_axis_data_tvalid),  // output wire m_axis_data_tvalid
//   .m_axis_data_tdata(data_out)    // output wire [15 : 0] m_axis_data_tdata
// );

//////////////////////////////////mix_sig

reg [1:0]  count_MIX ;
reg signed [15:0] ad_data_I ;
reg signed [15:0] ad_data_Q ;

always @(posedge clk) begin
    if (!rstn) begin
    	  data_valid_o = 1'b0;
    end
    else if(m_axis_data_tvalid) begin  
    	  data_valid_o = 1'b1;
    end
    else begin
        data_valid_o = 1'b0;
    end
end
         

always @(posedge clk) begin
if (!rstn) begin
	  ad_data_I = 16'h0;
      ad_data_Q = 16'h0;
end
   else if(m_axis_data_tvalid) begin        
        case(count_MIX)
            2'd0:begin
		        ad_data_I <=16'h0;		        
		        ad_data_Q <=data_in;   
            end
            2'd1:begin
            	ad_data_I <=~data_in + 1'h1;
	        	ad_data_Q <=16'h0;
            end
            2'd2:begin
            	ad_data_I <=16'h0;
            	ad_data_Q <=~data_in + 1'h1;
            end
            2'd3:begin
            	ad_data_I <=data_in;
            	ad_data_Q <=16'h0;
            end
        endcase	
        count_MIX <= count_MIX + 1'b1;
    end
    else begin
		ad_data_I <=16'h0;	
 		ad_data_Q <=16'h0;
 		end
end

assign jidai_data_I = ad_data_I;
assign jidai_data_Q = ad_data_Q;

//////////////////////////////////JIDAI_LVBUO
//fir_lowpass fir_lowpass (
//  .aresetn(~rst),                        // input wire aresetn
//  .aclk(clk),                              // input wire aclk
//  .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
//  .s_axis_data_tready(),  // output wire s_axis_data_tready
//  .s_axis_data_tdata({ad_data_Q,ad_data_I}),    // input wire [31 : 0] s_axis_data_tdata
//  .m_axis_data_tvalid(),  // output wire m_axis_data_tvalid
//  .m_axis_data_tdata({jidai_data_Q,jidai_data_I})    // output wire [31 : 0] m_axis_data_tdata
//);
///////////////////////////////////////////////

// localparam cnt = 'd23170; //0.707

// wire [31:0]dout;

// mult_gen_1 u0 (
//   .CLK(clk),  // input wire CLK
//   .A(data_in),      // input wire [15 : 0] A
//   .B(cnt),      // input wire [15 : 0] B
//   .CE(m_axis_data_tvalid),    // input wire CE
//   .P(dout)      // output wire [31 : 0] P
// );

// always @(posedge clk) begin
// if (!rstn) begin
// 	  ad_data_I = 16'h0;
//       ad_data_Q = 16'h0;
// end
//    else if(m_axis_data_tvalid) begin        
//         case(count_MIX)
//             2'd0:begin
// 		        ad_data_I <= ~dout[30:15] + 1'h1;		        
// 		        ad_data_Q <= dout[30:15];   
//             end
//             2'd1:begin
//             	ad_data_I <= ~dout[30:15] + 1'h1;
// 	        	ad_data_Q <= ~dout[30:15] + 1'h1;
//             end
//             2'd2:begin
//             	ad_data_I <= dout[30:15];
//             	ad_data_Q <= ~dout[30:15] + 1'h1;
//             end
//             2'd3:begin
//             	ad_data_I <= dout[30:15];
//             	ad_data_Q <= dout[30:15];
//             end
//         endcase	
//         count_MIX <= count_MIX + 1'b1;
//     end
//     else begin
// 		ad_data_I <=16'h0;	
//  		ad_data_Q <=16'h0;
//  		end
// end

endmodule 
