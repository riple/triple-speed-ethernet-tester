/*
 * File   : ctrl_top.v
 * Date   : 20130830
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module ctrl_top (

    input  wire rst, clk,

    input  wire         up_clk,
    input  wire         up_cs,
    input  wire         up_wr,
    input  wire         up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31: 0] up_data_wr,
    output wire [31: 0] up_data_rd,
    output wire         up_busy,

    output wire         ctrl_up_clk,
    output wire         ctrl_up_cs_stat,
    output wire         ctrl_up_cs_data,
    output wire         ctrl_up_wr,
    output wire         ctrl_up_rd,
    output wire [32-1: 0] ctrl_up_addr,
    output wire [31: 0] ctrl_up_data_wr,
    input  wire [31: 0] ctrl_up_data_rd_stat,
    input  wire [31: 0] ctrl_up_data_rd_data,

    output wire         tx_con_clk,
    
    output wire         mdio_clk,
    inout  wire         mdio_io,

    output wire         soft_rst,
    output wire         phy_rst,

    output wire         phy_link_up,
    output wire         phy_giga_mode,

    output wire         stat_clk,
    output wire         stat_rst,
    input  wire         stat_rst_done,

    output wire         sys_clk,
    output wire [31: 0] sys_time

);

parameter CONST_CS_CTRL_MDIO             = 8'h00;
parameter CONST_CS_CTRL_CONTROL          = 8'h04;
parameter CONST_CS_CTRL_STATUS           = 8'h08;
parameter CONST_CS_CTRL_LINK_STATUS      = 8'h0C;
parameter CONST_CS_CTRL_CPU_RD_STAT_TIME = 8'h10;
parameter CONST_CS_CTRL_FREERUN_TIME     = 8'h14;

// PLL
wire pll_locked;
ctrl_clk clk_gen (
    .areset(rst),
    .inclk0(clk), // 25MHz
    .c0    (sys_clk ), // 100MHz
    .c1    (stat_clk), // 50MHz
    .c2    (mdio_clk), // 2.5MHz
    .c3    (tx_con_clk), // 50MHz
    .c4    (), // 25MHz
    .locked(pll_locked)
);

// CPU access all modules
wire        ctrl_up_cs_ctrl;
wire [31:0] ctrl_up_data_rd_ctrl;
ctrl_cpu cpu_agent (
    .up_clk(up_clk),
    .up_cs(up_cs),
    .up_wr(up_wr),
    .up_rd(up_rd),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd),
    .up_busy(up_busy),
    
    .ctrl_up_clk(ctrl_up_clk),
    .ctrl_up_cs_stat(ctrl_up_cs_stat),
    .ctrl_up_cs_data(ctrl_up_cs_data),
    .ctrl_up_cs_ctrl(ctrl_up_cs_ctrl),
    .ctrl_up_wr(ctrl_up_wr),
    .ctrl_up_rd(ctrl_up_rd),
    .ctrl_up_addr(ctrl_up_addr),
    .ctrl_up_data_wr(ctrl_up_data_wr),
    .ctrl_up_data_rd_stat(ctrl_up_data_rd_stat),
    .ctrl_up_data_rd_data(ctrl_up_data_rd_data),
    .ctrl_up_data_rd_ctrl(ctrl_up_data_rd_ctrl)
);

// MDIO control
wire        ctrl_up_cs_mdio = ctrl_up_cs_ctrl && ctrl_up_addr[7:2]==CONST_CS_CTRL_MDIO[7:2];  // rd 0x00000000
wire [31:0] ctrl_up_data_rd_mdio;
ctrl_mdio mdio_ctrl (
    .rst(rst),

    .up_clk    (ctrl_up_clk),
    .up_wr     (ctrl_up_wr && ctrl_up_cs_mdio),
    .up_rd     (ctrl_up_rd && ctrl_up_cs_mdio),
    .up_addr   (ctrl_up_addr),
    .up_data_wr(ctrl_up_data_wr),
    .up_data_rd(ctrl_up_data_rd_mdio),

    .mdio_clk(mdio_clk),
    .mdio_io(mdio_io)
);

// system timer
reg [31: 0] sys_timer;
assign sys_time = sys_timer;
always @(posedge rst or posedge sys_clk) begin
  if (rst)
    sys_timer <= 'd0;
  else
    sys_timer <= sys_timer + 1;
end

// CPU access ctrl_top
reg [31:0] ctrl_control_reg;  // 00000004
wire ctrl_up_cs_control = ctrl_up_cs_ctrl && ctrl_up_addr[7:2]==CONST_CS_CTRL_CONTROL[7:2];
always @(posedge ctrl_up_clk or posedge rst) begin
    if (rst)
        ctrl_control_reg <= 'd0;
    else if (ctrl_up_wr && ctrl_up_cs_ctrl && ctrl_up_addr[7:2]==CONST_CS_CTRL_CONTROL[7:2])
        ctrl_control_reg <= ctrl_up_data_wr;
end
assign soft_rst      = ctrl_control_reg[0];
assign phy_rst       = ctrl_control_reg[1];
assign stat_rst      = ctrl_control_reg[4];

reg [31:0] ctrl_status_reg;  // 00000008
wire ctrl_up_cs_status  = ctrl_up_cs_ctrl && ctrl_up_addr[7:2]==CONST_CS_CTRL_STATUS[7:2];
always @(posedge ctrl_up_clk or posedge rst) begin
    if (rst)
        ctrl_status_reg <= 'd0;
    else
        ctrl_status_reg <= {20'd0, {2'd0, phy_giga_mode, phy_link_up}, {2'd0, pll_locked, stat_rst_done}, {2'd0, phy_rst, soft_rst}};
end

reg [31:0] ctrl_link_status_reg;  // 0000000C
wire ctrl_up_cs_link_status = ctrl_up_cs_ctrl && ctrl_up_addr[7:2]==CONST_CS_CTRL_LINK_STATUS[7:2];
always @(posedge ctrl_up_clk or posedge rst) begin
    if (rst)
        ctrl_link_status_reg <= 'd0;
    else if (ctrl_up_wr && ctrl_up_cs_ctrl && ctrl_up_addr[7:2]==CONST_CS_CTRL_LINK_STATUS[7:2])
        ctrl_link_status_reg <= ctrl_up_data_wr;
end
assign phy_link_up   = ctrl_link_status_reg[0];
assign phy_giga_mode = ctrl_link_status_reg[1];

reg  [31: 0] cpu_rd_stat_time;  // 00000010
wire ctrl_up_cs_cpu_rd_stat_time = ctrl_up_cs_ctrl && ctrl_up_addr[7:2]==CONST_CS_CTRL_CPU_RD_STAT_TIME[7:2];
wire cpu_rd_stat = ctrl_up_cs_stat && ctrl_up_rd;
always @(posedge rst or posedge stat_clk) begin
  if (rst)
    cpu_rd_stat_time <= 'd0;
  else if (cpu_rd_stat)
    cpu_rd_stat_time <= sys_timer;
end

wire ctrl_up_cs_freerun_time = ctrl_up_cs_ctrl && ctrl_up_addr[7:2]==CONST_CS_CTRL_FREERUN_TIME[7:2];

// CPU read data from ctrl_top
assign ctrl_up_data_rd_ctrl = ctrl_up_cs_mdio   ? ctrl_up_data_rd_mdio: (
                              ctrl_up_cs_control? ctrl_control_reg:     (
                              ctrl_up_cs_status ? ctrl_status_reg:      (
                              ctrl_up_cs_link_status ? ctrl_link_status_reg: (
                              ctrl_up_cs_cpu_rd_stat_time? cpu_rd_stat_time: (
                              ctrl_up_cs_freerun_time ? sys_timer:
                              32'h12345678)))));

endmodule
