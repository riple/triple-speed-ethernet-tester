/*
 * File   : data_top.v
 * Date   : 20130830
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module data_top (

    input  wire         rst,
    input  wire         clk,
    
    input  wire         tx_con_clk,

    input  wire           up_clk,
    input  wire           up_wr,
    input  wire           up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31  : 0] up_data_wr,
    output wire [31  : 0] up_data_rd,

    input  wire         rgmii_rxclk,
    input  wire         rgmii_rxden,
    input  wire [ 3: 0] rgmii_rxdin,
    output wire         rgmii_txclk,
    output wire         rgmii_txden,
    output wire [ 3: 0] rgmii_txdout,

    input  wire         sys_clk,
    input  wire [31: 0] sys_time,
    input  wire         phy_link_up,
    input  wire         phy_giga_mode,
    
    output wire         tx_stat_chk,
    output wire [ 3: 0] tx_stat_base_addr,
    output wire [63: 0] tx_stat_bit,
    output wire[575: 0] tx_stat_vec,
    
    output wire         rx_stat_chk,
    output wire [ 3: 0] rx_stat_base_addr,
    output wire [63: 0] rx_stat_bit,
    output wire[575: 0] rx_stat_vec,
    
    output wire         tx_active,
    output wire         rx_active
        
);

// CPU access
wire up_cs_tx  = (up_addr[17]==1'b0)? 1'b1: 1'b0;  // rd 0400xxxx
wire up_cs_rx  = (up_addr[17]==1'b1)? 1'b1: 1'b0;  // rd 0402xxxx

wire [31:0] up_data_rd_rx;
wire [31:0] up_data_rd_tx;

assign up_data_rd =  up_cs_rx? up_data_rd_rx:
                    (up_cs_tx? up_data_rd_tx: 32'hdeadbeef);


wire        lpbk_info_rqst;
wire        lpbk_info_vald;
wire [31:0] lpbk_info_data;

wire        lpbk_buff_rden;
wire [11:0] lpbk_buff_rdad;
wire [31:0] lpbk_buff_rdda;

data_tx tx (

    .rst(rst),
    .tx_gen_clk(rgmii_rxclk),
    .tx_con_clk(tx_con_clk),

    .up_clk(up_clk),
    .up_wr(up_wr && up_cs_tx),
    .up_rd(up_rd && up_cs_tx),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd_tx),

    .lpbk_out_clk(lpbk_out_clk),
    .lpbk_gen_en(lpbk_gen_en),
    .lpbk_info_rqst(lpbk_info_rqst),
    .lpbk_info_vald(lpbk_info_vald),
    .lpbk_info_data(lpbk_info_data),
    .lpbk_buff_rden(lpbk_buff_rden),
    .lpbk_buff_rdad(lpbk_buff_rdad),
    .lpbk_buff_rdda(lpbk_buff_rdda),

    .rgmii_txclk (rgmii_txclk),
    .rgmii_txden (rgmii_txden),
    .rgmii_txdout(rgmii_txdout),
    
    .sys_clk(sys_clk),
    .sys_time(sys_time),
    .phy_link_up(phy_link_up),
    .phy_giga_mode(phy_giga_mode),

    .tx_stat_chk(tx_stat_chk),
    .tx_stat_base_addr(tx_stat_base_addr),
    .tx_stat_bit(tx_stat_bit),
    .tx_stat_vec(tx_stat_vec),
    
    .pause_on(pause_on),

    .tx_active(tx_active)
);

data_rx rx (

    .rst(rst),
    .clk(),

    .up_clk(up_clk),
    .up_wr(up_wr && up_cs_rx),
    .up_rd(up_rd && up_cs_rx),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd_rx),

    .rgmii_rxclk(rgmii_rxclk),
    .rgmii_rxden(rgmii_rxden),
    .rgmii_rxdin(rgmii_rxdin),
    
    .sys_clk(sys_clk),
    .sys_time(sys_time),
    .phy_link_up(phy_link_up),
    .phy_giga_mode(phy_giga_mode),

    .rx_stat_chk(rx_stat_chk),
    .rx_stat_base_addr(rx_stat_base_addr),
    .rx_stat_bit(rx_stat_bit),
    .rx_stat_vec(rx_stat_vec),

    .lpbk_out_clk(lpbk_out_clk),
    .lpbk_gen_en(lpbk_gen_en),
    .lpbk_info_rqst(lpbk_info_rqst),
    .lpbk_info_vald(lpbk_info_vald),
    .lpbk_info_data(lpbk_info_data),
    .lpbk_buff_rden(lpbk_buff_rden),
    .lpbk_buff_rdad(lpbk_buff_rdad),
    .lpbk_buff_rdda(lpbk_buff_rdda),

    .pause_on(pause_on),
    
    .rx_active(rx_active)

);


endmodule
