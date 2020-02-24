/*
 * File   : bit_queue.v
 * Date   : 20130831
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module bit_queue
#(
  parameter integer bit_width = 64
)
(
  input  wire                  rst, clk,

  input  wire                  chk_in,
  input  wire [bit_width-1: 0] bit_in,
  input  wire [bit_width-1: 0] clr_in,

  output reg  [bit_width-1: 0] bit_out
);

generate
genvar i;
  for (i=0; i<bit_width; i=i+1) begin: bit_latch
    always @(posedge clr_in[i] or posedge clk) begin
      if (clr_in[i])   // NOTE: must be asynchronous clear!
        bit_out[i] <= 1'b0;
      else if (chk_in)
        bit_out[i] <= bit_in[i];
    end
  end
endgenerate

endmodule
