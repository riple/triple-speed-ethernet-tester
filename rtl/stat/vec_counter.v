/*
 * File   : vec_counter.v
 * Date   : 20130902
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module vec_counter
#(
  parameter integer vec_width_index = 4,
  parameter integer vec_width_value = 32,
  parameter integer vec_num         = 16,
  parameter integer vec_width_total = (vec_width_index+vec_width_value)*vec_num
)
(
  input  wire rst, clk,

  input  wire clr_in,

  input  wire         up_rd,
  input  wire [15: 0] up_addr,
  output wire [31: 0] up_data_rd,

  input  wire [                        3: 0] base_addr,
  input  wire [vec_width_index*vec_num-1: 0] vec_index_in,
  input  wire [vec_width_value*vec_num-1: 0] vec_value_in,

  output reg  [vec_width_index*vec_num-1: 0] clr_out
);

// parse input vector values into seperate signals
wire [vec_width_value-1:0] vec_value [vec_num-1:0];
genvar k;
generate
  for (k=0; k<vec_num; k=k+1) begin: vec_loop
    assign vec_value[k] = vec_value_in[(vec_width_value*(k+1)-1):(vec_width_value*(k+0))];
  end
endgenerate

// generate clr_out
wire [vec_width_index*vec_num-0:0] vec_index_in_temp = {1'b0, vec_index_in};  // enlarge 1 invalid bit for looping
genvar i;
generate
  for (i=0; i<vec_width_index*vec_num; i=i+1) begin: clr_out_loop
    always @(posedge clk) clr_out[i] <= (vec_index_in_temp[vec_width_index*vec_num:i+1]=='d0 && vec_index_in_temp[i]==1'b1)? 1'b1: 1'b0;
  end
endgenerate

// generate cntr_addr
reg  [ 5: 0] cntr_addr;
integer j;
always @(posedge clk) begin
  for (j=0; j<vec_width_index*vec_num; j=j+1) begin: cntr_addr_loop
    if (vec_index_in[j] == 1'b1) cntr_addr <= j;
  end
end

// generate ram read-modify-write control signals
wire [ 9: 0] cntr_rdad;
wire         cntr_rden;
reg  [ 9: 0] cntr_wrad;
reg          cntr_wren;
assign cntr_rden = (clr_out!='d0)? 1'b1: 1'b0;
assign cntr_rdad = {base_addr, cntr_addr}; // 4+6
always @(posedge clk) begin cntr_wren <= cntr_rden; end
always @(posedge clk) begin cntr_wrad <= cntr_rdad; end

// generate ram read-modify-wrie values
wire [31: 0] cntr_curr;
reg  [31: 0] cntr_next;
always @(*) begin
  case (cntr_wrad[1:0])
    2'b11  : cntr_next =  cntr_curr + 1;                                                                 // sum high
    2'b10  : cntr_next =  cntr_curr + vec_value[cntr_wrad[5:2]];                                         // sum low
    2'b01  : cntr_next = (cntr_curr > vec_value[cntr_wrad[5:2]])? cntr_curr: vec_value[cntr_wrad[5:2]];  // max
    2'b00  : cntr_next = (cntr_curr < vec_value[cntr_wrad[5:2]])? cntr_curr: vec_value[cntr_wrad[5:2]];  // min
  endcase
end

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

reg [31:0] cntr_clr_da;
always @(posedge clk) begin
  case (cntr_clr_ad[1:0])
    2'b10:    cntr_clr_da <= 32'h00000000;  // sum high
    2'b01:    cntr_clr_da <= 32'h00000000;  // sum low
    2'b00:    cntr_clr_da <= 32'h00000000;  // max
    2'b11:    cntr_clr_da <= 32'hffffffff;  // min
    default:  cntr_clr_da <= 32'h00000000;  //
  endcase
end

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
  .rdaddress(up_addr[11:2]),  // rd 08030000 ~ 08030ffc
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
