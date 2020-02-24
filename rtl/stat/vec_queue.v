/*
 * File   : vec_queue.v
 * Date   : 20130902
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module vec_queue
#(
  parameter integer vec_width_index = 4,
  parameter integer vec_width_value = 32,
  parameter integer vec_num         = 16,
  parameter integer vec_width_total = (vec_width_index+vec_width_value)*vec_num
)
(
  input  wire rst, clk,

  input  wire                                chk_in,
  input  wire [vec_width_index*vec_num-1: 0] clr_in,
  input  wire [vec_width_total        -1: 0] vec_in,

  output reg  [vec_width_index*vec_num-1: 0] vec_index_out,
  output reg  [vec_width_value*vec_num-1: 0] vec_value_out
);

generate
genvar i;
genvar j;
  for (i=0; i<vec_num;         i=i+1) begin: vec_loop_1
  for (j=0; j<vec_width_index; j=j+1) begin: index_loop
    always @(posedge clr_in[(i-0)*vec_width_index+j] or posedge clk) begin
      if (clr_in[(i-0)*vec_width_index+j])   // NOTE: must be asynchronous clear! 
        vec_index_out[(i-0)*vec_width_index+j] <= 1'b0;
      else if (chk_in)
        vec_index_out[(i-0)*vec_width_index+j] <= vec_in[(i+1)*(vec_width_index+vec_width_value)-vec_width_index+j];
    end
  end
  end
endgenerate

generate
genvar m;
genvar n;
  for (m=0; m<vec_num;         m=m+1) begin: vec_loop_2
  for (n=0; n<vec_width_value; n=n+1) begin: value_loop
    always @(posedge clk) begin
      if (chk_in)
        vec_value_out[(m-0)*vec_width_value+n] <= vec_in[(m+1)*(vec_width_index+vec_width_value)-vec_width_index-vec_width_value+n];
    end
  end
  end
endgenerate

endmodule
