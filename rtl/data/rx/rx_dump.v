/*
 * File   : rx_dump.v
 * Date   : 20140626
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module rx_dump (
    input  wire         rst,


    input  wire [31: 0] up_data_rx_ctrl,

    input  wire         in_clk,
    input  wire         in_par_en,
    input  wire [31: 0] in_data,
    input  wire         in_valid,
    input  wire         in_sop,
    input  wire         in_eop,
    input  wire [ 1: 0] in_mod,
    input  wire [31: 0] in_info,
    input  wire [63: 0] in_stat,
    input  wire [ 3: 0] in_snum,

    input  wire           up_clk,
    input  wire           up_wr,
    input  wire           up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31  : 0] up_data_wr,
    output wire [31  : 0] up_data_rd
);


// buffer in_par_en
reg in_par_en_d1, in_par_en_d2, in_par_en_d3, in_par_en_d4,
    in_par_en_d5, in_par_en_d6, in_par_en_d7, in_par_en_d8,
    in_par_en_d9, in_par_en_d10, in_par_en_d11, in_par_en_d12;
always @(posedge rst or posedge in_clk) begin
  if (rst) begin
    in_par_en_d1 <= 1'b0;
    in_par_en_d2 <= 1'b0;
    in_par_en_d3 <= 1'b0;
    in_par_en_d4 <= 1'b0;
    in_par_en_d5 <= 1'b0;
    in_par_en_d6 <= 1'b0;
    in_par_en_d7 <= 1'b0;
    in_par_en_d8 <= 1'b0;
    in_par_en_d9 <= 1'b0;
    in_par_en_d10 <= 1'b0;
    in_par_en_d11 <= 1'b0;
    in_par_en_d12 <= 1'b0;
  end
  else begin
    in_par_en_d1 <= in_par_en;
    in_par_en_d2 <= in_par_en_d1;
    in_par_en_d3 <= in_par_en_d2;
    in_par_en_d4 <= in_par_en_d3;
    in_par_en_d5 <= in_par_en_d4;
    in_par_en_d6 <= in_par_en_d5;
    in_par_en_d7 <= in_par_en_d6;
    in_par_en_d8 <= in_par_en_d7;
    in_par_en_d9 <= in_par_en_d8;
    in_par_en_d10 <= in_par_en_d9;
    in_par_en_d11 <= in_par_en_d10;
    in_par_en_d12 <= in_par_en_d11;
  end
end

wire par_en = in_par_en_d8;// || in_par_en_d12;

// get buffer control info
wire [ 3:0]rx_loop_en  = up_data_rx_ctrl[27:24];  // 4 bit enable: bit0=L1, bit1=L2, bit2=L3, bit3=L4
wire       rx_dump_en  = up_data_rx_ctrl[   28];  // dump enable
wire       rx_pause_en = up_data_rx_ctrl[    5];  // pause enable

wire loop_l1 = rx_loop_en[0];                   // +1 loop enable
wire loop_l2 = rx_loop_en[0] && rx_loop_en[1];  // +2 switch mac address
wire loop_l3 = rx_loop_en[0] && rx_loop_en[2];  // +4 switch ip address
wire loop_l4 = rx_loop_en[0] && rx_loop_en[3];  // +8 switch tcp/udp port

wire dump_it = (in_stat[7:0]==8'h04)? 1'b1: 1'b0;

// cpu access
parameter [15:0] RX_DUMP_INFO_ADDR = 16'h0010;  // read all-zero when no packet is in buffer
parameter [15:0] RX_DUMP_BUFF_ADDR = 16'h0020;  // write to load base address, read to get data and increase address

wire up_cs_dump_info = (up_addr[15:0]==RX_DUMP_INFO_ADDR)? 1'b1: 1'b0;  // rd 04030010
wire up_cs_dump_buff = (up_addr[15:0]==RX_DUMP_BUFF_ADDR)? 1'b1: 1'b0;  // rd 04030020

wire [31:0] up_data_rd_dump_info;
wire [31:0] up_data_rd_dump_buff;
assign up_data_rd = up_cs_dump_info? up_data_rd_dump_info: (
                    up_cs_dump_buff? up_data_rd_dump_buff:
                                     32'hdeadbeef          );

wire        dump_out_clk = up_clk;
wire        dump_gen_en  = 1'b1;

wire        dump_info_rqst = up_rd && up_cs_dump_info;
wire        dump_info_vald;
wire [31:0] dump_info_data;

wire        dump_buff_rden = up_rd && up_cs_dump_buff;
reg  [11:0] dump_buff_rdad;
wire [31:0] dump_buff_rdda;

always @(posedge rst or posedge up_clk) begin
  if (rst)
    dump_buff_rdad <= 'd0;
  else if (up_wr && up_addr[15:0]==RX_DUMP_BUFF_ADDR)
    dump_buff_rdad <= up_data_wr[13:2];
  else if (up_rd && up_addr[15:0]==RX_DUMP_BUFF_ADDR)
    dump_buff_rdad <= dump_buff_rdad + 'd1;
end

assign up_data_rd_dump_info = dump_info_vald? dump_info_data: 32'd0;
assign up_data_rd_dump_buff = dump_buff_rdda;




//////////////////////////////////
// rx dump packet buffer
reg         dbuf_wren_h;
reg  [11:0] dbuf_wrad_h;
reg  [17:0] dbuf_wrda_h;
wire        dbuf_rden_h;
wire [11:0] dbuf_rdad_h;
wire [17:0] dbuf_rdda_h;
`ifdef ALTERA
dpram_dc_18_4096 dump_buffer_h (
  .aclr_a    (rst),
  .clock_a   (in_clk),
  .address_a (dbuf_wrad_h),
  .data_a    (dbuf_wrda_h),
  .enable_a  (par_en),
  .rden_a    (1'b0),
  .wren_a    (dbuf_wren_h),
  .q_a       (),

  .aclr_b    (rst),
  .clock_b   (dump_out_clk),
  .address_b (dbuf_rdad_h),
  .data_b    (18'd0),
  .enable_b  (dump_gen_en),
  .rden_b    (dbuf_rden_h),
  .wren_b    (1'b0),
  .q_b       (dbuf_rdda_h)
);
`endif
`ifdef XILINX_SPARTAN6
dpram_dc_18_4096 dump_buffer_h(
  .clka  (in_clk),
  .rsta  (rst),
  .ena   (par_en),
  .wea   (dbuf_wren_h),
  .addra (dbuf_wrad_h),
  .dina  (dbuf_wrda_h),
  .douta (),

  .clkb  (dump_out_clk),
  .rstb  (rst),
  .enb   (dump_gen_en && dbuf_rden_h),
  .web   (1'b0),
  .addrb (dbuf_rdad_h),
  .dinb  (18'd0),
  .doutb (dbuf_rdda_h)
);
`endif

reg         dbuf_wren_l;
reg  [11:0] dbuf_wrad_l;
reg  [17:0] dbuf_wrda_l;
wire        dbuf_rden_l;
wire [11:0] dbuf_rdad_l;
wire [17:0] dbuf_rdda_l;
`ifdef ALTERA
dpram_dc_18_4096 dump_buffer_l (
  .aclr_a    (rst),
  .clock_a   (in_clk),
  .address_a (dbuf_wrad_l),
  .data_a    (dbuf_wrda_l),
  .enable_a  (par_en),
  .rden_a    (1'b0),
  .wren_a    (dbuf_wren_l),
  .q_a       (),

  .aclr_b    (rst),
  .clock_b   (dump_out_clk),
  .address_b (dbuf_rdad_l),
  .data_b    (18'd0),
  .enable_b  (dump_gen_en),
  .rden_b    (dbuf_rden_l),
  .wren_b    (1'b0),
  .q_b       (dbuf_rdda_l)
);
`endif
`ifdef XILINX_SPARTAN6
dpram_dc_18_4096 dump_buffer_l(
  .clka  (in_clk),
  .rsta  (rst),
  .ena   (par_en),
  .wea   (dbuf_wren_l),
  .addra (dbuf_wrad_l),
  .dina  (dbuf_wrda_l),
  .douta (),

  .clkb  (dump_out_clk),
  .rstb  (rst),
  .enb   (dump_gen_en && dbuf_rden_l),
  .web   (1'b0),
  .addrb (dbuf_rdad_l),
  .dinb  (18'd0),
  .doutb (dbuf_rdda_l)
);
`endif

////////////////////////////////////////
// logic to read from delay buffer
assign dbuf_rden_h = dump_buff_rden;
assign dbuf_rden_l = dump_buff_rden;
assign dbuf_rdad_h = dump_buff_rdad;
assign dbuf_rdad_l = dump_buff_rdad;
assign dump_buff_rdda = {dbuf_rdda_h[15:0], dbuf_rdda_l[15:0]};

////////////////////////////////////////
// logic to write to delay buffer
reg  [11:0] dbuf_wrad;
wire        dbuf_wrad_incr, dbuf_wrad_hold, dbuf_wrad_load;
wire [11:0] dbuf_wrad_base;
always @(posedge rst or posedge in_clk) begin
  if (rst)
    dbuf_wrad <= 'd0;
  else if (par_en)
         if (dbuf_wrad_load)
      dbuf_wrad <= dbuf_wrad_base;
    else if (dbuf_wrad_hold)
      dbuf_wrad <= dbuf_wrad + 'd0;
    else if (dbuf_wrad_incr)
      dbuf_wrad <= dbuf_wrad + 'd1;
end

wire dbuf_wrad_full = (dbuf_wrad + 12'd1 == dump_buff_rdad)? 1'b1: 1'b0;

// fsm state transition
reg  [ 7:0] fsm_dbwr_curr_st, fsm_dbwr_next_st, fsm_dbwr_last_st;

parameter [ 7:0]
FSM_DBWR_IDLE        =                       0,  // 0
FSM_DBWR_PREAMBLE    = FSM_DBWR_IDLE       + 1,  // 1
FSM_DBWR_ACTIVE      = FSM_DBWR_PREAMBLE   + 1,  // 2
FSM_DBWR_STAT_H      =                      64,  //64
FSM_DBWR_STAT_L      = FSM_DBWR_STAT_H     + 1,  //65
FSM_DBWR_DEACTIVE    =                     255;  // 255

always @(posedge rst or posedge in_clk) begin
    if (rst) begin
        fsm_dbwr_curr_st <= FSM_DBWR_IDLE;
        fsm_dbwr_last_st <= FSM_DBWR_IDLE;
    end
    else if (par_en) begin
      if (dbuf_wrad_full)
        fsm_dbwr_curr_st <= FSM_DBWR_IDLE;
      else
        fsm_dbwr_curr_st <= fsm_dbwr_next_st;
        fsm_dbwr_last_st <= fsm_dbwr_curr_st;
    end
end

always @(*) begin
    case (fsm_dbwr_curr_st)
        FSM_DBWR_IDLE:
            if (in_valid && in_sop)
                fsm_dbwr_next_st = FSM_DBWR_PREAMBLE;
            else
                fsm_dbwr_next_st = FSM_DBWR_IDLE;
        FSM_DBWR_PREAMBLE:
                fsm_dbwr_next_st = FSM_DBWR_ACTIVE;
        FSM_DBWR_ACTIVE:
            if (in_valid && in_eop)
                fsm_dbwr_next_st = FSM_DBWR_STAT_H;
            else
                fsm_dbwr_next_st = FSM_DBWR_ACTIVE;
        FSM_DBWR_STAT_H:
                fsm_dbwr_next_st = FSM_DBWR_STAT_L;
        FSM_DBWR_STAT_L:
                fsm_dbwr_next_st = FSM_DBWR_IDLE;
        FSM_DBWR_DEACTIVE:
                fsm_dbwr_next_st = FSM_DBWR_IDLE;
        default:
            fsm_dbwr_next_st = FSM_DBWR_IDLE;
    endcase
end

// FSM output signals: buffer fill-in operaion
reg [11:0] dbuf_wrad_h_temp, dbuf_wrad_l_temp;
reg [17:0] dbuf_wrda_h_temp, dbuf_wrda_l_temp;  // l4 dst, l4 src
reg        dbuf_lpl4_rewrite;                   // temporarily store the l4 port values to write it back later, using the overwritten eop cycle

always @(posedge rst or posedge in_clk) begin
    if (rst) begin
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b0, 1'b0, 12'd0, 12'd0, 18'd0, 18'd0};
    end
    else if (par_en) begin
             if (fsm_dbwr_curr_st==FSM_DBWR_IDLE)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b0, 1'b0, 12'd0, 12'd0, 18'd0, 18'd0};
        else if (fsm_dbwr_curr_st==FSM_DBWR_PREAMBLE)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b0, 1'b0, 12'd0, 12'd0, 18'd0, 18'd0};
        else if (fsm_dbwr_curr_st==FSM_DBWR_ACTIVE) 
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, dbuf_wrad, dbuf_wrad, {in_sop, in_eop, in_data[31:16]}, {in_mod, in_data[15: 0]}};
        else if (fsm_dbwr_curr_st==FSM_DBWR_STAT_H)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, dbuf_wrad,dbuf_wrad, {2'b11, in_stat[63:48]}, {2'b11, in_stat[47:32]}};
        else if (fsm_dbwr_curr_st==FSM_DBWR_STAT_L)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b1, 1'b1, dbuf_wrad,dbuf_wrad, {2'b11, in_stat[31:16]}, {2'b11, in_stat[15: 0]}};
        else if (fsm_dbwr_curr_st==FSM_DBWR_DEACTIVE)
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b0, 1'b0, 12'd0, 12'd0, 18'd0, 18'd0};
        else
            {dbuf_wren_h, dbuf_wren_l, dbuf_wrad_h, dbuf_wrad_l, dbuf_wrda_h, dbuf_wrda_l} <= 
                {1'b0, 1'b0, 12'd0, 12'd0, 18'd0, 18'd0};
    end
end

assign dbuf_wrad_incr = (fsm_dbwr_curr_st!=FSM_DBWR_IDLE   && fsm_dbwr_curr_st!=FSM_DBWR_PREAMBLE && fsm_dbwr_curr_st!=FSM_DBWR_DEACTIVE)? 1'b1:1'b0;
assign dbuf_wrad_hold = (fsm_dbwr_curr_st!=FSM_DBWR_STAT_H && fsm_dbwr_next_st==FSM_DBWR_STAT_H)? 1'b1:1'b0;
assign dbuf_wrad_load = (fsm_dbwr_curr_st==FSM_DBWR_STAT_L && !dump_it || dbuf_wrad_full)? 1'b1:1'b0;




///////////////////////////////
// info buffer
wire info_fifo_empty_h;
wire info_fifo_full_h;
wire        info_fifo_rden_h;
wire [17:0] info_fifo_rdda_h;
wire        info_fifo_wren_h;
wire [17:0] info_fifo_wrda_h;
`ifdef XILINX_SPARTAN6
fifo_dc_18_512 info_fifo_h(
    .rst    (rst),
 
    .wr_clk (in_clk),
    .wr_en  (par_en && info_fifo_wren_h),
    .din    (info_fifo_wrda_h),
    .full   (info_fifo_full_h),
    .wr_data_count(),
 
    .rd_clk (dump_out_clk),
    .rd_en (dump_gen_en && info_fifo_rden_h),
    .dout   (info_fifo_rdda_h),
    .empty  (info_fifo_empty_h),
    .rd_data_count()
);
`endif
`ifdef ALTERA
fifo_dc_18_512 info_fifo_h(
    .aclr(rst),

    .wrclk(in_clk),
    .wrreq(par_en && info_fifo_wren_h),
    .data(info_fifo_wrda_h),

    .rdclk(dump_out_clk),
    .rdreq(dump_gen_en && info_fifo_rden_h),
    .q(info_fifo_rdda_h),

    .rdempty(info_fifo_empty_h),
    .rdusedw(),
    .wrfull(info_fifo_full_h),
    .wrusedw()
);
`endif

wire info_fifo_empty_l;
wire info_fifo_full_l;
wire        info_fifo_rden_l;
wire [17:0] info_fifo_rdda_l;
wire        info_fifo_wren_l;
wire [17:0] info_fifo_wrda_l;
`ifdef XILINX_SPARTAN6
fifo_dc_18_512 info_fifo_l(
    .rst    (rst),
 
    .wr_clk (in_clk),
    .wr_en  (par_en && info_fifo_wren_l),
    .din    (info_fifo_wrda_l),
    .full   (info_fifo_full_l),
    .wr_data_count(),
 
    .rd_clk (dump_out_clk),
    .rd_en (dump_gen_en && info_fifo_rden_l),
    .dout   (info_fifo_rdda_l),
    .empty  (info_fifo_empty_l),
    .rd_data_count()
);
`endif
`ifdef ALTERA
fifo_dc_18_512 info_fifo_l(
    .aclr(rst),

    .wrclk(in_clk),
    .wrreq(par_en && info_fifo_wren_l),
    .data(info_fifo_wrda_l),

    .rdclk(dump_out_clk),
    .rdreq(dump_gen_en && info_fifo_rden_l),
    .q(info_fifo_rdda_l),

    .rdempty(info_fifo_empty_l),
    .rdusedw(),
    .wrfull(info_fifo_full_l),
    .wrusedw()
);
`endif

///////////////////////////////////////////////////////
// FSM output signals: info fifo fill-in operation
reg  [15:0] info_data_leng;
wire [ 3:0] info_data_snum = in_snum;
reg  [11:0] info_data_base;
wire [11:0] dbuf_wrad_interval = dbuf_wrad - info_data_base;
assign      dbuf_wrad_base = info_data_base;
always @(posedge rst or posedge in_clk) begin
    if (rst) begin
        info_data_leng <= 'd0;
        info_data_base <= 'd0;
    end
    else if (par_en) begin
        if (fsm_dbwr_curr_st!=FSM_DBWR_STAT_H && fsm_dbwr_next_st==FSM_DBWR_STAT_H) begin
            info_data_leng <= (in_mod==2'b00)? {2'b00, dbuf_wrad_interval, 2'b00}: {2'b00, (dbuf_wrad_interval-1), in_mod};
        end
        if (fsm_dbwr_curr_st==FSM_DBWR_PREAMBLE) begin
            info_data_base <= dbuf_wrad;
        end
    end
end

reg        info_fifo_wren;
reg [31:0] info_fifo_wrda;
always @(posedge rst or posedge in_clk) begin
    if (rst) begin
        info_fifo_wren <= 1'b0;
        info_fifo_wrda <= 32'd0;
    end
    else if (par_en) begin
        if (fsm_dbwr_curr_st==FSM_DBWR_STAT_H && dump_it && rx_dump_en) begin
            info_fifo_wren <= 1'b1;
            info_fifo_wrda <= {info_data_leng, 4'hf, info_data_base};  // {16, 4, 12}
        end
        else begin
            info_fifo_wren <= 1'b0;
            info_fifo_wrda <= 32'd0;
        end
    end
end

assign {info_fifo_wren_h, info_fifo_wren_l} = {        info_fifo_wren,                 info_fifo_wren};
assign {info_fifo_wrda_h, info_fifo_wrda_l} = {{2'b00, info_fifo_wrda[31:16]}, {2'b00, info_fifo_wrda[15: 0]}};

///////////////////////////////////////
// info fifo read out operation
wire info_fifo_empty = (info_fifo_empty_h || info_fifo_empty_l)? 1'b1: 1'b0;
wire info_fifo_rden  = (dump_info_rqst && !info_fifo_empty)? 1'b1: 1'b0;

reg info_fifo_rden_d1, info_fifo_rden_d2;
always @(posedge rst or posedge dump_out_clk) begin
    if (rst) begin
        info_fifo_rden_d1 <= 1'b0;
        info_fifo_rden_d2 <= 1'b0;
    end
    else if (dump_gen_en) begin
        info_fifo_rden_d1 <= info_fifo_rden;
        info_fifo_rden_d2 <= info_fifo_rden_d1;
    end
end

assign info_fifo_rden_h = info_fifo_rden && !info_fifo_rden_d1;
assign info_fifo_rden_l = info_fifo_rden && !info_fifo_rden_d1;

assign dump_info_vald = info_fifo_rden_d1 && !info_fifo_rden_d2;
assign dump_info_data = {info_fifo_rdda_h[15:0], info_fifo_rdda_l[15:0]};




endmodule
