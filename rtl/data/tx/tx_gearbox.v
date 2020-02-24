/*
 * File   : tx_gearbox.v
 * Date   : 20131017
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module tx_gearbox (
    input  wire rst,
    input  wire clk,

    input  wire phy_giga_mode,
    output reg  gen_en,

    input  wire [31: 0] int_data_i,
    input  wire         int_valid_i,
    input  wire         int_sop_i,
    input  wire         int_eop_i,
    input  wire [ 1: 0] int_mod_i,

    output wire         gmii_clk,
    output reg          gmii_ctrl,
    output reg  [ 7: 0] gmii_data
);


// compensate for 32-bit datapath larger granularity, to generate minimum 96bit IFG
reg         int_eop_latch;
reg [ 1: 0] int_mod_latch;
reg [ 2: 0] int_cntr_hold_cntr;
reg [ 2: 0] int_cntr;

// capture packet eop and mod
always @(posedge clk) begin
    if (phy_giga_mode) begin
        if (int_cntr[1:0]==3-2) begin
            if (int_valid_i && int_eop_i) begin
                int_eop_latch <= 1'b1;
                int_mod_latch <= int_mod_i;
            end
            else begin
                int_eop_latch <= 1'b0;
                int_mod_latch <= 2'b00;
            end
        end
    end
    else begin
        if (int_cntr[2:0]==7-2) begin
            if (int_valid_i && int_eop_i) begin
                int_eop_latch <= 1'b1;
                int_mod_latch <= int_mod_i;
            end
            else begin
                int_eop_latch <= 1'b0;
                int_mod_latch <= 2'b00;
            end
        end
    end
end

always @(posedge rst or posedge clk) begin
    if (rst)
        int_cntr_hold_cntr <= 'd0;
    else if (int_cntr[1:0]==3-2 && int_eop_latch &&  phy_giga_mode)
        int_cntr_hold_cntr <= {1'b0,int_mod_latch};
    else if (int_cntr[2:0]==7-2 && int_eop_latch && !phy_giga_mode)
        int_cntr_hold_cntr <= {int_mod_latch,1'b0};
    else if (int_cntr_hold_cntr>'d0)
        int_cntr_hold_cntr <= int_cntr_hold_cntr - 'd1;
end

/* 32b internal data-path */
// 32b @125MHz 4cycle; 32b @25MHz 8cycle; 32b @2.5MHz 8cycle

/*  8b  GMII */
// H4b @125MHz 1cycle;  00 @25MHz 1cycle;  00 @2.5MHz 1cycle;
// L4b @125MHz 1cycle; L4b @25MHz 1cycle; L4b @2.5MHz 1cycle;

/*  8b  GMII, DDRIO input  */
// H4b @125MHz 1cycle; L4b @25MHz 1cycle; L4b @2.5MHz 1cycle;
// L4b @125MHz 1cycle; L4b @25MHz 1cycle; L4b @2.5MHz 1cycle;

/*  4b RGMII, DDRIO output */
//  4b @125MHz DDR   ;  4b @25MHz SDR   ;  4b @2.5MHz SDR

