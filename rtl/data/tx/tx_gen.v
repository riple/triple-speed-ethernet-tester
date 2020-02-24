/*
 * File   : tx_gen.v
 * Date   : 20131021
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module tx_gen (
    input  wire rst,
    input  wire clk,

    input  wire           up_clk,
    input  wire           up_wr,
    input  wire           up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31  : 0] up_data_wr,
    output wire [31  : 0] up_data_rd,

    input  wire [31  : 0] up_data_tx_ctrl,
    output reg            tx_nontest_return,
    output reg            tx_err_inj_return,

    input  wire [31: 0] sys_time_tx,

    input  wire gen_en,

    output reg            rate_buffer_rd_rqst,
    input  wire           rate_buffer_rd_vald,
    input  wire [17  : 0] rate_buffer_rd_data,

    output reg         lpbk_info_rqst,
    input  wire        lpbk_info_vald,
    input  wire [31:0] lpbk_info_data,
    output wire        lpbk_buff_rden,
    output wire [11:0] lpbk_buff_rdad,
    input  wire [31:0] lpbk_buff_rdda,

    output reg         int_valid_o,
    output reg  [31:0] int_data_o,
    output reg         int_sop_o,
    output reg         int_eop_o,
    output reg  [ 1:0] int_mod_o,

    output reg         tx_stat_chk,
    output reg [ 3: 0] tx_stat_base_addr,
    output reg [63: 0] tx_stat_bit,
    output reg[575: 0] tx_stat_vec
);

parameter [15:0] TX_GEN_STRM0_CONF_ADDR = 16'h0000;
parameter [15:0] TX_GEN_STRM1_CONF_ADDR = 16'h0100;
parameter [15:0] TX_GEN_STRM2_CONF_ADDR = 16'h0200;
parameter [15:0] TX_GEN_STRM3_CONF_ADDR = 16'h0300;
parameter [15:0] TX_GEN_STRM4_CONF_ADDR = 16'h0400;
parameter [15:0] TX_GEN_STRM5_CONF_ADDR = 16'h0500;
parameter [15:0] TX_GEN_STRM6_CONF_ADDR = 16'h0600;
parameter [15:0] TX_GEN_STRM7_CONF_ADDR = 16'h0700;

parameter [15:0] TX_GEN_CPUTX_CONF_ADDR = 16'h0800;

// tx_gen control
wire       tx_test        = up_data_tx_ctrl[    0];  // +1
wire       testtag_en     = up_data_tx_ctrl[    1] || 1'b1;  // +2
wire       tx_nontest     = up_data_tx_ctrl[    2];  // +4
wire       test_y1564     = up_data_tx_ctrl[    3];  // +8
wire       tx_lpbk_en     = up_data_tx_ctrl[    4];  // +16
wire       tx_pause_en    = up_data_tx_ctrl[    5];  // +32
wire       tx_err_inj     = up_data_tx_ctrl[   16];  // error injection enable
wire [ 2:0]tx_err_inj_strm= up_data_tx_ctrl[14:12];  // 8 streams
wire [ 3:0]tx_err_inj_type= up_data_tx_ctrl[11: 8];  // 16 types


// tx_gen data to cpu
wire        up_cs_info = 1'b1;

reg [31:0] header_info [8:0];  // TODO: use memory to store
always @(posedge up_clk) begin
    if (up_wr && up_cs_info && up_addr[11:2]==TX_GEN_STRM0_CONF_ADDR[11:2])
            header_info[0] <= up_data_wr;
    if (up_wr && up_cs_info && up_addr[11:2]==TX_GEN_STRM1_CONF_ADDR[11:2])
            header_info[1] <= up_data_wr;
    if (up_wr && up_cs_info && up_addr[11:2]==TX_GEN_STRM2_CONF_ADDR[11:2])
            header_info[2] <= up_data_wr;
    if (up_wr && up_cs_info && up_addr[11:2]==TX_GEN_STRM3_CONF_ADDR[11:2])
            header_info[3] <= up_data_wr;
    if (up_wr && up_cs_info && up_addr[11:2]==TX_GEN_STRM4_CONF_ADDR[11:2])
            header_info[4] <= up_data_wr;
    if (up_wr && up_cs_info && up_addr[11:2]==TX_GEN_STRM5_CONF_ADDR[11:2])
            header_info[5] <= up_data_wr;
    if (up_wr && up_cs_info && up_addr[11:2]==TX_GEN_STRM6_CONF_ADDR[11:2])
            header_info[6] <= up_data_wr;
    if (up_wr && up_cs_info && up_addr[11:2]==TX_GEN_STRM7_CONF_ADDR[11:2])
            header_info[7] <= up_data_wr;
    
    if (up_wr && up_cs_info && up_addr[11:2]==TX_GEN_CPUTX_CONF_ADDR[11:2])
            header_info[8] <= up_data_wr;
end

// tx_gen read to cpu
wire [31:0] up_data_info;
assign up_data_rd = up_data_info;


// tx_test synched to clk
wire tx_test_pulse, tx_test_level;
synchronizer_level tx_test_sync (
    .clk_out(clk),
    .clk_en(gen_en),
    .reset_n(!rst),
    .sync_in(tx_test),

    .sync_out_p1  (tx_test_pulse),
    .sync_out_reg2(tx_test_level)
);

// tx_nontest synched to clk
wire tx_nontest_pulse, tx_nontest_level;
synchronizer_level tx_nontest_sync (
    .clk_out(clk),
    .clk_en(gen_en),
    .reset_n(!rst),
    .sync_in(tx_nontest),

    .sync_out_p1  (tx_nontest_pulse),
    .sync_out_reg2(tx_nontest_level)
);

// tx_err_inj synched to clk
wire tx_err_inj_pulse, tx_err_inj_level;
synchronizer_level tx_err_inj_sync (
    .clk_out(clk),
    .clk_en(gen_en),
    .reset_n(!rst),
    .sync_in(tx_err_inj),

    .sync_out_p1  (tx_err_inj_pulse),
    .sync_out_reg2(tx_err_inj_level)
);


// CPU generated packet control
reg  tx_nontest_req;
wire tx_nontest_ack;
always @(posedge clk or posedge rst) begin
    if (rst)
        tx_nontest_req <= 1'b0;
    else if (gen_en)
        if (tx_nontest_pulse)
            tx_nontest_req <= 1'b1;
        else if (tx_nontest_ack)
            tx_nontest_req <= 1'b0;
end  // capture cpu command, until responded by FSM

reg  nontest_latch;
wire nontest_start;
wire nontest_done;
always @(posedge clk or posedge rst) begin
    if (rst)
        nontest_latch <= 1'b0;
    else if (gen_en)
        if (nontest_start)
            nontest_latch <= 1'b1;
        else if (nontest_done)
            nontest_latch <= 1'b0;
end  // hold the command captured by FSM, lasting for a cycle of the FSM, this is the singal used by internal logic

always @(posedge clk or negedge tx_nontest) begin
    if (!tx_nontest)
        tx_nontest_return <= 1'b0;
    else if (gen_en)
        if (nontest_done)
            tx_nontest_return <= 1'b1;
end  // return to cpu command, until the command is cleared by cpu

reg tx_nontest_pulse_d1;
always @(posedge clk or posedge rst) begin
    if (rst)
        tx_nontest_pulse_d1 <= 1'b0;
    else if (gen_en)
        tx_nontest_pulse_d1 <= tx_nontest_pulse;
end


// loopback 
wire lpbk_info_busy;
always @(posedge clk or posedge rst) begin
    if (rst)
        lpbk_info_rqst <= 1'b0;
    else if (gen_en)
        if (lpbk_info_vald)
            lpbk_info_rqst <= 1'b0;
        else if (!lpbk_info_busy)
            lpbk_info_rqst <= 1'b1;
end
wire lpbk_info_vald_ack;
reg  lpbk_info_vald_latch;
always @(posedge clk or posedge rst) begin
    if (rst)
        lpbk_info_vald_latch <= 1'b0;
    else if (gen_en)
        if (lpbk_info_vald)
            lpbk_info_vald_latch <= 1'b1;
        else if (lpbk_info_vald_ack)
            lpbk_info_vald_latch <= 1'b0;
end
wire lpbk_info_vald_int = lpbk_info_vald_latch || lpbk_info_vald;

// cpu error injection control
reg  tx_err_inj_req;
wire tx_err_inj_ack;
always @(posedge clk or posedge rst) begin
    if (rst)
        tx_err_inj_req <= 1'b0;
    else if (gen_en)
        if (tx_err_inj_pulse)
            tx_err_inj_req <= 1'b1;
        else if (tx_err_inj_ack)
            tx_err_inj_req <= 1'b0;
end  // capture cpu command, until responded by FSM

reg  err_inj_latch;
wire err_inj_start;
wire err_inj_done;
always @(posedge clk or posedge rst) begin
    if (rst)
        err_inj_latch <= 1'b0;
    else if (gen_en)
        if (err_inj_start)
            err_inj_latch <= 1'b1;
        else if (err_inj_done)
            err_inj_latch <= 1'b0;
end  // hold the command captured by FSM, lasting for a cycle of the FSM, this is the singal used by internal logic

always @(posedge clk or negedge tx_err_inj) begin
    if (!tx_err_inj)
        tx_err_inj_return <= 1'b0;
    else if (gen_en)
        if (err_inj_done)
            tx_err_inj_return <= 1'b1;
end  // return to cpu command, until the command is cleared by cpu


// cpu test frame header information to tx_gen
reg         info_rd, info_wr;
reg  [ 9:0] info_addr, info_addr_d1;
reg  [31:0] info_data_wr;
wire [31:0] info_data_rd;
dpram_dc_32_1024 info_mem(
    // cpu access
    .aclr_a(rst),
    .clock_a(up_clk),
    .enable_a(1'b1),
    .rden_a(up_rd && up_cs_info),
    .wren_a(up_wr && up_cs_info),
    .address_a(up_addr[11:2]),
    .data_a(up_data_wr),
    .q_a(up_data_info),
    // tx_gen access
    .aclr_b(rst),
    .clock_b(clk),
    .enable_b(gen_en),
    .rden_b(info_rd),
    .wren_b(info_wr),
    .address_b(info_addr),
    .data_b(info_data_wr),
    .q_b(info_data_rd)
);// low 2kB for test frame header (8x256B); high 2kB for nontest frame generation (1x2kB), longest non-test frame is 2048B+4B


// test traffic generation from tx_con
wire       framend_trigger;
wire tx_gen_traffic_ready = rate_buffer_rd_vald;

reg [15:0] frame_leng;
always @(posedge clk) begin
    if (gen_en)
        if (rate_buffer_rd_vald)
            frame_leng <= {2'b00, rate_buffer_rd_data[13: 0]};
end

reg [ 2:0] stream_index;
always @(posedge clk) begin
    if (gen_en)
        if (rate_buffer_rd_vald)
           stream_index <=        rate_buffer_rd_data[16:14];
end

// packet information inferred from cpu input
reg  [15:0] header_leng;
reg  [15:0] payload_tag;
reg  [63:0] header_stat;
wire [ 4:0] testtag_leng = testtag_en? 'd20: 'd0;
wire [15:0] payload_leng = {frame_leng[15:2],2'b00} + ((frame_leng[1:0]==2'b00)? 'd0: 'd4) - header_leng - testtag_leng - 'd4 - 'd4;  // 4B padding, 4B CRC
wire [ 3:0] ifg_leng     = (nontest_latch || tx_lpbk_en)? ((header_leng[1:0]==2'b00)? 'd12: 'd8): ((frame_leng[1:0]==2'b00)? 'd12: 'd8);

// test tag information
wire        testsop_trigger;
wire [31:0] time_stamp = sys_time_tx;

wire       testtag_trigger;
reg [31:0] seq_num [7:0];  // TODO: use memory to store
always @(posedge clk or posedge rst) begin
    if (rst) begin
            seq_num[7] <= 'd0;
            seq_num[6] <= 'd0;
            seq_num[5] <= 'd0;
            seq_num[4] <= 'd0;
            seq_num[3] <= 'd0;
            seq_num[2] <= 'd0;
            seq_num[1] <= 'd0;
            seq_num[0] <= 'd0;
    end
    else if (gen_en) begin
        if (testtag_trigger) begin
            if (err_inj_latch && tx_err_inj_type[3:2]==2'b01)
                case (tx_err_inj_type[1:0])
            /*los*/ 2'd0: seq_num[stream_index] <= seq_num[stream_index] + 'd2;
            /*oos*/ 2'd1: seq_num[stream_index] <= seq_num[stream_index] - 'd1;
            /*dup*/ 2'd2: seq_num[stream_index] <= seq_num[stream_index] + 'd0;
            /*xxx*/ 2'd3: seq_num[stream_index] <= seq_num[stream_index] + 'd1;
                endcase
            else
                seq_num[stream_index] <= seq_num[stream_index] + 'd1;
        end
    end
