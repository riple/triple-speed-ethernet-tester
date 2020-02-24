/*
 * File   : cpu_bfm_usbspi.v
 * Date   : 20140102
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns
module cpu_bfm_usbspi (
    input  wire spi_cs,
    input  wire spi_clk,
    input  wire spi_mosi,
    output wire spi_miso,

    input  wire         up_clk,
    output wire         up_wr,
    output wire         up_rd,
    output wire [31: 0] up_addr,
    output wire [31: 0] up_data_wr,
    input  wire [31: 0] up_data_rd
);

usbspi_master usbspi_master_inst (
    .spi_cs  (spi_cs),
    .spi_clk (spi_clk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),

    .up_clk    (up_clk),
    .up_addr   (up_addr),
    .up_wr     (up_wr),
    .up_rd     (up_rd),
    .up_wr_data(up_data_wr),
    .up_rd_data(up_data_rd)
);

endmodule
