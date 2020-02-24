/*
 * File   : synchronizer_level.v
 * Date   : 20130830
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

/*

***************************************
* Declaration of the input ports      *
***************************************
clk_out: timing driver, positive edge is active.
clk_en : clock enable
reset_n: asynchronous reset_n.
sync_in: signal before synchronization.

***************************************
* Declaration of the output ports     *
***************************************
sync_out_reg2: signal after synchronization.

***************************************
* Declaration of the registers        *
***************************************
sync_out_reg1: signal registered by first DFF.
sync_out_reg2: signal registered by second DFF.

*/
`timescale 1 ns / 1 ns
module synchronizer_level (

	 clk_out
        ,clk_en
	,reset_n 
	,sync_in 
	,sync_out_reg2
	,sync_out_p1
        
        );
        
input	clk_out;
input   clk_en;
input   reset_n;
input   sync_in;
output  sync_out_reg2;
output  sync_out_p1;

reg 	sync_out_reg1;
reg 	sync_out_reg2;
reg 	sync_out_reg3;

always @(posedge clk_out or negedge reset_n)
  if(~reset_n)
    sync_out_reg1 <= 0;
  else if (clk_en)
    sync_out_reg1 <= sync_in;

always @(posedge clk_out or negedge reset_n)
  if(~reset_n)
    sync_out_reg2 <= 0;
  else if (clk_en)
    sync_out_reg2 <= sync_out_reg1;

always @(posedge clk_out or negedge reset_n)
  if(~reset_n)
    sync_out_reg3 <= 0;
  else if (clk_en)
    sync_out_reg3 <= sync_out_reg2;

assign sync_out_p1 = sync_out_reg2 & ~sync_out_reg3;


endmodule
