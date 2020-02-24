/*
 * File   : tx_payload.v
 * Date   : 20131216
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module tx_payload (
    input  wire rst,
    input  wire clk,

    input  wire gen_en,

    input  wire        payload_pre,
    input  wire [31:0] payload_seed,
    input  wire [ 7:0] payload_byte,
    input  wire [ 3:0] payload_type,
    input  wire        payload_err_inj,

    input  wire        payload_valid,
    output reg  [31:0] payload_data
);

parameter TYPE_CNST = 4'b0000;
parameter TYPE_INCR = 4'b0001;
parameter TYPE_DECR = 4'b0010;
parameter TYPE_XXXX = 4'b0011;
parameter TYPE_2E31 = 4'b0100;
parameter TYPE_2E23 = 4'b0101;
parameter TYPE_2E15 = 4'b0110;
parameter TYPE_2E11 = 4'b0111;

// simple data patterns
wire [31:0] cnst_out = {payload_byte, payload_byte, payload_byte, payload_byte};

reg  [31:0] incr_out;
always @(posedge clk or posedge rst) begin
  if (rst)
    incr_out <= 32'd0;
  else if (payload_pre && payload_type==TYPE_INCR)
    incr_out <= payload_seed;
  else if (payload_valid && payload_type==TYPE_INCR)
    incr_out <= incr_out + 32'd1;
end

reg  [31:0] decr_out;
always @(posedge clk or posedge rst) begin
  if (rst)
    decr_out <= 32'd0;
  else if (payload_pre && payload_type==TYPE_DECR)
    decr_out <= payload_seed;
  else if (payload_valid && payload_type==TYPE_DECR)
    decr_out <= decr_out - 32'd1;
end

//   Set paramaters to the following values for a ITU-T compliant PRBS
//------------------------------------------------------------------------------
// POLY_LENGHT POLY_TAP INV_PATTERN  || nbr of   bit seq.   max 0      feedback   
//                                   || stages    length  sequence      stages  
//------------------------------------------------------------------------------ 
//     7          6       false      ||    7         127      6 ni        6, 7   (*)
//     9          5       false      ||    9         511      8 ni        5, 9   
//    11          9       false      ||   11        2047     10 ni        9,11   
//    15         14       true       ||   15       32767     15 i        14,15   
//    20          3       false      ||   20     1048575     19 ni        3,20   
//    23         18       true       ||   23     8388607     23 i        18,23   
//    29         27       true       ||   29   536870911     29 i        27,29   
//    31         28       true       ||   31  2147483647     31 i        28,31

wire [31:0] prbs_31_out;
PRBS_ANY #(
  .CHK_MODE(0),
  .INV_PATTERN(1),
  .POLY_LENGHT(31),
  .POLY_TAP(28),
  .NBITS(32))
PRBS_31(
  .RST(payload_pre),
  .RST_DATA(payload_seed),
  .CLK(clk),
  .DATA_IN(32'd0),
  .EN(payload_valid && payload_type==TYPE_2E31),
  .DATA_OUT(prbs_31_out));

wire [31:0] prbs_23_out;
PRBS_ANY #(
  .CHK_MODE(0),
  .INV_PATTERN(1),
  .POLY_LENGHT(23),
  .POLY_TAP(18),
  .NBITS(32))
PRBS_23(
  .RST(payload_pre),
  .RST_DATA(payload_seed),
  .CLK(clk),
  .DATA_IN(32'd0),
  .EN(payload_valid && payload_type==TYPE_2E23),
  .DATA_OUT(prbs_23_out));

wire [31:0] prbs_15_out;
PRBS_ANY #(
  .CHK_MODE(0),
  .INV_PATTERN(1),
  .POLY_LENGHT(15),
  .POLY_TAP(14),
  .NBITS(32))
PRBS_15(
  .RST(payload_pre),
  .RST_DATA(payload_seed),
  .CLK(clk),
  .DATA_IN(32'd0),
  .EN(payload_valid && payload_type==TYPE_2E15),
  .DATA_OUT(prbs_15_out));

wire [31:0] prbs_11_out;
PRBS_ANY #(
  .CHK_MODE(0),
  .INV_PATTERN(0),
  .POLY_LENGHT(11),
  .POLY_TAP(9),
  .NBITS(32))
PRBS_11(
  .RST(payload_pre),
  .RST_DATA(payload_seed),
  .CLK(clk),
  .DATA_IN(32'd0),
  .EN(payload_valid && payload_type==TYPE_2E11),
  .DATA_OUT(prbs_11_out));

// data pattern output
reg [31:0] payload_data_org;
always @(*) begin
  case (payload_type)
    TYPE_CNST: payload_data_org = cnst_out;
    TYPE_INCR: payload_data_org = incr_out;
    TYPE_DECR: payload_data_org = decr_out;
    TYPE_XXXX: payload_data_org = cnst_out;  // redundant, reserved
    TYPE_2E31: payload_data_org = prbs_31_out;
    TYPE_2E23: payload_data_org = prbs_23_out;
    TYPE_2E15: payload_data_org = prbs_15_out;
    TYPE_2E11: payload_data_org = prbs_11_out;
    default: payload_data_org = cnst_out;
  endcase
end

reg payload_pre_d1, payload_pre_d2;
always @(posedge clk or posedge rst) begin
  if (rst) begin
    payload_pre_d1 <= 1'b0;
    payload_pre_d2 <= 1'b0;
  end 
  else if (gen_en) begin
    payload_pre_d1 <= payload_pre;
    payload_pre_d2 <= payload_pre_d1;
  end
end

wire payload_err = payload_pre_d2 && payload_err_inj;
always @(*) begin
  if (payload_err)
    payload_data = {(~payload_data_org[31]), payload_data_org[30:0]};
  else
    payload_data = payload_data_org[31:0];
end

endmodule

