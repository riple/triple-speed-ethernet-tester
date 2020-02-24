/*
 * File   : stat_top.v
 * Date   : 20130830
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module stat_top
#(
  parameter integer bit_width = 64,

  parameter integer vec_width_index = 4,
  parameter integer vec_width_value = 32,
  parameter integer vec_num         = 16,
  parameter integer vec_width_total = (vec_width_index+vec_width_value)*vec_num
)
(

    input  wire rst, stat_clk, data_clk,

    input  wire           up_clk,  // unused, should be the same as stat_clk
    input  wire           up_wr,
    input  wire           up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31  : 0] up_data_wr,
    output wire [31  : 0] up_data_rd,

    input  wire clr_in,
    output wire clr_done,

    input  wire                       tx_stat_chk,
    input  wire [ 3:0]                tx_stat_base_addr,
    input  wire [bit_width-1:0]       tx_stat_bit,
    input  wire [vec_width_total-1:0] tx_stat_vec,

    input  wire                       rx_stat_chk,
    input  wire [ 3:0]                rx_stat_base_addr,
    input  wire [bit_width-1:0]       rx_stat_bit,
    input  wire [vec_width_total-1:0] rx_stat_vec

);

// CPU access
wire up_cs_tx  = (up_addr[17]==1'b0)? 1'b1: 1'b0;  // rd 0800xxxx
wire up_cs_rx  = (up_addr[17]==1'b1)? 1'b1: 1'b0;  // rd 0802xxxx

wire [31:0] up_data_rd_rx;
wire [31:0] up_data_rd_tx;

assign up_data_rd =  up_cs_rx? up_data_rd_rx:
                    (up_cs_tx? up_data_rd_tx: 32'hdeadbeef);


// CTRL to STAT global clear
wire clr_in_cdc;
synchronizer_level clr_in_sync (
    .clk_out(stat_clk),
    .clk_en(1'b1),
    .reset_n(!rst),
    .sync_in(clr_in),

    .sync_out_p1(),
    .sync_out_reg2(clr_in_cdc)
);

// CPU clear command return
reg [1+3+6-1:0] clr_cntr;  // 2*8*64=1024
assign clr_done = (clr_cntr==10'h3ff)? 1'b1: 1'b0;
always @(posedge rst or posedge stat_clk) begin
    if (rst)
        clr_cntr <= 'd0;
    else if (clr_in_cdc)
        clr_cntr <= clr_done? clr_cntr: (clr_cntr + 'd1);
    else
        clr_cntr <= 'd0;
end

// RX: DATA to STAT packet statistic check point
wire rx_stat_chk_cdc;
synchronizer_level rx_stat_chk_sync (
    .clk_out(stat_clk),
    .clk_en(1'b1),
    .reset_n(!rst),
    .sync_in(rx_stat_chk),

    .sync_out_p1(rx_stat_chk_cdc),
    .sync_out_reg2()
);
reg [3:0] rx_stat_base_addr_sync; always @(posedge stat_clk) if(rx_stat_chk_cdc) rx_stat_base_addr_sync <= rx_stat_base_addr;

bit_vec_stat rx_stat_inst (
    .rst(rst),
    .clk(stat_clk),

    .up_rd(up_rd && up_cs_rx),
    .up_addr(up_addr),
    .up_data_rd(up_data_rd_rx),

    .clr_in(clr_in_cdc),

    .stat_chk(rx_stat_chk_cdc),
    .stat_base_addr(rx_stat_base_addr_sync),
    .stat_bit(rx_stat_bit),
    .stat_vec(rx_stat_vec)
);
defparam
    rx_stat_inst.bit_width       = bit_width,
    rx_stat_inst.vec_width_index = vec_width_index,
    rx_stat_inst.vec_width_value = vec_width_value,
    rx_stat_inst.vec_num         = vec_num,
    rx_stat_inst.vec_width_total = (vec_width_index+vec_width_value)*vec_num;

// TX: DATA to STAT packet statistic check point
wire tx_stat_chk_cdc;
synchronizer_level tx_stat_chk_sync (
    .clk_out(stat_clk),
    .clk_en(1'b1),
    .reset_n(!rst),
    .sync_in(tx_stat_chk),

    .sync_out_p1(tx_stat_chk_cdc),
    .sync_out_reg2()
);
reg [3:0] tx_stat_base_addr_sync; always @(posedge stat_clk) if (tx_stat_chk_cdc) tx_stat_base_addr_sync <= tx_stat_base_addr;

bit_vec_stat tx_stat_inst (
    .rst(rst),
    .clk(stat_clk),

    .up_rd(up_rd && up_cs_tx),
    .up_addr(up_addr),
    .up_data_rd(up_data_rd_tx),

    .clr_in(clr_in_cdc),

    .stat_chk(tx_stat_chk_cdc),
    .stat_base_addr(tx_stat_base_addr_sync),
    .stat_bit(tx_stat_bit),
    .stat_vec(tx_stat_vec)
);
defparam
    tx_stat_inst.bit_width       = bit_width,
    tx_stat_inst.vec_width_index = vec_width_index,
    tx_stat_inst.vec_width_value = vec_width_value,
    tx_stat_inst.vec_num         = vec_num,
    tx_stat_inst.vec_width_total = (vec_width_index+vec_width_value)*vec_num;

endmodule