// internal counter to control all multicycle actions
always @(posedge rst or posedge clk) begin
    if (rst)
        int_cntr <= 'd0;
    else if (int_cntr_hold_cntr>'d0)
        int_cntr <= int_cntr;
    else
        int_cntr <= int_cntr + 'd1;
end

// latch 32 bit data-path control
reg int_valid;
always @(posedge clk) begin
    if (int_valid_i)
        int_valid <= 1'b1;
    else if (int_valid && ((phy_giga_mode && int_cntr[1:0]=='d3) || (!phy_giga_mode && int_cntr[2:0]=='d7)))
        int_valid <= 1'b0;
end
 
reg int_sop, int_eop;
always @(posedge clk) begin
    if (int_valid_i && int_sop_i)
        int_sop <= 1'b1;
    else if (int_sop   && ((phy_giga_mode && int_cntr[1:0]=='d3) || (!phy_giga_mode && int_cntr[2:0]=='d7)))
        int_sop <= 1'b0;
end
always @(posedge clk) begin
    if (int_valid_i && int_eop_i)
        int_eop <= 1'b1;
    else if (int_eop   && ((phy_giga_mode && int_cntr[1:0]=='d3) || (!phy_giga_mode && int_cntr[2:0]=='d7)))
        int_eop <= 1'b0;
end

reg [1:0] int_mod;
always @(posedge clk) begin
    if (int_valid_i && int_eop_i)
        int_mod <= int_mod_i;
    else if (int_eop   && ((phy_giga_mode && int_cntr[1:0]=='d3) || (!phy_giga_mode && int_cntr[2:0]=='d7)))
        int_mod <= 'd0;
end

// reform 32bit to 8bit
reg [ 7: 0] int_data;
always @(posedge clk) begin
    if (phy_giga_mode)
        case (int_cntr[1:0])
            2'd3: int_data[7:0] <= int_data_i[31:24];
            2'd0: int_data[7:0] <= int_data_i[23:16];
            2'd1: int_data[7:0] <= int_data_i[15: 8];
            2'd2: int_data[7:0] <= int_data_i[ 7: 0];
        endcase
    else
        case (int_cntr[2:0])  // [7:4]=4'd0 in 100M/10M mode
            3'd7: int_data[7:0] <= {4'b0000, int_data_i[27:24]};
            3'd0: int_data[7:0] <= {4'b0000, int_data_i[31:28]};
            3'd1: int_data[7:0] <= {4'b0000, int_data_i[19:16]};
            3'd2: int_data[7:0] <= {4'b0000, int_data_i[23:20]};
            3'd3: int_data[7:0] <= {4'b0000, int_data_i[11: 8]};
            3'd4: int_data[7:0] <= {4'b0000, int_data_i[15:12]};
            3'd5: int_data[7:0] <= {4'b0000, int_data_i[ 3: 0]};
            3'd6: int_data[7:0] <= {4'b0000, int_data_i[ 7: 4]};
        endcase
end

// output gmii signals 
assign gmii_clk = clk;
always @(posedge clk) begin
    if (phy_giga_mode)
        if (int_valid && int_eop)
            case (int_mod)
                2'b00: gmii_ctrl <= (int_cntr[1:0]<='d3)? 1'b1: 1'b0;
                2'b01: gmii_ctrl <= (int_cntr[1:0]<='d0)? 1'b1: 1'b0;
                2'b10: gmii_ctrl <= (int_cntr[1:0]<='d1)? 1'b1: 1'b0;
                2'b11: gmii_ctrl <= (int_cntr[1:0]<='d2)? 1'b1: 1'b0;
            endcase
        else if (int_valid)
            gmii_ctrl <= 1'b1;
        else
            gmii_ctrl <= 1'b0;
    else
        if (int_valid && int_eop)
            case (int_mod)
                2'b00: gmii_ctrl <= (int_cntr[2:0]<='d7)? 1'b1: 1'b0;
                2'b01: gmii_ctrl <= (int_cntr[2:0]<='d1)? 1'b1: 1'b0;
                2'b10: gmii_ctrl <= (int_cntr[2:0]<='d3)? 1'b1: 1'b0;
                2'b11: gmii_ctrl <= (int_cntr[2:0]<='d5)? 1'b1: 1'b0;
            endcase
        else if (int_valid)
            gmii_ctrl <= 1'b1;
        else
            gmii_ctrl <= 1'b0;
end
always @(posedge clk) begin
    if (int_valid) begin
        gmii_data[7:4] <= phy_giga_mode? int_data[3:0]: int_data[3:0];  // GMII[3:0] captured on rising edge of rgmii
        gmii_data[3:0] <= phy_giga_mode? int_data[7:4]: int_data[3:0];  // GMII[7:4]=XX in 100M/10M mode
    end
    else begin
        gmii_data[7:0] <= 8'd0;
    end
end

// output multicycle control signal
always @(posedge clk) begin
    if (phy_giga_mode)
        gen_en <= (int_cntr[1:0]==3-2)? 1'b1: 1'b0;  // every 4 clk cycle
    else
        gen_en <= (int_cntr[2:0]==7-2)? 1'b1: 1'b0;  // every 8 clk cycle
end

endmodule

