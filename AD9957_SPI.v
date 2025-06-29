`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/21 14:58:29
// Design Name: 
// Module Name: AD9957_SPI
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
module AD9957_SPI(
    input sysclk,
    input rst_n,

    output reg ad9957_mosi,
    output reg ad9957_cs,
    output reg ad9957_sck,
    input  ad9957_miso,

    input[6:0] len,
    input[7:0] address,
    input[63:0] value,

    input start,
    output reg wr_finish,
    output reg ad9957_dataDir,

    output reg[71:0] wrFrameData64,
    output reg[55:0] wrFrameData48,
    output reg[39:0] wrFrameData32,
    output reg[23:0] wrFrameData16,
    output reg[63:0] rdByte64,
    output reg[47:0] rdByte48,
    output reg[31:0] rdByte32,
    output reg[15:0] rdByte16
);

reg[6:0] len_reg;
reg[6:0] len_reg_rd; 

reg[3:0] shift;
reg nRd;
reg[7:0] Data_State;
reg[7:0] rdFrame;
 
always@(posedge sysclk)begin
    if (!rst_n)begin
        shift <= 4'b0000;
    end
    else if (len == 'd16)begin
        shift <= 4'b0001;
    end
    else if (len == 'd32)begin
        shift <= 4'b0010;
    end
    else if (len == 'd48)begin
        shift <= 4'b0100;
    end
    else if (len == 'd64)begin
        shift <= 4'b1000;
    end
end

always@(posedge sysclk or negedge rst_n)begin
    if (!rst_n) 
        nRd <= 1'b0;
    else if (address[7] == 1'b0)
        nRd <= 1'b1;
    else
        nRd <= 1'b0;
end

always@(posedge sysclk or negedge rst_n)begin
    if(!rst_n)begin
        ad9957_cs <= 1'b1;
        ad9957_mosi <= 1'b0;
        ad9957_sck <= 1'b0;
        wr_finish <= 1'b0;
        len_reg <= 'd0;
        ad9957_dataDir <= 1'b1;
        Data_State <= 1'b0;
    end
    else begin
        if (nRd && ((shift[0] == 1'b1)))begin//16位写
            case(Data_State)
            'd0,'d2:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                Data_State <= Data_State + 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
                wrFrameData16 <= {address,value[15:0]};
                len_reg <= len + 7;
            end
            'd1:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd1;
                end
            end
            'd3:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd3;
                end
            end
            'd5,'d7,'d9,'d11,'d13,'d15,'d17,'d19,'d21,'d23,'d25,'d27,'d29,'d31,
            'd33,'d35,'d37,'d39,'d41,'d43,'d45,'d47,'d49:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd51:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd52:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd53:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd54:begin
                ad9957_sck <= 1'b0;
                wr_finish <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            'd4:begin
                ad9957_cs <= 1'b0;
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData16[len_reg];
                if (len_reg == 'd0)
                    len_reg <= len_reg;
                else
                    len_reg <= len_reg - 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd6,'d8,'d10,'d12,'d14,'d16,'d18,'d20,'d22,'d24,'d26,'d28,'d30,
            'd32,'d34,'d36,'d38,'d40,'d42,'d44,'d46,'d48,'d50:begin
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData16[len_reg];
                if (len_reg == 'd0)
                    len_reg <= len_reg;
                else
                    len_reg <= len_reg - 1'b1;
                Data_State <= Data_State + 1'b1;
            end 
            default:begin
                ad9957_sck <= 1'b1;
                Data_State <= 1'd0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b0;
            end
        endcase
        end
        else if (nRd && ((shift[1] == 1'b1)))begin//32位写
            case(Data_State)
            'd0,'d2:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                Data_State <= Data_State + 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
                wrFrameData32 <= {address,value[31:0]};
                len_reg <= len + 7;
            end
            'd1:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd1;
                end
            end
            'd3:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd3;
                end
            end
            'd5,'d7,'d9,'d11,'d13,'d15,'d17,'d19,'d21,'d23,'d25,'d27,'d29,'d31,
            'd33,'d35,'d37,'d39,'d41,'d43,'d45,'d47,'d49,'d51,'d53,'d55,'d57,'d59,'d61,
            'd63,'d65,'d67,'d69,'d71,'d73,'d75,'d77,'d79,'d81:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd83:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd84:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd85:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd86:begin
                ad9957_sck <= 1'b0;
                wr_finish <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            'd4:begin
                ad9957_cs <= 1'b0;
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData32[len_reg];
                if (len_reg == 'd0)
                    len_reg <= len_reg;
                else
                    len_reg <= len_reg - 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd6,'d8,'d10,'d12,'d14,'d16,'d18,'d20,'d22,'d24,'d26,'d28,'d30,
            'd32,'d34,'d36,'d38,'d40,'d42,'d44,'d46,'d48,'d50,'d52,'d54,'d56,'d58,'d60,
            'd62,'d64,'d66,'d68,'d70,'d72,'d74,'d76,'d78,'d80,'d82:begin
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData32[len_reg];
                if (len_reg == 'd0)
                    len_reg <= len_reg;
                else
                    len_reg <= len_reg - 1'b1;
                Data_State <= Data_State + 1'b1;
            end 
            default:begin
                ad9957_sck <= 1'b1;
                Data_State <= 1'd0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b0;
            end
        endcase
        end
        else if (nRd && (shift[2] == 1'b1))begin//48位写
            case(Data_State)
            'd0,'d2:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                Data_State <= Data_State + 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
                wrFrameData48 <= {address,value[47:0]};
                len_reg <= len + 7;
            end
            'd1:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd1;
                end
            end
            'd3:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd3;
                end
            end
            'd5,'d7,'d9,'d11,'d13,'d15,'d17,'d19,'d21,'d23,'d25,'d27,'d29,'d31,
            'd33,'d35,'d37,'d39,'d41,'d43,'d45,'d47,'d49,'d51,'d53,'d55,'d57,'d59,'d61,
            'd63,'d65,'d67,'d69,'d71,'d73,'d75,'d77,'d79,'d81,'d83,'d85,'d87,'d89,'d91,
            'd93,'d95,'d97,'d99,'d101,'d103,'d105,'d107,'d109,'d111,'d113:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd115:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd116:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd117:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd118:begin
                ad9957_sck <= 1'b0;
                wr_finish <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            'd4:begin
                ad9957_cs <= 1'b0;
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData48[len_reg];
                if (len_reg == 'd0)
                    len_reg <= len_reg;
                else
                    len_reg <= len_reg - 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd6,'d8,'d10,'d12,'d14,'d16,'d18,'d20,'d22,'d24,'d26,'d28,'d30,
            'd32,'d34,'d36,'d38,'d40,'d42,'d44,'d46,'d48,'d50,'d52,'d54,'d56,'d58,'d60,
            'd62,'d64,'d66,'d68,'d70,'d72,'d74,'d76,'d78,'d80,'d82,'d84,'d86,'d88,'d90,
            'd92,'d94,'d96,'d98,'d100,'d102,'d104,'d106,'d108,'d110,'d112,'d114:begin
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData48[len_reg];
                if (len_reg == 'd0)
                    len_reg <= len_reg;
                else
                    len_reg <= len_reg - 1'b1;
                Data_State <= Data_State + 1'b1;
            end 
            default:begin
                ad9957_sck <= 1'b1;
                Data_State <= 1'd0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b0;
            end
        endcase
        end
        else if (nRd && (shift[3] == 1'b1))begin//64位写
            case(Data_State)
            'd0,'d2:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                Data_State <= Data_State + 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
                wrFrameData64 <= {address,value};
                len_reg <= len + 7;
            end
            'd1:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd1;
                end
            end
            'd3:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd3;
                end
            end
            'd5,'d7,'d9,'d11,'d13,'d15,'d17,'d19,'d21,'d23,'d25,'d27,'d29,'d31,
            'd33,'d35,'d37,'d39,'d41,'d43,'d45,'d47,'d49,'d51,'d53,'d55,'d57,'d59,'d61,
            'd63,'d65,'d67,'d69,'d71,'d73,'d75,'d77,'d79,'d81,'d83,'d85,'d87,'d89,'d91,
            'd93,'d95,'d97,'d99,'d101,'d103,'d105,'d107,'d109,'d111,'d113,'d115,'d117,'d119,'d121,
            'd123,'d125,'d127,'d129,'d131,'d133,'d135,'d137,'d139,'d141,'d143,'d145:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd147:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd148:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd149:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd150:begin
                ad9957_sck <= 1'b0;
                wr_finish <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            'd4:begin
                ad9957_cs <= 1'b0;
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData64[len_reg];
                if (len_reg == 'd0)
                    len_reg <= len_reg;
                else
                    len_reg <= len_reg - 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd6,'d8,'d10,'d12,'d14,'d16,'d18,'d20,'d22,'d24,'d26,'d28,'d30,
            'd32,'d34,'d36,'d38,'d40,'d42,'d44,'d46,'d48,'d50,'d52,'d54,'d56,'d58,'d60,
            'd62,'d64,'d66,'d68,'d70,'d72,'d74,'d76,'d78,'d80,'d82,'d84,'d86,'d88,'d90,
            'd92,'d94,'d96,'d98,'d100,'d102,'d104,'d106,'d108,'d110,'d112,'d114,'d116,'d118,'d120,
            'd122,'d124,'d126,'d128,'d130,'d132,'d134,'d136,'d138,'d140,'d142,'d144,'d146:begin
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData64[len_reg];
                if (len_reg == 'd0)
                    len_reg <= len_reg;
                else
                    len_reg <= len_reg - 1'b1;
                Data_State <= Data_State + 1'b1;
            end 
            default:begin
                ad9957_sck <= 1'b1;
                Data_State <= 1'd0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b0;
            end
        endcase
        end
        else if ((!nRd) && (shift[0] == 1'b1))begin//16位读
            case(Data_State)
            'd0,'d2:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                Data_State <= Data_State + 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
                rdFrame <= address;
                len_reg_rd <= 'd7;
                len_reg <= len + 7;
            end
            'd1:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd1;
                end
            end
            'd3:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd3;
                end
            end
            'd5,'d7,'d9,'d11,'d13,'d15,'d17,'d19,'d21,'d23,'d25,'d27,'d29,'d31,
            'd33,'d35,'d37,'d39,'d41,'d43,'d45,'d47,'d49:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd51:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd52:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd53:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd54:begin
                ad9957_sck <= 1'b0;
                wr_finish <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            'd4:begin
                ad9957_cs <= 1'b0;
                ad9957_sck <= 1'b0;
                ad9957_mosi <= rdFrame[len_reg_rd];
                if (len_reg_rd == 'd0)
                    len_reg_rd <= len_reg_rd;
                else
                    len_reg_rd <= len_reg_rd - 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd6,'d8,'d10,'d12,'d14,'d16,'d18:begin
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData16[len_reg_rd];
                if (len_reg_rd == 'd0)
                    len_reg_rd <= len_reg_rd;
                else
                    len_reg_rd <= len_reg_rd - 1'b1;
                if (Data_State == 'd18)begin
                    ad9957_dataDir <= 1'b0;
                end
                else begin
                    ad9957_dataDir <= 1'b1;
                end
                Data_State <= Data_State + 1'b1;
            end 
            'd20,'d22,'d24,'d26,'d28,'d30,
            'd32,'d34,'d36,'d38,'d40,'d42,'d44,'d46,'d48,'d50:begin
                rdByte16 <= {rdByte16[14:0],ad9957_miso};
                ad9957_sck <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            default:begin
                ad9957_sck <= 1'b1;
                Data_State <= 1'd0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
            end
        endcase
        end
        else if ((!nRd) && (shift[1] == 1'b1))begin//32位读
            case(Data_State)
            'd0,'d2:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                Data_State <= Data_State + 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
                rdFrame <= address;
                len_reg_rd <= 'd7;
                len_reg <= len + 7;
            end
            'd1:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd1;
                end
            end
            'd3:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd3;
                end
            end
            'd5,'d7,'d9,'d11,'d13,'d15,'d17,'d19,'d21,'d23,'d25,'d27,'d29,'d31,
            'd33,'d35,'d37,'d39,'d41,'d43,'d45,'d47,'d49,'d51,'d53,'d55,'d57,'d59,'d61,
            'd63,'d65,'d67,'d69,'d71,'d73,'d75,'d77,'d79,'d81:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd83:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd84:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd85:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd86:begin
                ad9957_sck <= 1'b0;
                wr_finish <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            'd4:begin
                ad9957_cs <= 1'b0;
                ad9957_sck <= 1'b0;
                ad9957_mosi <= rdFrame[len_reg_rd];
                if (len_reg_rd == 'd0)
                    len_reg_rd <= len_reg_rd;
                else
                    len_reg_rd <= len_reg_rd - 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd6,'d8,'d10,'d12,'d14,'d16,'d18:begin
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData32[len_reg_rd];
                if (len_reg_rd == 'd0)
                    len_reg_rd <= len_reg_rd;
                else
                    len_reg_rd <= len_reg_rd - 1'b1;
                if (Data_State == 'd18)begin
                    ad9957_dataDir <= 1'b0;
                end
                else begin
                    ad9957_dataDir <= 1'b1;
                end
                Data_State <= Data_State + 1'b1;
            end 
            'd20,'d22,'d24,'d26,'d28,'d30,
            'd32,'d34,'d36,'d38,'d40,'d42,'d44,'d46,'d48,'d50,'d52,'d54,'d56,'d58,'d60,
            'd62,'d64,'d66,'d68,'d70,'d72,'d74,'d76,'d78,'d80,'d82:begin
                rdByte32 <= {rdByte32[30:0],ad9957_miso};
                ad9957_sck <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            default:begin
                ad9957_sck <= 1'b1;
                Data_State <= 1'd0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
            end
        endcase
        end
        else if ((!nRd) && (shift[2] == 1'b1))begin //48位读
            case(Data_State)
            'd0,'d2:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                Data_State <= Data_State + 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
                rdFrame <= address;
                len_reg_rd <= 'd7;
                len_reg <= len + 7;
            end
            'd1:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd1;
                end
            end
            'd3:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd3;
                end
            end
            'd5,'d7,'d9,'d11,'d13,'d15,'d17,'d19,'d21,'d23,'d25,'d27,'d29,'d31,
            'd33,'d35,'d37,'d39,'d41,'d43,'d45,'d47,'d49,'d51,'d53,'d55,'d57,'d59,'d61,
            'd63,'d65,'d67,'d69,'d71,'d73,'d75,'d77,'d79,'d81,'d83,'d85,'d87,'d89,'d91,
            'd93,'d95,'d97,'d99,'d101,'d103,'d105,'d107,'d109,'d111,'d113:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd115:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd116:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd117:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd118:begin
                ad9957_sck <= 1'b0;
                wr_finish <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            'd4:begin
                ad9957_cs <= 1'b0;
                ad9957_sck <= 1'b0;
                ad9957_mosi <= rdFrame[len_reg_rd];
                if (len_reg_rd == 'd0)
                    len_reg_rd <= len_reg_rd;
                else
                    len_reg_rd <= len_reg_rd - 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd6,'d8,'d10,'d12,'d14,'d16,'d18:begin
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData48[len_reg_rd];
                if (len_reg_rd == 'd0)
                    len_reg_rd <= len_reg_rd;
                else
                    len_reg_rd <= len_reg_rd - 1'b1;
                if (Data_State == 'd18)begin
                    ad9957_dataDir <= 1'b0;
                end
                else begin
                    ad9957_dataDir <= 1'b1;
                end
                Data_State <= Data_State + 1'b1;
            end 
            'd20,'d22,'d24,'d26,'d28,'d30,
            'd32,'d34,'d36,'d38,'d40,'d42,'d44,'d46,'d48,'d50,'d52,'d54,'d56,'d58,'d60,
            'd62,'d64,'d66,'d68,'d70,'d72,'d74,'d76,'d78,'d80,'d82,'d84,'d86,'d88,'d90,
            'd92,'d94,'d96,'d98,'d100,'d102,'d104,'d106,'d108,'d110,'d112,'d114:begin
                rdByte48 <= {rdByte48[46:0],ad9957_miso};
                ad9957_sck <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            default:begin
                ad9957_sck <= 1'b1;
                Data_State <= 1'd0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
            end
        endcase
        end
        else if ((!nRd) && (shift[3] == 1'b1))begin //64位读
            case(Data_State)
            'd0,'d2:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                Data_State <= Data_State + 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
                rdFrame <= address;
                len_reg_rd <= 'd7;
                len_reg <= len + 7;
            end
            'd1:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd1;
                end
            end
            'd3:begin
                if (start)begin
                    ad9957_sck <= 1'b1;
                    Data_State <= Data_State + 1'b1;
                end
                else begin
                    ad9957_sck <= ad9957_sck + 1'b1;
                    Data_State <= 'd3;
                end
            end
            'd5,'d7,'d9,'d11,'d13,'d15,'d17,'d19,'d21,'d23,'d25,'d27,'d29,'d31,
            'd33,'d35,'d37,'d39,'d41,'d43,'d45,'d47,'d49,'d51,'d53,'d55,'d57,'d59,'d61,
            'd63,'d65,'d67,'d69,'d71,'d73,'d75,'d77,'d79,'d81,'d83,'d85,'d87,'d89,'d91,
            'd93,'d95,'d97,'d99,'d101,'d103,'d105,'d107,'d109,'d111,'d113,'d115,'d117,'d119,'d121,
            'd123,'d125,'d127,'d129,'d131,'d133,'d135,'d137,'d139,'d141,'d143,'d145:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd147:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd148:begin
                ad9957_sck <= 1'b0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd149:begin
                ad9957_sck <= 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd150:begin
                ad9957_sck <= 1'b0;
                wr_finish <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            'd4:begin
                ad9957_cs <= 1'b0;
                ad9957_sck <= 1'b0;
                ad9957_mosi <= rdFrame[len_reg_rd];
                if (len_reg_rd == 'd0)
                    len_reg_rd <= len_reg_rd;
                else
                    len_reg_rd <= len_reg_rd - 1'b1;
                Data_State <= Data_State + 1'b1;
            end
            'd6,'d8,'d10,'d12,'d14,'d16,'d18:begin
                ad9957_sck <= 1'b0;
                ad9957_mosi <= wrFrameData64[len_reg_rd];
                if (len_reg_rd == 'd0)
                    len_reg_rd <= len_reg_rd;
                else
                    len_reg_rd <= len_reg_rd - 1'b1;
                if (Data_State == 'd18)begin
                    ad9957_dataDir <= 1'b0;
                end
                else begin
                    ad9957_dataDir <= 1'b1;
                end
                Data_State <= Data_State + 1'b1;
            end 
            'd20,'d22,'d24,'d26,'d28,'d30,
            'd32,'d34,'d36,'d38,'d40,'d42,'d44,'d46,'d48,'d50,'d52,'d54,'d56,'d58,'d60,
            'd62,'d64,'d66,'d68,'d70,'d72,'d74,'d76,'d78,'d80,'d82,'d84,'d86,'d88,'d90,
            'd92,'d94,'d96,'d98,'d100,'d102,'d104,'d106,'d108,'d110,'d112,'d114,'d116,'d118,'d120,
            'd122,'d124,'d126,'d128,'d130,'d132,'d134,'d136,'d138,'d140,'d142,'d144,'d146:begin
                rdByte64 <= {rdByte64[62:0],ad9957_miso};
                ad9957_sck <= 1'b0;
                Data_State <= Data_State + 1'b1;
            end
            default:begin
                ad9957_sck <= 1'b1;
                Data_State <= 1'd0;
                ad9957_cs <= 1'b1;
                wr_finish <= 1'b0;
                ad9957_dataDir <= 1'b1;
            end
        endcase
        end
    end
end
endmodule
