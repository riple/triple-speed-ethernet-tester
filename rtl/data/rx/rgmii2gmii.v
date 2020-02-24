/*
 * File   : rgmii2gmii.v
 * Date   : 20130816
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module rgmii2gmii (

    input  wire         rgmii_clk,
    input  wire         rgmii_den,
    input  wire [ 3: 0] rgmii_din,
    input  wire         phy_link_up,

    output wire         gmii_clk, 
    output reg          gmii_den,
    output reg  [ 7: 0] gmii_din,
    output reg          gmii_crs
);

// DDR[3:0] to SDR[3:0]
wire [4:0] gmii_dhi, gmii_dlo;
`ifdef XILINX_ZYNC
wire [4:0] rgmii_in = {rgmii_den,rgmii_din};
generate
genvar i;
for (i=0; i<5; i=i+1) begin: IDDR_loop
IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_PIPELINED"
    .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
    .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
    .SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC"
) IDDR_inst (
    .Q1(gmii_dhi[i]), // 1-bit output for positive edge of clock
    .Q2(gmii_dlo[i]), // 1-bit output for negative edge of clock
    .C(rgmii_clk), // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D(rgmii_in[i]), // 1-bit DDR data input
    .R(1'b0), // 1-bit reset
    .S(1'b0) // 1-bit set
);
end
endgenerate
`endif
`ifdef XILINX_SPARTAN6
wire [4:0] rgmii_in = {rgmii_den,rgmii_din};
generate
genvar i;
for (i=0; i<5; i=i+1) begin: IDDR_loop
IDDR2 #(
    .DDR_ALIGNMENT("C1"), // Sets output alignment to "NONE", "C0" or "C1"
    .INIT_Q0(1'b0), // Sets initial state of the Q0 output to 1'b0 or 1'b1
    .INIT_Q1(1'b0), // Sets initial state of the Q1 output to 1'b0 or 1'b1
    .SRTYPE("ASYNC") // Specifies "SYNC" or "ASYNC" set/reset
) IDDR2_inst (
    .Q0(gmii_dhi[i]), // 1-bit output captured with C0 clock
    .Q1(gmii_dlo[i]), // 1-bit output captured with C1 clock
    .C0(rgmii_clk), // 1-bit clock input
    .C1(!rgmii_clk), // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D(rgmii_in[i]), // 1-bit DDR data input
    .R(1'b0), // 1-bit reset input
    .S(1'b0) // 1-bit set input
);
end
endgenerate
`endif
`ifdef ALTERA
altddio_in  altddio_in_component (
    .datain    ({rgmii_den,rgmii_din}),
    .inclock   (rgmii_clk),
    .dataout_h (gmii_dhi),
    .dataout_l (gmii_dlo),
    .aclr      (1'b0),
    .aset      (1'b0),
    .inclocken (1'b1),
    .sclr      (1'b0),
    .sset      (1'b0));
defparam
    altddio_in_component.intended_device_family = "Cyclone IV",
    altddio_in_component.invert_input_clocks = "ON",
    altddio_in_component.lpm_type = "altddio_in",
    altddio_in_component.power_up_high = "OFF",
    altddio_in_component.width = 5;
`endif

// SDR[3:0] to SDR[7:0]
always @ (posedge rgmii_clk) begin
    gmii_den <= (gmii_dhi[  4] && gmii_dlo[  4]) && phy_link_up;
    gmii_din <= {gmii_dhi[3:0],   gmii_dlo[3:0]};
end

// using rgmii_clk as gmii_clk
assign gmii_clk = rgmii_clk;

// TODO: CRS decoding
/*
`define CARRIER_SENSE_CODE (({gmii_dhi[3:0],gmii_dlo[3:0]} == 8'hff) || ({gmii_dhi[3:0],gmii_dlo[3:0]} == 8'h0E))
reg gmii_rxdv, gmii_rxerr, gmii_rxdv_pre;
reg gmii_idle_err;
reg gmii_idle_crs;

always @ (posedge rgmii_clk) begin
    gmii_rxdv_pre = gmii_rxdv;
    gmii_rxdv     = gmii_dhi[4];
    gmii_rxerr    = gmii_dlo[4];
    gmii_idle_err = !gmii_rxdv_pre & !gmii_rxdv &  gmii_rxerr;
    gmii_idle_crs =  gmii_idle_err & `CARRIER_SENSE_CODE;
end
*/
endmodule
