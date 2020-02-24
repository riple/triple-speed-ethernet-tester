/*
 * File   : rx_loop.v
 * Date   : 20140512
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module rx_loop (
    input  wire         rst,


    input  wire [31: 0] up_data_rx_ctrl,

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

    input  wire        lpbk_out_clk,
    input  wire        lpbk_gen_en,

    input  wire        lpbk_info_rqst,
    output wire        lpbk_info_vald,
    output wire [31:0] lpbk_info_data,

    input  wire        lpbk_buff_rden,
    input  wire [11:0] lpbk_buff_rdad,
    output wire [31:0] lpbk_buff_rdda
);


// buffer in_par_en
reg in_par_en_d1, in_par_en_d2, in_par_en_d3, in_par_en_d4,
    in_par_en_d5, in_par_en_d6, in_par_en_d7, in_par_en_d8,
    in_par_en_d9, in_par_en_d10, in_par_en_d11, in_par_en_d12;
always @(posedge rst or posedge in_clk) begin
  if (rst) begin
    in_par_en_d1 <= 1'b0;
    in_par_en_d2 <= 1'b0;
    in_par_en_d3 <= 1'b0;
    in_par_en_d4 <= 1'b0;
    in_par_en_d5 <= 1'b0;
    in_par_en_d6 <= 1'b0;
    in_par_en_d7 <= 1'b0;
    in_par_en_d8 <= 1'b0;
    in_par_en_d9 <= 1'b0;
    in_par_en_d10 <= 1'b0;
    in_par_en_d11 <= 1'b0;
    in_par_en_d12 <= 1'b0;
  end
  else begin
    in_par_en_d1 <= in_par_en;
    in_par_en_d2 <= in_par_en_d1;
    in_par_en_d3 <= in_par_en_d2;
    in_par_en_d4 <= in_par_en_d3;
    in_par_en_d5 <= in_par_en_d4;
    in_par_en_d6 <= in_par_en_d5;
    in_par_en_d7 <= in_par_en_d6;
    in_par_en_d8 <= in_par_en_d7;
    in_par_en_d9 <= in_par_en_d8;
    in_par_en_d10 <= in_par_en_d9;
    in_par_en_d11 <= in_par_en_d10;
    in_par_en_d12 <= in_par_en_d11;
  end
end

wire par_en = in_par_en_d8;// || in_par_en_d12;

// get buffer control info
wire [ 3:0]rx_loop_en  = up_data_rx_ctrl[27:24];  // 4 bit enable: bit0=L1, bit1=L2, bit2=L3, bit3=L4
wire       rx_dump_en  = up_data_rx_ctrl[   28];  // dump enable
wire       rx_pause_en = up_data_rx_ctrl[    5];  // pause enable

wire loop_l1 = rx_loop_en[0];                   // +1 loop enable
wire loop_l2 = rx_loop_en[0] && rx_loop_en[1];  // +2 switch mac address
wire loop_l3 = rx_loop_en[0] && rx_loop_en[2];  // +4 switch ip address
wire loop_l4 = rx_loop_en[0] && rx_loop_en[3];  // +8 switch tcp/udp port

wire loop_it = (in_stat[7:0]==8'h04 || in_stat[9]==1'b1)? 1'b1: 1'b0;  // unicast && crc_good || pause

// get packet parser info
// out_info  <= {24'd0, {bypass_tcp, bypass_udp, bypass_ipv6, bypass_ipv4}, {bypass_mpls, bypass_llc, bypass_vlan,bypass_mac}};
wire hereis_mac = in_info[0];
wire hereis_ip4 = in_info[4];
wire hereis_ip6 = in_info[5];
wire hereis_udp = in_info[6];
wire hereis_tcp = in_info[7];

reg [5:0] hereis_mac_cntr;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    hereis_mac_cntr <= 'd0;
  else if (par_en) begin
    if (in_sop && in_valid)
      hereis_mac_cntr <= 'd0;
    else if (hereis_mac)
      hereis_mac_cntr <= hereis_mac_cntr + 'd1;
  end
end

reg hereis_ip4_d1;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    hereis_ip4_d1 <= 1'b0;
  else if (par_en)
    hereis_ip4_d1 <= hereis_ip4;
end

reg [5:0] hereis_ip4_cntr;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    hereis_ip4_cntr <= 'd0;
  else if (par_en) begin
    if (in_sop && in_valid)
      hereis_ip4_cntr <= 'd0;
    else if (hereis_ip4 || hereis_ip4_d1)
      hereis_ip4_cntr <= hereis_ip4_cntr + 'd1;
  end
end

reg hereis_ip6_d1;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    hereis_ip6_d1 <= 1'b0;
  else if (par_en)
    hereis_ip6_d1 <= hereis_ip6;
end

reg [5:0] hereis_ip6_cntr;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    hereis_ip6_cntr <= 'd0;
  else if (par_en) begin
    if (in_sop && in_valid)
      hereis_ip6_cntr <= 'd0;
    else if (hereis_ip6 || hereis_ip6_d1)
      hereis_ip6_cntr <= hereis_ip6_cntr + 'd1;
  end
end

reg [5:0] hereis_udp_cntr;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    hereis_udp_cntr <= 'd0;
  else if (par_en) begin
    if (in_sop && in_valid)
      hereis_udp_cntr <= 'd0;
    else if (hereis_udp)
      hereis_udp_cntr <= hereis_udp_cntr + 'd1;
  end
end

reg [5:0] hereis_tcp_cntr;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    hereis_tcp_cntr <= 'd0;
  else if (par_en) begin
    if (in_sop && in_valid)
      hereis_tcp_cntr <= 'd0;
    else if (hereis_tcp)
      hereis_tcp_cntr <= hereis_tcp_cntr + 'd1;
  end
end

/*
// buffer data input
reg        in_valid_d1, in_valid_d2, in_valid_d3, in_valid_d4, in_valid_d5, in_valid_d6, in_valid_d7, in_valid_d8;
reg        in_sop_d1, in_sop_d2, in_sop_d3, in_sop_d4, in_sop_d5, in_sop_d6, in_sop_d7, in_sop_d8;
reg        in_eop_d1, in_eop_d2, in_eop_d3, in_eop_d4, in_eop_d5, in_eop_d6, in_eop_d7, in_eop_d8;
reg [ 1:0] in_mod_d1, in_mod_d2, in_mod_d3, in_mod_d4, in_mod_d5, in_mod_d6, in_mod_d7, in_mod_d8;
reg [31:0] in_data_d1, in_data_d2, in_data_d3, in_data_d4, in_data_d5, in_data_d6, in_data_d7, in_data_d8;
always @(posedge rst or posedge in_clk) begin
  if (rst) begin
    in_sop_d1 <= 1'b0;
    in_sop_d2 <= 1'b0;
    in_sop_d3 <= 1'b0;
    in_sop_d4 <= 1'b0;
  end
  else if (par_en) begin
    in_sop_d1 <= in_sop;
    in_sop_d2 <= in_sop_d1;
    in_sop_d3 <= in_sop_d2;
    in_sop_d4 <= in_sop_d3;
  end
end
always @(posedge rst or posedge in_clk) begin
  if (rst) begin
    in_eop_d1 <= 1'b0;
    in_eop_d2 <= 1'b0;
    in_eop_d3 <= 1'b0;
    in_eop_d4 <= 1'b0;
  end
  else if (par_en) begin
    in_eop_d1 <= in_eop;
    in_eop_d2 <= in_eop_d1;
    in_eop_d3 <= in_eop_d2;
    in_eop_d4 <= in_eop_d3;
  end
end
always @(posedge rst or posedge in_clk) begin
  if (rst) begin
    in_mod_d1 <= 2'd0;
    in_mod_d2 <= 2'd0;
    in_mod_d3 <= 2'd0;
    in_mod_d4 <= 2'd0;
  end
  else if (par_en) begin
    in_mod_d1 <= in_mod;
    in_mod_d2 <= in_mod_d1;
    in_mod_d3 <= in_mod_d2;
    in_mod_d4 <= in_mod_d3;
  end
end
always @(posedge rst or posedge in_clk) begin
  if (rst) begin
    in_valid_d1 <= 1'b0;
    in_valid_d2 <= 1'b0;
    in_valid_d3 <= 1'b0;
    in_valid_d4 <= 1'b0;
  end
  else if (par_en) begin
    in_valid_d1 <= in_valid;
    in_valid_d2 <= in_valid_d1;
    in_valid_d3 <= in_valid_d2;
    in_valid_d4 <= in_valid_d3;
  end
end
always @(posedge rst or posedge in_clk) begin
  if (rst) begin
    in_data_d1  <= 32'h00000000;
    in_data_d2  <= 32'h00000000;
    in_data_d3  <= 32'h00000000;
    in_data_d4  <= 32'h00000000;
  end
  else if (par_en) begin
    in_data_d1  <= in_data;
    in_data_d2  <= in_data_d1;
    in_data_d3  <= in_data_d2;
    in_data_d4  <= in_data_d3;
  end
end
*/


