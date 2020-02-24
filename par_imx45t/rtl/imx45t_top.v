/*
 * File   : imx45t_top.v
 * Date   : 20150204
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns
module imx45t_top (
    
    // sys
    input  wire sys_rst_n,
    input  wire clk_125M_in_p,
    input  wire clk_125M_in_n,
    
    // Port 0

    // spi
    input  wire p0_spi_cs,
    input  wire p0_spi_clk,
    input  wire p0_spi_mosi,
    output wire p0_spi_miso,
    
    // Triple-Speed Ethernet
    input  wire [ 3:0] p0_tse_mac_rgmii_in,
    output wire [ 3:0] p0_tse_mac_rgmii_out,
    input  wire        p0_tse_mac_rx_control,
    output wire        p0_tse_mac_tx_control,
    output wire        p0_tse_mac_mdc,
    inout  wire        p0_tse_mac_mdio,
    input  wire        p0_tse_mac_rx_clk,
    output wire        p0_tse_mac_tx_clk,
    output wire        p0_tse_mac_resetn,

    // debug
    output wire        p0_phy_led_rx,
    output wire        p0_phy_led_tx,

    // Port 1

    // spi
    input  wire p1_spi_cs,
    input  wire p1_spi_clk,
    input  wire p1_spi_mosi,
    output wire p1_spi_miso,
    
    // Triple-Speed Ethernet
    input  wire [ 3:0] p1_tse_mac_rgmii_in,
    output wire [ 3:0] p1_tse_mac_rgmii_out,
    input  wire        p1_tse_mac_rx_control,
    output wire        p1_tse_mac_tx_control,
    output wire        p1_tse_mac_mdc,
    inout  wire        p1_tse_mac_mdio,
    input  wire        p1_tse_mac_rx_clk,
    output wire        p1_tse_mac_tx_clk,
    output wire        p1_tse_mac_resetn,

    // debug
    output wire        p1_phy_led_rx,
    output wire        p1_phy_led_tx
);

// clock input and reset input
wire rst_n;
wire clk_125M;
`ifdef XILINX_SPARTAN6
IBUFDS refclk_ibuf (.O(clk_125M), .I(clk_125M_in_p), .IB(clk_125M_in_n));
IBUF sys_reset_n_ibuf (.O(rst_n), .I(sys_rst_n));
`endif


// CPU
wire up_clk_p0, up_clk_p1;
wire up_cs_p0, up_cs_p1;
wire up_wr_p0, up_wr_p1;
wire up_rd_p0, up_rd_p1;
wire [31:0] up_addr_p0, up_addr_p1;
wire [31:0] up_data_wr_p0, up_data_wr_p1;
wire [31:0] up_data_rd_p0, up_data_rd_p1;
wire up_wait_p0, up_wait_p1;

wire up_clk;
wire up_wr, up_rd;
wire [31:0] up_addr;
wire up_cs = up_addr[31]? 1'b0:1'b1;
wire [31:0] up_data_wr;
wire [31:0] up_data_rd;
wire up_wait;

assign up_clk = up_clk_p0;
assign up_data_rd = up_cs? up_data_rd_p0: up_data_rd_p1;
assign up_wait = up_cs? up_wait_p0: up_wait_p1;

`ifdef USE_SPI_CPU_BFM
// SPI CPU
`ifdef USE_PORT0
cpu_bfm_usbspi bfm_cpu_p0 (
    .spi_cs  (p0_spi_cs),
    .spi_clk (p0_spi_clk),
    .spi_mosi(p0_spi_mosi),
    .spi_miso(p0_spi_miso),

    .up_clk    (up_clk_p0),
    .up_addr   (up_addr_p0),
    .up_wr     (up_wr_p0),
    .up_rd     (up_rd_p0),
    .up_data_wr(up_data_wr_p0),
    .up_data_rd(up_data_rd_p0)
);
assign up_cs_p0 = 1'b1;
`else
assign p0_spi_miso = 1'bz;
`endif
`ifdef USE_PORT1
cpu_bfm_usbspi bfm_cpu_p1 (
    .spi_cs  (p1_spi_cs),
    .spi_clk (p1_spi_clk),
    .spi_mosi(p1_spi_mosi),
    .spi_miso(p1_spi_miso),

    .up_clk    (up_clk_p1),
    .up_addr   (up_addr_p1),
    .up_wr     (up_wr_p1),
    .up_rd     (up_rd_p1),
    .up_data_wr(up_data_wr_p1),
    .up_data_rd(up_data_rd_p1)
);
assign up_cs_p1 = 1'b1;
`else
assign p1_spi_miso = 1'bz;
`endif
`else
assign p0_spi_miso = 1'bz;
assign p1_spi_miso = 1'bz;
`endif
`ifdef USE_VJTAG_CPU_BFM
// JTAG CPU
cpu_bfm_vjtag bfm_cpu (
    .up_rst(1'b0),
    .up_clk(up_clk),
    .up_wr(up_wr),
    .up_rd(up_rd),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd),
    .up_wait(up_wait)
);
assign {up_cs_p0, up_cs_p1} = {up_cs, !up_cs};
assign {up_wr_p0, up_wr_p1} = {up_wr, up_wr};
assign {up_rd_p0, up_rd_p1} = {up_rd, up_rd};
assign {up_addr_p0, up_addr_p1} = {{1'b0, up_addr[30:0]}, {1'b0, up_addr[30:0]}};
assign {up_data_wr_p0, up_data_wr_p1} = {up_data_wr, up_data_wr};
`endif

`ifdef USE_VJTAG_CPU_MON
// CPU Monitor
wire [31:0] up_data_p0 = up_wr_p0? up_data_wr_p0: up_data_rd_p0;
up_monitor mon_cpu (
    .clk(up_clk),
    .wr_en(up_wr_p0),
    .rd_en(up_rd_p0),
    .addr_in(up_addr_p0),
    .data_in(up_data_p0)
);
`endif

// DUT Port 0
`ifdef USE_PORT0
wire p0_phy_rst;
wire p0_tse_mac_mdc_int;
wire [3:0] p0_debug_led;
ether_top dut_p0 (
    .rst(1'b0),
    .clk(clk_125M),

    .up_clk(up_clk_p0),
    .up_cs(up_cs_p0),
    .up_wr(up_wr_p0),
    .up_rd(up_rd_p0),
    .up_addr(up_addr_p0),
    .up_data_wr(up_data_wr_p0),
    .up_data_rd(up_data_rd_p0),
    .up_busy(up_wait_p0),

    .mdio_clk(p0_tse_mac_mdc_int),
    .mdio_io(p0_tse_mac_mdio),
    
    .rgmii_txclk(p0_tse_mac_tx_clk),
    .rgmii_txden(p0_tse_mac_tx_control),
    .rgmii_txdout(p0_tse_mac_rgmii_out),
    .rgmii_rxclk(p0_tse_mac_rx_clk),
    .rgmii_rxden(p0_tse_mac_rx_control),
    .rgmii_rxdin({p0_tse_mac_rgmii_in[3],p0_tse_mac_rgmii_in[2],p0_tse_mac_rgmii_in[1],p0_tse_mac_rgmii_in[0]}),

    .phy_rst(p0_phy_rst),
    .up_clk_out(up_clk_p0),
    .debug_led(p0_debug_led)
);

assign p0_tse_mac_resetn = !p0_phy_rst;
`else
assign up_data_rd_p0 = 'd0;
assign up_wait_p0 = 1'b0;
assign p0_tse_mac_tx_clk = 1'b0;
assign p0_tse_mac_tx_control = 1'b0;
assign p0_tse_mac_rgmii_out = 'd0;
assign p0_phy_rst = 1'b1;
assign up_clk_p0 = 1'b0;
assign p0_tse_mac_mdc_int = 1'b0;
assign p0_tse_mac_mdio = 1'bz;
assign p0_tse_mac_resetn = 1'b1;
`endif

// clock output
`ifdef XILINX_ZYNQ
ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
    .INIT(1'b0), // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC"
) ODDR_p0 (
    .Q(p0_tse_mac_mdc), // 1-bit DDR output
    .C(p0_tse_mac_mdc_int), // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D1(1'b1), // 1-bit data input (positive edge)
    .D2(1'b0), // 1-bit data input (negative edge)
    .R(1'b0), // 1-bit reset
    .S(1'b0) // 1-bit set
);
`endif
`ifdef XILINX_SPARTAN6
ODDR2 #(
    .DDR_ALIGNMENT("C0"), // Sets output alignment to "NONE", "C0" or "C1"
    .INIT(1'b0), // Sets initial state of the Q output to 1'b0 or 1'b1
    .SRTYPE("ASYNC") // Specifies "SYNC" or "ASYNC" set/reset
) ODDR2_p0 (
    .Q(p0_tse_mac_mdc), // 1-bit DDR output data
    .C0(p0_tse_mac_mdc_int), // 1-bit clock input
    .C1(!p0_tse_mac_mdc_int), // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D0(1'b1), // 1-bit data input (associated with C0)
    .D1(1'b0), // 1-bit data input (associated with C1)
    .R(1'b0), // 1-bit reset input
    .S(1'b0) // 1-bit set input
);
`endif

// DUT Port 1
`ifdef USE_PORT1
wire p1_phy_rst;
wire p1_tse_mac_mdc_int;
wire [3:0] p1_debug_led;
ether_top dut_p1 (
    .rst(1'b0),
    .clk(clk_125M),

    .up_clk(up_clk_p1),
    .up_cs(up_cs_p1),
    .up_wr(up_wr_p1),
    .up_rd(up_rd_p1),
    .up_addr(up_addr_p1),
    .up_data_wr(up_data_wr_p1),
    .up_data_rd(up_data_rd_p1),
    .up_busy(up_wait_p1),

    .mdio_clk(p1_tse_mac_mdc_int),
    .mdio_io(p1_tse_mac_mdio),
    
    .rgmii_txclk(p1_tse_mac_tx_clk),
    .rgmii_txden(p1_tse_mac_tx_control),
    .rgmii_txdout(p1_tse_mac_rgmii_out),
    .rgmii_rxclk(p1_tse_mac_rx_clk),
    .rgmii_rxden(p1_tse_mac_rx_control),
    .rgmii_rxdin({p1_tse_mac_rgmii_in[3],p1_tse_mac_rgmii_in[2],p1_tse_mac_rgmii_in[1],p1_tse_mac_rgmii_in[0]}),

    .phy_rst(p1_phy_rst),
    .up_clk_out(up_clk_p1),
    .debug_led(p1_debug_led)
);

assign p1_tse_mac_resetn = !p1_phy_rst;
`else
assign up_data_rd_p1 = 'd0;
assign up_wait_p1 = 1'b0;
assign p1_tse_mac_tx_clk = 1'b0;
assign p1_tse_mac_tx_control = 1'b0;
assign p1_tse_mac_rgmii_out = 'd0;
assign p1_phy_rst = 1'b1;
assign up_clk_p1 = 1'b0;
assign p1_tse_mac_mdc_int = 1'b0;
assign p1_tse_mac_mdio = 1'bz;
assign p1_tse_mac_resetn = 1'b1;
`endif

// clock output
`ifdef XILINX_ZYNQ
ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
    .INIT(1'b0), // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC"
) ODDR_p1 (
    .Q(p1_tse_mac_mdc), // 1-bit DDR output
    .C(p1_tse_mac_mdc_int), // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D1(1'b1), // 1-bit data input (positive edge)
    .D2(1'b0), // 1-bit data input (negative edge)
    .R(1'b0), // 1-bit reset
    .S(1'b0) // 1-bit set
);
`endif
`ifdef XILINX_SPARTAN6
ODDR2 #(
    .DDR_ALIGNMENT("C0"), // Sets output alignment to "NONE", "C0" or "C1"
    .INIT(1'b0), // Sets initial state of the Q output to 1'b0 or 1'b1
    .SRTYPE("ASYNC") // Specifies "SYNC" or "ASYNC" set/reset
) ODDR2_p1 (
    .Q(p1_tse_mac_mdc), // 1-bit DDR output data
    .C0(p1_tse_mac_mdc_int), // 1-bit clock input
    .C1(!p1_tse_mac_mdc_int), // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D0(1'b1), // 1-bit data input (associated with C0)
    .D1(1'b0), // 1-bit data input (associated with C1)
    .R(1'b0), // 1-bit reset input
    .S(1'b0) // 1-bit set input
);
`endif


// Debug
parameter debug_counter_width = 28;
parameter toggle_bit_index = debug_counter_width - 3;
reg [debug_counter_width-1:0] debug_counter;
always @(posedge clk_125M) debug_counter <= debug_counter + 1;

`ifdef USE_PORT0
reg p0_phy_active_tx, p0_phy_active_rx;
always @(posedge clk_125M) begin
    if (debug_counter[toggle_bit_index] && debug_counter[toggle_bit_index-1]) begin
        if (p0_debug_led[1])
            p0_phy_active_tx <= 1'b1;
        if (p0_debug_led[0])
            p0_phy_active_rx <= 1'b1;
    end
    else if (!debug_counter[toggle_bit_index] && debug_counter[toggle_bit_index-1]) begin
            p0_phy_active_tx <= 1'b0;
            p0_phy_active_rx <= 1'b0;
    end
end
assign {p0_phy_led_rx, p0_phy_led_tx} = {(!p0_phy_active_rx ^ p0_debug_led[3]), (!p0_phy_active_tx ^ p0_debug_led[2])};//{debug_counter[26], rst_n};//
`else
assign {p0_phy_led_rx, p0_phy_led_tx} = {debug_counter[toggle_bit_index], rst_n};
`endif

`ifdef USE_PORT1
reg p1_phy_active_tx, p1_phy_active_rx;
always @(posedge clk_125M) begin
    if (debug_counter[toggle_bit_index] && debug_counter[toggle_bit_index-1]) begin
        if (p1_debug_led[1])
            p1_phy_active_tx <= 1'b1;
        if (p1_debug_led[0])
            p1_phy_active_rx <= 1'b1;
    end
    else if (!debug_counter[toggle_bit_index] && debug_counter[toggle_bit_index-1]) begin
            p1_phy_active_tx <= 1'b0;
            p1_phy_active_rx <= 1'b0;
    end
end
assign {p1_phy_led_rx, p1_phy_led_tx} = {(!p1_phy_active_rx ^ p1_debug_led[3]), (!p1_phy_active_tx ^ p1_debug_led[2])};//{debug_counter[26], rst_n};//
`else
assign {p1_phy_led_rx, p1_phy_led_tx} = {debug_counter[toggle_bit_index], rst_n};
`endif

endmodule
