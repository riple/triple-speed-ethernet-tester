/*
 * File   : ctrl_mdio.v
 * Date   : 20130923
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module ctrl_mdio (
    input  wire rst,

    input  wire         up_clk,
    input  wire         up_wr,
    input  wire         up_rd,
    input  wire [31: 0] up_addr,
    input  wire [31: 0] up_data_wr,
    output reg  [31: 0] up_data_rd,

    input  wire mdio_clk,
    inout  wire mdio_io
);

// tri-state driver 
wire mdio_i;
reg  mdio_o;
reg  mdio_oe;
assign mdio_io = mdio_oe? mdio_o: 1'bz;
assign mdio_i  = mdio_io;

// cpu interface: input
reg up_wr_mdio;
always @(posedge rst or posedge up_clk) begin
  if (rst)
    up_wr_mdio <= 1'b0;
  else if (up_wr)
    up_wr_mdio <= 1'b1;
  else
    up_wr_mdio <= 1'b0;
end

reg          mdio_drct;
reg  [31: 0] mdio_ctrl;
always @(posedge rst or posedge up_clk) begin
  if (rst) begin
    mdio_drct <= 1'b0;
    mdio_ctrl <= 32'd0;
  end
  else if (up_wr) begin
    // up_data_wr = {2'bRW, 1'b0, 5'bAAAAA, 3'b000, 5'bRRRRR, 16'bDDDDDDDDDDDDDDDD}
    $display("MDIO_MASTER: RW=2'b%2b, PHY=5'b%5b, REG=5'b%5b, DATA=16'h%4h", up_data_wr[31:30], up_data_wr[28:24], up_data_wr[20:16], up_data_wr[15: 0]);
    mdio_drct <=         up_data_wr[   30];  // 1 = wr
    mdio_ctrl <= {2'b01, up_data_wr[31:30], up_data_wr[28:24], up_data_wr[20:16], 2'b10, up_data_wr[15: 0]};
  end
end

wire mdio_load;
synchronizer_pulse up_wr_mdio_sync (
       .clk_in(up_clk),
       .clk_out(mdio_clk),
       .reset_n(!rst),
       .sync_in(up_wr_mdio),

       .sync_out_p1(mdio_load),
       .sync_out_p2(),
       .sync_out_reg2()
);

reg  [31: 0] up_data_in;
always @(posedge up_clk) begin
  if (up_wr) begin
    up_data_in <= up_data_wr;
  end
end

// state counter
reg [6:0] mdio_cntr;
always @(posedge rst or negedge mdio_clk) begin
  if (rst)
    mdio_cntr <= 'd64;
  else if (mdio_load)
    mdio_cntr <= 'd0;
  else if (mdio_cntr[6]==1'b0)
    mdio_cntr <= mdio_cntr + 'd1;
end

// shift register
reg [63:0] mdio_data;
always @(posedge rst or negedge mdio_clk) begin
  if (rst) begin
    mdio_data    <= {32'h00000000, 32'h00000000};
  end
  else if (mdio_load) begin
    mdio_data    <= {32'hffffffff, mdio_ctrl};
  end
  else if (mdio_cntr<'d64) begin
    mdio_data[63: 1] <= mdio_data[62: 0];
    mdio_data[    0] <= mdio_i;
  end
  else begin
    mdio_data    <= mdio_data;
  end
end

// output control
always @(posedge rst or negedge mdio_clk) begin
  if (rst) begin
    mdio_o <= 1'b1;
  end
  else if (mdio_load) begin
    mdio_o <= 1'b1;
  end
  else begin
    mdio_o <= mdio_data[63];
  end
end
always @(posedge rst or negedge mdio_clk) begin
  if (rst) begin
    mdio_oe <= 1'b0;
  end
  else begin
         if (mdio_cntr>='d46 && mdio_cntr<'d64)
      mdio_oe <= mdio_drct;
    else if (mdio_cntr>='d0  && mdio_cntr<'d46)
      mdio_oe <= 1'b1;
    else
      mdio_oe <= 1'b0;
  end
end

// cpu interface: output
wire mdio_done;
synchronizer_level clr_in_sync (
       .clk_out(up_clk),
       .clk_en(1'b1),
       .reset_n(!rst),
       .sync_in(mdio_cntr[6]),

       .sync_out_p1(mdio_done),
       .sync_out_reg2()
);

always @(posedge up_clk) begin
  if (up_wr) begin
    up_data_rd <=  up_data_in[31: 0];
  end
  if (mdio_done) begin
    // up_data_wr = {2'bRW, 1'b0, 5'bAAAAA, 3'b000, 5'bRRRRR, 16'bDDDDDDDDDDDDDDDD}
    up_data_rd <= {up_data_in[31:30], mdio_done, up_data_in[28:16], (mdio_drct? up_data_in[15:0]: mdio_data[15:0])};
  end
end

endmodule