end

//////////////////////////////////
// Main FSM
//////////////////////////////////

// FSM to generate packet: preamble/sfd, header, payload, tag, crc
reg  [ 3:0] tx_gen_curr_st, tx_gen_next_st, tx_gen_last_st;
reg  [15:0] st_hold_cntr;
reg  [15:0] frame_leng_cntr;
reg  [ 3:0] ifg_leng_latch;

parameter [3:0]
TX_GEN_IDLE     =                   0,  // 0
TX_GEN_PREAMBLE = TX_GEN_IDLE     + 1,  // 1
TX_GEN_HEADER   = TX_GEN_PREAMBLE + 1,  // 2
TX_GEN_PAYLOAD  = TX_GEN_HEADER   + 1,  // 3
TX_GEN_TESTTAG  = TX_GEN_PAYLOAD  + 1,  // 4
TX_GEN_PADDING  = TX_GEN_TESTTAG  + 1,  // 5
TX_GEN_CRC      = TX_GEN_PADDING  + 1,  // 6
TX_GEN_IFG      = TX_GEN_CRC      + 1;  // 7

always @(posedge clk or posedge rst) begin
    if (rst)
        tx_gen_curr_st <= TX_GEN_IDLE;
    else if (gen_en)
        tx_gen_curr_st <= tx_gen_next_st;
