/*
 * File   : rx_payload.v
 * Date   : 20131225
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module rx_payload (
    input  wire rst,
    input  wire clk,

    input  wire        payload_valid,
    input  wire [31:0] payload_data,

    input  wire        payload_pre,
    input  wire [31:0] payload_seed,
    input  wire [ 3:0] payload_type,

    output reg  [31:0] payload_esum
);

// simple data patterns
wire [31:0] cnst_ref = payload_seed;

reg  [31:0] incr_ref;
always @(posedge clk or posedge rst) begin
  if (rst)
    incr_ref <= 32'd0;
  else if (payload_pre)
    incr_ref <= payload_seed;
  else if (payload_valid)
    incr_ref <= incr_ref + 32'd1;
end

reg  [31:0] decr_ref;
always @(posedge clk or posedge rst) begin
  if (rst)
    decr_ref <= 32'd0;
  else if (payload_pre)
    decr_ref <= payload_seed;
  else if (payload_valid)
    decr_ref <= decr_ref - 32'd1;
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

wire [31:0] prbs_31_ref;
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
  .EN(payload_valid),
  .DATA_OUT(prbs_31_ref));

wire [31:0] prbs_23_ref;
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
  .EN(payload_valid),
  .DATA_OUT(prbs_23_ref));

wire [31:0] prbs_15_ref;
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
  .EN(payload_valid),
  .DATA_OUT(prbs_15_ref));

wire [31:0] prbs_11_ref;
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
  .EN(payload_valid),
  .DATA_OUT(prbs_11_ref));

// data pattern error
reg [31:0] payload_err;
always @(*) begin
  case (payload_type)
    4'b0000: payload_err = payload_data ^ cnst_ref;
    4'b0001: payload_err = payload_data ^ incr_ref;
    4'b0010: payload_err = payload_data ^ decr_ref;
    4'b0011: payload_err = payload_data ^ cnst_ref;  // redundant, reserved
    4'b0100: payload_err = payload_data ^ prbs_31_ref;
    4'b0101: payload_err = payload_data ^ prbs_23_ref;
    4'b0110: payload_err = payload_data ^ prbs_15_ref;
    4'b0111: payload_err = payload_data ^ prbs_11_ref;
    default: payload_err = payload_data ^ cnst_ref;
  endcase
end

reg [31:0] payload_enum;
always @(*) begin
  payload_enum = payload_err[ 0] + payload_err[ 8] + payload_err[16] + payload_err[24] +
                 payload_err[ 1] + payload_err[ 9] + payload_err[17] + payload_err[25] +
                 payload_err[ 2] + payload_err[10] + payload_err[18] + payload_err[26] +
                 payload_err[ 3] + payload_err[11] + payload_err[19] + payload_err[27] +
                 payload_err[ 4] + payload_err[12] + payload_err[20] + payload_err[28] +
                 payload_err[ 5] + payload_err[13] + payload_err[21] + payload_err[29] +
                 payload_err[ 6] + payload_err[14] + payload_err[22] + payload_err[30] +
                 payload_err[ 7] + payload_err[15] + payload_err[23] + payload_err[31];
end

// data pattern error sum output
always @(posedge clk or posedge rst) begin
  if (rst)
    payload_esum <= 32'd0;
  else if (payload_pre)
    payload_esum <= 32'd0;
  else if (payload_valid)
    payload_esum <= payload_esum + payload_enum;
end

endmodule

