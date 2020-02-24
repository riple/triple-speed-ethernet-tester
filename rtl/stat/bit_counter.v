/*
 * File   : bit_counter.v
 * Date   : 20130831
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module bit_counter
#(
  parameter integer bit_width = 64
)
(
  input  wire rst, clk,

  input  wire clr_in,

  input  wire         up_rd,
  input  wire [15: 0] up_addr,
  output wire [31: 0] up_data_rd,

  input  wire [          3: 0] base_addr,
  input  wire [bit_width-1: 0] bit_in,

  output reg  [bit_width-1: 0] clr_out
);

// generate clr_out
wire [bit_width-0:0] bit_in_temp = {1'b0, bit_in};  // enlarge 1 invalid bit for looping
genvar i;
generate
  for (i=0; i<bit_width; i=i+1) begin: clr_out_loop
    always @(posedge clk) clr_out[i] <= (bit_in_temp[bit_width:i+1]=='d0 && bit_in_temp[i]==1'b1)? 1'b1: 1'b0;
  end
endgenerate

// generate cntr_addr
reg  [ 5: 0] cntr_addr;
integer j;
always @(posedge clk) begin
  for (j=0; j<bit_width; j=j+1) begin: cntr_addr_loop
    if (bit_in[j] == 1'b1) cntr_addr <= j;
  end
end

// generate ram read-modify-write control signals
wire [ 9: 0] cntr_rdad;
wire         cntr_rden;
reg  [ 9: 0] cntr_wrad;
reg          cntr_wren;
assign cntr_rden = (clr_out!='d0)? 1'b1: 1'b0;
assign cntr_rdad = {base_addr, cntr_addr};
always @(posedge clk) cntr_wren <= cntr_rden;
always @(posedge clk) cntr_wrad <= cntr_rdad;

// generate ram read-modify-write value signals
wire [31: 0] cntr_curr;
wire [31: 0] cntr_next = cntr_curr + 1'b1;

// pipeline registers to improve timing
reg  [ 9: 0] cntr_wrad_d1, cntr_wrad_d2;
reg          cntr_wren_d1, cntr_wren_d2;
reg  [31: 0] cntr_next_d1, cntr_next_d2;
always @(posedge clk) begin cntr_wren_d1 <= cntr_wren; cntr_wren_d2 <= cntr_wren_d1; end
always @(posedge clk) begin cntr_wrad_d1 <= cntr_wrad; cntr_wrad_d2 <= cntr_wrad_d1; end
always @(posedge clk) begin cntr_next_d1 <= cntr_next; cntr_next_d2 <= cntr_next_d1; end

// cntr_clr
reg [9:0] cntr_clr_ad;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    cntr_clr_ad <= 'd0;
  end
  else if (clr_in) begin
    cntr_clr_ad <= cntr_clr_ad + 'd1;
  end
end

wire [31:0] cntr_clr_da = 32'h00000000;

// stat internal registers(ram-based), 64cntr*16stream=1024
dpram_sc_32_1024 stat_temp (
  .aclr     (rst),
  .clock    (clk),
  // update cntr_next
  .wren     (clr_in?        1'b1: cntr_wren_d2),
  .wraddress(clr_in? cntr_clr_ad: cntr_wrad_d2),
  .data     (clr_in? cntr_clr_da: cntr_next_d2),

  // get cntr_curr
  .rden     (cntr_rden),
  .rdaddress(cntr_rdad),
  .q        (cntr_curr)
);

// stat output registers(ram_based), 64cntr*16stream=1024
dpram_sc_32_1024 stat_dout (
  .aclr     (rst),
  .clock    (clk),
  // update cntr_next
  .wren     (clr_in?        1'b1: cntr_wren_d2),
  .wraddress(clr_in? cntr_clr_ad: cntr_wrad_d2),
  .data     (clr_in? cntr_clr_da: cntr_next_d2),

  // port B, CPU read port
  .rden     (up_rd),
  .rdaddress(up_addr[11:2]),  // rd 08020000 ~ 08020ffc
  .q        (up_data_rd)
);

/*
// debug: stat output shadow registers(ram_based), 64cntr*16stream=1024
spram_sc_32_1024_jtag stat_dout_shadow (
  .aclr     (rst),
  .clock    (clk),
  // update cntr_next
  .wren   (clr_in?        1'b1: cntr_wren_d2),
  .address(clr_in? cntr_clr_ad: cntr_wrad_d2),
  .data   (clr_in? cntr_clr_da: cntr_next_d2),
  
  // no read in user logic
  .rden   (),
  .q      ()
);
*/

endmodule
