/*
 * File   : spi_fsm.v
 * Date   : 20140102
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns
module spi_fsm(
    input  wire       spi_cs,
    input  wire       spi_byte_o_en,
    input  wire [7:0] spi_byte_o,
    output reg        spi_byte_i_en,
    output reg  [7:0] spi_byte_i,

    input  wire        up_clk,
    output reg  [31:0] up_addr,
    output reg         up_wr,
    output reg         up_rd,
    output reg  [31:0] up_wr_data,
    input  wire [31:0] up_rd_data
);

parameter CMMD_GET = 8'd5;
parameter CMMD_PUT = 8'd6;

reg spi_byte_o_en_d1, spi_byte_o_en_d2, spi_byte_o_en_d3, spi_byte_o_en_d4;
always @(posedge up_clk) begin
    spi_byte_o_en_d1 <= spi_byte_o_en;
    spi_byte_o_en_d2 <= spi_byte_o_en_d1;
    spi_byte_o_en_d3 <= spi_byte_o_en_d2;
    spi_byte_o_en_d4 <= spi_byte_o_en_d3;
end

// byte index counter for one spi session: 2B+4B, 4B
reg [3:0] spi_byte_cnt;
always @(posedge spi_cs or posedge up_clk) begin
    if (spi_cs)
        spi_byte_cnt <= 'd0;
    else if (spi_byte_o_en)
        spi_byte_cnt <= spi_byte_cnt + 'd1;
end

// capture command
reg [7:0] spi_fsm_cmmd;
always @(posedge spi_cs or posedge up_clk) begin
    if (spi_cs)
        spi_fsm_cmmd <= 8'd0;
    else if (spi_byte_o_en && spi_byte_cnt=='d0)
        spi_fsm_cmmd <= spi_byte_o;
end

// capture address
reg [31:0] spi_fsm_addr;
always @(posedge spi_cs or posedge up_clk) begin
    if (spi_cs)
        spi_fsm_addr <= 32'd0;
    else if (spi_byte_o_en && spi_byte_cnt=='d2)
        spi_fsm_addr[ 7: 0] <= spi_byte_o;
    else if (spi_byte_o_en && spi_byte_cnt=='d3)
        spi_fsm_addr[15: 8] <= spi_byte_o;
    else if (spi_byte_o_en && spi_byte_cnt=='d4)
        spi_fsm_addr[23:16] <= spi_byte_o;
    else if (spi_byte_o_en && spi_byte_cnt=='d5)
        spi_fsm_addr[31:24] <= spi_byte_o;
end

// capture spi output data
reg [31:0] spi_fsm_data_o;
always @(posedge spi_cs or posedge up_clk) begin
    if (spi_cs)
        spi_fsm_data_o <= 32'd0;
    else if (spi_byte_o_en && spi_byte_cnt=='d6)
        spi_fsm_data_o[ 7: 0] <= spi_byte_o;
    else if (spi_byte_o_en && spi_byte_cnt=='d7)
        spi_fsm_data_o[15: 8] <= spi_byte_o;
    else if (spi_byte_o_en && spi_byte_cnt=='d8)
        spi_fsm_data_o[23:16] <= spi_byte_o;
    else if (spi_byte_o_en && spi_byte_cnt=='d9)
        spi_fsm_data_o[31:24] <= spi_byte_o;
end

// generate up interface signals
always @(posedge spi_cs or posedge up_clk) begin
    if (spi_cs)
        up_addr <= 32'd0;
    else if (spi_byte_cnt=='d6 && spi_byte_o_en_d1)
        up_addr <= spi_fsm_addr;
end

always @(posedge spi_cs or posedge up_clk) begin
    if (spi_cs) begin
        up_wr <= 1'b0;
        up_rd <= 1'b0;
    end
    else begin
        if (spi_fsm_cmmd==CMMD_PUT && spi_byte_cnt=='d10 && spi_byte_o_en_d1)
            up_wr <= 1'b1;
        else
            up_wr <= 1'b0;

        if (spi_fsm_cmmd==CMMD_GET && spi_byte_cnt=='d6 && spi_byte_o_en_d1)
            up_rd <= 1'b1;
        else
            up_rd <= 1'b0;        
    end
end

always @(posedge spi_cs or posedge up_clk) begin
    if (spi_cs)
        up_wr_data <= 32'd0;
    else if (spi_byte_cnt=='d10 && spi_byte_o_en_d1)
        up_wr_data <= spi_fsm_data_o;
end

always @(posedge spi_cs or posedge up_clk) begin
    if (spi_cs) begin
        spi_byte_i    <= 32'd0;
        spi_byte_i_en <= 1'b0;
    end
    else begin
             if (spi_fsm_cmmd==CMMD_GET && spi_byte_cnt=='d6)
            spi_byte_i <= up_rd_data[31:24];
        else if (spi_fsm_cmmd==CMMD_GET && spi_byte_cnt=='d7)
            spi_byte_i <= up_rd_data[23:16];
        else if (spi_fsm_cmmd==CMMD_GET && spi_byte_cnt=='d8)
            spi_byte_i <= up_rd_data[15: 8];
        else if (spi_fsm_cmmd==CMMD_GET && spi_byte_cnt=='d9)
            spi_byte_i <= up_rd_data[ 7: 0];
        
             if (spi_fsm_cmmd==CMMD_GET && spi_byte_cnt=='d6 && spi_byte_o_en_d3)
            spi_byte_i_en <= 1'b1;
        else if (spi_fsm_cmmd==CMMD_GET && spi_byte_cnt=='d7 && spi_byte_o_en_d3)
            spi_byte_i_en <= 1'b1;
        else if (spi_fsm_cmmd==CMMD_GET && spi_byte_cnt=='d8 && spi_byte_o_en_d3)
            spi_byte_i_en <= 1'b1;
        else if (spi_fsm_cmmd==CMMD_GET && spi_byte_cnt=='d9 && spi_byte_o_en_d3)
            spi_byte_i_en <= 1'b1;
        else
            spi_byte_i_en <= 1'b0;
    end
end

endmodule