end

always @(*) begin
    case (tx_gen_curr_st)
        TX_GEN_IDLE:
            if (tx_nontest_pulse_d1)
                tx_gen_next_st = TX_GEN_PREAMBLE;
            else if (tx_test_level && tx_gen_traffic_ready)
                tx_gen_next_st = TX_GEN_PREAMBLE;
            else if (tx_lpbk_en && lpbk_info_vald_int)
                tx_gen_next_st = TX_GEN_PREAMBLE;
            else
                tx_gen_next_st = TX_GEN_IDLE;
        TX_GEN_PREAMBLE:
            if (st_hold_cntr=='d8/4-'d1)
                tx_gen_next_st = TX_GEN_HEADER;
            else
                tx_gen_next_st = TX_GEN_PREAMBLE;
        TX_GEN_HEADER:
            if (st_hold_cntr==header_leng/4-'d1 && !(nontest_latch || tx_lpbk_en))   
                if (payload_leng/4=='d0)
                    tx_gen_next_st = testtag_en? TX_GEN_TESTTAG: TX_GEN_PADDING;
                else
                    tx_gen_next_st = TX_GEN_PAYLOAD;
            else if (st_hold_cntr==header_leng/4-'d2 && (nontest_latch || tx_lpbk_en) && header_leng[1:0]==2'b00)
                tx_gen_next_st = TX_GEN_PADDING;
            else if (st_hold_cntr==header_leng/4-'d1 && (nontest_latch || tx_lpbk_en) && header_leng[1:0]!=2'b00)
                tx_gen_next_st = TX_GEN_PADDING;
            else
                tx_gen_next_st = TX_GEN_HEADER;
        TX_GEN_PAYLOAD:
            if (st_hold_cntr==payload_leng/4-'d1)
                tx_gen_next_st = testtag_en? TX_GEN_TESTTAG: TX_GEN_PADDING;
            else
                tx_gen_next_st = TX_GEN_PAYLOAD;
        TX_GEN_TESTTAG:
            if (st_hold_cntr==testtag_leng/4-'d1)
                tx_gen_next_st = TX_GEN_PADDING;
            else
                tx_gen_next_st = TX_GEN_TESTTAG;
        TX_GEN_PADDING:
            if (st_hold_cntr=='d4/4-'d1)
                tx_gen_next_st = TX_GEN_CRC;
            else
                tx_gen_next_st = TX_GEN_PADDING;
        TX_GEN_CRC:
            if (st_hold_cntr=='d4/4-'d1)
                tx_gen_next_st = TX_GEN_IFG;
            else
                tx_gen_next_st = TX_GEN_CRC;
        TX_GEN_IFG:
            if (st_hold_cntr>=ifg_leng_latch/4-'d1)
                if (!tx_test_level && !tx_lpbk_en)
                    tx_gen_next_st = TX_GEN_IDLE;
                else if (tx_test_level && tx_gen_traffic_ready)
                    tx_gen_next_st = TX_GEN_PREAMBLE;
                else if (tx_lpbk_en && lpbk_info_vald_int)
                    tx_gen_next_st = TX_GEN_PREAMBLE;
                else
                    tx_gen_next_st = TX_GEN_IFG;
            else
                tx_gen_next_st = TX_GEN_IFG;
        default:
            tx_gen_next_st = TX_GEN_IDLE;
    endcase
end

// FSM control feedback signals
always @(posedge rst or posedge clk) begin
    if (rst)
        st_hold_cntr <= 'd0;
    else if (gen_en)
        if (tx_gen_next_st!=tx_gen_curr_st)
            st_hold_cntr <= 'd0;
        else if (st_hold_cntr==16'hffff)
            st_hold_cntr <= st_hold_cntr;
        else if (tx_gen_curr_st!=TX_GEN_IDLE)
            st_hold_cntr <= st_hold_cntr + 'd1;
end

always @(posedge rst or posedge clk) begin
    if (rst)
        tx_gen_last_st <= 'd0;
    else if (gen_en)
        tx_gen_last_st <= tx_gen_curr_st;
end

wire [2:0] frame_leng_mod;
always @(posedge rst or posedge clk) begin
    if (rst)
        frame_leng_cntr <= 'd0;
    else if (gen_en)
             if (tx_gen_curr_st==TX_GEN_IDLE)
            frame_leng_cntr <= 'd0;
        else if (tx_gen_curr_st==TX_GEN_PREAMBLE)
            frame_leng_cntr <= 'd0;
        else if (tx_gen_curr_st==TX_GEN_IFG)
            frame_leng_cntr <= frame_leng_cntr;
        else if (tx_gen_curr_st==TX_GEN_CRC)
            frame_leng_cntr <= frame_leng_cntr + frame_leng_mod;
        else
            frame_leng_cntr <= frame_leng_cntr + 'd4;
end

always @(posedge rst or posedge clk) begin
    if (rst)
        ifg_leng_latch <= 'd0;
    else if (gen_en)
        if (tx_gen_curr_st==TX_GEN_PREAMBLE)
            ifg_leng_latch <= ifg_leng;
end

assign lpbk_info_busy = (tx_gen_curr_st==TX_GEN_IDLE || tx_gen_curr_st==TX_GEN_CRC)? 1'b0: 1'b1;
assign lpbk_info_vald_ack = (tx_gen_curr_st==TX_GEN_PREAMBLE)? 1'b1: 1'b0;

// FSM output feedback signals
assign testsop_trigger = (tx_gen_curr_st==TX_GEN_PREAMBLE && st_hold_cntr=='d0)? 1'b1: 1'b0;
assign testtag_trigger = (tx_gen_curr_st==TX_GEN_TESTTAG  && st_hold_cntr=='d0)? 1'b1: 1'b0;
assign framend_trigger = (tx_gen_curr_st==TX_GEN_IFG      && st_hold_cntr=='d0)? 1'b1: 1'b0;
assign tx_nontest_ack  = (tx_gen_curr_st!=TX_GEN_PREAMBLE && tx_gen_next_st==TX_GEN_PREAMBLE && tx_nontest_req)? 1'b1: 1'b0;
assign nontest_start   = tx_nontest_ack;
assign nontest_done    = (tx_gen_curr_st==TX_GEN_IFG      && st_hold_cntr=='d1 && nontest_latch)? 1'b1: 1'b0;
assign tx_err_inj_ack  = (tx_gen_curr_st==TX_GEN_PREAMBLE && st_hold_cntr=='d1 && tx_err_inj_req && !(nontest_latch || tx_lpbk_en) && stream_index==tx_err_inj_strm)? 1'b1: 1'b0;
assign err_inj_start   = tx_err_inj_ack;
assign err_inj_done    = (tx_gen_curr_st==TX_GEN_IFG      && st_hold_cntr=='d1 && err_inj_latch)? 1'b1: 1'b0;

always @(posedge clk or posedge rst) begin
    if (rst)
        rate_buffer_rd_rqst <= 1'b0;
    else if (gen_en)
             if (tx_gen_curr_st==TX_GEN_PREAMBLE && rate_buffer_rd_vald && !(nontest_latch || tx_lpbk_en))
            rate_buffer_rd_rqst <= 1'b0;
        else if (tx_gen_curr_st==TX_GEN_IDLE && tx_test_level)
            rate_buffer_rd_rqst <= 1'b1;
        else if (tx_gen_next_st==TX_GEN_IFG  && tx_test_level && tx_gen_curr_st!=TX_GEN_IFG)
            rate_buffer_rd_rqst <= 1'b1;
end

always @(posedge rst or posedge clk) begin
    if (rst) begin
        info_addr <= 'd0;
        info_rd   <= 1'b0;
    end
    else if (gen_en)
        //     if (tx_gen_curr_st!=TX_GEN_PREAMBLE && tx_gen_next_st==TX_GEN_PREAMBLE) begin
        //    info_addr <= tx_nontest_req? {1'b1, 9'd0}:           {1'b0, stream_index, 6'd0};  // 64x4b=256B frame header
        //    info_rd   <= 1'b1;
        //end
             if (tx_gen_curr_st==TX_GEN_PREAMBLE && st_hold_cntr=='d0) begin
            info_addr <= tx_lpbk_en?     10'd0: ((nontest_latch? {1'b1, 9'd0          }: {1'b0, stream_index, 6'd0          }) + 'd1);  // 64x4b=256B frame header
            info_rd   <= 1'b1;
        end
        else if (tx_gen_curr_st!=TX_GEN_IDLE) begin
               if (((nontest_latch || tx_lpbk_en) && info_addr[8:0] < header_leng/4+'d2) || (!(nontest_latch || tx_lpbk_en) && info_addr[5:0] < header_leng/4+'d2)) begin
            info_addr <= (tx_lpbk_en? info_addr: (nontest_latch? {1'b1, info_addr[8:0]}: {1'b0, stream_index, info_addr[5:0]})) + 'd1;
            info_rd   <= 1'b1;
          end
          else if ((nontest_latch || tx_lpbk_en) && info_addr[8:0] == header_leng/4+'d2 && header_leng[1:0]!=2'b00) begin
            info_addr <= (tx_lpbk_en? info_addr: (nontest_latch? {1'b1, info_addr[8:0]}: {1'b0, stream_index, info_addr[5:0]})) + 'd1;
            info_rd   <= 1'b1;
          end
          else begin
            info_addr <= info_addr;
            info_rd   <= 1'b0;
          end
        end
        else begin
            info_addr <= 'd0;
            info_rd   <= 1'b0;
        end
end

reg [11:0] lpbk_buff_base;
reg [ 3:0] lpbk_stream_index;
assign lpbk_buff_rden = info_rd;
assign lpbk_buff_rdad = info_addr + lpbk_buff_base;

always @(posedge rst or posedge clk) begin
    if (rst)
        lpbk_buff_base <= 'd0;
    else if (gen_en)
        if (lpbk_info_vald &&  tx_lpbk_en)
            lpbk_buff_base <= lpbk_info_data[11: 0];
end

always @(posedge rst or posedge clk) begin
    if (rst)
        lpbk_stream_index <= 'd0;
    else if (gen_en)
        if (lpbk_info_vald &&  tx_lpbk_en)
            lpbk_stream_index <= lpbk_info_data[15:12];
end

always @(posedge clk) begin
    if (gen_en)
        info_addr_d1 <= info_addr;
end

always @(posedge rst or posedge clk) begin
    if (rst)
        header_leng <= 'd16;  // 14B min + 2B tag
    else if (gen_en)
             if (info_addr[5:0]==6'd1 && !(nontest_latch || tx_lpbk_en))
            header_leng <= header_info[stream_index][15:0];
        else if (info_addr[8:0]==9'd1 &&  (nontest_latch))
            header_leng <= header_info[8           ][15:0];
        else if (lpbk_info_vald &&  tx_lpbk_en)
            header_leng <= lpbk_info_data[31:16];
end

always @(posedge rst or posedge clk) begin
    if (rst)
        payload_tag <= 'd0;
    else if (gen_en)
             if (info_addr[5:0]==6'd1 && !(nontest_latch || tx_lpbk_en))
            payload_tag <= header_info[stream_index][31:16];
end

always @(posedge rst or posedge clk) begin
    if (rst)
        header_stat <= 64'd0;
    else if (gen_en) begin
             if ((info_addr_d1[5:0]==header_leng/4+'d1)                                     && !(nontest_latch || tx_lpbk_en))
            header_stat[63:32] <= info_data_rd[31: 0];
        else if ((info_addr_d1[8:0]==header_leng/4+'d1+((header_leng[1:0]==2'b00)?'d0:'d1)) &&   nontest_latch)
            header_stat[63:32] <= info_data_rd[31: 0];
        else if ((info_addr_d1[8:0]==header_leng/4+'d0+((header_leng[1:0]==2'b00)?'d0:'d1)) &&   tx_lpbk_en)
            header_stat[63:32] <= lpbk_buff_rdda[31: 0];

             if ((info_addr_d1[5:0]==header_leng/4+'d2)                                     && !(nontest_latch || tx_lpbk_en))
            header_stat[31: 0] <= info_data_rd[31: 0];
        else if ((info_addr_d1[8:0]==header_leng/4+'d2+((header_leng[1:0]==2'b00)?'d0:'d1)) &&   nontest_latch)
            header_stat[31: 0] <= info_data_rd[31: 0];
        else if ((info_addr_d1[8:0]==header_leng/4+'d1+((header_leng[1:0]==2'b00)?'d0:'d1)) &&   tx_lpbk_en)
            header_stat[31: 0] <= lpbk_buff_rdda[31: 0];
    end
end

// generate payload
wire        payload_pre   = (tx_gen_curr_st!=TX_GEN_PAYLOAD  && tx_gen_next_st==TX_GEN_PAYLOAD && !(nontest_latch || tx_lpbk_en))? 1'b1: 1'b0;
wire        payload_last  = (tx_gen_curr_st==TX_GEN_PAYLOAD  && tx_gen_next_st!=TX_GEN_PAYLOAD && !(nontest_latch || tx_lpbk_en))? 1'b1: 1'b0;
wire        payload_valid = (tx_gen_curr_st==TX_GEN_PAYLOAD                                    && !(nontest_latch || tx_lpbk_en))? 1'b1: 1'b0;
wire [31:0] payload_data;
reg  [31:0] payload_seed [7:0];  // TODO: use memory to store
tx_payload payload_gen (
    .rst(rst),
    .clk(clk),

    .gen_en(gen_en),

    .payload_pre (payload_pre && gen_en),
    .payload_seed(payload_seed[stream_index]),
    .payload_byte(payload_tag[ 7: 0]),  // 8bit for cnst
    .payload_type(payload_tag[15:12]),  // 0~3: cnst,incr,decr,cnst; 4~7: 2e31,2e23,2e15,2e11
    .payload_err_inj(err_inj_latch && tx_err_inj_type==4'd1),

    .payload_valid(payload_valid && gen_en),
    .payload_data(payload_data)
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
            payload_seed[7] <= 32'ha5a5a5a5;
            payload_seed[6] <= 32'ha5a5a5a5;
            payload_seed[5] <= 32'ha5a5a5a5;
            payload_seed[4] <= 32'ha5a5a5a5;
            payload_seed[3] <= 32'ha5a5a5a5;
            payload_seed[2] <= 32'ha5a5a5a5;
            payload_seed[1] <= 32'ha5a5a5a5;
            payload_seed[0] <= 32'ha5a5a5a5;
    end
    else if (gen_en) begin
        if (payload_last)
            payload_seed[stream_index] <= payload_data;
    end
end

// for L4 checksum
reg  [17:0] int_l4_sum;
wire [15:0] int_l4_sum_cmp;

// FSM output signals
reg         int_valid;
reg  [31:0] int_data;
reg         int_sop;
reg         int_eop;
reg  [ 1:0] int_mod;
always @(posedge rst or posedge clk) begin
    if (rst) begin
        int_valid <= 1'b0;
        int_data  <= 32'd0;
        int_sop   <= 1'b0;
        int_eop   <= 1'b0;
        int_mod   <= 2'b00;
    end
    else if (gen_en)
        // preamble + SFD
             if (tx_gen_curr_st==TX_GEN_PREAMBLE && st_hold_cntr=='d0) begin
            int_valid <= 1'b1;
            int_data  <= 32'h55555555;
            int_sop   <= 1'b1;
            int_eop   <= 1'b0;
            int_mod   <= 2'b00;
        end
        else if (tx_gen_curr_st==TX_GEN_PREAMBLE && st_hold_cntr=='d1) begin
            int_valid <= 1'b1;
            int_data  <= 32'h555555d5;
            int_sop   <= 1'b0;
            int_eop   <= 1'b0;
            int_mod   <= 2'b00;
        end
        // header
        else if (tx_gen_curr_st==TX_GEN_HEADER) begin
            int_valid <= 1'b1;
            int_data  <= tx_lpbk_en? lpbk_buff_rdda: info_data_rd;//{4'd0, tx_gen_curr_st, 8'd0, st_hold_cntr};//
            int_sop   <= 1'b0;
            int_eop   <= 1'b0;
            int_mod   <= 2'b00;
        end
        // payload
        else if (tx_gen_curr_st==TX_GEN_PAYLOAD) begin
            int_valid <= 1'b1;
            int_data  <= payload_data;//{4'd0, tx_gen_curr_st, 8'd0, st_hold_cntr};
            int_sop   <= 1'b0;
            int_eop   <= 1'b0;
            int_mod   <= 2'b00;
        end
        // test tag + TCP checksum compensation
        else if (tx_gen_curr_st==TX_GEN_TESTTAG && st_hold_cntr=='d0) begin
            int_valid <= 1'b1;
            int_data  <= seq_num[stream_index];  // 32bit sequence number
            int_sop   <= 1'b0;
            int_eop   <= 1'b0;
            int_mod   <= 2'b00;
        end
        else if (tx_gen_curr_st==TX_GEN_TESTTAG && st_hold_cntr=='d1) begin
            int_valid <= 1'b1;
            int_data  <= time_stamp;  // 32bit time stamp
            int_sop   <= 1'b0;
            int_eop   <= 1'b0;
            int_mod   <= 2'b00;
        end
        else if (tx_gen_curr_st==TX_GEN_TESTTAG && st_hold_cntr=='d2) begin
            int_valid <= 1'b1;
            int_data  <= {4'd0, 1'b0, stream_index, 8'h54, 8'h52};  // 3bit stream index, "T" "R"
            int_sop   <= 1'b0;
            int_eop   <= 1'b0;
            int_mod   <= 2'b00;
        end
        else if (tx_gen_curr_st==TX_GEN_TESTTAG && st_hold_cntr=='d3) begin
            int_valid <= 1'b1;
            int_data  <= {8'h49, 8'h45, 8'h54, 8'h48};  // "I" "E" "T" "H"
            int_sop   <= 1'b0;
            int_eop   <= 1'b0;
            int_mod   <= 2'b00;
        end
        else if (tx_gen_curr_st==TX_GEN_TESTTAG && st_hold_cntr=='d4) begin
            int_valid <= 1'b1;  // TODO: add TCP checksum compensation
            int_data  <= {int_l4_sum_cmp, 8'hff, 8'hff};//{8'haa, 8'hbb, 8'hcc, 8'hff};  // 3byte TCP checksum compensation, 1byte padding
            int_sop   <= 1'b0;
            int_eop   <= 1'b0;
            int_mod   <= 2'b00;
        end
        // MOD Padding
        else if (tx_gen_curr_st==TX_GEN_PADDING && st_hold_cntr=='d0) begin
            int_valid <= 1'b1;
            int_data  <= tx_lpbk_en? lpbk_buff_rdda: (nontest_latch? info_data_rd: {8'hff, 8'hff, 8'hff, 8'hff});  // 1 to 4 byte padding
            int_sop   <= 1'b0;
            int_eop   <= 1'b0;
            int_mod   <= (nontest_latch || tx_lpbk_en)? header_leng[1:0]: frame_leng[1:0];
        end
        // CRC
        else if (tx_gen_curr_st==TX_GEN_CRC) begin
            int_valid <= 1'b1;
            int_data  <= 32'h12345678;
            int_sop   <= 1'b0;
            int_eop   <= 1'b1;
            int_mod   <= (nontest_latch || tx_lpbk_en)? header_leng[1:0]: frame_leng[1:0];
        end
        // IFG
        else if (tx_gen_curr_st==TX_GEN_IFG) begin
            int_valid <= 1'b0;
            int_data  <= 32'h12345678;
            int_sop   <= 1'b0;
            int_eop   <= 1'b0;
            int_mod   <= 2'b00;
        end  
end

assign frame_leng_mod = (int_mod[1:0]==2'b00)? {1'b1, int_mod[1:0]}: {1'b0, int_mod[1:0]};

// calculate TCP checksum compensation
always @(posedge clk) begin
    if (gen_en)
        if      (tx_gen_curr_st==TX_GEN_PAYLOAD && st_hold_cntr=='d0)
          if (err_inj_latch && tx_err_inj_type==4'd3)
            int_l4_sum <= {2'b01,16'h4945} + {2'b00,16'h5448};  // Inject error
          else
            int_l4_sum <= {2'b00,16'h4945} + {2'b00,16'h5448};  // The last 16bit is fixed and used as initial vlaue, to gain one clock timing in advance
        else if (tx_gen_curr_st==TX_GEN_PAYLOAD && st_hold_cntr>='d1 || tx_gen_curr_st==TX_GEN_TESTTAG && st_hold_cntr<='d3)
            int_l4_sum <= {2'b00,int_l4_sum[15:0]} + {2'b00,int_data[31:16]} + {2'b00,int_data[15:0]} + {16'd0, int_l4_sum[17:16]};
end
assign int_l4_sum_cmp = ~(int_l4_sum[15:0]+{14'd0,int_l4_sum[17:16]});  // the compensation makes the payload part sum to all 0's, so the checksum value in the header is untouched and correct

// calculate CRC
wire [31:0] int_crc;
crc32_data32 crc32_gen (
    .rst(rst),
    .clk(clk),

    .init_i (tx_gen_curr_st==TX_GEN_HEADER && st_hold_cntr=='d0 && gen_en),
    .valid_i(int_valid && gen_en),
    .mod_i  (int_mod),
    .data_i (int_data),

    .crc_o(int_crc)
);

// output L2 frame, with CRC inserted
reg         int_valid_d1, int_valid_d2;
reg         int_sop_d1, int_sop_d2;
reg         int_eop_d1, int_eop_d2;
reg  [ 1:0] int_mod_d1, int_mod_d2;
reg  [31:0] int_data_d1, int_data_d2;
reg  [31:0] int_crc_d1, int_crc_d2;
always @(posedge clk) begin
    if (gen_en) begin
        int_valid_d1 <= int_valid;
        int_sop_d1   <= int_sop;
        int_eop_d1   <= int_eop;
        int_mod_d1   <= int_mod;
        int_data_d1  <= int_data;
        int_crc_d1   <= (err_inj_latch && tx_err_inj_type==4'd0)? ~int_crc: int_crc;

        int_valid_d2 <= int_valid_d1;
        int_sop_d2   <= int_sop_d1;
        int_eop_d2   <= int_eop_d1;
        int_mod_d2   <= int_mod_d1;
        int_data_d2  <= int_data_d1;
        int_crc_d2   <= int_crc_d1;
    end
end

always @(posedge clk) begin
    if (gen_en) begin
            int_valid_o <= int_valid_d2;
            int_sop_o   <= int_sop_d2;
            int_eop_o   <= int_eop_d2;
        if (int_eop_d2)
            int_mod_o   <= int_mod_d2;
        else
            int_mod_o   <= 2'b00;
        if (int_eop_d1)
            case (int_mod_d1)
                2'b00: int_data_o <=  int_data_d2[31: 0];
                2'b11: int_data_o <= {int_data_d2[31: 8],int_crc_d1[31:24]};
                2'b10: int_data_o <= {int_data_d2[31:16],int_crc_d1[31:16]};
                2'b01: int_data_o <= {int_data_d2[31:24],int_crc_d1[31: 8]};
            endcase
        else if (int_eop_d2)
            case (int_mod_d2)
                2'b00: int_data_o <=  int_crc_d2[31: 0];
                2'b11: int_data_o <= {int_crc_d2[23: 0], 8'h00    };
                2'b10: int_data_o <= {int_crc_d2[15: 0],16'h0000  };
                2'b01: int_data_o <= {int_crc_d2[ 7: 0],24'h000000};
            endcase
        else
            int_data_o  <= int_data_d2;
    end
end



// output common statistic signals
wire frame_check_point_p1 = int_valid    && int_eop;
wire frame_check_point    = int_valid_d1 && int_eop_d1;

// latch current stream_index
reg [2:0] stream_index_latch;
always @(posedge rst or posedge clk) begin
    if (rst)
        stream_index_latch <= 'd0;
    else if (gen_en && tx_gen_curr_st==TX_GEN_CRC)
        stream_index_latch <= stream_index;
end

reg [3:0] lpbk_stream_index_latch;
always @(posedge rst or posedge clk) begin
    if (rst)
        lpbk_stream_index_latch <= 'd0;
    else if (gen_en && tx_gen_curr_st==TX_GEN_CRC)
        lpbk_stream_index_latch <= lpbk_stream_index;
end

// latch current err_inj info
reg       tx_err_inj_done_latch;
reg [3:0] tx_err_inj_type_latch;
always @(posedge rst or posedge clk) begin
    if (rst)
        tx_err_inj_done_latch <= 'd0;
    else if (gen_en && frame_check_point_p1)
        tx_err_inj_done_latch <= err_inj_latch;
end
always @(posedge rst or posedge clk) begin
    if (rst)
        tx_err_inj_type_latch <= 'd0;
    else if (gen_en && frame_check_point_p1)
        tx_err_inj_type_latch <= tx_err_inj_type;
end

// get info-rate length
reg [ 15:0] info_leng_byte;
always @(posedge rst or posedge clk) begin
  if (rst)
    info_leng_byte <= 'd0;
  else if (gen_en && frame_check_point_p1)
    info_leng_byte <= frame_leng_cntr;
end

// get line-rate length
reg [ 15:0] line_leng_byte;
always @(posedge rst or posedge clk) begin
  if (rst)
    line_leng_byte <= 'd0;
  else if (gen_en && frame_check_point_p1)
    line_leng_byte <= frame_leng_cntr + 'd20;
end

// bit based statistics
// 0 0:7
wire mac_brdcast = header_stat[0];
wire mac_mltcast = header_stat[1];
wire mac_unicast = header_stat[2];
wire mac_keepalv = header_stat[3];
wire mac_xxxxx04 = 1'b0;
wire mac_xxxxx03 = 1'b0;
wire mac_xxxxx02 = 1'b0;
wire mac_crc_bad = (tx_err_inj_done_latch && tx_err_inj_type_latch==4'd0)? 1'b1: 1'b0;
// 1 8:15
wire mactp_arp   = header_stat[8];
wire mactp_pause = header_stat[9];
wire mactp_xxx06 = 1'b0;
wire mactp_xxx05 = 1'b0;
wire mactp_xxx04 = 1'b0;
wire mactp_xxx03 = 1'b0;
wire mactp_xxx02 = 1'b0;
wire mactp_xxx01 = 1'b0;
// 2 16:23
wire vlan_num_01 = header_stat[16];
wire vlan_num_02 = header_stat[17];
wire vlan_num_03 = header_stat[18];
wire vlan_xxxx04 = 1'b0;
wire vlan_xxxx03 = 1'b0;
wire vlan_xxxx02 = 1'b0;
wire vlan_xxxx01 = 1'b0;
wire vlan_xxxx00 = 1'b0;
// 3 24:31
wire mpls_num_01 = header_stat[24];
wire mpls_num_02 = header_stat[25];
wire mpls_num_03 = header_stat[26];
wire mpls_xxxx04 = 1'b0;
wire mpls_xxxx03 = 1'b0;
wire mpls_xxxx02 = 1'b0;
wire mpls_xxxx01 = 1'b0;
wire mpls_xxxx00 = 1'b0;
// 4 32:39
wire ip_version4 = header_stat[32];
wire ip_version6 = header_stat[33];
wire ip_brdcast  = header_stat[34];
wire ip_mltcast  = header_stat[35];
wire ip_anycast  = header_stat[36];
wire ip_unicast  = header_stat[37];
wire ip_xxxxx02  = 1'b0;
wire ip_xxxxx01  = 1'b0;
// 5 40:47
wire iprtcl_tcp  = header_stat[40];
wire iprtcl_udp  = header_stat[41];
wire iprtcl_xx06 = 1'b0;
wire iprtcl_xx05 = 1'b0;
wire iprtcl_xx04 = 1'b0;
wire iprtcl_xx03 = 1'b0;
wire iprtcl_xx02 = 1'b0;
wire iprtcl_xx01 = 1'b0;
// 6 48:55
wire l4_cksum_er = (tx_err_inj_done_latch && tx_err_inj_type_latch==4'd3)? 1'b1: 1'b0;
// 7 56:63
wire frame_anyl = 1'b1;
wire frame_runt = (line_leng_byte-'d20) < 'd64;
wire frame_jumb = (line_leng_byte-'d20) > 'd1518;

// output frame checking results
always @(posedge rst or posedge clk) begin
  if (rst)
    tx_stat_bit <= 'd0;
  else if (gen_en) begin
    if (frame_check_point)
      tx_stat_bit <= {
                      //7: 63:56
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      frame_jumb,
                      frame_runt,
                      frame_anyl,
                      //6: 55:48
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      1'b0,
                      l4_cksum_er,
                      //5: 47:40
                      iprtcl_xx01,
                      iprtcl_xx02,
                      iprtcl_xx03,
                      iprtcl_xx04,
                      iprtcl_xx05,
                      iprtcl_xx06,
                      iprtcl_udp ,
                      iprtcl_tcp ,
                      //4: 39:32
                      ip_xxxxx01 ,
                      ip_xxxxx02 ,
                      ip_unicast ,
                      ip_anycast ,
                      ip_mltcast ,
                      ip_brdcast ,
                      ip_version6,
                      ip_version4,
                      //3: 31:24
                      mpls_xxxx00,
                      mpls_xxxx01,
                      mpls_xxxx02,
                      mpls_xxxx03,
                      mpls_xxxx04,
                      mpls_num_03,
                      mpls_num_02,
                      mpls_num_01,
                      //2: 23:16
                      vlan_xxxx00,
                      vlan_xxxx01,
                      vlan_xxxx02,
                      vlan_xxxx03,
                      vlan_xxxx04,
                      vlan_num_03,
                      vlan_num_02,
                      vlan_num_01,
                      //1: 15:8
                      mactp_xxx01,
                      mactp_xxx02,
                      mactp_xxx03,
                      mactp_xxx04,
                      mactp_xxx05,
                      mactp_xxx06,
                      mactp_pause,
                      mactp_arp  ,
                      //0: 7:0
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
    tx_stat_bit <= tx_stat_bit;
  end
end

// vector based statistics
wire [31:0] info_leng = {16'd0, info_leng_byte};
wire [31:0] line_leng = {16'd0, line_leng_byte};
wire [31:0] test_nber = (tx_err_inj_done_latch && tx_err_inj_type_latch==4'd1)? 32'd1: 32'd0;
wire [31:0] test_slos = (tx_err_inj_done_latch && tx_err_inj_type_latch==4'd4)? 32'd1: 32'd0;
wire [31:0] test_soos = (tx_err_inj_done_latch && tx_err_inj_type_latch==4'd5)? 32'd1: 32'd0;
wire [31:0] test_sdup = (tx_err_inj_done_latch && tx_err_inj_type_latch==4'd6)? 32'd1: 32'd0;

wire line_leng_sum = 1'b1;
wire line_leng_max = 1'b1;
wire line_leng_min = 1'b1;
wire info_leng_sum = 1'b1;
wire info_leng_max = 1'b1;
wire info_leng_min = 1'b1;
wire pack_intv_sum = 1'b1;
wire pack_intv_max = 1'b1;
wire pack_intv_min = 1'b1;
wire test_nber_sum = 1'b1;
wire test_slos_sum = 1'b1;
wire test_soos_sum = 1'b1;
wire test_sdup_sum = 1'b1;

always @(posedge rst or posedge clk) begin  // TODO: add missing vector based statistics for TX side
  if (rst)
    tx_stat_vec <= 'd0;
  else if (gen_en && frame_check_point)
    tx_stat_vec <= {
                    {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 63:60
                    {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 59:56
                    {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 55:52
                    {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 51:48
                    {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 47:44
                    {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 43:40
                    {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 39:36
                    {          1'b0,line_leng_sum, line_leng_max, line_leng_min}, line_leng,  // 35:32
                                   
                    {          1'b0,info_leng_sum, info_leng_max, info_leng_min}, info_leng,  // 31:28
                    {          1'b0,pack_intv_sum, pack_intv_max, pack_intv_min},     32'd0,  // 27:24
                    {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 23:20
                    {          1'b0,         1'b0,          1'b0,          1'b0},     32'd0,  // 19:16
                    {          1'b0,test_nber_sum,          1'b0,          1'b0}, test_nber,  // 15:12
                    {          1'b0,test_slos_sum,          1'b0,          1'b0}, test_slos,  // 11: 8
                    {          1'b0,test_soos_sum,          1'b0,          1'b0}, test_soos,  //  7: 4
                    {          1'b0,test_sdup_sum,          1'b0,          1'b0}, test_sdup   //  3: 0
                    };
  else
    tx_stat_vec <= tx_stat_vec;
end

// tx stat trigger
always @(posedge rst or posedge clk) begin
  if (rst)
    tx_stat_chk <= 1'b0;
  else if (gen_en)
    tx_stat_chk <= frame_check_point;
end

// tx stat stream address
always @(posedge rst or posedge clk) begin
  if (rst)
    tx_stat_base_addr <= 'd0;
  else if (gen_en)
    if (frame_check_point)
      tx_stat_base_addr <= tx_lpbk_en? lpbk_stream_index_latch: (nontest_latch? {1'b1, 3'd0}: {1'b0, stream_index_latch});
end

endmodule

