/*
 * File   : data_rx.v
 * Date   : 20130816
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module data_rx (

    input  wire         rst,
    input  wire         clk,

    input  wire           up_clk,
    input  wire           up_wr,
    input  wire           up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31  : 0] up_data_wr,
    output wire [31  : 0] up_data_rd,

    input  wire         rgmii_rxclk,
    input  wire         rgmii_rxden,
    input  wire [ 3: 0] rgmii_rxdin,

    input  wire         sys_clk,
    input  wire [31: 0] sys_time,
    input  wire         phy_link_up,
    input  wire         phy_giga_mode,
    
    output wire         rx_stat_chk,
    output wire [ 3: 0] rx_stat_base_addr,
    output wire [63: 0] rx_stat_bit,
    output wire[575: 0] rx_stat_vec,

    input  wire        lpbk_out_clk,
    input  wire        lpbk_gen_en,
    input  wire        lpbk_info_rqst,
    output wire        lpbk_info_vald,
    output wire [31:0] lpbk_info_data,
    input  wire        lpbk_buff_rden,
    input  wire [11:0] lpbk_buff_rdad,
    output wire [31:0] lpbk_buff_rdda,

    output wire         pause_on,
    
    output wire         rx_active

);

// CPU access
wire up_cs_rx_parser = (up_addr[16]==1'b0)? 1'b1: 1'b0;  // rd 0402xxxx
wire up_cs_rx_dumper = (up_addr[16]==1'b1)? 1'b1: 1'b0;  // rd 0403xxxx

wire [31:0] up_data_rd_rx_parser;
wire [31:0] up_data_rd_rx_dumper;

assign up_data_rd = up_cs_rx_parser? up_data_rd_rx_parser: (
                    up_cs_rx_dumper? up_data_rd_rx_dumper: 
                                     32'hdeadbeef          );

// rgmii to gmii converter
wire       gmii_clk;
wire       gmii_ctrl;
wire [7:0] gmii_data;
rgmii2gmii rgmii2gmii_inst(
  .rgmii_clk(rgmii_rxclk),
  .rgmii_den(rgmii_rxden),
  .rgmii_din(rgmii_rxdin),
  .phy_link_up(phy_link_up),
  
  .gmii_clk(gmii_clk), 
  .gmii_den(gmii_ctrl),
  .gmii_din(gmii_data),
  .gmii_crs()
);

// 8bit to 32bit gearbox
wire         par_en;
wire [31: 0] int_data;
wire         int_valid;
wire         int_sop;
wire         int_eop;
wire [ 1: 0] int_mod;
rx_gearbox rx_gearbox_inst(
  .rst(rst),
  
  .phy_giga_mode(phy_giga_mode),

  .gmii_clk(gmii_clk), 
  .gmii_ctrl(gmii_ctrl),
  .gmii_data(gmii_data),

  .par_en(par_en),

  .int_data_o(int_data),
  .int_valid_o(int_valid),
  .int_sop_o(int_sop),
  .int_eop_o(int_eop),
  .int_mod_o(int_mod)
);

// rx timestamp
wire int_sop_cdc;
synchronizer_pulse rx_rscv_time_sync (
    .clk_in(gmii_clk),
    .clk_out(sys_clk),
    .reset_n(!rst),
    .sync_in(int_sop && int_valid),

    .sync_out_p1(int_sop_cdc),
    .sync_out_p2(),
    .sync_out_reg2()
);

reg [31:0] sys_time_rx;
always @(posedge rst or posedge sys_clk) begin
  if (rst)
    sys_time_rx <= 'd0;
  else if (int_sop_cdc)
    sys_time_rx <= sys_time;
end

// rx packet parser
// works at 1/4 gmii_clk frequency, needs multicycle timing constraint
// TODO: use PLL to generate 1/4 gmii_clk. To be discussed. PLL cannot accept tri-speed gmii_clk as input,
wire         out_clk = gmii_clk;
wire         out_par_en = par_en;
wire [31: 0] out_data;
wire         out_valid;
wire         out_sop;
wire         out_eop;
wire [ 1: 0] out_mod;
wire [31: 0] out_info;
wire [63: 0] out_stat;
wire [ 3: 0] out_snum;

wire [31:0] up_data_rx_ctrl;
rx_parser rx_parser_inst(
  .clk(gmii_clk),
  .rst(rst),

  .up_clk(up_clk),
  .up_wr(up_wr && up_cs_rx_parser),
  .up_rd(up_rd && up_cs_rx_parser),
  .up_addr(up_addr),
  .up_data_wr(up_data_wr),
  .up_data_rd(up_data_rd_rx_parser),

  .up_data_rx_ctrl(up_data_rx_ctrl),
  
  .par_en(par_en),

  .int_data(int_data),
  .int_valid(int_valid),
  .int_sop(int_sop),
  .int_eop(int_eop),
  .int_mod(int_mod),

  .out_data(out_data),
  .out_valid(out_valid),
  .out_sop(out_sop),
  .out_eop(out_eop),
  .out_mod(out_mod),
  .out_info(out_info),
  .out_stat(out_stat),
  .out_snum(out_snum),
  
  .int_time(sys_time_rx),
  
  .rx_stat_chk(rx_stat_chk),
  .rx_stat_base_addr(rx_stat_base_addr),
  .rx_stat_bit(rx_stat_bit),
  .rx_stat_vec(rx_stat_vec)
);
  
  assign rx_active = gmii_ctrl;


// L1-L4 loopback
rx_loop rx_loop_inst(
    .rst(rst),

    .up_data_rx_ctrl(up_data_rx_ctrl),               //
    
    .in_clk    (out_clk),
    .in_par_en (out_par_en),
    .in_data   (out_data),
    .in_valid  (out_valid),
    .in_sop    (out_sop),
    .in_eop    (out_eop),
    .in_mod    (out_mod),
    .in_info   (out_info),
    .in_stat   (out_stat),
    .in_snum   (out_snum),

    .lpbk_out_clk(lpbk_out_clk),
    .lpbk_gen_en(lpbk_gen_en),

    .lpbk_info_rqst(lpbk_info_rqst),
    .lpbk_info_vald(lpbk_info_vald),
    .lpbk_info_data(lpbk_info_data),

    .lpbk_buff_rden(lpbk_buff_rden),
    .lpbk_buff_rdad(lpbk_buff_rdad),
    .lpbk_buff_rdda(lpbk_buff_rdda)
);


// CPU packet dump
rx_dump rx_dump_inst(
    .rst(rst),

    .up_data_rx_ctrl(up_data_rx_ctrl),               //
    
    .in_clk    (out_clk),
    .in_par_en (out_par_en),
    .in_data   (out_data),
    .in_valid  (out_valid),
    .in_sop    (out_sop),
    .in_eop    (out_eop),
    .in_mod    (out_mod),
    .in_info   (out_info),
    .in_stat   (out_stat),
    .in_snum   (out_snum),

    .up_clk(up_clk),
    .up_wr(up_wr && up_cs_rx_dumper),
    .up_rd(up_rd && up_cs_rx_dumper),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd_rx_dumper)
);


// pause signal generation
rx_pause rx_pause_inst(
    .rst(rst),

    .up_data_rx_ctrl(up_data_rx_ctrl),               //
    
    .in_clk    (out_clk),
    .in_par_en (out_par_en),
    .in_data   (out_data),
    .in_valid  (out_valid),
    .in_sop    (out_sop),
    .in_eop    (out_eop),
    .in_mod    (out_mod),
    .in_info   (out_info),
    .in_stat   (out_stat),
    .in_snum   (out_snum),

    .pause_on(pause_on)
);

endmodule
