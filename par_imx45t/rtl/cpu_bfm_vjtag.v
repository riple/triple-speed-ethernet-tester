/*
 * File   : cpu_bfm_vjtag.v
 * Date   : 20150217
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns
module cpu_bfm_vjtag (
    input  wire         up_rst,
    input  wire         up_clk,
    output wire         up_wr,
    output wire         up_rd,
    output wire [31: 0] up_addr,
    output wire [31: 0] up_data_wr,
    input  wire [31: 0] up_data_rd,
    input  wire         up_wait
);

wire up_rd_int;
reg  up_rd_int_d1;
always @(posedge up_clk) up_rd_int_d1 <= up_rd_int;
assign up_rd = up_rd_int && !up_rd_int_d1;

reg up_rd_d1;
always @(posedge up_clk) up_rd_d1 <= up_rd;
wire up_wait_int = up_rd || up_rd_d1;

buscli_jtag vjtag_master (
    .buscli_clk(up_clk),
    .buscli_reset(up_rst),
    .buscli_waitrequest(up_wait_int),
    .buscli_irq(1'b0),
    .buscli_address(up_addr),
    .buscli_read(up_rd_int),
    .buscli_write(up_wr),
    .buscli_writedata(up_data_wr),
    .buscli_readdata(up_data_rd),
    .buscli_resetrequest()
);

endmodule