//////////////////////////////////
// loopback delay buffer
reg         dbuf_wren_h;
reg  [11:0] dbuf_wrad_h;
reg  [17:0] dbuf_wrda_h;
wire        dbuf_rden_h;
wire [11:0] dbuf_rdad_h;
wire [17:0] dbuf_rdda_h;
`ifdef ALTERA
dpram_dc_18_4096 loop_delay_buffer_h (
  .aclr_a    (rst),
  .clock_a   (in_clk),
  .address_a (dbuf_wrad_h),
  .data_a    (dbuf_wrda_h),
  .enable_a  (par_en),
  .rden_a    (1'b0),
  .wren_a    (dbuf_wren_h),
  .q_a       (),

  .aclr_b    (rst),
  .clock_b   (lpbk_out_clk),
  .address_b (dbuf_rdad_h),
  .data_b    (18'd0),
  .enable_b  (lpbk_gen_en),
  .rden_b    (dbuf_rden_h),
  .wren_b    (1'b0),
  .q_b       (dbuf_rdda_h)
);
`endif
`ifdef XILINX_SPARTAN6
dpram_dc_18_4096 loop_delay_buffer_h(
  .clka  (in_clk),
  .rsta  (rst),
  .ena   (par_en),
  .wea   (dbuf_wren_h),
  .addra (dbuf_wrad_h),
  .dina  (dbuf_wrda_h),
  .douta (),

  .clkb  (lpbk_out_clk),
  .rstb  (rst),
  .enb   (lpbk_gen_en && dbuf_rden_h),
  .web   (1'b0),
  .addrb (dbuf_rdad_h),
  .dinb  (18'd0),
  .doutb (dbuf_rdda_h)
);
`endif

