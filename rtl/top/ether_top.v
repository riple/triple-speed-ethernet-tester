/*
 * File   : ether_top.v
 * Date   : 20130830
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module ether_top (

    input  wire         rst,
    input  wire         clk,

    input  wire         up_clk,
    input  wire         up_cs,
    input  wire         up_wr,
    input  wire         up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31: 0] up_data_wr,
    output wire [31: 0] up_data_rd,
    output wire         up_busy,

    output wire         mdio_clk,
    inout  wire         mdio_io,

    input  wire         rgmii_rxclk,
    input  wire         rgmii_rxden,
    input  wire [ 3: 0] rgmii_rxdin,
    output wire         rgmii_txclk,
    output wire         rgmii_txden,
    output wire [ 3: 0] rgmii_txdout,

    output wire         phy_rst,
    output wire         up_clk_out,
    
    output wire [ 3: 0] debug_led

);

wire         ctrl_up_clk;
wire         ctrl_up_cs_stat;
wire         ctrl_up_cs_data;
wire         ctrl_up_wr;
wire         ctrl_up_rd;
wire [32-1: 0] ctrl_up_addr;
wire [31: 0] ctrl_up_data_wr;
wire [31: 0] ctrl_up_data_rd_stat;
wire [31: 0] ctrl_up_data_rd_data;

wire         sys_clk;
wire [31: 0] sys_time;
wire         phy_link_up;
wire         phy_giga_mode;

wire         tx_con_clk;

wire         tx_stat_chk;
wire [ 3: 0] tx_stat_base_addr;
wire [63: 0] tx_stat_bit;
wire[575: 0] tx_stat_vec;

wire         rx_stat_chk;
wire [ 3: 0] rx_stat_base_addr;
wire [63: 0] rx_stat_bit;
wire[575: 0] rx_stat_vec;

wire         tx_active;
wire         rx_active;

wire soft_rst;

wire stat_clk;
wire stat_rst, stat_rst_done;

assign up_clk_out = stat_clk;  // NOTE: must be the same clock with stat_top module

assign debug_led = {phy_link_up, phy_giga_mode, rx_active, tx_active};

ctrl_top ctrl (
    // system interface
    .rst(rst),
    .clk(clk),
    // cpu interface
    .up_clk(up_clk),
    .up_cs(up_cs),
    .up_wr(up_wr),
    .up_rd(up_rd),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd),
    .up_busy(up_busy),

    // internal register access control
    .ctrl_up_clk(ctrl_up_clk),
    .ctrl_up_cs_stat(ctrl_up_cs_stat),
    .ctrl_up_cs_data(ctrl_up_cs_data),
    .ctrl_up_wr(ctrl_up_wr),
    .ctrl_up_rd(ctrl_up_rd),
    .ctrl_up_addr(ctrl_up_addr),
    .ctrl_up_data_wr(ctrl_up_data_wr),
    .ctrl_up_data_rd_stat(ctrl_up_data_rd_stat),
    .ctrl_up_data_rd_data(ctrl_up_data_rd_data),

    // tx_con traffic generation clock
    .tx_con_clk(tx_con_clk),
    
    // phy control interface
    .mdio_clk(mdio_clk),
    .mdio_io(mdio_io),

    // global soft reset
    .soft_rst(soft_rst),
    .phy_rst(phy_rst),

    // phy status
    .phy_link_up(phy_link_up),
    .phy_giga_mode(phy_giga_mode),

    // statistics clock
    .stat_clk(stat_clk),
    .stat_rst(stat_rst),
    .stat_rst_done(stat_rst_done),
    // 10ns timer
    .sys_clk(sys_clk),
    .sys_time(sys_time)
);

stat_top stat (
    .rst(rst || soft_rst),
    .stat_clk(stat_clk),
    .data_clk(rgmii_rxclk),

    .up_clk(ctrl_up_clk),
    .up_wr(ctrl_up_wr && ctrl_up_cs_stat),
    .up_rd(ctrl_up_rd && ctrl_up_cs_stat),
    .up_addr(ctrl_up_addr),
    .up_data_wr(ctrl_up_data_wr),
    .up_data_rd(ctrl_up_data_rd_stat),

    .clr_in(stat_rst),
    .clr_done(stat_rst_done),
    
    .tx_stat_chk(tx_stat_chk),
    .tx_stat_base_addr(tx_stat_base_addr),
    .tx_stat_bit(tx_stat_bit),
    .tx_stat_vec(tx_stat_vec),

    .rx_stat_chk(rx_stat_chk),
    .rx_stat_base_addr(rx_stat_base_addr),
    .rx_stat_bit(rx_stat_bit),
    .rx_stat_vec(rx_stat_vec)
);

data_top data (

    .rst(rst || soft_rst),
    .clk(),
    
    .tx_con_clk(tx_con_clk),

    .up_clk(ctrl_up_clk),
    .up_wr(ctrl_up_wr && ctrl_up_cs_data),
    .up_rd(ctrl_up_rd && ctrl_up_cs_data),
    .up_addr(ctrl_up_addr),
    .up_data_wr(ctrl_up_data_wr),
    .up_data_rd(ctrl_up_data_rd_data),

    .rgmii_rxclk(rgmii_rxclk),
    .rgmii_rxden(rgmii_rxden),
    .rgmii_rxdin(rgmii_rxdin),
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

    .rx_stat_chk(rx_stat_chk),
    .rx_stat_base_addr(rx_stat_base_addr),
    .rx_stat_bit(rx_stat_bit),
    .rx_stat_vec(rx_stat_vec),
        
    .tx_active(tx_active),
    .rx_active(rx_active)

);

endmodule
