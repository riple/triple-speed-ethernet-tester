/*
 * File   : rx_pause.v
 * Date   : 20150630
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module rx_pause (
    input  wire        rst,

    input  wire [31:0] up_data_rx_ctrl,

    input  wire         in_clk,
    input  wire         in_par_en,
    input  wire [31: 0] in_data,
    input  wire         in_valid,
    input  wire         in_sop,
    input  wire         in_eop,
    input  wire [ 1: 0] in_mod,
    input  wire [31: 0] in_info,
    input  wire [63: 0] in_stat,
    input  wire [ 3: 0] in_snum,

    output reg  pause_on
);

wire par_en = in_par_en;

// get pause control info
wire [ 3:0]rx_loop_en  = up_data_rx_ctrl[27:24];  // 4 bit enable: bit0=L1, bit1=L2, bit2=L3, bit3=L4
wire       rx_dump_en  = up_data_rx_ctrl[   28];  // dump enable
wire       rx_pause_en = up_data_rx_ctrl[    5] || 1'b1;  // pause enable 

wire loop_l1 = rx_loop_en[0];                   // +1 loop enable
wire loop_l2 = rx_loop_en[0] && rx_loop_en[1];  // +2 switch mac address
wire loop_l3 = rx_loop_en[0] && rx_loop_en[2];  // +4 switch ip address
wire loop_l4 = rx_loop_en[0] && rx_loop_en[3];  // +8 switch tcp/udp port

// get packet parser info
// out_info  <= {24'd0, {bypass_tcp, bypass_udp, bypass_ipv6, bypass_ipv4}, {bypass_mpls, bypass_llc, bypass_vlan,bypass_mac}};
wire hereis_mac = in_info[0];
reg  hereis_mac_d1, hereis_mac_d2;
always @(posedge rst or posedge in_clk) begin
  if (rst) begin
    hereis_mac_d1 <= 1'b0;
    hereis_mac_d2 <= 1'b0;
  end
  else if (par_en) begin
    hereis_mac_d1 <= hereis_mac;
    hereis_mac_d2 <= hereis_mac_d1;
  end
end

reg [5:0] hereis_mac_cntr;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    hereis_mac_cntr <= 'd0;
  else if (par_en) begin
    if (in_sop && in_valid)
      hereis_mac_cntr <= 'd0;
    else if (hereis_mac || hereis_mac_d1 || hereis_mac_d2)
      hereis_mac_cntr <= hereis_mac_cntr + 'd1;
  end
end

// parse pause info
reg pause_rx;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    pause_rx <= 1'b0;
  else if (par_en) begin
    if (in_sop && in_valid)
      pause_rx <= 1'b0;
    else if (hereis_mac_cntr==6'd3 && in_data==32'h88080001)
      pause_rx <= 1'b1;
  end
end

reg [15:0] pause_time;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    pause_time <= 16'd0;
  else if (par_en && hereis_mac_d2==1'b1 && hereis_mac_cntr==6'd4 && pause_rx==1'b1)
    pause_time <= in_data[31:16];
  else if (pause_time==16'd0)
    pause_time <= pause_time;
  else
    pause_time <= pause_time - 16'd64;  // 1 quanta == 512 bit time == 64 byte time
end

// generate pause output
always @(posedge rst or posedge in_clk) begin
  if (rst)
    pause_on <= 1'b0;
  else if (pause_time == 16'd0)
    pause_on <= 1'b0;
  else
    pause_on <= rx_pause_en;
end


endmodule
