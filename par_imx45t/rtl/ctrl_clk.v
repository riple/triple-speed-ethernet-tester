/*
 * File   : imx45t_top.v
 * Date   : 20150204
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns

module ctrl_clk (
	areset,
	inclk0,
	c0,
	c1,
	c2,
	c3,
	c4,
	locked);

	input	  areset;
	input	  inclk0;
	output	  c0;
	output	  c1;
	output	  c2;
	output	  c3;
	output	  c4;
	output	  locked;

clk_wiz_v3_6 clk_gen (
    .RESET    (areset),
    .CLK_IN1  (inclk0), // 25MHz
    .CLK_OUT1 (c0 ), // 100MHz
    .CLK_OUT2 (c1), // 50MHz
    .CLK_OUT3 (c2), // 2.5MHz
    .CLK_OUT4 (c3), // 50MHz
    .CLK_OUT5 (c4), // 25MHz
    .LOCKED(locked)
);

endmodule
