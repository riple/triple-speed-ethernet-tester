/*
 * File   : usbspi_master.v
 * Date   : 20140102
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns
module usbspi_master(
    input  wire spi_cs,
    input  wire spi_clk,
    input  wire spi_mosi,
    output wire spi_miso,

    input  wire        up_clk,
    output wire [31:0] up_addr,
    output wire        up_wr,
    output wire        up_rd,
    output wire [31:0] up_wr_data,
    input  wire [31:0] up_rd_data
);

wire       spi_byte_o_en;
wire [7:0] spi_byte_o;
wire       spi_byte_i_en;
wire [7:0] spi_byte_i;
spi_phy spi_low_level (
    .spi_cs  (spi_cs),
    .spi_clk (spi_clk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),

    .spi_byte_o_en(spi_byte_o_en),
    .spi_byte_o   (spi_byte_o),
    .spi_byte_i_en(spi_byte_i_en),
    .spi_byte_i   (spi_byte_i)
);

reg spi_byte_o_en_d1, spi_byte_o_en_d2, spi_byte_o_en_d3;
always @(posedge up_clk) begin
    spi_byte_o_en_d1 <= spi_byte_o_en;
    spi_byte_o_en_d2 <= spi_byte_o_en_d1;
    spi_byte_o_en_d3 <= spi_byte_o_en_d2;
end

wire spi_byte_o_en_pulse = spi_byte_o_en_d2 && !spi_byte_o_en_d3;
spi_fsm spi_high_level (
    .spi_cs       (spi_cs),
    .spi_byte_o_en(spi_byte_o_en_pulse),
    .spi_byte_o   (spi_byte_o),
    .spi_byte_i_en(spi_byte_i_en),
    .spi_byte_i   (spi_byte_i),

    .up_clk    (up_clk),
    .up_addr   (up_addr),
    .up_wr     (up_wr),
    .up_rd     (up_rd),
    .up_wr_data(up_wr_data),
    .up_rd_data(up_rd_data)
);

endmodule

