//**************************************************************
// Module             : chipscope_vio_adda_stat.v
// Platform           : Ubuntu 12.04 
// Simulator          : Modelsim 6.5b
// Synthesizer        : PlanAhead 14.2
// Place and Route    : PlanAhead 14.2
// Targets device     : Zynq-7000
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.3 
// Date               : 2012/11/19
// Description        : addr/data capture output to debug host
//                      via Virtual JTAG.
//**************************************************************

`timescale 1ns/1ns

module chipscope_vio_adda_stat(adda_out, stat_in, clk, icon_ctrl);

parameter adda_width  = 4+32+32;
parameter stat_width  = 4+32+32;

output [adda_width-1:0] adda_out;
input  [stat_width-1:0] stat_in;

input clk;
inout [35:0] icon_ctrl;

wire [adda_width-1:0] adda_vi;
wire [stat_width-1:0] stat_vo;

reg  [adda_width-1:0] adda_out;
always @(posedge clk) begin
  adda_out <= adda_vi;
end
assign stat_vo = stat_in;

chipscope_vio VIO_inst (
  .CONTROL(icon_ctrl), // INOUT BUS [35:0]
  .CLK(clk), // IN
  .SYNC_OUT(adda_vi), // OUT BUS [1:0]
  .SYNC_IN(stat_vo) // IN BUS [107:0]
);

endmodule
