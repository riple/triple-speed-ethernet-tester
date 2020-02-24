/*
 * File   : bit_vec_stat.v
 * Date   : 20131017
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module bit_vec_stat
#(
    parameter integer bit_width = 64,

    parameter integer vec_width_index = 4,
    parameter integer vec_width_value = 32,
    parameter integer vec_num         = 16,
    parameter integer vec_width_total = (vec_width_index+vec_width_value)*vec_num
)
(
    input  wire rst,
    input  wire clk,
    
    input  wire           up_rd,
    input  wire [32-1: 0] up_addr,
    output wire [31  : 0] up_data_rd,

    input  wire clr_in,

    input  wire                       stat_chk,
    input  wire [3                :0] stat_base_addr,
    input  wire [bit_width-1      :0] stat_bit,
    input  wire [vec_width_total-1:0] stat_vec
);

// CPU access
wire up_cs_bit = (up_addr[16]==1'b0)? 1'b1: 1'b0;  // rd 0800xxxx or 0802xxxx
wire up_cs_vec = (up_addr[16]==1'b1)? 1'b1: 1'b0;  // rd 0801xxxx or 0803xxxx
wire [31:0] up_data_rd_bit;
wire [31:0] up_data_rd_vec;
assign up_data_rd =  up_cs_bit? up_data_rd_bit:
                    (up_cs_vec? up_data_rd_vec: 32'hdeadbeef);

// Rx: bit based statistic
wire [bit_width-1: 0] stat_bit_clr;
wire [bit_width-1: 0] stat_bit_reg;

bit_queue stat_bit_queue (
    .rst(rst),
    .clk(clk),

    .chk_in (stat_chk && !clr_in),
    .bit_in (stat_bit),
    .clr_in (stat_bit_clr),
    .bit_out(stat_bit_reg)
);

bit_counter stat_bit_counter (
    .rst(rst),
    .clk(clk),
    .clr_in(clr_in),

    .up_rd(up_rd && up_cs_bit),
    .up_addr(up_addr[15:0]),
    .up_data_rd(up_data_rd_bit),

    .base_addr(stat_base_addr),
    .bit_in (stat_bit_reg),
    .clr_out(stat_bit_clr)
);

// Rx: vec based statistic
wire [vec_width_index*vec_num-1: 0] stat_vec_clr;
wire [vec_width_index*vec_num-1: 0] stat_vec_reg;
wire [vec_width_value*vec_num-1: 0] stat_vec_val;

vec_queue stat_vec_queue (
    .rst(rst),
    .clk(clk),

    .chk_in (stat_chk && !clr_in),
    .vec_in (stat_vec),
    .clr_in (stat_vec_clr),
    .vec_index_out(stat_vec_reg),
    .vec_value_out(stat_vec_val)
);

vec_counter stat_vec_counter (
    .rst(rst),
    .clk(clk),
    .clr_in(clr_in),

    .up_rd(up_rd && up_cs_vec),
    .up_addr(up_addr[15:0]),
    .up_data_rd(up_data_rd_vec),

    .base_addr(stat_base_addr),
    .vec_index_in(stat_vec_reg),
    .vec_value_in(stat_vec_val),
    .clr_out(stat_vec_clr)
);

endmodule
