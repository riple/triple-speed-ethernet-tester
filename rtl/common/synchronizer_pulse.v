/*
 * File   : synchronizer_pulse.v
 * Date   : 20130830
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

/*

***************************************
* Declaration of the input ports      *
***************************************
clk_in: source clock domain.
clk_out: destination clock domain.
reset_n: asynchronous reset_n.
sync_in: signal before synchronization.

***************************************
* Declaration of the output ports     *
***************************************
sync_out_p1: pulse signal built by Sync_out_reg2 after it is valid.
sync_out_p2: pulse signal built by Sync_out_reg2 before it is invalid.
sync_out_reg2: signal after synchronization.

*/

`timescale 1 ns / 1 ns
module synchronizer_pulse (

        clk_in
       ,clk_out
       ,reset_n
       ,sync_in
       ,sync_out_p1
       ,sync_out_p2
       ,sync_out_reg2
       
       );
       
input	clk_in;
input	clk_out;
input   reset_n;
input   sync_in;
output  sync_out_p1;
output  sync_out_p2;
output  sync_out_reg2;

wire	sync_out_p1;
wire	sync_out_p2;

reg	sync_out_reg2;
   	
reg	sync_in_reg1;
reg	sync_in_reg2;
reg	sync_out_reg1;
reg	sync_out_reg3;
reg	sync_fb_reg1;
reg	sync_fb_reg2;
reg	sync_fb_reg3;

wire	sync_in_d2_se;
wire	sync_in_d2;

//signal sync_in registered by DFF in source clock domain.
always @(posedge clk_in or negedge reset_n)
  if(!reset_n)
    sync_in_reg1 <= 1'b0;
  else
    sync_in_reg1 <= sync_in;

//signal sync_in_d2 registered by DFF in source clock domain.    
always @(posedge clk_in or negedge reset_n)
  if(!reset_n)
    sync_in_reg2 <= 1'b0;
  else
    sync_in_reg2 <= sync_in_d2;

//signal sync_in_reg2 registered by DFF in destination clock domain.    
always @(posedge clk_out or negedge reset_n)
  if(!reset_n)
    sync_out_reg1 <= 1'b0;
  else
    sync_out_reg1 <= sync_in_reg2;

//signal sync_out_reg1 registered by DFF in destination clock domain.
always @(posedge clk_out or negedge reset_n)
  if(!reset_n)
    sync_out_reg2 <= 1'b0;
  else 
    sync_out_reg2 <= sync_out_reg1;

//signal sync_out_reg2 registered by DFF in destination clock domain.
always @(posedge clk_out or negedge reset_n)
  if(!reset_n)
    sync_out_reg3 <= 1'b0;
  else
    sync_out_reg3 <= sync_out_reg2;

//signal sync_out_reg2 registered by DFF in source clock domain.    
always @(posedge clk_in or negedge reset_n)
  if(!reset_n)
    sync_fb_reg1 <= 1'b0;
  else
    sync_fb_reg1 <= sync_out_reg2;

//signal sync_fb_reg1 registered by DFF in source clock domain.
always @(posedge clk_in or negedge reset_n)
  if(!reset_n)
    sync_fb_reg2 <= 1'b0;
  else
    sync_fb_reg2 <= sync_fb_reg1;

//signal sync_fb_reg2 registered by DFF in source clock domain.
always @(posedge clk_in or negedge reset_n)
  if(!reset_n)
    sync_fb_reg3 <= 1'b0;
  else
    sync_fb_reg3 <= sync_fb_reg2;

//select signal of sync_in_d2  
assign sync_in_d2_se = sync_fb_reg2 & ~sync_fb_reg3;

//signal sync_in_d2 uses to lock signal before synchronized and to release signal after synchronized 
assign sync_in_d2 = sync_in_d2_se ? 1'b0 : (sync_in_reg1 | sync_in_reg2);

assign sync_out_p1 = sync_out_reg2 & ~sync_out_reg3;

assign sync_out_p2 = sync_out_reg3 & ~sync_out_reg2;

endmodule
