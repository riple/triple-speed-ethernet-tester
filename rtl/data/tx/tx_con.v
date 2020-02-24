/*
 * File   : tx_con.v
 * Date   : 20131127
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
//`define ENABLE_Y1564
module tx_con (
    input  wire         rst,
    input  wire         tx_gen_clk,
    input  wire         tx_con_clk,

    input  wire           up_clk,
    input  wire           up_wr,
    input  wire           up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31  : 0] up_data_wr,
    output wire [31  : 0] up_data_rd,

    output reg  [31  : 0] up_data_tx_ctrl,
    input  wire           tx_nontest_return,
    input  wire           tx_err_inj_return,

    input  wire           pause_on,

    input  wire           rate_buffer_rd_rqst,
    output wire           rate_buffer_rd_vald,
    output wire [17  : 0] rate_buffer_rd_data
);
parameter STR_NUM = 8;

parameter [15:0] TX_GEN_CTRL_ADDR = 16'h0010;
parameter [15:0] TX_GEN_STUS_ADDR = 16'h0014;

// cpu access
wire up_cs_bw_con = (up_addr[12]==1'b0)? 1'b1: 1'b0;  // rd 04000xxx
wire up_cs_ir_con = (up_addr[12]==1'b1)? 1'b1: 1'b0;  // rd 04001xxx

wire [31:0] up_data_rd_bw_con;
wire [31:0] up_data_rd_ir_con;

// cpu control to tx_con
always @(posedge up_clk or posedge rst) begin
    if (rst)
        up_data_tx_ctrl <= 'd0;
    else if (up_wr && up_addr[15:0]==TX_GEN_CTRL_ADDR)
        up_data_tx_ctrl <= up_data_wr;
end

// capture cpu control inputs
wire       tx_test    = up_data_tx_ctrl[0];  // +1
wire       testtag_en = up_data_tx_ctrl[1];  // +2
wire       tx_nontest = up_data_tx_ctrl[2];  // +4
`ifdef ENABLE_Y1564
wire       test_y1564 = up_data_tx_ctrl[3];  // +8
`else
wire       test_y1564 = 1'b0;
`endif
wire       tx_lpbk_en  = up_data_tx_ctrl[4];  // enable loopbacked frame
wire       tx_pause_en = up_data_tx_ctrl[5];  // respond to pause frame

wire       tx_err_inj     = up_data_tx_ctrl[   16];  // error injection enable
wire [ 2:0]tx_err_inj_strm= up_data_tx_ctrl[14:12];  // 8 streams
wire [ 3:0]tx_err_inj_type= up_data_tx_ctrl[11: 8];  // 16 types

// tx_con status to cpu
wire [31:0] up_data_tx_stus = {15'd0, tx_err_inj_return, {1'b0, tx_err_inj_strm, tx_err_inj_type}, {4'd0, 1'b0, tx_nontest_return, up_data_tx_ctrl[1], up_data_tx_ctrl[0]}};

// tx_con read to cpu
assign up_data_rd = (up_addr[15:0]==TX_GEN_CTRL_ADDR)? up_data_tx_ctrl: (
                    (up_addr[15:0]==TX_GEN_STUS_ADDR)? up_data_tx_stus: (
                    (up_cs_bw_con)?                    up_data_rd_bw_con: (
                    (up_cs_ir_con)?                    up_data_rd_bw_con: (
                                                       32'hdeadbeef))));

// tx_test synched to tx_con_clk
wire tx_test_pulse, tx_test_level;
synchronizer_level tx_test_sync (
    .clk_out(tx_con_clk),
    .clk_en(1'b1),
    .reset_n(!rst),
    .sync_in(tx_test),

    .sync_out_p1  (tx_test_pulse),
    .sync_out_reg2(tx_test_level)
);

// pause_on synched to tx_con_clk
wire pause_on_level;
synchronizer_level pause_on_sync (
    .clk_out(tx_con_clk),
    .clk_en(1'b1),
    .reset_n(!rst),
    .sync_in(pause_on && tx_pause_en),

    .sync_out_p1  (),
    .sync_out_reg2(pause_on_level)
);

// constant traffic rate generation
wire         bw_rate_wr;
wire [17: 0] bw_rate_wr_data;
bw_con bw_con_inst (
    .rst(rst),
    .clk(tx_con_clk),

    .up_clk(up_clk),
    .up_wr(up_wr && up_cs_bw_con),
    .up_rd(up_rd && up_cs_bw_con),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd_bw_con),

    .tx_test_pulse(tx_test_pulse),
    .tx_test_level(tx_test_level),

    .bw_rate_wr(bw_rate_wr),
    .bw_rate_wr_data(bw_rate_wr_data)
);

// variable traffic rate generation
wire         ir_rate_wr;
wire [35: 0] ir_rate_wr_data;
ir_con ir_con_inst (
    .rst(rst),
    .clk(tx_con_clk),

    .test_start(tx_test_level),

    .up_clk(up_clk),
    .up_wr(up_wr && up_cs_ir_con),
    .up_rd(up_rd && up_cs_ir_con),
    .up_addr(up_addr),
    .up_data_wr(up_data_wr),
    .up_data_rd(up_data_rd_ir_con),

    .frame_fifo_wr_in  (test_y1564? bw_rate_wr: 1'b0),
    .frame_fifo_data_in({6'd0,bw_rate_wr_data[13:0],13'd0,bw_rate_wr_data[16:14]}),

    .frame_fifo_wr_out  (ir_rate_wr),
    .frame_fifo_data_out(ir_rate_wr_data)
);

// rate buffer
wire         rate_buffer_wr      = test_y1564?       ir_rate_wr                                  : bw_rate_wr;
wire [17: 0] rate_buffer_wr_data = test_y1564? {1'b0,ir_rate_wr_data[2:0],ir_rate_wr_data[29:16]}: bw_rate_wr_data;
wire         rate_buffer_rd;
wire         rate_buffer_full;
wire         rate_buffer_empty;
`ifdef XILINX_ZYNQ
FIFO18E1 #(
    .ALMOST_EMPTY_OFFSET(13'h0080), // Sets the almost empty threshold
    .ALMOST_FULL_OFFSET(13'h0080), // Sets almost full threshold
    .DATA_WIDTH(18), // Sets data width to 4-36
    .DO_REG(1), // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
    .EN_SYN("FALSE"), // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
    .FIFO_MODE("FIFO18"), // Sets mode to FIFO18 or FIFO18_36
    .FIRST_WORD_FALL_THROUGH("FALSE"), // Sets the FIFO FWFT to FALSE, TRUE
    .INIT(36'h000000000), // Initial values on output port
    .SIM_DEVICE("7SERIES"), // Must be set to "7SERIES" for simulation behavior
    .SRVAL(36'h000000000) // Set/Reset value for output port
)
FIFO18E1_inst (
    // Read Data: 32-bit (each) output: Read output data
    .DO(DO), // 32-bit output: Data output
    .DOP(DOP), // 4-bit output: Parity data output
    // Status: 1-bit (each) output: Flags and other FIFO status outputs
    .ALMOSTEMPTY(ALMOSTEMPTY), // 1-bit output: Almost empty flag
    .ALMOSTFULL(ALMOSTFULL), // 1-bit output: Almost full flag
    .EMPTY(EMPTY), // 1-bit output: Empty flag
    .FULL(FULL), // 1-bit output: Full flag
    .RDCOUNT(RDCOUNT), // 12-bit output: Read count
    .RDERR(RDERR), // 1-bit output: Read error
    .WRCOUNT(WRCOUNT), // 12-bit output: Write count
    .WRERR(WRERR), // 1-bit output: Write error
    // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
    .RDCLK(RDCLK), // 1-bit input: Read clock
    .RDEN(RDEN), // 1-bit input: Read enable
    .REGCE(REGCE), // 1-bit input: Clock enable
    .RST(RST), // 1-bit input: Asynchronous Reset
    .RSTREG(RSTREG), // 1-bit input: Output register set/reset
    // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
    .WRCLK(WRCLK), // 1-bit input: Write clock
    .WREN(WREN), // 1-bit input: Write enable
    // Write Data: 32-bit (each) input: Write input data
    .DI(DI), // 32-bit input: Data input
    .DIP(DIP) // 4-bit input: Parity input
);
`endif
`ifdef XILINX_SPARTAN6
fifo_dc_18_512 rate_buffer(
    .rst    (rst),
 
    .wr_clk (tx_con_clk),
    .wr_en  (rate_buffer_wr && !rate_buffer_full && !pause_on_level),
    .din    (rate_buffer_wr_data),
    .full   (rate_buffer_full),
    .wr_data_count(),
 
    .rd_clk (tx_gen_clk),
    .rd_en (rate_buffer_rd),
    .dout   (rate_buffer_rd_data),
    .empty  (rate_buffer_empty),
    .rd_data_count()
);
`endif
`ifdef ALTERA
fifo_dc_18_512 rate_buffer(
    .aclr   (rst),
 
    .wrclk  (tx_con_clk),
    .wrreq  (rate_buffer_wr && !rate_buffer_full && !pause_on_level),
    .data   (rate_buffer_wr_data),
    .wrfull (rate_buffer_full),
    .wrusedw(),
 
    .rdclk  (tx_gen_clk),
    .rdreq  (rate_buffer_rd),
    .q      (rate_buffer_rd_data),
    .rdempty(rate_buffer_empty),
    .rdusedw()
);
`endif

// read from rate buffer

reg  rate_buffer_rd_rqst_com, rate_buffer_rd_rqst_com_d1;
always @(*) begin
        rate_buffer_rd_rqst_com <= rate_buffer_rd_rqst && !rate_buffer_empty;
end
always @(posedge tx_gen_clk or posedge rst) begin
    if (rst)
        rate_buffer_rd_rqst_com_d1 <= 1'b0;
    else
        rate_buffer_rd_rqst_com_d1 <= rate_buffer_rd_rqst_com;
end

reg  rate_buffer_rd_rqst_reg, rate_buffer_rd_rqst_reg_d1;
always @(posedge tx_gen_clk or posedge rst) begin
    if (rst)
        rate_buffer_rd_rqst_reg <= 1'b0;
    else if (!rate_buffer_rd_rqst)
        rate_buffer_rd_rqst_reg <= 1'b0;
    else if (rate_buffer_rd_rqst && !rate_buffer_empty)
        rate_buffer_rd_rqst_reg <= 1'b1;
end
always @(posedge tx_gen_clk or posedge rst) begin
    if (rst)
        rate_buffer_rd_rqst_reg_d1 <= 1'b0;
    else
        rate_buffer_rd_rqst_reg_d1 <= rate_buffer_rd_rqst_reg;
end

assign rate_buffer_rd      = rate_buffer_rd_rqst_com && !rate_buffer_rd_rqst_reg;
assign rate_buffer_rd_vald = rate_buffer_rd_rqst_reg;

endmodule
