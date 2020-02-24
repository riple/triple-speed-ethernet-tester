/*
 * File   : top_bench.v
 * Date   : 20130816
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module top_bench();

// CLK
reg clk_sys;
initial
begin
    clk_sys=1'b0;
    `ifdef XILINX_SPARTAN6
    forever begin
        #4 clk_sys=~clk_sys;
    end
    `endif
    `ifdef ALTERA
    forever begin
        #20 clk_sys=~clk_sys;
    end
    `endif
end

// RST
reg rst;
initial
begin
    rst=1'b1;
    #200;
    rst=1'b0;
end

// MAIN
initial                                                
begin                                             
    $display("Testbench running!");
end

// CPU
wire up_clk;
wire up_wr, up_rd;
wire [31:0] up_addr, up_data_wr, up_data_rd;
cpu_bfm bfm_cpu (
    .up_clk(up_clk),
    .up_cs(),
    .up_wr(up_wr),
    .up_rd(up_rd),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd)
);

// PHY MDIO
wire MDIO;
wire MDC;
phy_mdio_bfm bfm_mdio (
    .mdc(MDC),
    .mdio(MDIO)
);

// PHY RGMII
wire       RxClk;
wire       RxDv;
wire [3:0] RxData;
wire       TxClk;
wire       TxEn;
wire [3:0] TxData;
phy_rgmii_bfm bfm_rgmii (
    .RxClk(RxClk),
    .RxDv(RxDv),
    .RxData(RxData),
    .TxClk(TxClk),
    .TxEn(TxEn),
    .TxData(TxData)
);

wire [3:0] debug_led;

// DUT
ether_top dut (
    .rst(rst),
    .clk(clk_sys),

    .up_clk(up_clk),
    .up_cs(1'b1),
    .up_wr(up_wr),
    .up_rd(up_rd),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd),
    .up_busy(),

    .mdio_clk(MDC),
    .mdio_io(MDIO),
        
        
    .rgmii_txclk(TxClk),
    .rgmii_txden(TxEn),
    .rgmii_txdout(TxData),
    .rgmii_rxclk(RxClk),
    .rgmii_rxden(RxDv),
    .rgmii_rxdin(RxData),
    
    .phy_rst(),
    .up_clk_out(up_clk),
        
    .debug_led(debug_led)
);

// Debug
reg [27:0] debug_counter;
always @(posedge rst or posedge clk_sys) if (rst) debug_counter <= 'd0; else debug_counter <= debug_counter + 1;

reg phy_active_tx, phy_active_rx;
always @(posedge clk_sys) begin
    if (debug_counter[10] && debug_counter[9]) begin
        if (debug_led[1])
            phy_active_tx <= 1'b1;
        if (debug_led[0])
            phy_active_rx <= 1'b1;
    end
    else if (!debug_counter[10] && debug_counter[9]) begin
            phy_active_tx <= 1'b0;
            phy_active_rx <= 1'b0;
    end
end

wire phy_led_rx, phy_led_tx;
assign {phy_led_rx, phy_led_tx} = {(!phy_active_rx ^ debug_led[3]), (!phy_active_tx ^ debug_led[2])};//{debug_counter[26], rst_n};//

endmodule

