/*
 * File   : buscli_jtag.v
 * Date   : 20150217
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns
module buscli_jtag (
    `ifdef XILINX `ifdef AXI_IP
    inout [35:0] icontrol0,
    `endif `endif
    input  wire           buscli_reset,
    input  wire           buscli_clk,
    output reg            buscli_write,
    output reg            buscli_read,
    output reg  [32-1: 0] buscli_address,
    output reg  [32-1: 0] buscli_writedata,
    input  wire [32-1: 0] buscli_readdata,
    input  wire           buscli_waitrequest,
    input  wire           buscli_irq,
    output wire           buscli_resetrequest
);

wire [4+32+32-1:0] jtag_adda_out;
wire [4+32+32-1:0] jtag_stat_in;

wire rst_en_int, rd_en_int, wr_en_int;
wire [32-1:0] addr_int, data_int;
assign {rst_en_int, rd_en_int, wr_en_int} = jtag_adda_out[66:64];
assign {addr_int, data_int} = jtag_adda_out[32+32-1:0];

reg rst_en_d1, rd_en_d1, wr_en_d1;
always @(posedge buscli_clk) begin
    rst_en_d1 <= rst_en_int;
    rd_en_d1  <= rd_en_int;
    wr_en_d1  <= wr_en_int;
end

wire rst_en_pos = rst_en_int && !rst_en_d1;
wire rd_en_pos  = rd_en_int  && !rd_en_d1;
wire wr_en_pos  = wr_en_int  && !wr_en_d1;

always @(posedge buscli_reset or posedge buscli_clk) begin
    if (buscli_reset) begin
        buscli_write     <= 1'b0;
        buscli_read      <= 1'b0;
        buscli_address   <= 32'd0;
        buscli_writedata <= 32'd0;
    end
    else if (wr_en_pos || rd_en_pos) begin
        buscli_write     <= wr_en_pos;
        buscli_read      <= rd_en_pos;
        buscli_address   <= addr_int;
        buscli_writedata <= data_int;
    end
    else if (buscli_waitrequest) begin
        buscli_write     <= buscli_write;
        buscli_read      <= buscli_read;
        buscli_address   <= buscli_address;
        buscli_writedata <= buscli_writedata;
    end
    else begin
        buscli_write     <= 1'b0;
        buscli_read      <= 1'b0;
        buscli_address   <= buscli_address;
        buscli_writedata <= buscli_writedata;
    end
end


reg [31:0] buscli_clk_counter;
always @(posedge rst_en_pos or posedge buscli_clk) begin
    if (rst_en_pos)
        buscli_clk_counter <= 'd0;
    else
        buscli_clk_counter <= buscli_clk_counter + 1;
end

reg buscli_waitrequest_d1;
always @(posedge buscli_reset or posedge buscli_clk)
    if (buscli_reset)
        buscli_waitrequest_d1 <= 1'b0;
    else
        buscli_waitrequest_d1 <= buscli_waitrequest;

reg [31:0] buscli_readdata_int;
always @(posedge buscli_reset or posedge buscli_clk) begin
    if (buscli_reset)
        buscli_readdata_int <= 32'd0;
    else if (!buscli_waitrequest && buscli_waitrequest_d1)
        buscli_readdata_int <= buscli_readdata;
end

assign jtag_stat_in = {buscli_reset, buscli_waitrequest_d1, buscli_irq, 1'd0, buscli_clk_counter, buscli_readdata_int};

assign buscli_resetrequest = rst_en_pos;

`ifdef XILINX

`ifdef AXI_IP
// external ICON
`else
// internal ICON
wire  [35:0] icontrol0;
`endif

chipscope_vio_adda_stat u_chipscope_vio_adda_stat (
    .adda_out(jtag_adda_out), 
    .stat_in(jtag_stat_in), 
    .clk(buscli_clk), 
    .icon_ctrl(icontrol0)
);
defparam
	u_chipscope_vio_adda_stat.adda_width = 4+32+32,
	u_chipscope_vio_adda_stat.stat_width = 4+32+32;

`ifdef AXI_IP
// external ICON
`else
// internal ICON
chipscope_icon u_chipscope_icon (
	.CONTROL0(icontrol0)
	);
`endif

`endif

endmodule
