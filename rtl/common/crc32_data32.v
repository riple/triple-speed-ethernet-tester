/*
 * File   : crc32_data32.v
 * Date   : 20131021
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns / 1 ns
module crc32_data32 (
    input  wire rst,
    input  wire clk,

    input  wire        init_i,
    input  wire        valid_i,
    input  wire [ 1:0] mod_i,
    input  wire [31:0] data_i,

    output reg  [31:0] crc_o
);

function [31:0] bit_swap;
    input [31:0] data;
    integer i;
begin
    for (i=0; i<=7; i=i+1) begin
        bit_swap[31-i] = data[24+i];
        bit_swap[23-i] = data[16+i];
        bit_swap[15-i] = data[ 8+i];
        bit_swap[ 7-i] = data[ 0+i];
    end
end
endfunction

function [31:0] next_div32_data1; // remainder of M(x)/P(x)
    input [31:0] crc;             // previous CRC value
    input        B;               // input data bit (MSB first)
begin
    next_div32_data1 = {crc[30:0], B} ^ ({32{crc[31]}} & 32'b0000_0100_1100_0001_0001_1101_1011_0111);
                                                      // ^26 ^23 ^22 ^16 ^12 ^11 ^10 ^8 ^7 ^5 ^4 ^2 ^1 ^0
end
endfunction

function [31:0] next_crc32_data64;
    input [31:0] crc;
    input [63:0] inp;
    integer i;
begin
    next_crc32_data64 = crc;
    for(i=0; i<64; i=i+1)
        next_crc32_data64 = next_div32_data1(next_crc32_data64, inp[63-i]);
end
endfunction

wire [31:0] data_i_swap = bit_swap(data_i);

reg [31:0] crc;
always @(posedge rst or posedge clk) begin
    if (rst)
        crc <= 32'd0;
    else if (init_i)
        crc <= 32'hffffffff;
    else if (valid_i)
        case (mod_i)
            2'b00: crc <= next_crc32_data64(32'h00000000, {             crc^ data_i_swap[31: 0]              , 32'h00000000});
            2'b01: crc <= next_crc32_data64(32'h00000000, {24'h000000, (crc^{data_i_swap[31:24], 24'h000000}),  8'h00      });
            2'b10: crc <= next_crc32_data64(32'h00000000, {16'h0000  , (crc^{data_i_swap[31:16], 16'h0000  }), 16'h0000    });
            2'b11: crc <= next_crc32_data64(32'h00000000, { 8'h00    , (crc^{data_i_swap[31: 8],  8'h00    }), 24'h000000  });
        endcase
end

wire [31:0] crc_reverse = ~crc;
wire [31:0] crc_swap = bit_swap(crc_reverse);
always @(*) crc_o = crc_swap;

endmodule

