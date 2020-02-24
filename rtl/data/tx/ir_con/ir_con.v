/*
 * File   : ir_con.v
 * Date   : 20141217
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module ir_con (
    input  wire         rst,
    input  wire         clk,
    input  wire         test_start,

    input  wire           up_clk,
    input  wire           up_wr,
    input  wire           up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31  : 0] up_data_wr,
    output wire [31  : 0] up_data_rd,

    input  wire           frame_fifo_wr_in,
    input  wire [35  : 0] frame_fifo_data_in,
    output wire           frame_fifo_wr_out,
    output wire [35  : 0] frame_fifo_data_out
);

assign up_data_rd = 'd0;
assign frame_fifo_wr_out = 'd0;
assign frame_fifo_data_out = 'd0;

endmodule
