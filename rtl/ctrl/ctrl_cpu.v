/*
 * File   : ctrl_cpu.v
 * Date   : 20130923
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module ctrl_cpu (

    input  wire         up_clk,
    input  wire         up_cs,
    input  wire         up_wr,
    input  wire         up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31: 0] up_data_wr,
    output wire [31: 0] up_data_rd,
    output wire         up_busy,

    output wire         ctrl_up_clk,
    output reg          ctrl_up_cs_stat,
    output reg          ctrl_up_cs_data,
    output reg          ctrl_up_cs_ctrl,
    output reg          ctrl_up_wr,
    output reg          ctrl_up_rd,
    output reg  [32-1: 0] ctrl_up_addr,
    output reg  [31: 0] ctrl_up_data_wr,
    input  wire [31: 0] ctrl_up_data_rd_stat,
    input  wire [31: 0] ctrl_up_data_rd_data,
    input  wire [31: 0] ctrl_up_data_rd_ctrl
);

parameter CONST_CS_CTRL = 8'h00;
parameter CONST_CS_DATA = 8'h04;
parameter CONST_CS_STAT = 8'h08;
parameter CONST_CS_XXXX = 8'h0c;

wire ctrl_up_cs_ctrl_int = (up_cs && up_addr[32-2:32-8]==CONST_CS_CTRL[6:0])? 1'b1: 1'b0;  // rd 00xx_xxxx
wire ctrl_up_cs_data_int = (up_cs && up_addr[32-2:32-8]==CONST_CS_DATA[6:0])? 1'b1: 1'b0;  // rd 04xx_xxxx
wire ctrl_up_cs_stat_int = (up_cs && up_addr[32-2:32-8]==CONST_CS_STAT[6:0])? 1'b1: 1'b0;  // rd 08xx_xxxx

assign ctrl_up_clk = up_clk;

always @(posedge up_clk) begin
  if (up_wr || up_rd) begin
    ctrl_up_addr    <= up_addr;
    ctrl_up_cs_ctrl <= ctrl_up_cs_ctrl_int;
    ctrl_up_cs_data <= ctrl_up_cs_data_int;
    ctrl_up_cs_stat <= ctrl_up_cs_stat_int;
  end
end

always @(posedge up_clk) begin
  ctrl_up_wr      <= up_wr;
  ctrl_up_rd      <= up_rd;
  ctrl_up_data_wr <= up_data_wr;
end

assign up_data_rd =  ctrl_up_cs_ctrl? ctrl_up_data_rd_ctrl:
                    (ctrl_up_cs_data? ctrl_up_data_rd_data:
                    (ctrl_up_cs_stat? ctrl_up_data_rd_stat: 32'hdeadbeef));
    

assign up_busy = 1'b0;

endmodule

