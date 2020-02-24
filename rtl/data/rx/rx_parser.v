/*
 * File   : rx_parser.v
 * Date   : 20130816
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module rx_parser (
  input  wire        clk, rst,

  input  wire           up_clk,
  input  wire           up_wr,
  input  wire           up_rd,
  input  wire [32-1: 0] up_addr,
  input  wire [31  : 0] up_data_wr,
  output wire [31  : 0] up_data_rd,

  output reg  [31:0] up_data_rx_ctrl,

  input  wire        par_en,

  input  wire [31:0] int_data,
  input  wire        int_valid,
  input  wire        int_sop,
  input  wire        int_eop,
  input  wire [ 1:0] int_mod,

  output reg  [31:0] out_data,
  output reg         out_valid,
  output reg         out_sop,
  output reg         out_eop,
  output reg  [ 1:0] out_mod,
  output reg  [31:0] out_info,
  output reg  [63:0] out_stat,
  output reg  [ 3:0] out_snum,

  input  wire [31:0] int_time,

  output reg         rx_stat_chk,
  output reg [ 3: 0] rx_stat_base_addr,
  output reg [63: 0] rx_stat_bit,
  output reg[575: 0] rx_stat_vec
);

parameter [15:0] RX_PAR_CTRL_ADDR = 16'h0010;  // rd 04020010

// cpu control to rx_parser
always @(posedge up_clk or posedge rst) begin
    if (rst)
        up_data_rx_ctrl <= 'd0;
    else if (up_wr && up_addr[15:0]==RX_PAR_CTRL_ADDR)
        up_data_rx_ctrl <= up_data_wr;
end

// capture cpu control inputs
wire [ 3:0]rx_loop_en  = up_data_rx_ctrl[27:24];  // 4 bit enable: bit0=L1, bit1=L2, bit2=L3, bit3=L4
wire       rx_dump_en  = up_data_rx_ctrl[   28];  // dump enable
wire       rx_pause_en = up_data_rx_ctrl[    5];  // pause enable

wire loop_l1 = rx_loop_en[0];  // loop enable
wire loop_l2 = rx_loop_en[0] && rx_loop_en[1];  // switch mac address
wire loop_l3 = rx_loop_en[0] && rx_loop_en[2];  // switch ip address
wire loop_l4 = rx_loop_en[0] && rx_loop_en[3];  // switch tcp/udp port

// rx_parser read to cpu
assign up_data_rd = (up_addr[15:0]==RX_PAR_CTRL_ADDR)? up_data_rx_ctrl: 
                                                       32'hdeadbeef;

// constant values
parameter c_8023_mleng = 16'h05dc;
parameter c_llch_value = 24'haaaa03;

parameter c_vlan_tpid_1 = 16'h8100;
parameter c_vlan_tpid_2 = 16'h88a8;
parameter c_vlan_tpid_3 = 16'h9100;

parameter c_mpls_type_1 = 16'h8847;
parameter c_mpls_type_2 = 16'h8848;

parameter c_ipv4_type   = 16'h0800;
parameter c_ipv6_type   = 16'h86dd;

parameter c_trieth_tag = 48'h545249455448; // "TRIETH"

// buffer data input
reg        int_valid_d1, /**/ int_valid_d2, int_valid_d3, int_valid_d4, int_valid_d5, int_valid_d6, int_valid_d7, int_valid_d8;
reg        int_sop_d1, /**/ int_sop_d2, int_sop_d3, int_sop_d4, int_sop_d5, int_sop_d6, int_sop_d7, int_sop_d8;
reg        int_eop_d1, int_eop_d2, /**/ int_eop_d3, int_eop_d4, int_eop_d5, int_eop_d6, int_eop_d7, int_eop_d8;
reg [ 1:0] int_mod_d1, /**/ int_mod_d2, int_mod_d3, int_mod_d4, int_mod_d5, int_mod_d6, int_mod_d7, int_mod_d8;
reg [31:0] int_data_d1, int_data_d2, int_data_d3, int_data_d4, int_data_d5, /**/ int_data_d6, int_data_d7, int_data_d8;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    int_sop_d1 <= 1'b0;
    int_sop_d2 <= 1'b0;
    int_sop_d3 <= 1'b0;
    int_sop_d4 <= 1'b0;
    int_sop_d5 <= 1'b0;
    int_sop_d6 <= 1'b0;
    int_sop_d7 <= 1'b0;
    int_sop_d8 <= 1'b0;
  end
  else if (par_en) begin
    int_sop_d1 <= int_sop;
    int_sop_d2 <= int_sop_d1;
    int_sop_d3 <= int_sop_d2;
    int_sop_d4 <= int_sop_d3;
    int_sop_d5 <= int_sop_d4;
    int_sop_d6 <= int_sop_d5;
    int_sop_d7 <= int_sop_d6;
    int_sop_d8 <= int_sop_d7;
  end
end
always @(posedge rst or posedge clk) begin
  if (rst) begin
    int_eop_d1 <= 1'b0;
    int_eop_d2 <= 1'b0;
    int_eop_d3 <= 1'b0;
    int_eop_d4 <= 1'b0;
    int_eop_d5 <= 1'b0;
    int_eop_d6 <= 1'b0;
    int_eop_d7 <= 1'b0;
    int_eop_d8 <= 1'b0;
  end
  else if (par_en) begin
    int_eop_d1 <= int_eop;
    int_eop_d2 <= int_eop_d1;
    int_eop_d3 <= int_eop_d2;
    int_eop_d4 <= int_eop_d3;
    int_eop_d5 <= int_eop_d4;
    int_eop_d6 <= int_eop_d5;
    int_eop_d7 <= int_eop_d6;
    int_eop_d8 <= int_eop_d7;
  end
