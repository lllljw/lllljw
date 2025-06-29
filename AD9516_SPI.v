`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/21 12:45:18
// Design Name: 
// Module Name: AD9516_SPI
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
module AD9516_SPI(sysclk,rst_n,value,ad9516_sck,ad9516_cs,ad9516_mosi,wr_finish,ad9516_miso,start,nRd,rdByte,dataDir,Data_State,rdFrame);
    input sysclk;
    input rst_n;
    input [23:0] value;
    input ad9516_miso;
    input start;
    input nRd;
    output reg ad9516_sck;
    output reg ad9516_cs;
    output reg ad9516_mosi;
    output reg wr_finish;
    output reg[7:0] rdByte;
    output reg dataDir;
    output reg[5:0] Data_State;
    output reg[15:0] rdFrame;
/*构造状态机*/
// reg[5:0] Data_State = 6'd0;


parameter D23_State = 6'd2;//发送最高位数据-状态
parameter D22_State = 6'd4;
parameter D21_State = 6'd6;
parameter D20_State = 6'd8;
parameter D19_State = 6'd10;
parameter D18_State = 6'd12;
parameter D17_State = 6'd14;
parameter D16_State = 6'd16;
parameter D15_State = 6'd18;
parameter D14_State = 6'd20;
parameter D13_State = 6'd22;
parameter D12_State = 6'd24;
parameter D11_State = 6'd26;
parameter D10_State = 6'd28;
parameter D9_State = 6'd30;
parameter D8_State = 6'd32;
parameter D7_State = 6'd34;
parameter D6_State = 6'd36;
parameter D5_State = 6'd38;
parameter D4_State = 6'd40;
parameter D3_State = 6'd42;
parameter D2_State = 6'd44;
parameter D1_State = 6'd46;
parameter D0_State = 6'd48;//发送最低位数据-状态

always@(posedge sysclk or negedge rst_n)
begin
    if(!rst_n)//复位
    begin
        ad9516_sck <= 1'b0;    //SCK初始电平为低
        ad9516_cs <= 1'b1;     //CS初始电平为高
        ad9516_mosi <= 1'b0;   //AD9516_MOSI初始电平为低
        wr_finish<= 1'b0;
        Data_State <= 1'b0;
        dataDir <= 1'b1;
        rdFrame <= 1'b0;
        rdByte <= 1'b0;
    end
    else //产生SPI时序
    begin
     if (nRd)begin
        case(Data_State)
        6'd0:begin
           ad9516_sck <= 1'b0;
           ad9516_cs <= 1'b1;
           Data_State <= Data_State + 1'b1;
           wr_finish <= 1'b0;
        end
        6'd1:begin
          if (start)begin
            ad9516_sck <= 1'b1;
            Data_State <= Data_State + 1'b1;
          end
          else begin
            ad9516_sck <= ad9516_sck + 1'b1;
            Data_State <= 'd1;
          end
          dataDir <= 1'b1;
        end
        6'd3,6'd5,6'd7,6'd9,6'd11,6'd13,6'd15,6'd17,6'd19,6'd21,6'd23,6'd25,6'd27,6'd29,6'd31,
        6'd33,6'd35,6'd37,6'd39,6'd41,6'd43,6'd45,'d47://每次放置数据完毕后 在此拉高时钟线，便于下次的下降沿产生
         begin
           ad9516_sck <= 1'b1;//准备在下降沿放置数据，提前将SCK拉高
           Data_State <= Data_State + 6'd1;//切换为数据放置状态(每发完1bit数据进入此一次，将时钟线拉高)
         end
        6'd49:begin
          ad9516_sck <= 1'b1;
          Data_State <= Data_State + 1'b1;
        end
        6'd50:begin
          ad9516_sck <= 1'b0;
          ad9516_cs <= 1'b1;
          wr_finish <= 1'b1;
          Data_State <= Data_State + 1'b1;
        end
        6'd51:begin
          ad9516_sck <= 1'b1;
          Data_State <= Data_State + 1'b1;
        end
        6'd52:begin
          ad9516_sck <= 1'b0;
          wr_finish <= 1'b0;
          Data_State <= Data_State + 1'b1;
        end
        D23_State://第23位数据发送状态
        begin		
            ad9516_cs <= 1'b0;//CS拉低准备数据传输
            ad9516_mosi <= value[23];//D23数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D22_State://c第22位数据发送状态
        begin
            ad9516_mosi <= value[22];//D22数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D21_State://第21位数据发送状态
        begin
            ad9516_mosi <= value[21];//D21数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D20_State://第20位数据发送状态
        begin
            ad9516_mosi <= value[20];//D20数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D19_State://第19位数据发送状态
        begin
            ad9516_mosi <= value[19];//D19数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D18_State://第18位数据发送状态
        begin
            ad9516_mosi <= value[18];//D18数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D17_State://第17位数据发送状态
        begin
            ad9516_mosi <= value[17];//D17数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D16_State://第16位数据发送状态
        begin
            ad9516_mosi <= value[16];//D16数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D15_State://第15位数据发送状态
        begin
            ad9516_mosi <= value[15];//D15数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D14_State://第14位数据发送状态
        begin
            ad9516_mosi <= value[14];//D14数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D13_State://第13位数据发送状态
        begin
            ad9516_mosi <= value[13];//D13数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D12_State://第12位数据发送状态
        begin
            ad9516_mosi <= value[12];//D12数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D11_State://第11位数据发送状态
        begin
            ad9516_mosi <= value[11];//D11数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D10_State://第10位数据发送状态
        begin
            ad9516_mosi <= value[10];//D10数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D9_State://第9位数据发送状态
        begin
            ad9516_mosi <= value[9];//D9数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D8_State://第8位数据发送状态
        begin
            ad9516_mosi <= value[8];//D8数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D7_State://第7位数据发送状态
        begin 
            ad9516_mosi <= value[7];//D7数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D6_State://第6位数据发送状态
        begin
            ad9516_mosi <= value[6];//D6数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D5_State://第5位数据发送状态
        begin
            ad9516_mosi <= value[5];//D5数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D4_State://第4位数据发送状态
        begin
            ad9516_mosi <= value[4];//D4数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D3_State://第3位数据发送状态
        begin
            ad9516_mosi <= value[3];//D3数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D2_State://第2位数据发送状态
        begin
            ad9516_mosi <= value[2];//D2数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D1_State://第1位数据发送状态
        begin
            ad9516_mosi <= value[1];//D1数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        D0_State://第0位数据发送状态
        begin
            ad9516_mosi <= value[0];//D0数据
            ad9516_sck <= 1'b0;//在下降沿放置数据
            Data_State <= Data_State + 6'd1;//切换状态
        end
        default:begin
            ad9516_sck <= 1'b1;
            Data_State <= 'd0;
            ad9516_cs <= 1'b1;
            wr_finish <= 1'b0;
          end
        endcase
     end
     else begin
          case(Data_State)
               'd0:begin
                    ad9516_sck <= 1'b0;
                    ad9516_cs <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                    wr_finish <= 1'b0;
               end
               6'd1:begin
                    if (start)begin
                         ad9516_sck <= 1'b1;
                         Data_State <= Data_State + 1'b1;
                    end
                    else begin
                         ad9516_sck <= ad9516_sck + 1'b1;
                         Data_State <= 'd1;
                    end
                    dataDir <= 1'b1;
                    rdFrame <= {1'b0,2'b00,value[20:8]};
               end
               6'd3,6'd5,6'd7,6'd9,6'd11,6'd13,6'd15,6'd17,6'd19,6'd21,6'd23,6'd25,6'd27,6'd29,6'd31,
               6'd33,6'd35,6'd37,6'd39,6'd41,6'd43,6'd45,'d47://每次放置数据完毕后 在此拉高时钟线，便于下次的下降沿产生
               begin
                    ad9516_sck <= 1'b1;//准备在下降沿放置数据，提前将SCK拉高
                    Data_State <= Data_State + 6'd1;//切换为数据放置状态(每发完1bit数据进入此一次，将时钟线拉高)
               end
               6'd49:begin
                    ad9516_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
               end
               6'd50:begin
                    ad9516_sck <= 1'b0;
                    ad9516_cs <= 1'b1;
                    wr_finish <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                    dataDir <= 1'b1;
               end
               6'd51:begin
                    ad9516_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
               end
               6'd52:begin
                    ad9516_sck <= 1'b0;
                    wr_finish <= 1'b0;
                    Data_State <= Data_State + 1'b1;
               end
               D23_State:begin
                    ad9516_cs <= 1'b0;//CS拉低准备数据传输
                    ad9516_mosi <= rdFrame[15];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D22_State:begin
                    ad9516_mosi <= rdFrame[14];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D21_State:begin
                    ad9516_mosi <= rdFrame[13];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D20_State:begin
                    ad9516_mosi <= rdFrame[12];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D19_State:begin
                    ad9516_mosi <= rdFrame[11];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D18_State:begin
                    ad9516_mosi <= rdFrame[10];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D17_State:begin
                    ad9516_mosi <= rdFrame[9];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D16_State:begin
                    ad9516_mosi <= rdFrame[8];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D15_State:begin
                    ad9516_mosi <= rdFrame[7];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D14_State:begin
                    ad9516_mosi <= rdFrame[6];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D13_State:begin
                    ad9516_mosi <= rdFrame[5];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D12_State:begin
                    ad9516_mosi <= rdFrame[4];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D11_State:begin
                    ad9516_mosi <= rdFrame[3];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D10_State:begin
                    ad9516_mosi <= rdFrame[2];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D9_State:begin
                    ad9516_mosi <= rdFrame[1];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b1;
               end
               D8_State:begin
                    ad9516_mosi <= rdFrame[0];
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
                    dataDir <= 1'b0;
               end
               D7_State,D6_State,D5_State,D4_State,D3_State,D2_State,D1_State,D0_State:begin
                    rdByte <= {rdByte[6:0],ad9516_miso};
                    ad9516_sck <= 1'b0;//在下降沿放置数据
                    Data_State <= Data_State + 6'd1;//切换状态
               end
               default:begin
                    ad9516_sck <= 1'b1;
                    Data_State <= 'd0;
                    ad9516_cs <= 1'b1;
                    wr_finish <= 1'b0;
                    dataDir <= 1'b1;
               end
     endcase
     end
    end
end
endmodule