reg         dbuf_wren_l;
reg  [11:0] dbuf_wrad_l;
reg  [17:0] dbuf_wrda_l;
wire        dbuf_rden_l;
wire [11:0] dbuf_rdad_l;
wire [17:0] dbuf_rdda_l;
`ifdef ALTERA
dpram_dc_18_4096 loop_delay_buffer_l (
  .aclr_a    (rst),
  .clock_a   (in_clk),
  .address_a (dbuf_wrad_l),
  .data_a    (dbuf_wrda_l),
  .enable_a  (par_en),
  .rden_a    (1'b0),
  .wren_a    (dbuf_wren_l),
  .q_a       (),

  .aclr_b    (rst),
  .clock_b   (lpbk_out_clk),
  .address_b (dbuf_rdad_l),
  .data_b    (18'd0),
  .enable_b  (lpbk_gen_en),
  .rden_b    (dbuf_rden_l),
  .wren_b    (1'b0),
  .q_b       (dbuf_rdda_l)
);
`endif
`ifdef XILINX_SPARTAN6
dpram_dc_18_4096 loop_delay_buffer_l(
  .clka  (in_clk),
  .rsta  (rst),
  .ena   (par_en),
  .wea   (dbuf_wren_l),
  .addra (dbuf_wrad_l),
  .dina  (dbuf_wrda_l),
  .douta (),

  .clkb  (lpbk_out_clk),
  .rstb  (rst),
  .enb   (lpbk_gen_en && dbuf_rden_l),
  .web   (1'b0),
  .addrb (dbuf_rdad_l),
  .dinb  (18'd0),
  .doutb (dbuf_rdda_l)
);
`endif

////////////////////////////////////////
// logic to read from delay buffer
assign dbuf_rden_h = lpbk_buff_rden;
assign dbuf_rden_l = lpbk_buff_rden;
assign dbuf_rdad_h = lpbk_buff_rdad;
assign dbuf_rdad_l = lpbk_buff_rdad;
assign lpbk_buff_rdda = {dbuf_rdda_h[15:0], dbuf_rdda_l[15:0]};