end
always @(posedge rst or posedge clk) begin
  if (rst) begin
    int_mod_d1 <= 2'd0;
    int_mod_d2 <= 2'd0;
    int_mod_d3 <= 2'd0;
    int_mod_d4 <= 2'd0;
    int_mod_d5 <= 2'd0;
    int_mod_d6 <= 2'd0;
    int_mod_d7 <= 2'd0;
    int_mod_d8 <= 2'd0;
  end
  else if (par_en) begin
    int_mod_d1 <= int_mod;
    int_mod_d2 <= int_mod_d1;
    int_mod_d3 <= int_mod_d2;
    int_mod_d4 <= int_mod_d3;
    int_mod_d5 <= int_mod_d4;
    int_mod_d6 <= int_mod_d5;
    int_mod_d7 <= int_mod_d6;
    int_mod_d8 <= int_mod_d7;
  end
end
always @(posedge rst or posedge clk) begin
  if (rst) begin
    int_valid_d1 <= 1'b0;
    int_valid_d2 <= 1'b0;
    int_valid_d3 <= 1'b0;
    int_valid_d4 <= 1'b0;
    int_valid_d5 <= 1'b0;
    int_valid_d6 <= 1'b0;
    int_valid_d7 <= 1'b0;
    int_valid_d8 <= 1'b0;
  end
  else if (par_en) begin
    int_valid_d1 <= int_valid;
    int_valid_d2 <= int_valid_d1;
    int_valid_d3 <= int_valid_d2;
    int_valid_d4 <= int_valid_d3;
    int_valid_d5 <= int_valid_d4;
    int_valid_d6 <= int_valid_d5;
    int_valid_d7 <= int_valid_d6;
    int_valid_d8 <= int_valid_d7;
  end
end
always @(posedge rst or posedge clk) begin
  if (rst) begin
    int_data_d1  <= 32'h00000000;
    int_data_d2  <= 32'h00000000;
    int_data_d3  <= 32'h00000000;
    int_data_d4  <= 32'h00000000;
    int_data_d5  <= 32'h00000000;
    int_data_d6  <= 32'h00000000;
    int_data_d7  <= 32'h00000000;
    int_data_d8  <= 32'h00000000;
  end
  else if (par_en) begin
    int_data_d1  <= int_data;
    int_data_d2  <= int_data_d1;
    int_data_d3  <= int_data_d2;
    int_data_d4  <= int_data_d3;
    int_data_d5  <= int_data_d4;
    int_data_d6  <= int_data_d5;
    int_data_d7  <= int_data_d6;
    int_data_d8  <= int_data_d7;
  end
end

// packet parser: counter
reg [15:0] int_cnt;
reg [ 9:0] bypass_mac_cnt, bypass_vlan_cnt, bypass_llc_cnt, bypass_mpls_cnt, bypass_ipv4_cnt, bypass_ipv6_cnt, bypass_udp_cnt, bypass_tcp_cnt;
reg bypass_mac, bypass_vlan, bypass_llc, bypass_mpls, bypass_ipv4, bypass_ipv6, found_udp, bypass_udp, found_tcp, bypass_tcp;
wire bypass_l2_header     = bypass_vlan || bypass_llc;
reg  bypass_l2_header_d1; always @(posedge clk) if (par_en) bypass_l2_header_d1 <= bypass_l2_header;
wire bypass_l3_header     = bypass_mpls || bypass_ipv4 || bypass_ipv6;
wire bypass_l2l3l4_header = bypass_vlan || bypass_llc || bypass_mpls || bypass_ipv4 || bypass_ipv6 || bypass_udp || bypass_tcp;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    int_cnt         <= 0;
    bypass_mac_cnt  <= 0;
    bypass_vlan_cnt <= 0;
    bypass_llc_cnt  <= 0;
    bypass_mpls_cnt <= 0;
    bypass_ipv4_cnt <= 0;
    bypass_ipv6_cnt <= 0;
    bypass_udp_cnt  <= 0;
    bypass_tcp_cnt  <= 0;
  end
  else if (par_en) begin
    if (int_valid && int_sop)
      int_cnt <= 0;  // int_cnt <= 2; if w/o 8byte preamble+sfd
    else if (int_valid)
      int_cnt <= int_cnt + 1 - bypass_l2l3l4_header;

    if (int_valid && int_sop)
      bypass_mac_cnt <= 0;
    else if (int_valid && bypass_mac)
      bypass_mac_cnt <= bypass_mac_cnt + 1;

    if (int_valid && int_sop)
      bypass_vlan_cnt <= 0;
    else if (int_valid && bypass_vlan)
      bypass_vlan_cnt <= bypass_vlan_cnt + 1;

    if (int_valid && int_sop)
      bypass_llc_cnt <= 0;
    else if (int_valid && bypass_llc)
      bypass_llc_cnt <= bypass_llc_cnt + 1;

    if (int_valid && int_sop)
      bypass_mpls_cnt <= 0;
    else if (int_valid && bypass_mpls)
      bypass_mpls_cnt <= bypass_mpls_cnt + 1;

    if (int_valid && int_sop)
      bypass_ipv4_cnt <= 0;
    else if (int_valid && bypass_ipv4)
      bypass_ipv4_cnt <= bypass_ipv4_cnt + 1;

    if (int_valid && int_sop)
      bypass_ipv6_cnt <= 0;
    else if (int_valid && bypass_ipv6)
      bypass_ipv6_cnt <= bypass_ipv6_cnt + 1;

    if (int_valid && int_sop)
      bypass_udp_cnt <= 0;
    else if (int_valid && bypass_udp)
      bypass_udp_cnt <= bypass_udp_cnt + 1;

    if (int_valid && int_sop)
      bypass_tcp_cnt <= 0;
    else if (int_valid && bypass_tcp)
      bypass_tcp_cnt <= bypass_tcp_cnt + 1;
  end
