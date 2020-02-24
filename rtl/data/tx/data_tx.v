/*
 * File   : data_tx.v
 * Date   : 20131015
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module data_tx (

    input  wire         rst,
    input  wire         tx_gen_clk,
    input  wire         tx_con_clk,

    input  wire           up_clk,
    input  wire           up_wr,
    input  wire           up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31  : 0] up_data_wr,
    output wire [31  : 0] up_data_rd,

    output wire        lpbk_out_clk,
    output wire        lpbk_gen_en,
    output wire        lpbk_info_rqst,
    input  wire        lpbk_info_vald,
    input  wire [31:0] lpbk_info_data,
    output wire        lpbk_buff_rden,
    output wire [11:0] lpbk_buff_rdad,
    input  wire [31:0] lpbk_buff_rdda,

    output wire         rgmii_txclk,
    output wire         rgmii_txden,
    output wire [ 3: 0] rgmii_txdout,

    input  wire         sys_clk,
    input  wire [31: 0] sys_time,
    input  wire         phy_link_up,
    input  wire         phy_giga_mode,
    
    output wire         tx_stat_chk,
    output wire [ 3: 0] tx_stat_base_addr,
    output wire [63: 0] tx_stat_bit,
    output wire[575: 0] tx_stat_vec,

    input  wire         pause_on,
    
    output wire         tx_active

);
// CPU access
wire up_cs_tx_con = (up_addr[16]==1'b0)? 1'b1: 1'b0;  // rd 0400xxxx
wire up_cs_tx_gen = (up_addr[16]==1'b1)? 1'b1: 1'b0;  // rd 0401xxxx

wire [31:0] up_data_rd_tx_con;
wire [31:0] up_data_rd_tx_gen;

assign up_data_rd = (up_cs_tx_con)? up_data_rd_tx_con: (
                    (up_cs_tx_gen)? up_data_rd_tx_gen: 
                     32'hdeadbeef                      );

// gmii to rgmii converter
wire       gmii_clk;
wire       gmii_ctrl;
wire [7:0] gmii_data;
gmii2rgmii gmii2rgmii_inst(
    .gmii_clk (gmii_clk), 
    .gmii_den (gmii_ctrl),
    .gmii_dout(gmii_data),

    .rgmii_clk (rgmii_txclk),
    .rgmii_den (rgmii_txden),
    .rgmii_dout(rgmii_txdout)
);

// 32bit to 8bit gearbox
wire gen_en;
wire [31: 0] int_data;
wire         int_valid;
wire         int_sop;
wire         int_eop;
wire [ 1: 0] int_mod;
tx_gearbox tx_gearbox_inst(
    .rst(rst),
    .clk(tx_gen_clk),  
  
    .phy_giga_mode(phy_giga_mode),

    .gen_en(gen_en),

    .int_valid_i(int_valid),
    .int_data_i (int_data),
    .int_sop_i  (int_sop),
    .int_eop_i  (int_eop),
    .int_mod_i  (int_mod),

    .gmii_clk (gmii_clk), 
    .gmii_ctrl(gmii_ctrl),
    .gmii_data(gmii_data)
);

// tx timestamp
wire int_sop_cdc;
synchronizer_pulse tx_tran_time_sync (
    .clk_in(tx_gen_clk),
    .clk_out(sys_clk),
    .reset_n(!rst),
    .sync_in(int_sop && int_valid),

    .sync_out_p1(int_sop_cdc),
    .sync_out_p2(),
    .sync_out_reg2()
);

reg [31:0] sys_time_tx;
always @(posedge rst or posedge sys_clk) begin
  if (rst)
    sys_time_tx <= 'd0;
  else if (int_sop_cdc)
    sys_time_tx <= sys_time;
end

// packet generator
wire [31: 0] up_data_tx_ctrl;
wire         tx_nontest_return;
wire         tx_err_inj_return;
wire         rate_buffer_rd_rqst;
wire         rate_buffer_rd_vald;
wire [17: 0] rate_buffer_rd_data;
tx_gen tx_gen_inst(
    .rst(rst),
    .clk(tx_gen_clk),

    .up_clk(up_clk),
    .up_wr(up_wr && up_cs_tx_gen),
    .up_rd(up_rd && up_cs_tx_gen),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd_tx_gen),

    .up_data_tx_ctrl(up_data_tx_ctrl),
    .tx_nontest_return(tx_nontest_return),
    .tx_err_inj_return(tx_err_inj_return),

    .sys_time_tx(sys_time_tx),

    //.pause_on(pause_on_cdc),

    .gen_en(gen_en),

    .rate_buffer_rd_rqst(rate_buffer_rd_rqst),
    .rate_buffer_rd_vald(rate_buffer_rd_vald),
    .rate_buffer_rd_data(rate_buffer_rd_data),

    .lpbk_info_rqst(lpbk_info_rqst),
    .lpbk_info_vald(lpbk_info_vald),
    .lpbk_info_data(lpbk_info_data),
    .lpbk_buff_rden(lpbk_buff_rden),
    .lpbk_buff_rdad(lpbk_buff_rdad),
    .lpbk_buff_rdda(lpbk_buff_rdda),

    .int_valid_o(int_valid),
    .int_data_o (int_data),
    .int_sop_o  (int_sop),
    .int_eop_o  (int_eop),
    .int_mod_o  (int_mod),

    .tx_stat_chk(tx_stat_chk),
    .tx_stat_base_addr(tx_stat_base_addr),
    .tx_stat_bit(tx_stat_bit),
    .tx_stat_vec(tx_stat_vec)
);

// traffic control
tx_con tx_con_inst(
    .rst(rst),
    .tx_gen_clk(tx_gen_clk),
    .tx_con_clk(tx_con_clk),

    .up_clk(up_clk),
    .up_wr(up_wr && up_cs_tx_con),
    .up_rd(up_rd && up_cs_tx_con),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd_tx_con),

    .up_data_tx_ctrl(up_data_tx_ctrl),
    .tx_nontest_return(tx_nontest_return),
    .tx_err_inj_return(tx_err_inj_return),

    .pause_on(pause_on),

    .rate_buffer_rd_rqst(rate_buffer_rd_rqst),
    .rate_buffer_rd_vald(rate_buffer_rd_vald),
    .rate_buffer_rd_data(rate_buffer_rd_data)
);

assign tx_active = gmii_ctrl;

assign lpbk_out_clk = tx_gen_clk;
assign lpbk_gen_en  = gen_en;

endmodule
