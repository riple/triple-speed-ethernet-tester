/*
 * File   : cpu_bfm.v
 * Date   : 20131011
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns
module cpu_bfm (
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

avalon_vjtag_master vjtag_master (
    .avm_mj_clk(up_clk),
    .avm_mj_reset(up_rst),
    .avm_mj_waitrequest(up_wait_int),
    .avm_mj_irq('d0),
    .avm_mj_address(up_addr),
    .avm_mj_read(up_rd_int),
    .avm_mj_write(up_wr),
    .avm_mj_writedata(up_data_wr),
    .avm_mj_readdata(up_data_rd),
    .avm_mj_resetrequest()
);
defparam
    vjtag_master.jtag_instance_index = 8;

endmodule