end

// packet parser: comparator
always @(posedge rst or posedge clk) begin
  if (rst) begin
    bypass_mac   <= 1'b0;
    bypass_vlan  <= 1'b0;
    bypass_llc   <= 1'b0;
    bypass_mpls  <= 1'b0;
    bypass_ipv4  <= 1'b0;
    bypass_ipv6  <= 1'b0;
    found_udp    <= 1'b0;
    bypass_udp   <= 1'b0;
    found_tcp    <= 1'b0;
    bypass_tcp   <= 1'b0;
  end
  else if (par_en) begin
    if (int_valid && int_sop) begin
      bypass_mac   <= 1'b0;
      bypass_vlan  <= 1'b0;
      bypass_llc   <= 1'b0;
      bypass_mpls  <= 1'b0;
      bypass_ipv4  <= 1'b0;
      bypass_ipv6  <= 1'b0;
      found_udp    <= 1'b0;
      bypass_udp   <= 1'b0;
      found_tcp    <= 1'b0;
      bypass_tcp   <= 1'b0;
    end
    else begin
      // L2 parsing
      // TODO: bypass 8B preamble+sfd
      // bypass mac
      if (int_valid && int_cnt>=1 && int_cnt<=3)
        bypass_mac <= 1'b1;
      else if (int_valid)
        bypass_mac <= 1'b0;
      
      // bypass vlan
      if      (int_valid && int_cnt==10'd4 && (int_data[31:16]==c_vlan_tpid_1 || int_data[31:16]==c_vlan_tpid_2 || int_data[31:16]==c_vlan_tpid_3))  // ether_type == vlan
        bypass_vlan <= 1'b1;
      else if (int_valid && int_cnt==10'd5 && (int_data[31:16]==c_vlan_tpid_1 || int_data[31:16]==c_vlan_tpid_2 || int_data[31:16]==c_vlan_tpid_3) && bypass_vlan)  // vlan_type == vlan
        bypass_vlan <= 1'b1;
      else if (int_valid && bypass_vlan)
        bypass_vlan <= 1'b0;
      
      // bypass llc
      if      (int_valid && (int_cnt==10'd4 || (bypass_vlan && int_cnt==10'd5)) && int_data[31:16]<=c_8023_mleng && int_data[15: 0]==c_llch_value[23:8])  // ether_leng <= 1500. TODO: search for whole c_llch_value
        bypass_llc <= 1'b1;
      else if (int_valid && bypass_llc_cnt==1)
        bypass_llc <= 1'b0;
      
      
    // L3 parsing
      // bypass mpls
      if      (int_valid && (int_cnt==10'd4 || ((bypass_vlan || bypass_llc) && int_cnt==10'd5)) && 
              (int_data[31:16]==c_mpls_type_1 || int_data[31:16]==c_mpls_type_2))  // ether_type == mpls
        bypass_mpls <= 1'b1;
      else if (int_valid &&  int_cnt==10'd5 && bypass_mpls && 
               int_data[24]==1'b0)  // bottom of label stack == 0
        bypass_mpls <= 1'b1;
      else if (int_valid && bypass_mpls)
        bypass_mpls <= 1'b0;
      
      // bypass ipv4
      if      (int_valid && (int_cnt==10'd4 || ((bypass_vlan || bypass_llc || bypass_mpls) && int_cnt==10'd5)) && bypass_ipv4_cnt==10'd0 &&
              (int_data[31:16]==c_ipv4_type || bypass_mpls) && int_data[15:12]==4'h4)  // ether_type == ipv4, ip_version == 4
        bypass_ipv4 <= 1'b1;
      else if (int_valid && bypass_ipv4_cnt==10'd5-1)  // 20B
        bypass_ipv4 <= 1'b0;
      
      // bypass ipv6
      if      (int_valid && (int_cnt==10'd4 || ((bypass_vlan || bypass_llc || bypass_mpls) && int_cnt==10'd5)) && bypass_ipv6_cnt==10'd0 &&
              (int_data[31:16]==c_ipv6_type || bypass_mpls) && int_data[15:12]==4'h6)  // ether_type == ipv6, ip_version == 6
        bypass_ipv6 <= 1'b1;
      else if (int_valid && bypass_ipv6_cnt==10'd10-1)  // 40B
        bypass_ipv6 <= 1'b0;
      
    // L4 parsing
      // check if it is udp
      if      (int_valid && bypass_ipv4_cnt==10'd1 && int_data[ 7: 0]== 8'h11)  // ipv4_protocol == udp
        found_udp <= 1'b1;
      else if (int_valid && bypass_ipv6_cnt==10'd1 && int_data[31:24]== 8'h11)  // ipv6_protocol == udp
        found_udp <= 1'b1;
      
      // bypass udp
      if      (int_valid && bypass_ipv4_cnt==10'd4 && bypass_udp_cnt==10'd0 && found_udp)  // ipv4_udp
        bypass_udp <= 1'b1;
      else if (int_valid && bypass_ipv6_cnt==10'd9 && bypass_udp_cnt==10'd0 && found_udp)  // ipv6_udp
        bypass_udp <= 1'b1;
      else if (int_valid && bypass_udp_cnt==10'd2-1)  // 8B
        bypass_udp <= 1'b0;
      
      // check if it is tcp
      if      (int_valid && bypass_ipv4_cnt==10'd1 && int_data[ 7: 0]== 8'h06)  // ipv4_protocol == tcp
        found_tcp <= 1'b1;
      else if (int_valid && bypass_ipv6_cnt==10'd1 && int_data[31:24]== 8'h06)  // ipv6_protocol == udp
        found_tcp <= 1'b1;
      
      // bypass tcp
      if      (int_valid && bypass_ipv4_cnt==10'd4 && bypass_tcp_cnt==10'd0 && found_tcp)  // ipv4_tcp
        bypass_tcp <= 1'b1;
      else if (int_valid && bypass_ipv6_cnt==10'd9 && bypass_tcp_cnt==10'd0 && found_tcp)  // ipv6_tcp
        bypass_tcp <= 1'b1;
      else if (int_valid && bypass_tcp_cnt==10'd5-1)  // 20B
        bypass_tcp <= 1'b0;
    end
  end
end

// get TRIETH ID based stream_id, stream_seq, tx_time_stamp, rx_time_stamp
reg        test_stream_found;
reg [ 2:0] test_stream_index;
reg [31:0] test_stream_seqnum;
reg [31:0] test_stream_tstamp;
reg [31:0] test_stream_rstamp;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    test_stream_found <= 1'b0;
    test_stream_index <= 3'd0;
    test_stream_tstamp <= 'd0;
    test_stream_seqnum <= 'd0;
    test_stream_rstamp <= 'd0;
  end
  else if (par_en) begin
    if (int_valid && {int_data_d2[15:0],int_data_d1[31:0]}==c_trieth_tag) begin
      test_stream_found  <= 1'b1;
      test_stream_index  <= int_data_d2[18:16];
      test_stream_tstamp <= int_data_d3[31: 0];
      test_stream_seqnum <= int_data_d4[31: 0];
      test_stream_rstamp <= int_time   [31: 0];
    end
    else if (int_valid && int_sop) begin
      test_stream_found  <= 1'b0;
      test_stream_index  <= test_stream_index;
      test_stream_tstamp <= test_stream_tstamp;
      test_stream_seqnum <= test_stream_seqnum;
      test_stream_rstamp <= test_stream_rstamp;
    end
  end
end

// get payload
reg        payload_valid;
reg [31:0] payload_data;
reg [15:0] payload_tag;
reg [31:0] payload_seed;
reg        payload_pre;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    payload_valid <= 1'b0;
    payload_data  <= 32'd0;
    payload_tag   <= 16'd0;
    payload_seed  <= 32'd0;
    payload_pre   <= 1'b0;
  end
  else if (par_en) begin
    if (int_valid && int_sop) begin
      payload_valid <= 1'b0;
      payload_data  <= 32'd0;
      payload_tag   <= 16'd0;
      payload_seed  <= 32'd0;
      payload_pre   <= 1'b0;
    end
    else if (int_valid && test_stream_found) begin
      payload_valid <= 1'b0;
      payload_data  <= 32'd0;
      payload_tag   <= 16'd0;
      payload_seed  <= 32'd0;
      payload_pre   <= 1'b0;
    end
    else begin
      if (int_valid && int_cnt>=10 && !bypass_l2l3l4_header) begin
        payload_valid <= 1'b1;
        payload_data  <= int_data_d5[31:0];  //{int_data_d1[15:0], int_data[31:16]};
      end
      if (int_valid && int_cnt==9 && !bypass_l2l3l4_header) begin
        payload_tag   <= int_data_d5[15:0];
        payload_seed  <= int_data_d4[31:0];
      end
      if (int_valid && int_cnt==9 && !bypass_l2l3l4_header) begin
        payload_pre   <= 1'b1;
      end else begin
        payload_pre   <= 1'b0;
      end
    end
  end
end

// check payload
wire [31:0] payload_esum;
rx_payload payload_chk (
    .rst(rst),
    .clk(clk),
    
    .payload_valid(payload_valid && par_en),
    .payload_data (payload_data),

    .payload_pre (payload_pre && par_en),
    .payload_seed(payload_seed),
    .payload_type(payload_tag[15:12]),  // 0~3: cnst,incr,decr,cnst; 4~7: 2e31,2e23,2e15,2e11

    .payload_esum(payload_esum)
);

// get l4_data
reg        l4_data_valid;
reg [31:0] l4_data_data;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    l4_data_valid <= 1'b0;
    l4_data_data  <= 32'd0;
  end
  else if (par_en) begin
    if (int_valid && int_sop) begin
      l4_data_valid <= 1'b0;
      l4_data_data  <= 32'd0;
    end
    else if (int_valid && int_eop) begin
      l4_data_valid <= 1'b0;
      l4_data_data  <= 32'd0;
    end
    else begin
      if (int_valid && int_cnt>=6 && !bypass_l2l3l4_header && (found_udp || found_tcp)) begin
        l4_data_valid <= 1'b1;
        l4_data_data  <= int_data_d1[31:0];
      end
    end
  end
end

// check l4_data
reg [17:0] l4_data_sum;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    l4_data_sum <= 18'd0;
  end
  else if (par_en) begin
    if (int_valid && int_sop)
      l4_data_sum <= 18'h0ffff;
    else if (l4_data_valid)
      l4_data_sum <= {2'b00,l4_data_sum[15:0]} + {2'b00,l4_data_data[31:16]} + {2'b00,l4_data_data[15:0]} + {16'd0, l4_data_sum[17:16]};
  end
end
wire [15:0] l4_data_sum_check = ~({14'd0,l4_data_sum[17:16]}+l4_data_sum[15:0]);

// get info-rate length
reg [ 15:0] info_leng_byte;
always @(posedge rst or posedge clk) begin
  if (rst)
    info_leng_byte <= 'd0;
  else if (par_en) begin
    if (int_valid && int_cnt=='d1)
      info_leng_byte <= 4;
    else if (int_valid && int_eop)
      info_leng_byte <= info_leng_byte + ((int_mod=='d0)? 4: int_mod);
    else if (int_valid)
      info_leng_byte <= info_leng_byte + 4;
  end
end

// get line-rate length
reg [ 15:0] line_leng_byte;
always @(posedge rst or posedge clk) begin
  if (rst)
    line_leng_byte <= 'd0;
  else if (par_en) begin
    if (int_valid && int_cnt=='d1)
      line_leng_byte <= 4+20;
    else if (int_valid && int_eop)
      line_leng_byte <= line_leng_byte + ((int_mod=='d0)? 4: int_mod);
    else if (int_valid)
      line_leng_byte <= line_leng_byte + 4;
  end
end

// get mac_da, mac_sa; vlan_num; mpls_num; ipv4_sa, ipv4_da; ipv6_sa, ipv6_da; udp_sp, udp_dp; tcp_sp, tcp_dp
reg [ 47: 0] mac_da, mac_sa;      // 48bit mac address
reg [ 15: 0] mac_type;            // 16bit mac type
reg [  3: 0] vlan_num, mpls_num;  // up to 15 vlan/mpls stacking
reg [ 31: 0] ipv4_sa, ipv4_da;    // 32bit ipv4 address
reg [127: 0] ipv6_sa, ipv6_da;    // 128bit ipv6 address
reg [  7: 0] ip_protocol;         // 8bit ip protocol
reg [ 15: 0] udp_sp, udp_dp;      // 16bit udp port number
reg [ 15: 0] tcp_sp, tcp_dp;      // 16bit tcp port number
always @(posedge rst or posedge clk) begin
  if (rst) begin
    mac_da <= 'd0;
    mac_sa <= 'd0;
    mac_type <= 'd0;
    vlan_num <= 'd0;
    mpls_num <= 'd0;
    ipv4_sa <= 'd0;
    ipv4_da <= 'd0;
    ipv6_sa <= 'd0;
    ipv6_da <= 'd0;
    ip_protocol <= 'd0;
    udp_sp <= 'd0;
    udp_dp <= 'd0;
    tcp_sp <= 'd0;
    tcp_dp <= 'd0;
  end
  else if (par_en) begin
    if (int_valid && int_sop) begin
      mac_da <= 'd0;
      mac_sa <= 'd0;
      mac_type <= 'd0;
      vlan_num <= 'd0;
      mpls_num <= 'd0;
      ipv4_sa <= 'd0;
      ipv4_da <= 'd0;
      ipv6_sa <= 'd0;
      ipv6_da <= 'd0;
      ip_protocol <= 'd0;
      udp_sp <= 'd0;
      udp_dp <= 'd0;
      tcp_sp <= 'd0;
      tcp_dp <= 'd0;
    end
    else begin
      if (int_valid && int_cnt==2) mac_da <= {int_data_d1[31: 0], int_data[31:16]};
      if (int_valid && int_cnt==3) mac_sa <= {int_data_d1[15: 0], int_data[31: 0]};
    
      if (int_valid && (!bypass_l2_header && bypass_l2_header_d1) || (int_cnt==5 && !bypass_l2_header)) mac_type <= int_data_d1[31:16];
    
      if (int_valid && int_cnt==6) vlan_num <= bypass_vlan_cnt;
      if (int_valid && int_cnt==6) mpls_num <= bypass_mpls_cnt;
    
      if (int_valid && bypass_ipv4_cnt==3 && bypass_ipv4) ipv4_sa <= {int_data_d1[15: 0], int_data[31:16]};
      if (int_valid && bypass_ipv4_cnt==4 && bypass_ipv4) ipv4_da <= {int_data_d1[15: 0], int_data[31:16]};
    
      if (int_valid && bypass_ipv6_cnt==5 && bypass_ipv6) ipv6_sa <= {int_data_d4[15: 0], int_data_d3[31: 0], int_data_d2[31: 0], int_data_d1[31: 0], int_data[31:16]};
      if (int_valid && bypass_ipv6_cnt==9 && bypass_ipv6) ipv6_da <= {int_data_d4[15: 0], int_data_d3[31: 0], int_data_d2[31: 0], int_data_d1[31: 0], int_data[31:16]};
    
      if (int_valid) ip_protocol <= (bypass_ipv4_cnt==1 && bypass_ipv4)? int_data[ 7: 0]:
                                    (bypass_ipv6_cnt==1 && bypass_ipv6)? int_data[31:24]: ip_protocol;
    
      if (int_valid && bypass_udp_cnt ==0 && bypass_udp)  udp_sp  <=  int_data_d1[15: 0];
      if (int_valid && bypass_udp_cnt ==1 && bypass_udp)  udp_dp  <=  int_data_d1[31:16];
    
      if (int_valid && bypass_tcp_cnt ==0 && bypass_tcp)  tcp_sp  <=  int_data_d1[15: 0];
      if (int_valid && bypass_tcp_cnt ==1 && bypass_tcp)  tcp_dp  <=  int_data_d1[31:16];
    end
  end
end

// calculate CRC
wire [31:0] int_crc;
crc32_data32 crc32_par (
    .rst(rst),
    .clk(clk),

    .init_i (int_valid && int_cnt==1 && par_en),
    .valid_i(int_valid_d1 && par_en),
    .mod_i  (int_mod_d1),
    .data_i (int_data_d1),

    .crc_o(int_crc)
);



// over-all statistics checking control
wire frame_check_point = int_eop_d2;

// get bit statistics
// 0
wire mac_brdcast = (mac_da[47: 0] == 48'hffffffffffff)? 1'b1: 1'b0;
wire mac_mltcast = (mac_da[   40] == 1'b1 && !mac_brdcast)? 1'b1: 1'b0;
wire mac_unicast = !mac_brdcast && !mac_mltcast;
wire mac_keepalv = (mac_da[47: 0] == mac_sa[47: 0])? 1'b1: 1'b0;
wire mac_crc_bad = (int_crc[31:0] == 32'h1CDF4421)? 1'b0: 1'b1;
wire mac_xxxxx02 = 1'b0;
wire mac_xxxxx03 = 1'b0;
wire mac_xxxxx04 = 1'b0;
// 1
wire mactp_arp   = (mac_type==16'h0806)? 1'b1: 1'b0;
wire mactp_pause = (mac_type==16'h8808)? 1'b1: 1'b0;
wire mactp_xxx01 = 1'b0;
wire mactp_xxx02 = 1'b0;
wire mactp_xxx03 = 1'b0;
wire mactp_xxx04 = 1'b0;
wire mactp_xxx05 = 1'b0;
wire mactp_xxx06 = 1'b0;
// 2
wire vlan_num_01 = (bypass_vlan_cnt=='d1)? 1'b1: 1'b0;
wire vlan_num_02 = (bypass_vlan_cnt=='d2)? 1'b1: 1'b0;
wire vlan_num_03 = (bypass_vlan_cnt=='d3)? 1'b1: 1'b0;
wire vlan_xxxx00 = 1'b0;
wire vlan_xxxx01 = 1'b0;
wire vlan_xxxx02 = 1'b0;
wire vlan_xxxx03 = 1'b0;
wire vlan_xxxx04 = 1'b0;
// 3
wire mpls_num_01 = (bypass_mpls_cnt=='d1)? 1'b1: 1'b0;
wire mpls_num_02 = (bypass_mpls_cnt=='d2)? 1'b1: 1'b0;
wire mpls_num_03 = (bypass_mpls_cnt=='d3)? 1'b1: 1'b0;
wire mpls_xxxx00 = 1'b0;
wire mpls_xxxx01 = 1'b0;
wire mpls_xxxx02 = 1'b0;
wire mpls_xxxx03 = 1'b0;
wire mpls_xxxx04 = 1'b0;
// 4
wire ip_version4 = (bypass_ipv4_cnt>='d5 )? 1'b1: 1'b0;
wire ip_version6 = (bypass_ipv6_cnt>='d10)? 1'b1: 1'b0;
wire ip_brdcast  = 1'b0;
wire ip_mltcast  = 1'b0;
wire ip_anycast  = 1'b0;
wire ip_unicast  = 1'b0;
wire ip_xxxxx01  = 1'b0;
wire ip_xxxxx02  = 1'b0;
// 5
wire iprtcl_tcp  = (ip_protocol=='d6 )? 1'b1: 1'b0;
wire iprtcl_udp  = (ip_protocol=='d17)? 1'b1: 1'b0;
wire iprtcl_xx01 = 1'b0;
wire iprtcl_xx02 = 1'b0;
wire iprtcl_xx03 = 1'b0;
wire iprtcl_xx04 = 1'b0;
wire iprtcl_xx05 = 1'b0;
wire iprtcl_xx06 = 1'b0;
// 6
wire l4_cksum_er = (l4_data_sum_check!=16'd0)? test_stream_found: 1'b0;
// 7
wire frame_anyl = 1'b1;
wire frame_runt = (line_leng_byte-'d20) < 'd64;
wire frame_jumb = (line_leng_byte-'d20) > 'd1518;

// output frame checking results
always @(posedge rst or posedge clk) begin
  if (rst)
    rx_stat_bit <= 'd0;
  else if (par_en) begin
    if (frame_check_point)
      rx_stat_bit <= {
                      //7
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      frame_jumb,
                      frame_runt,
                      frame_anyl,
                      //6           
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      l4_cksum_er,
                      //5
                      iprtcl_xx01,
                      iprtcl_xx02,
                      iprtcl_xx03,
                      iprtcl_xx04,
                      iprtcl_xx05,
                      iprtcl_xx06,
                      iprtcl_udp ,
                      iprtcl_tcp ,
                      //4
                      ip_xxxxx01 ,
                      ip_xxxxx02 ,
                      ip_unicast ,
                      ip_anycast ,
                      ip_mltcast ,
                      ip_brdcast ,
                      ip_version6,
                      ip_version4,
                      //3
                      mpls_xxxx00,
                      mpls_xxxx01,
                      mpls_xxxx02,
                      mpls_xxxx03,
                      mpls_xxxx04,
                      mpls_num_03,
                      mpls_num_02,
                      mpls_num_01,
                      //2
                      vlan_xxxx00,
                      vlan_xxxx01,
                      vlan_xxxx02,
                      vlan_xxxx03,
                      vlan_xxxx04,
                      vlan_num_03,
                      vlan_num_02,
                      vlan_num_01,
                      //1
                      mactp_xxx01,
                      mactp_xxx02,
                      mactp_xxx03,
                      mactp_xxx04,
                      mactp_xxx05,
                      mactp_xxx06,
                      mactp_pause,
                      mactp_arp  ,
                      //0
                      mac_crc_bad,
                      mac_xxxxx02,
                      mac_xxxxx03,
                      mac_xxxxx04,
                      mac_keepalv,
                      mac_unicast,
                      mac_mltcast,
                      mac_brdcast
                      };
    else
      rx_stat_bit <= rx_stat_bit;
  end
end

// get vector statistics
reg [7:0] test_stream_1st_time;
always @(posedge rst or posedge clk) begin
    if (rst)
        test_stream_1st_time <= 8'hff;
    else if (par_en)
      if (frame_check_point && test_stream_found)
        test_stream_1st_time[test_stream_index] <= 1'b0;
end

// TODO: use memory to store previous values
reg  [31:0] test_stream_tstamp_old [7:0];
reg  [31:0] test_stream_rstamp_old [7:0];
reg  [31:0] test_stream_seqnum_old [7:0];
always @(posedge rst or posedge clk) begin
  if (rst) begin
    test_stream_tstamp_old[0] <= 'd0;
    test_stream_rstamp_old[0] <= 'd0;
    test_stream_seqnum_old[0] <= 'd0;
    test_stream_tstamp_old[1] <= 'd0;
    test_stream_rstamp_old[1] <= 'd0;
    test_stream_seqnum_old[1] <= 'd0;
    test_stream_tstamp_old[2] <= 'd0;
    test_stream_rstamp_old[2] <= 'd0;
    test_stream_seqnum_old[2] <= 'd0;
    test_stream_tstamp_old[3] <= 'd0;
    test_stream_rstamp_old[3] <= 'd0;
    test_stream_seqnum_old[3] <= 'd0;
    test_stream_tstamp_old[4] <= 'd0;
    test_stream_rstamp_old[4] <= 'd0;
    test_stream_seqnum_old[4] <= 'd0;
    test_stream_tstamp_old[5] <= 'd0;
    test_stream_rstamp_old[5] <= 'd0;
    test_stream_seqnum_old[5] <= 'd0;
    test_stream_tstamp_old[6] <= 'd0;
    test_stream_rstamp_old[6] <= 'd0;
    test_stream_seqnum_old[6] <= 'd0;
    test_stream_tstamp_old[7] <= 'd0;
    test_stream_rstamp_old[7] <= 'd0;
    test_stream_seqnum_old[7] <= 'd0;
  end
  else if (par_en)
    if (frame_check_point) begin
      test_stream_tstamp_old[test_stream_index] <= test_stream_tstamp;
      test_stream_rstamp_old[test_stream_index] <= test_stream_rstamp;
      test_stream_seqnum_old[test_stream_index] <= test_stream_seqnum;
    end
end

// TODO: use memory to store previous values
wire [31:0] pack_time_rscv = int_time;
reg  [31:0] pack_time_rscv_old [7:0];
always @(posedge rst or posedge clk) begin
  if (rst) begin
      pack_time_rscv_old[0] <= 'd0;
      pack_time_rscv_old[1] <= 'd0;
      pack_time_rscv_old[2] <= 'd0;
      pack_time_rscv_old[3] <= 'd0;
      pack_time_rscv_old[4] <= 'd0;
      pack_time_rscv_old[5] <= 'd0;
      pack_time_rscv_old[6] <= 'd0;
      pack_time_rscv_old[7] <= 'd0;
  end
  else if (par_en)
    if (frame_check_point) begin
        pack_time_rscv_old[test_stream_index] <= pack_time_rscv;
    end
end

wire [31:0] line_leng = {16'd0, line_leng_byte};
wire [31:0] info_leng = {16'd0, info_leng_byte};
wire [31:0] pack_intv = (pack_time_rscv > pack_time_rscv_old[test_stream_index])?
                        (pack_time_rscv - pack_time_rscv_old[test_stream_index]):
                        (32'hffffffff   - pack_time_rscv_old[test_stream_index] + pack_time_rscv + 32'd1);
wire [31:0] test_dely = (test_stream_rstamp > test_stream_tstamp)?
                        (test_stream_rstamp - test_stream_tstamp):
                        (32'hffffffff       - test_stream_tstamp + test_stream_rstamp + 32'd1);
wire [31:0] test_jitr = ((test_stream_rstamp-test_stream_rstamp_old[test_stream_index]) > (test_stream_tstamp-test_stream_tstamp_old[test_stream_index]))?
                        ((test_stream_rstamp-test_stream_rstamp_old[test_stream_index]) - (test_stream_tstamp-test_stream_tstamp_old[test_stream_index])):
                        ((test_stream_tstamp-test_stream_tstamp_old[test_stream_index]) - (test_stream_rstamp-test_stream_rstamp_old[test_stream_index]));
wire [31:0] test_nber = payload_esum;
wire [31:0] test_slos = (test_stream_seqnum>(test_stream_seqnum_old[test_stream_index]+0))? (test_stream_seqnum-(test_stream_seqnum_old[test_stream_index]+1)): 32'd0;
wire [31:0] test_soos = (test_stream_seqnum<(test_stream_seqnum_old[test_stream_index]+0))? 32'd1: 32'd0;
wire [31:0] test_sdup = (test_stream_seqnum==test_stream_seqnum_old[test_stream_index]   )? 32'd1: 32'd0;

// 8
wire line_leng_sum = 1'b1;
wire line_leng_max = 1'b1;
wire line_leng_min = 1'b1;
// 7
wire info_leng_sum = 1'b1;
wire info_leng_max = 1'b1;
wire info_leng_min = 1'b1;
// 6
wire pack_intv_sum = test_stream_found && !test_stream_1st_time[test_stream_index];
wire pack_intv_max = test_stream_found && !test_stream_1st_time[test_stream_index];
wire pack_intv_min = test_stream_found && !test_stream_1st_time[test_stream_index];
// 5
wire test_dely_sum = test_stream_found && !test_stream_1st_time[test_stream_index];
wire test_dely_max = test_stream_found && !test_stream_1st_time[test_stream_index];
wire test_dely_min = test_stream_found && !test_stream_1st_time[test_stream_index];
// 4
wire test_jitr_sum = test_stream_found && !test_stream_1st_time[test_stream_index];
wire test_jitr_max = test_stream_found && !test_stream_1st_time[test_stream_index];
wire test_jitr_min = test_stream_found && !test_stream_1st_time[test_stream_index];
// 3
wire test_nber_sum = test_stream_found;
// 2
wire test_slos_sum = test_stream_found && !test_stream_1st_time[test_stream_index];
// 1
wire test_soos_sum = test_stream_found && !test_stream_1st_time[test_stream_index];
// 0
wire test_sdup_sum = test_stream_found && !test_stream_1st_time[test_stream_index];


// output frame checking results
always @(posedge rst or posedge clk) begin
  if (rst)
    rx_stat_vec <= 'd0;
  else if (par_en) begin
    if (frame_check_point)
      rx_stat_vec <= {
                      {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 63:60
                      {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 59:56
                      {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 55:52
                      {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 51:48
                      {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 47:44
                      {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 43:40
                      {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 39:36
                      {          1'b0,line_leng_sum, line_leng_max, line_leng_min}, line_leng,  // 35:32
                                     
                      {          1'b0,info_leng_sum, info_leng_max, info_leng_min}, info_leng,  // 31:28
                      {          1'b0,pack_intv_sum, pack_intv_max, pack_intv_min}, pack_intv,  // 27:24
                      {          1'b0,test_dely_sum, test_dely_max, test_dely_min}, test_dely,  // 23:20
                      {          1'b0,test_jitr_sum, test_jitr_max, test_jitr_min}, test_jitr,  // 19:16
                      {          1'b0,test_nber_sum,          1'b0,          1'b0}, test_nber,  // 15:12
                      {          1'b0,test_slos_sum,          1'b0,          1'b0}, test_slos,  // 11: 8
                      {          1'b0,test_soos_sum,          1'b0,          1'b0}, test_soos,  //  7: 4
                      {          1'b0,test_sdup_sum,          1'b0,          1'b0}, test_sdup   //  3: 0
                      };
    else
      rx_stat_vec <= rx_stat_vec;
  end
end

// output common statistic signals
always @(posedge rst or posedge clk) begin
  if (rst)
    rx_stat_chk <= 1'b0;
  else if (par_en) begin
    if (frame_check_point)
      rx_stat_chk <= 1'b1;
    else
      rx_stat_chk <= 1'b0;
  end
end

always @(posedge rst or posedge clk) begin
  if (rst)
    rx_stat_base_addr <= 'd0;
  else if (par_en)
    if (frame_check_point)
      rx_stat_base_addr <= test_stream_found? {1'b0, test_stream_index}: {1'b1, 3'd0};
end




// output parsed packet

always @(posedge rst or posedge clk) begin
    if (rst) begin
        out_data  <= 32'd0;
        out_valid <= 1'b0;
        out_sop   <= 1'b0;
        out_eop   <= 1'b0;
        out_mod   <= 2'b00;
        out_info  <= 32'd0;
    end
    else if (par_en) begin
        out_data  <= int_data_d1;
        out_valid <= int_valid_d1;
        out_sop   <= int_sop_d1;
        out_eop   <= int_eop_d1;
        out_mod   <= int_mod_d1;
        out_info  <= {24'd0, {bypass_tcp, bypass_udp, bypass_ipv6, bypass_ipv4}, {bypass_mpls, bypass_llc, bypass_vlan,bypass_mac}};
    end
end
always @(*) begin
    out_stat = rx_stat_bit;
    out_snum = rx_stat_base_addr;
end

endmodule