////////////////////////////////////////
// logic to write to delay buffer
reg  [11:0] dbuf_wrad;
wire        dbuf_wrad_incr, dbuf_wrad_hold, dbuf_wrad_load;
wire [11:0] dbuf_wrad_base;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    dbuf_wrad <= 'd0;
  else if (par_en)
         if (dbuf_wrad_load)
      dbuf_wrad <= dbuf_wrad_base;
    else if (dbuf_wrad_hold)
      dbuf_wrad <= dbuf_wrad + 'd0;
    else if (dbuf_wrad_incr)
      dbuf_wrad <= dbuf_wrad + 'd1;
end

// fsm state transition
reg  [ 7:0] fsm_dbwr_curr_st, fsm_dbwr_next_st, fsm_dbwr_last_st;

parameter [ 7:0]
FSM_DBWR_IDLE        =                       0,  // 0
FSM_DBWR_PREAMBLE    = FSM_DBWR_IDLE       + 1,  // 1
FSM_DBWR_ACTIVE      = FSM_DBWR_PREAMBLE   + 1,  // 2
FSM_DBWR_STAT_H      =                      64,  //64
FSM_DBWR_STAT_L      = FSM_DBWR_STAT_H     + 1,  //65
FSM_DBWR_DEACTIVE    =                     255;  // 255

always @(posedge rst or posedge in_clk) begin
    if (rst) begin
        fsm_dbwr_curr_st <= FSM_DBWR_IDLE;
        fsm_dbwr_last_st <= FSM_DBWR_IDLE;
    end
    else if (par_en) begin
        fsm_dbwr_curr_st <= fsm_dbwr_next_st;
        fsm_dbwr_last_st <= fsm_dbwr_curr_st;
    end
end

always @(*) begin
    case (fsm_dbwr_curr_st)
        FSM_DBWR_IDLE:
            if (in_valid && in_sop)
                fsm_dbwr_next_st = FSM_DBWR_PREAMBLE;
            else
                fsm_dbwr_next_st = FSM_DBWR_IDLE;
        FSM_DBWR_PREAMBLE:
                fsm_dbwr_next_st = FSM_DBWR_ACTIVE;
        FSM_DBWR_ACTIVE:
            if (in_valid && in_eop)
                fsm_dbwr_next_st = FSM_DBWR_STAT_H;
            else
                fsm_dbwr_next_st = FSM_DBWR_ACTIVE;
        FSM_DBWR_STAT_H:
                fsm_dbwr_next_st = FSM_DBWR_STAT_L;
        FSM_DBWR_STAT_L:
                fsm_dbwr_next_st = FSM_DBWR_IDLE;
        FSM_DBWR_DEACTIVE:
                fsm_dbwr_next_st = FSM_DBWR_IDLE;
        default:
            fsm_dbwr_next_st = FSM_DBWR_IDLE;
    endcase
end

// FSM output signals: buffer fill-in operaion
reg [11:0] dbuf_wrad_h_temp, dbuf_wrad_l_temp;
reg [17:0] dbuf_wrda_h_temp, dbuf_wrda_l_temp;  // l4 dst, l4 src
reg        dbuf_lpl4_rewrite;                   // temporarily store the l4 port values to write it back later, using the overwritten eop cycle

