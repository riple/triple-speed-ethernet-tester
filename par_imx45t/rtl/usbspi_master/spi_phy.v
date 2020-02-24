/*
 * File   : spi_phy.v
 * Date   : 20140102
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns
module spi_phy(
    input  wire spi_cs,
    input  wire spi_clk,
    input  wire spi_mosi,
    output reg  spi_miso,

    output reg        spi_byte_o_en,
    output reg  [7:0] spi_byte_o,
    input  wire       spi_byte_i_en,
    input  wire [7:0] spi_byte_i
);

// serial transfer index counter
reg [2:0] spi_bit_cnt;
always @(posedge spi_cs or posedge spi_clk) begin
    if (spi_cs)
        spi_bit_cnt <= 'd0;
    else
        spi_bit_cnt <= spi_bit_cnt + 'd1;
end

// serial transfer 8bit done
always @(posedge spi_cs or posedge spi_clk) begin
    if (spi_cs)
        spi_byte_o_en <= 1'b0;
    else if (spi_bit_cnt=='d7)
        spi_byte_o_en <= 1'b1;
    else
        spi_byte_o_en <= 1'b0;
end

// serial transfer 8bit data input
always @(posedge spi_cs or posedge spi_clk) begin
    if (spi_cs)
        spi_byte_o <= 8'd0;
    else
        spi_byte_o <= {spi_byte_o[6:0], spi_mosi};
end



// serial transfer 8bit data output
always @(*) begin  // intented to be a latch
    if (!spi_clk)
        spi_miso <= spi_byte_i[7-spi_bit_cnt[2:0]];
end

endmodule

