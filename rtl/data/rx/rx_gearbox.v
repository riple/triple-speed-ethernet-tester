/*
 * File   : rx_gearbox.v
 * Date   : 20130912
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module rx_gearbox(
  input               rst,
  input               phy_giga_mode,

  input  wire         gmii_clk,
  input  wire         gmii_ctrl,
  input  wire [ 7: 0] gmii_data,

  output reg          par_en,  // multicycle timing control signal

  output reg  [31: 0] int_data_o,
  output reg          int_valid_o,
  output reg          int_sop_o,
  output reg          int_eop_o,
  output reg  [ 1: 0] int_mod_o
);

// mii to gmii padding
reg nibble_h;
always @(posedge rst or posedge gmii_clk) begin
  if (rst)
    nibble_h <= 1'b0;
  else if (gmii_ctrl)
    nibble_h <= !nibble_h;
end

reg       gmii_ctrl_conv;
reg [7:0] gmii_data_conv;
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    gmii_ctrl_conv <= 1'b0;
    gmii_data_conv <= 8'd0;
  end
  else begin
    if (phy_giga_mode) begin
      gmii_ctrl_conv      <= gmii_ctrl;
      gmii_data_conv[7:0] <= gmii_data[7:0];
    end
    else begin
      // 4b-8b datapath gearbox
      if (gmii_ctrl) begin
        gmii_ctrl_conv      <= ( nibble_h)? 1'b1:1'b0;
        gmii_data_conv[7:4] <= ( nibble_h)? gmii_data[3:0]: gmii_data_conv[7:4];
        gmii_data_conv[3:0] <= (!nibble_h)? gmii_data[3:0]: gmii_data_conv[3:0];
      end
      else begin
        gmii_ctrl_conv      <= 1'b0;
        gmii_data_conv[7:4] <= gmii_data_conv[7:4];
        gmii_data_conv[3:0] <= gmii_data_conv[3:0];
      end
    end
  end
end

// buffer gmii input
reg       gmii_ctrl_conv_d1, gmii_ctrl_conv_d2, gmii_ctrl_conv_d3, gmii_ctrl_conv_d4,
          gmii_ctrl_conv_d5, gmii_ctrl_conv_d6, gmii_ctrl_conv_d7, gmii_ctrl_conv_d8,
          gmii_ctrl_conv_d9, gmii_ctrl_conv_da;
reg [7:0] gmii_data_conv_d1, gmii_data_conv_d2, gmii_data_conv_d3, gmii_data_conv_d4,
          gmii_data_conv_d5, gmii_data_conv_d6, gmii_data_conv_d7, gmii_data_conv_d8,
          gmii_data_conv_d9, gmii_data_conv_da;
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    gmii_ctrl_conv_d1 <= 1'b0;
    gmii_ctrl_conv_d2 <= 1'b0;
    gmii_ctrl_conv_d3 <= 1'b0;
    gmii_ctrl_conv_d4 <= 1'b0;
    gmii_ctrl_conv_d5 <= 1'b0;
    gmii_ctrl_conv_d6 <= 1'b0;
    gmii_ctrl_conv_d7 <= 1'b0;
    gmii_ctrl_conv_d8 <= 1'b0;
    gmii_ctrl_conv_d9 <= 1'b0;
    gmii_ctrl_conv_da <= 1'b0;
    gmii_data_conv_d1 <= 8'd0;
    gmii_data_conv_d2 <= 8'd0;
    gmii_data_conv_d3 <= 8'd0;
    gmii_data_conv_d4 <= 8'd0;
    gmii_data_conv_d5 <= 8'd0;
    gmii_data_conv_d6 <= 8'd0;
    gmii_data_conv_d7 <= 8'd0;
    gmii_data_conv_d8 <= 8'd0;
    gmii_data_conv_d9 <= 8'd0;
    gmii_data_conv_da <= 8'd0;
  end
  else begin
    gmii_ctrl_conv_d1 <= gmii_ctrl_conv;
    gmii_ctrl_conv_d2 <= gmii_ctrl_conv_d1;
    gmii_ctrl_conv_d3 <= gmii_ctrl_conv_d2;
    gmii_ctrl_conv_d4 <= gmii_ctrl_conv_d3;
    gmii_ctrl_conv_d5 <= gmii_ctrl_conv_d4;
    gmii_ctrl_conv_d6 <= gmii_ctrl_conv_d5;
    gmii_ctrl_conv_d7 <= gmii_ctrl_conv_d6;
    gmii_ctrl_conv_d8 <= gmii_ctrl_conv_d7;
    gmii_ctrl_conv_d9 <= gmii_ctrl_conv_d8;
    gmii_ctrl_conv_da <= gmii_ctrl_conv_d9;
    gmii_data_conv_d1 <= gmii_data_conv;
    gmii_data_conv_d2 <= gmii_data_conv_d1;
    gmii_data_conv_d3 <= gmii_data_conv_d2;
    gmii_data_conv_d4 <= gmii_data_conv_d3;
    gmii_data_conv_d5 <= gmii_data_conv_d4;
    gmii_data_conv_d6 <= gmii_data_conv_d5;
    gmii_data_conv_d7 <= gmii_data_conv_d6;
    gmii_data_conv_d8 <= gmii_data_conv_d7;
    gmii_data_conv_d9 <= gmii_data_conv_d8;
    gmii_data_conv_da <= gmii_data_conv_d9;
  end
end

// choose buffered gmii input
reg       int_gmii_ctrl;
reg       int_gmii_ctrl_d1, int_gmii_ctrl_d2, int_gmii_ctrl_d3, int_gmii_ctrl_d4,
          int_gmii_ctrl_d5;
reg [7:0] int_gmii_data;
reg [7:0] int_gmii_data_d1, int_gmii_data_d2, int_gmii_data_d3, int_gmii_data_d4,
          int_gmii_data_d5;
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    int_gmii_ctrl    <= 1'b0;
    int_gmii_data    <= 8'h00;
    int_gmii_ctrl_d1 <= 1'b0;
    int_gmii_data_d1 <= 8'h00;
    int_gmii_ctrl_d2 <= 1'b0;
    int_gmii_data_d2 <= 8'h00;
    int_gmii_ctrl_d3 <= 1'b0;
    int_gmii_data_d3 <= 8'h00;
    int_gmii_ctrl_d4 <= 1'b0;
    int_gmii_data_d4 <= 8'h00;
    int_gmii_ctrl_d5 <= 1'b0;
    int_gmii_data_d5 <= 8'h00;
  end
  else begin
    if (phy_giga_mode) begin
      int_gmii_ctrl    <= gmii_ctrl_conv;
      int_gmii_data    <= gmii_data_conv;
      int_gmii_ctrl_d1 <= gmii_ctrl_conv_d1;
      int_gmii_data_d1 <= gmii_data_conv_d1;
      int_gmii_ctrl_d2 <= gmii_ctrl_conv_d2;
      int_gmii_data_d2 <= gmii_data_conv_d2;
      int_gmii_ctrl_d3 <= gmii_ctrl_conv_d3;
      int_gmii_data_d3 <= gmii_data_conv_d3;
      int_gmii_ctrl_d4 <= gmii_ctrl_conv_d4;
      int_gmii_data_d4 <= gmii_data_conv_d4;
      int_gmii_ctrl_d5 <= gmii_ctrl_conv_d5;
      int_gmii_data_d5 <= gmii_data_conv_d5;
    end
    else begin
      int_gmii_ctrl    <= gmii_ctrl_conv;
      int_gmii_data    <= gmii_data_conv;
      int_gmii_ctrl_d1 <= gmii_ctrl_conv_d2;
      int_gmii_data_d1 <= gmii_data_conv_d2;
      int_gmii_ctrl_d2 <= gmii_ctrl_conv_d4;
      int_gmii_data_d2 <= gmii_data_conv_d4;
      int_gmii_ctrl_d3 <= gmii_ctrl_conv_d6;
      int_gmii_data_d3 <= gmii_data_conv_d6;
      int_gmii_ctrl_d4 <= gmii_ctrl_conv_d8;
      int_gmii_data_d4 <= gmii_data_conv_d8;
      int_gmii_ctrl_d5 <= gmii_ctrl_conv_da;
      int_gmii_data_d5 <= gmii_data_conv_da;
    end
  end
end

// 8b-32b datapath gearbox
reg        int_valid;
reg        int_sop, int_eop;
reg [ 1:0] int_bcnt, int_mod;
reg [31:0] int_data;
always @(posedge rst or posedge gmii_clk) begin
  if (rst)
    int_bcnt <= 2'd0;
  else
    if      ( int_gmii_ctrl && !int_gmii_ctrl_d1)
      int_bcnt <= 2'd0;  // clear on sop
    else if ( int_gmii_ctrl_d1)
      int_bcnt <= int_bcnt + 2'd1;  // increment
    else if (!int_gmii_ctrl && int_gmii_ctrl_d4 && (int_bcnt!=2'd0))
      int_bcnt <= int_bcnt + 2'd1;  // end on eop with mod
end
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    int_data  <= 32'd0;
    int_valid <=  1'b0;
    int_mod   <=  2'd0;
    int_sop   <=  1'b0;
    int_eop   <=  1'b0;
  end
  else begin
    if (int_gmii_ctrl_d1) begin
      int_data[ 7: 0] <= (int_bcnt==2'd3)? int_gmii_data_d1: int_data[ 7: 0];
      int_data[15: 8] <= (int_bcnt==2'd2)? int_gmii_data_d1: int_data[15: 8];
      int_data[23:16] <= (int_bcnt==2'd1)? int_gmii_data_d1: int_data[23:16];
      int_data[31:24] <= (int_bcnt==2'd0)? int_gmii_data_d1: int_data[31:24];
    end

    if (int_gmii_ctrl_d4 && int_bcnt==2'd3)
      int_valid <= 1'b1;
    else
      int_valid <= 1'b0;

    if (int_gmii_ctrl_d1 && !int_gmii_ctrl_d2)
      int_mod <= 2'd0;
    else if (!int_gmii_ctrl_d1 && int_gmii_ctrl_d2)
      int_mod <= int_bcnt;

    if (int_gmii_ctrl_d4 && !int_gmii_ctrl_d5 && int_bcnt==2'd3)
      int_sop <= 1'b1;
    else
      int_sop <= 1'b0;

    if (!int_gmii_ctrl   &&  int_gmii_ctrl_d4 && int_bcnt==2'd3)
      int_eop <= 1'b1;
    else
      int_eop <= 1'b0;

  end
end

// output
reg int_valid_d1,  int_valid_d2,  int_valid_d3,  int_valid_d4;
reg int_valid_d5,  int_valid_d6,  int_valid_d7,  int_valid_d8;
reg int_valid_d9,  int_valid_d10, int_valid_d11, int_valid_d12;
reg int_valid_d13, int_valid_d14, int_valid_d15, int_valid_d16;
reg int_valid_d17, int_valid_d18, int_valid_d19, int_valid_d20;
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    int_valid_d1  <= 1'b0;
    int_valid_d2  <= 1'b0;
    int_valid_d3  <= 1'b0;
    int_valid_d4  <= 1'b0;
    int_valid_d5  <= 1'b0;
    int_valid_d6  <= 1'b0;
    int_valid_d7  <= 1'b0;
    int_valid_d8  <= 1'b0;
    int_valid_d9  <= 1'b0;
    int_valid_d10 <= 1'b0;
    int_valid_d11 <= 1'b0;
    int_valid_d12 <= 1'b0;
    int_valid_d13 <= 1'b0;
    int_valid_d14 <= 1'b0;
    int_valid_d15 <= 1'b0;
    int_valid_d16 <= 1'b0;
    int_valid_d17 <= 1'b0;
    int_valid_d18 <= 1'b0;
    int_valid_d19 <= 1'b0;
    int_valid_d20 <= 1'b0;
  end
  else begin
    int_valid_d1  <= int_valid;
    int_valid_d2  <= int_valid_d1;
    int_valid_d3  <= int_valid_d2;
    int_valid_d4  <= int_valid_d3;
    int_valid_d5  <= int_valid_d4;
    int_valid_d6  <= int_valid_d5;
    int_valid_d7  <= int_valid_d6;
    int_valid_d8  <= int_valid_d7;
    int_valid_d9  <= int_valid_d8;
    int_valid_d10 <= int_valid_d9;
    int_valid_d11 <= int_valid_d10;
    int_valid_d12 <= int_valid_d11;
    int_valid_d13 <= int_valid_d12;
    int_valid_d14 <= int_valid_d13;
    int_valid_d15 <= int_valid_d14;
    int_valid_d16 <= int_valid_d15;
    int_valid_d17 <= int_valid_d16;
    int_valid_d18 <= int_valid_d17;
    int_valid_d19 <= int_valid_d18;
    int_valid_d20 <= int_valid_d19;
  end
end
wire int_par_en = phy_giga_mode? (int_valid_d3 || int_valid_d7 || int_valid_d11): (int_valid_d3 || int_valid_d11 || int_valid_d19);
always @(posedge rst or posedge gmii_clk) begin
  if (rst)
    par_en <= 1'b0;
  else
    par_en <= int_par_en;
end

always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    int_valid_o <= 1'b0;
    int_sop_o   <= 1'b0;
    int_eop_o   <= 1'b0;
    int_data_o  <= 32'h00000000;
    int_mod_o   <= 2'b00;
  end
  else begin
    if (int_valid || int_valid_d4) begin
      int_valid_o <= int_valid;
      int_sop_o   <= int_sop;
      int_eop_o   <= int_eop;
      int_data_o  <= int_data;
      int_mod_o   <= int_mod;
    end
  end
end

endmodule
