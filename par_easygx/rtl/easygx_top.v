/*
 * File   : easygx_top.v
 * Date   : 20140102
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns
`define USE_VJTAG_CPU_MON
module easygx_top (
    
    // sys
    input  wire clk_50M,
    input  wire clk_100M,
    input  wire clk_125M,
    input  wire ext_reset_n,
    
    // epcs flash
    output wire epcs_flash_controller_sdo,
    input  wire epcs_flash_controller_data0,
    output wire epcs_flash_controller_dclk,
    output wire epcs_flash_controller_sce,
    
    // ddr2
    inout  wire        ddr2_memory_mem_clk_n,
    inout  wire        ddr2_memory_mem_clk,
    inout  wire [ 1:0] ddr2_memory_mem_dqs,
    inout  wire [15:0] ddr2_memory_mem_dq,
    output wire [ 1:0] ddr2_memory_mem_dm,
    output wire [ 2:0] ddr2_memory_mem_ba,
    output wire [12:0] ddr2_memory_mem_addr,
    output wire        ddr2_memory_mem_cs_n,
    output wire        ddr2_memory_mem_odt,
    output wire        ddr2_memory_mem_cas_n,
    output wire        ddr2_memory_mem_we_n,
    output wire        ddr2_memory_mem_ras_n,
    output wire        ddr2_memory_mem_cke,
    
    // Triple-Speed Ethernet
    input  wire [ 3:0] tse_mac_rgmii_in,
    output wire [ 3:0] tse_mac_rgmii_out,
    input  wire        tse_mac_rx_control,
    output wire        tse_mac_tx_control,
    output wire        tse_mac_mdc,
    inout  wire        tse_mac_mdio,
    input  wire        tse_mac_rx_clk,
    output wire        tse_mac_tx_clk,
    output wire        tse_mac_resetn,
    
    // SD Card
    output wire sd_card_clk,
    output wire sd_card_cs_n,
    input  wire sd_card_data_in,
    output wire sd_card_data_out,
    
    // PCIe 
    //input  wire pcie_rx,
    //output wire pcie_tx,
    input  wire pcie_rst_n,
    
    // User IO
    output wire alive_led,
    output wire L0_led,
    output wire [3:0] led,
    input  wire button_pio
);

assign ddr2_memory_mem_clk_n = 'dz;
assign ddr2_memory_mem_clk   = 'dz;
assign ddr2_memory_mem_dqs   = 'dz;
assign ddr2_memory_mem_dq    = 'dz;
assign ddr2_memory_mem_dm    = 'dz;
assign ddr2_memory_mem_ba    = 'dz;
assign ddr2_memory_mem_addr  = 'dz;
assign ddr2_memory_mem_cs_n  = 'dz;
assign ddr2_memory_mem_odt   = 'dz;
assign ddr2_memory_mem_cas_n = 'dz;
assign ddr2_memory_mem_we_n  = 'dz;
assign ddr2_memory_mem_ras_n = 'dz;
assign ddr2_memory_mem_cke   = 'dz;

assign epcs_flash_controller_sdo  = 'dz;
assign epcs_flash_controller_dclk = 'dz;
assign epcs_flash_controller_sce  = 'dz;

assign sd_card_clk      = 'dz;
assign sd_card_cs_n     = 'dz;
assign sd_card_data_out = 'dz;

// CPU
wire up_clk;
wire up_wr, up_rd;
wire [31:0] up_addr, up_data_wr, up_data_rd;
wire up_wait;
cpu_bfm bfm_cpu (
    .up_rst(!ext_reset_n),
    .up_clk(up_clk),
    .up_wr(up_wr),
    .up_rd(up_rd),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd),
    .up_wait(up_wait)
);

`ifdef USE_VJTAG_CPU_MON
wire [31:0] up_data = up_wr? up_data_wr: up_data_rd;
up_monitor mon_cpu (
    .clk(up_clk),
    .wr_en(up_wr),
    .rd_en(up_rd),
    .addr_in(up_addr),
    .data_in(up_data)
);
`endif

// DUT
ether_top dut (
    .rst(!ext_reset_n),
    .clk(clk_50M),

    .up_clk(up_clk),
    .up_cs(1'b1),
    .up_wr(up_wr),
    .up_rd(up_rd),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd),
    .up_busy(up_wait),

    .mdio_clk(tse_mac_mdc),
    .mdio_io(tse_mac_mdio),
    
    .rgmii_txclk(tse_mac_tx_clk),
    .rgmii_txden(tse_mac_tx_control),
    .rgmii_txdout(tse_mac_rgmii_out),
    .rgmii_rxclk(tse_mac_rx_clk),
    .rgmii_rxden(tse_mac_rx_control),
    .rgmii_rxdin(tse_mac_rgmii_in),

    .phy_rst(phy_rst),
    .up_clk_out(up_clk)
);

assign tse_mac_resetn = !phy_rst;


endmodule
