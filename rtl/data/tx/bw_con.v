/*
 * File   : bw_con.v
 * Date   : 20131204
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module bw_con (
    input  wire         rst,
    input  wire         clk,

    input  wire           up_clk,
    input  wire           up_wr,
    input  wire           up_rd,
    input  wire [32-1: 0] up_addr,
    input  wire [31  : 0] up_data_wr,
    output wire [31  : 0] up_data_rd,

    input  wire         tx_test_pulse,
    input  wire         tx_test_level,

    output wire         bw_rate_wr,
    output wire [17: 0] bw_rate_wr_data
);
parameter STR_NUM = 8;

parameter [11:0] TX_CON_BW_STRM_0 = 12'h020;
parameter [11:0] TX_CON_BW_STRM_1 = 12'h024;
parameter [11:0] TX_CON_BW_STRM_2 = 12'h028;
parameter [11:0] TX_CON_BW_STRM_3 = 12'h02c;
parameter [11:0] TX_CON_BW_STRM_4 = 12'h030;
parameter [11:0] TX_CON_BW_STRM_5 = 12'h034;
parameter [11:0] TX_CON_BW_STRM_6 = 12'h038;
parameter [11:0] TX_CON_BW_STRM_7 = 12'h03c;

parameter [11:0] TX_CON_BW_SCAL_0 = 12'h040;
parameter [11:0] TX_CON_BW_SCAL_1 = 12'h044;
parameter [11:0] TX_CON_BW_SCAL_2 = 12'h048;
parameter [11:0] TX_CON_BW_SCAL_3 = 12'h04c;
parameter [11:0] TX_CON_BW_SCAL_4 = 12'h050;
parameter [11:0] TX_CON_BW_SCAL_5 = 12'h054;
parameter [11:0] TX_CON_BW_SCAL_6 = 12'h058;
parameter [11:0] TX_CON_BW_SCAL_7 = 12'h05c;

// cpu bandwidth parameter to tx_con
reg [31:0] up_data_tx_con_bw_strm [STR_NUM-1:0];
always @(posedge up_clk) begin
    if (up_wr) 
        case (up_addr[11:0])
            TX_CON_BW_STRM_0: up_data_tx_con_bw_strm[0] <= up_data_wr;
            TX_CON_BW_STRM_1: up_data_tx_con_bw_strm[1] <= up_data_wr;
            TX_CON_BW_STRM_2: up_data_tx_con_bw_strm[2] <= up_data_wr;
            TX_CON_BW_STRM_3: up_data_tx_con_bw_strm[3] <= up_data_wr;
            TX_CON_BW_STRM_4: up_data_tx_con_bw_strm[4] <= up_data_wr;
            TX_CON_BW_STRM_5: up_data_tx_con_bw_strm[5] <= up_data_wr;
            TX_CON_BW_STRM_6: up_data_tx_con_bw_strm[6] <= up_data_wr;
            TX_CON_BW_STRM_7: up_data_tx_con_bw_strm[7] <= up_data_wr;
        endcase
end

reg [31:0] up_data_tx_con_bw_scal [STR_NUM-1:0];
always @(posedge up_clk) begin
    if (up_wr) 
        case (up_addr[11:0])
            TX_CON_BW_SCAL_0: up_data_tx_con_bw_scal[0] <= up_data_wr;
            TX_CON_BW_SCAL_1: up_data_tx_con_bw_scal[1] <= up_data_wr;
            TX_CON_BW_SCAL_2: up_data_tx_con_bw_scal[2] <= up_data_wr;
            TX_CON_BW_SCAL_3: up_data_tx_con_bw_scal[3] <= up_data_wr;
            TX_CON_BW_SCAL_4: up_data_tx_con_bw_scal[4] <= up_data_wr;
            TX_CON_BW_SCAL_5: up_data_tx_con_bw_scal[5] <= up_data_wr;
            TX_CON_BW_SCAL_6: up_data_tx_con_bw_scal[6] <= up_data_wr;
            TX_CON_BW_SCAL_7: up_data_tx_con_bw_scal[7] <= up_data_wr;
        endcase
end

// tx_con read to cpu
assign up_data_rd = (up_addr[11:0]==TX_CON_BW_STRM_0)? up_data_tx_con_bw_strm[0]: (
                    (up_addr[11:0]==TX_CON_BW_STRM_1)? up_data_tx_con_bw_strm[1]: (
                    (up_addr[11:0]==TX_CON_BW_STRM_2)? up_data_tx_con_bw_strm[2]: (
                    (up_addr[11:0]==TX_CON_BW_STRM_3)? up_data_tx_con_bw_strm[3]: (
                    (up_addr[11:0]==TX_CON_BW_STRM_4)? up_data_tx_con_bw_strm[4]: (
                    (up_addr[11:0]==TX_CON_BW_STRM_5)? up_data_tx_con_bw_strm[5]: (
                    (up_addr[11:0]==TX_CON_BW_STRM_6)? up_data_tx_con_bw_strm[6]: (
                    (up_addr[11:0]==TX_CON_BW_STRM_7)? up_data_tx_con_bw_strm[7]: (
                    (up_addr[11:0]==TX_CON_BW_SCAL_0)? up_data_tx_con_bw_scal[0]: (
                    (up_addr[11:0]==TX_CON_BW_SCAL_1)? up_data_tx_con_bw_scal[1]: (
                    (up_addr[11:0]==TX_CON_BW_SCAL_2)? up_data_tx_con_bw_scal[2]: (
                    (up_addr[11:0]==TX_CON_BW_SCAL_3)? up_data_tx_con_bw_scal[3]: (
                    (up_addr[11:0]==TX_CON_BW_SCAL_4)? up_data_tx_con_bw_scal[4]: (
                    (up_addr[11:0]==TX_CON_BW_SCAL_5)? up_data_tx_con_bw_scal[5]: (
                    (up_addr[11:0]==TX_CON_BW_SCAL_6)? up_data_tx_con_bw_scal[6]: (
                    (up_addr[11:0]==TX_CON_BW_SCAL_7)? up_data_tx_con_bw_scal[7]: (
                                                       32'hdeadbeef))))))))))))))));

// constant traffic rate generation

// cpu input bandwidth parameters
wire [15:0] rate_cntr_incr [STR_NUM-1:0];
wire [15:0] frame_leng     [STR_NUM-1:0];
generate
genvar k;
for (k=0; k<STR_NUM; k=k+1) begin: rate_cntr_incr_init
assign {rate_cntr_incr[k], frame_leng[k]} = up_data_tx_con_bw_strm[k];
end
endgenerate

// increase rate counter
reg  [15:0] rate_cntr_curr [STR_NUM-1:0];
reg  [15:0] rate_cntr_last [STR_NUM-1:0];
generate
genvar i;
for (i=0; i<STR_NUM; i=i+1) begin: rate_cntr_incr_run
always @(posedge clk or posedge rst) begin
    if (rst) begin
        rate_cntr_curr[i] <= 'd0;
        rate_cntr_last[i] <= 'd0;
    end
    else if (tx_test_pulse) begin
        rate_cntr_curr[i] <= 'd0;
        rate_cntr_last[i] <= 'd0;
    end
    else if (tx_test_level) begin
        rate_cntr_curr[i] <= rate_cntr_curr[i] + rate_cntr_incr[i];
        rate_cntr_last[i] <= rate_cntr_curr[i];
    end
end
end
endgenerate

// rate counter carry out
reg [STR_NUM-1:0] rate_cntr_cout;
generate
genvar j;
for (j=0; j<STR_NUM; j=j+1) begin: rate_cntr_incr_cout
always @(*) begin
//    if (rst)
//        rate_cntr_cout[j] <= 1'b0;
    if (rate_cntr_curr[j]<rate_cntr_last[j])
        rate_cntr_cout[j] = 1'b1;
    else
        rate_cntr_cout[j] = 1'b0;
end
end
endgenerate

// increase scalor counter
reg  [31:0] rate_cntr_scal [STR_NUM-1:0];
reg  [STR_NUM-1:0] rate_cntr_scal_full;
reg  [STR_NUM-1:0] rate_cntr_scal_cclr;
generate
genvar l;
for (l=0; l<STR_NUM; l=l+1) begin: rate_cntr_scal_run
always @(posedge clk or posedge rst) begin
    if (rst) begin
        rate_cntr_scal[l] <= 'd0;
    end
    else if (tx_test_pulse) begin
        rate_cntr_scal[l] <= 'd0;
    end
    else if (rate_cntr_scal_cclr[l] && !rate_cntr_cout[l] && tx_test_level) begin
        rate_cntr_scal[l] <= rate_cntr_scal[l] - up_data_tx_con_bw_scal[l] + 'd0;
    end
    else if (rate_cntr_scal_cclr[l] &&  rate_cntr_cout[l] && tx_test_level) begin
        rate_cntr_scal[l] <= rate_cntr_scal[l] - up_data_tx_con_bw_scal[l] + 'd1;
    end
    else if (rate_cntr_cout[l] && tx_test_level) begin
        rate_cntr_scal[l] <= rate_cntr_scal[l] + 'd1;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rate_cntr_scal_full[l] <= 1'b0;
    end
    else if (tx_test_pulse) begin
        rate_cntr_scal_full[l] <= 1'b0;
    end
    else if (rate_cntr_scal_cclr[l]) begin
        rate_cntr_scal_full[l] <= 1'b0;
    end
    else if (rate_cntr_scal[l]==up_data_tx_con_bw_scal[l]-1 && rate_cntr_cout[l] && tx_test_level) begin
        rate_cntr_scal_full[l] <= 1'b1;
    end
end
end
endgenerate

// rate counter carry out triggers frame generation, writing to rate buffer
reg         rate_buffer_wr;
reg [17: 0] rate_buffer_wr_data;
always @(*) begin
         if (rate_cntr_scal_full[0] == 1'b1) begin
        rate_cntr_scal_cclr <= 8'b00000001;
        rate_buffer_wr <= 1'b1;
        rate_buffer_wr_data <= {4'd0, frame_leng[0][13:0]};
    end
    else if (rate_cntr_scal_full[1] == 1'b1) begin
        rate_cntr_scal_cclr <= 8'b00000010;
        rate_buffer_wr <= 1'b1;
        rate_buffer_wr_data <= {4'd1, frame_leng[1][13:0]};
    end
    else if (rate_cntr_scal_full[2] == 1'b1) begin
        rate_cntr_scal_cclr <= 8'b00000100;
        rate_buffer_wr <= 1'b1;
        rate_buffer_wr_data <= {4'd2, frame_leng[2][13:0]};
    end
    else if (rate_cntr_scal_full[3] == 1'b1) begin
        rate_cntr_scal_cclr <= 8'b00001000;
        rate_buffer_wr <= 1'b1;
        rate_buffer_wr_data <= {4'd3, frame_leng[3][13:0]};
    end
    else if (rate_cntr_scal_full[4] == 1'b1) begin
        rate_cntr_scal_cclr <= 8'b00010000;
        rate_buffer_wr <= 1'b1;
        rate_buffer_wr_data <= {4'd4, frame_leng[4][13:0]};
    end
    else if (rate_cntr_scal_full[5] == 1'b1) begin
        rate_cntr_scal_cclr <= 8'b00100000;
        rate_buffer_wr <= 1'b1;
        rate_buffer_wr_data <= {4'd5, frame_leng[5][13:0]};
    end
    else if (rate_cntr_scal_full[6] == 1'b1) begin
        rate_cntr_scal_cclr <= 8'b01000000;
        rate_buffer_wr <= 1'b1;
        rate_buffer_wr_data <= {4'd6, frame_leng[6][13:0]};
    end
    else if (rate_cntr_scal_full[7] == 1'b1) begin
        rate_cntr_scal_cclr <= 8'b10000000;
        rate_buffer_wr <= 1'b1;
        rate_buffer_wr_data <= {4'd7, frame_leng[7][13:0]};
    end
    else begin
        rate_cntr_scal_cclr <= 8'b00000000;
        rate_buffer_wr <= 1'b0;
        rate_buffer_wr_data <= {4'd0, frame_leng[0][13:0]};
    end
end

// generate output
assign bw_rate_wr      = rate_buffer_wr;
assign bw_rate_wr_data = rate_buffer_wr_data;

endmodule

