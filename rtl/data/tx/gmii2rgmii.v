/*
 * File   : gmii2rgmii.v
 * Date   : 20131017
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module gmii2rgmii (

    input  wire         gmii_clk, 
    input  wire         gmii_den,
    input  wire [ 7: 0] gmii_dout,
	 
    output wire         rgmii_clk,
    output wire         rgmii_den,
    output wire [ 3: 0] rgmii_dout

);

// SDR to DDR
wire [5:0] dataout;
`ifdef XILINX_ZYNQ
wire [5:0] gmii_hi = {1'b1, gmii_den, gmii_dout[7:4]};
wire [5:0] gmii_lo = {1'b0, gmii_den, gmii_dout[3:0]};
generate
genvar i;
for (i=0; i<6; i=i+1) begin: ODDR_loop
ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
    .INIT(1'b0), // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC"
) ODDR_inst (
    .Q(dataout[i]), // 1-bit DDR output
    .C(gmii_clk), // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D1(gmii_hi[i]), // 1-bit data input (positive edge)
    .D2(gmii_lo[i]), // 1-bit data input (negative edge)
    .R(1'b0), // 1-bit reset
    .S(1'b0) // 1-bit set
);
end
endgenerate
`endif
`ifdef XILINX_SPARTAN6
wire [5:0] gmii_hi = {1'b1, gmii_den, gmii_dout[7:4]};
wire [5:0] gmii_lo = {1'b0, gmii_den, gmii_dout[3:0]};
generate
genvar i;
for (i=0; i<6; i=i+1) begin: ODDR_loop
ODDR2 #(
    .DDR_ALIGNMENT("C0"), // Sets output alignment to "NONE", "C0" or "C1"
    .INIT(1'b0), // Sets initial state of the Q output to 1'b0 or 1'b1
    .SRTYPE("ASYNC") // Specifies "SYNC" or "ASYNC" set/reset
) ODDR2_inst (
    .Q(dataout[i]), // 1-bit DDR output data
    .C0(gmii_clk), // 1-bit clock input
    .C1(!gmii_clk), // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D0(gmii_hi[i]), // 1-bit data input (associated with C0)
    .D1(gmii_lo[i]), // 1-bit data input (associated with C1)
    .R(1'b0), // 1-bit reset input
    .S(1'b0) // 1-bit set input
);
end
endgenerate
`endif
`ifdef ALTERA
altddio_out	altddio_out_component (
			.datain_h ({1'b1, gmii_den, gmii_dout[7:4]}),
			.datain_l ({1'b0, gmii_den, gmii_dout[3:0]}),
			.outclock (gmii_clk),
			.dataout (dataout),
			.aclr (1'b0),
			.aset (1'b0),
			.oe (1'b1),
			.oe_out (),
			.outclocken (1'b1),
			.sclr (1'b0),
			.sset (1'b0));
defparam
	altddio_out_component.extend_oe_disable = "OFF",
	altddio_out_component.intended_device_family = "Cyclone IV",
	altddio_out_component.invert_output = "OFF",
	altddio_out_component.lpm_hint = "UNUSED",
	altddio_out_component.lpm_type = "altddio_out",
	altddio_out_component.oe_reg = "UNREGISTERED",
	altddio_out_component.power_up_high = "OFF",
	altddio_out_component.width = 6;
`endif

// DDR output
assign rgmii_clk  = dataout[  5];
assign rgmii_den  = dataout[  4];
assign rgmii_dout = dataout[3:0];

endmodule
