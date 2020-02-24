//------------------------------------------------------------------------------
//    File Name:  PRBS_ANY.v
//      Version:  1.0 
//         Date:  6-jul-10
//------------------------------------------------------------------------------
//
//      Company:  Xilinx, Inc.
//  Contributor:  Daniele Riccardi, Paolo Novellini
// 
//   Disclaimer:  XILINX IS PROVIDING THIS DESIGN, CODE, OR
//                INFORMATION "AS IS" SOLELY FOR USE IN DEVELOPING
//                PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY
//                PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
//                ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
//                APPLICATION OR STANDARD, XILINX IS MAKING NO
//                REPRESENTATION THAT THIS IMPLEMENTATION IS FREE
//                FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE
//                RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY
//                REQUIRE FOR YOUR IMPLEMENTATION.  XILINX
//                EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH
//                RESPECT TO THE ADEQUACY OF THE IMPLEMENTATION,
//                INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
//                REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
//                FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES
//                OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//                PURPOSE.
//
//                (c) Copyright 2010 Xilinx, Inc.
//                All rights reserved.
//
//--------------------------------------------------------------------------
// DESCRIPTION
//--------------------------------------------------------------------------
//   This module generates or check a PRBS pattern. The following table shows how  
//   to set the PARAMETERS for compliance to ITU-T Recommendation O.150 Section 5.
//    
//   When the CHK_MODE is "false", it uses a  LFSR strucure to generate the
//   PRBS pattern.
//   When the CHK_MODE is "true", the incoming data are loaded into prbs registers
//   and compared with the locally generated PRBS 
// 
//--------------------------------------------------------------------------
// PARAMETERS 
//--------------------------------------------------------------------------
//   CHK_MODE     : true =>  check mode
//                  false => generate mode
//   INV_PATTERN  : true : invert prbs pattern
//                     in "generate mode" the generated prbs is inverted bit-wise at outputs
//                     in "check mode" the input data are inverted before processing
//   POLY_LENGHT  : length of the polynomial (= number of shift register stages)
//   POLY_TAP     : intermediate stage that is xor-ed with the last stage to generate to next prbs bit 
//   NBITS        : bus size of DATA_IN and DATA_OUT
//
//--------------------------------------------------------------------------
// NOTES
//--------------------------------------------------------------------------
//
//
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
//
// i=inverted, ni= non-inverted
// (*) non standard
//----------------------------------------------------------------------------
//
// In the generated parallel PRBS, LSB is the first generated bit, for example
//         if the PRBS serial stream is : 000001111011... then
//         the generated PRBS with a parallelism of 3 bit becomes:
//            data_out(2) = 0  1  1  1 ... 
//            data_out(1) = 0  0  1  1 ...  
//            data_out(0) = 0  0  1  0 ... 
// In the received parallel PRBS, LSB is oldest bit received
//
// RESET pin is not needed for power-on reset : all registers are properly inizialized 
// in the source code.
// 
//------------------------------------------------------------------------------
// PINS DESCRIPTION 
//------------------------------------------------------------------------------
//
//      RST          : in : syncronous reset active high
//      CLK          : in : system clock
//      DATA_IN      : in : inject error (in generate mode)
//                          data to be checked (in check mode)
//      EN           : in : enable/pause pattern generation/check
//      DATA_OUT     : out: generated prbs pattern (in generate mode)
//                          error found (in check mode)
//
//-------------------------------------------------------------------------------------------------
// History:
//      Version    : 1.0
//      Date       : 6-jul-10
//      Author     : Daniele Riccardi
//      Description: First release
//-------------------------------------------------------------------------------------------------
// no timescale needed
`timescale 1ns/1ns

module PRBS_ANY(RST, RST_DATA, CLK, DATA_IN, EN, DATA_OUT);

  //--------------------------------------------		
  // Configuration parameters
  //--------------------------------------------		
   parameter CHK_MODE = 0;
   parameter INV_PATTERN = 0;
   parameter POLY_LENGHT = 31;
   parameter POLY_TAP = 3;
   parameter NBITS = 16;

  //--------------------------------------------		
  // Input/Outputs
  //--------------------------------------------		

   input RST;
   input [NBITS - 1:0] RST_DATA;
   input CLK;
   input [NBITS - 1:0] DATA_IN;
   input EN;
   output reg [NBITS - 1:0] DATA_OUT = {NBITS{1'b1}};

  //--------------------------------------------		
  // Internal variables
  //--------------------------------------------		

   wire [1:POLY_LENGHT] prbs[NBITS:0];
   wire [NBITS - 1:0] data_in_i;
   wire [NBITS - 1:0] prbs_xor_a;
   wire [NBITS - 1:0] prbs_xor_b;
   wire [NBITS:1] prbs_msb;
   reg  [1:POLY_LENGHT]prbs_reg = {(POLY_LENGHT){1'b1}};

  //--------------------------------------------		
  // Implementation
  //--------------------------------------------		

   assign data_in_i = INV_PATTERN == 0 ? DATA_IN : ( ~DATA_IN);
   assign prbs[0] = prbs_reg;
   
   genvar I;
   generate for (I=0; I<NBITS; I=I+1) begin : g1
      assign prbs_xor_a[I] = prbs[I][POLY_TAP] ^ prbs[I][POLY_LENGHT];
      assign prbs_xor_b[I] = prbs_xor_a[I] ^ data_in_i[I];
      assign prbs_msb[I+1] = CHK_MODE == 0 ? prbs_xor_a[I]  :  data_in_i[I];  
      assign prbs[I+1]     = {prbs_msb[I+1] , prbs[I][1:POLY_LENGHT-1]};
   end
   endgenerate

   always @(posedge CLK) begin
      if(RST == 1'b 1) begin
         prbs_reg <= RST_DATA[POLY_LENGHT-1:0];//{POLY_LENGHT{1'b1}};
         DATA_OUT <= RST_DATA;//{NBITS{1'b1}};
      end
      else if(EN == 1'b 1) begin
         DATA_OUT <= prbs_xor_b;
         prbs_reg <= prbs[NBITS];
      end
  end

endmodule