always @(posedge rst or posedge in_clk) begin
    if (rst) begin
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b0, 1'b0, 12'd0, 12'd0, 18'd0, 18'd0};
    end
    else if (par_en) begin
             if (fsm_dbwr_curr_st==FSM_DBWR_IDLE)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b0, 1'b0, 12'd0, 12'd0, 18'd0, 18'd0};
        else if (fsm_dbwr_curr_st==FSM_DBWR_PREAMBLE)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b0, 1'b0, 12'd0, 12'd0, 18'd0, 18'd0};
        else if (fsm_dbwr_curr_st==FSM_DBWR_ACTIVE) begin
            // non address 
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, dbuf_wrad, dbuf_wrad, {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            // l2 mac address
            if (hereis_mac && hereis_mac_cntr=='d0 && loop_l2)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad+12'd2), (dbuf_wrad+12'd1), {in_sop, in_eop, in_data[15: 0]}, {in_mod, in_data[31:16]}};
            if (hereis_mac && hereis_mac_cntr=='d1 && loop_l2)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad-12'd1), (dbuf_wrad+12'd1), {in_sop, in_eop, in_data[15: 0]}, {in_mod, in_data[31:16]}};
            if (hereis_mac && hereis_mac_cntr=='d2 && loop_l2)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad-12'd1), (dbuf_wrad-12'd2), {in_sop, in_eop, in_data[15: 0]}, {in_mod, in_data[31:16]}};
            // l3 ipv6 address
            if (hereis_ip6 && hereis_ip6_cntr=='d2 && loop_l3)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad+12'd0), (dbuf_wrad+12'd4), {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            if (hereis_ip6 && hereis_ip6_cntr=='d3 && loop_l3)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad+12'd4), (dbuf_wrad+12'd4), {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            if (hereis_ip6 && hereis_ip6_cntr=='d4 && loop_l3)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad+12'd4), (dbuf_wrad+12'd4), {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            if (hereis_ip6 && hereis_ip6_cntr=='d5 && loop_l3)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad+12'd4), (dbuf_wrad+12'd4), {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            if (hereis_ip6 && hereis_ip6_cntr=='d6 && loop_l3)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad+12'd4), (dbuf_wrad-12'd4), {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            if (hereis_ip6 && hereis_ip6_cntr=='d7 && loop_l3)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad-12'd4), (dbuf_wrad-12'd4), {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            if (hereis_ip6 && hereis_ip6_cntr=='d8 && loop_l3)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad-12'd4), (dbuf_wrad-12'd4), {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            if (hereis_ip6 && hereis_ip6_cntr=='d9 && loop_l3)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad-12'd4), (dbuf_wrad-12'd4), {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            if ((hereis_ip6 || hereis_ip6_d1) && hereis_ip6_cntr=='ha && loop_l3)
            {dbuf_wren_h, dbuf_wrad_h, dbuf_wrda_h} <= 
                {1'b1, (dbuf_wrad-12'd4), {in_sop, in_eop, in_data[31:16]}};
            // l3 ipv4 address
            if (hereis_ip4 && hereis_ip4_cntr=='d3 && loop_l3)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad+12'd0), (dbuf_wrad+12'd1), {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            if (hereis_ip4 && hereis_ip4_cntr=='d4 && loop_l3)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, (dbuf_wrad+12'd1), (dbuf_wrad-12'd1), {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
            if ((hereis_ip4 || hereis_ip4_d1) && hereis_ip4_cntr=='d5 && loop_l3)
            {dbuf_wren_h, dbuf_wrad_h, dbuf_wrda_h} <= 
                {1'b1, (dbuf_wrad-12'd1), {in_sop, in_eop, in_data[31:16]}};
            // l4 udp/tcp port
            if (hereis_udp && hereis_udp_cntr=='d0 && loop_l4)   // due to address conflict, need to store the values and write them later into ram
            {dbuf_wren_l, dbuf_wrad_l, dbuf_wrda_l} <= 
                {1'b1, (dbuf_wrad+12'd0), {in_sop, in_eop, in_data[15: 0]}};
            if (hereis_tcp && hereis_tcp_cntr=='d0 && loop_l4)   // due to address conflict, need to store the values and write them later into ram
            {dbuf_wren_l, dbuf_wrad_l, dbuf_wrda_l} <= 
                {1'b1, (dbuf_wrad+12'd0), {in_sop, in_eop, in_data[15: 0]}};
            if (dbuf_lpl4_rewrite && dbuf_wrad_hold && loop_l4)  // rewirte the switched l4 port values
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, dbuf_wrad_h_temp, dbuf_wrad_l_temp, dbuf_wrda_l_temp, dbuf_wrda_h_temp};
        end
        else if (fsm_dbwr_curr_st==FSM_DBWR_STAT_H)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, dbuf_wrad,dbuf_wrad, {2'b11, in_stat[63:48]}, {2'b11, in_stat[47:32]}};
        else if (fsm_dbwr_curr_st==FSM_DBWR_STAT_L)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, dbuf_wrad,dbuf_wrad, {2'b11, in_stat[31:16]}, {2'b11, in_stat[15: 0]}};
        else if (fsm_dbwr_curr_st==FSM_DBWR_DEACTIVE)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b0, 1'b0, 12'd0, 12'd0, 18'd0, 18'd0};
        else
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b0, 1'b0, 12'd0, 12'd0, 18'd0, 18'd0};
    end
end

always @(posedge rst or posedge in_clk) begin
    if (rst) begin
        {dbuf_wrad_h_temp, dbuf_wrad_l_temp, dbuf_wrda_h_temp, dbuf_wrda_l_temp} <= {12'd0, 12'd0, 18'd0, 18'd0};
    end
    else if (par_en) begin
        if (fsm_dbwr_curr_st==FSM_DBWR_ACTIVE) begin
            if (hereis_udp && hereis_udp_cntr=='d0 && loop_l4)  // UDP: capture l4 src_port
            {dbuf_wrad_l_temp, dbuf_wrda_l_temp} <= 
                {dbuf_wrad, {in_mod, in_data[15: 0]}};
            if (hereis_udp && hereis_udp_cntr=='d1 && loop_l4)  // UDP: capture l4 dst_port
            {dbuf_wrad_h_temp, dbuf_wrda_h_temp} <= 
                {dbuf_wrad, {in_sop, in_eop, in_data[31:16]}};
            if (hereis_tcp && hereis_tcp_cntr=='d0 && loop_l4)  // TCP: capture l4 src_port
            {dbuf_wrad_l_temp, dbuf_wrda_l_temp} <= 
                {dbuf_wrad, {in_mod, in_data[15: 0]}};
            if (hereis_tcp && hereis_tcp_cntr=='d1 && loop_l4)  // TCP: capture l4 dst_port
            {dbuf_wrad_h_temp, dbuf_wrda_h_temp} <= 
                {dbuf_wrad, {in_sop, in_eop, in_data[31:16]}};
        end
    end
end

always @(posedge rst or posedge in_clk) begin
    if (rst)
        dbuf_lpl4_rewrite <= 1'b0;
    else if (par_en) begin
        if (fsm_dbwr_curr_st==FSM_DBWR_PREAMBLE)
            dbuf_lpl4_rewrite <= 1'b0;
        else if (fsm_dbwr_curr_st==FSM_DBWR_ACTIVE) begin
            if (hereis_udp && hereis_udp_cntr=='d0 && loop_l4)
                dbuf_lpl4_rewrite <= 1'b1;
            if (hereis_tcp && hereis_tcp_cntr=='d0 && loop_l4)
                dbuf_lpl4_rewrite <= 1'b1;
        end
    end
end

assign dbuf_wrad_incr = (fsm_dbwr_curr_st!=FSM_DBWR_IDLE   && fsm_dbwr_curr_st!=FSM_DBWR_PREAMBLE && fsm_dbwr_curr_st!=FSM_DBWR_DEACTIVE)? 1'b1:1'b0;
assign dbuf_wrad_hold = (fsm_dbwr_curr_st!=FSM_DBWR_STAT_H && fsm_dbwr_next_st==FSM_DBWR_STAT_H)? 1'b1:1'b0;
assign dbuf_wrad_load = (fsm_dbwr_curr_st==FSM_DBWR_STAT_L && !loop_it)? 1'b1:1'b0;




///////////////////////////////
// info buffer
wire info_fifo_empty_h;
wire info_fifo_full_h;
wire        info_fifo_rden_h;
wire [17:0] info_fifo_rdda_h;
wire        info_fifo_wren_h;
wire [17:0] info_fifo_wrda_h;
`ifdef XILINX_SPARTAN6
fifo_dc_18_512 info_fifo_h(
    .rst    (rst),
 
    .wr_clk (in_clk),
    .wr_en  (par_en && info_fifo_wren_h),
    .din    (info_fifo_wrda_h),
    .full   (info_fifo_full_h),
    .wr_data_count(),
 
    .rd_clk (lpbk_out_clk),
    .rd_en (lpbk_gen_en && info_fifo_rden_h),
    .dout   (info_fifo_rdda_h),
    .empty  (info_fifo_empty_h),
    .rd_data_count()
);
`endif
`ifdef ALTERA
fifo_dc_18_512 info_fifo_h(
    .aclr(rst),

    .wrclk(in_clk),
    .wrreq(par_en && info_fifo_wren_h),
    .data(info_fifo_wrda_h),

    .rdclk(lpbk_out_clk),
    .rdreq(lpbk_gen_en && info_fifo_rden_h),
    .q(info_fifo_rdda_h),

    .rdempty(info_fifo_empty_h),
    .rdusedw(),
    .wrfull(info_fifo_full_h),
    .wrusedw()
);
`endif

wire info_fifo_empty_l;
wire info_fifo_full_l;
wire        info_fifo_rden_l;
wire [17:0] info_fifo_rdda_l;
wire        info_fifo_wren_l;
wire [17:0] info_fifo_wrda_l;
`ifdef XILINX_SPARTAN6
fifo_dc_18_512 info_fifo_l(
    .rst    (rst),
 
    .wr_clk (in_clk),
    .wr_en  (par_en && info_fifo_wren_l),
    .din    (info_fifo_wrda_l),
    .full   (info_fifo_full_l),
    .wr_data_count(),
 
    .rd_clk (lpbk_out_clk),
    .rd_en (lpbk_gen_en && info_fifo_rden_l),
    .dout   (info_fifo_rdda_l),
    .empty  (info_fifo_empty_l),
    .rd_data_count()
);
`endif
`ifdef ALTERA
fifo_dc_18_512 info_fifo_l(
    .aclr(rst),

    .wrclk(in_clk),
    .wrreq(par_en && info_fifo_wren_l),
    .data(info_fifo_wrda_l),

    .rdclk(lpbk_out_clk),
    .rdreq(lpbk_gen_en && info_fifo_rden_l),
    .q(info_fifo_rdda_l),

    .rdempty(info_fifo_empty_l),
    .rdusedw(),
    .wrfull(info_fifo_full_l),
    .wrusedw()
);
`endif

///////////////////////////////////////////////////////
// FSM output signals: info fifo fill-in operation
reg  [15:0] info_data_leng;
wire [ 3:0] info_data_snum = in_snum;
reg  [11:0] info_data_base;
wire [11:0] dbuf_wrad_interval = dbuf_wrad - info_data_base;
assign      dbuf_wrad_base = info_data_base;
always @(posedge rst or posedge in_clk) begin
    if (rst) begin
        info_data_leng <= 'd0;
        info_data_base <= 'd0;
    end
    else if (par_en) begin
        if (fsm_dbwr_curr_st!=FSM_DBWR_STAT_H && fsm_dbwr_next_st==FSM_DBWR_STAT_H) begin
            info_data_leng <= (in_mod==2'b00)? {2'b00, dbuf_wrad_interval, 2'b00}: {2'b00, (dbuf_wrad_interval-1), in_mod};
        end
        if (fsm_dbwr_curr_st==FSM_DBWR_PREAMBLE) begin
            info_data_base <= dbuf_wrad;
        end
    end
end

reg        info_fifo_wren;
reg [31:0] info_fifo_wrda;
always @(posedge rst or posedge in_clk) begin
    if (rst) begin
        info_fifo_wren <= 1'b0;
        info_fifo_wrda <= 32'd0;
    end
    else if (par_en) begin
        if (fsm_dbwr_curr_st==FSM_DBWR_STAT_H && loop_it && loop_l1) begin
            info_fifo_wren <= 1'b1;
            info_fifo_wrda <= {info_data_leng, info_data_snum, info_data_base};  // {16, 4, 12}
        end
        else begin
            info_fifo_wren <= 1'b0;
            info_fifo_wrda <= 32'd0;
        end
    end
end

assign {info_fifo_wren_h, info_fifo_wren_l} = {        info_fifo_wren,                 info_fifo_wren};
assign {info_fifo_wrda_h, info_fifo_wrda_l} = {{2'b00, info_fifo_wrda[31:16]}, {2'b00, info_fifo_wrda[15: 0]}};

///////////////////////////////////////
// info fifo read out operation
wire info_fifo_empty = (info_fifo_empty_h || info_fifo_empty_l)? 1'b1: 1'b0;
wire info_fifo_rden  = (lpbk_info_rqst && !info_fifo_empty)? 1'b1: 1'b0;

reg info_fifo_rden_d1, info_fifo_rden_d2;
always @(posedge rst or posedge lpbk_out_clk) begin
    if (rst) begin
        info_fifo_rden_d1 <= 1'b0;
        info_fifo_rden_d2 <= 1'b0;
    end
    else if (lpbk_gen_en) begin
        info_fifo_rden_d1 <= info_fifo_rden;
        info_fifo_rden_d2 <= info_fifo_rden_d1;
    end
end

assign info_fifo_rden_h = info_fifo_rden && !info_fifo_rden_d1;
assign info_fifo_rden_l = info_fifo_rden && !info_fifo_rden_d1;

assign lpbk_info_vald = info_fifo_rden_d1 && !info_fifo_rden_d2;
assign lpbk_info_data = {info_fifo_rdda_h[15:0], info_fifo_rdda_l[15:0]};




endmodule
