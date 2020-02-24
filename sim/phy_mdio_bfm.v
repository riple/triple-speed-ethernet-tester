/*
 * File   : phy_mdio_bfm.v
 * Date   : 20130922
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1 ns/ 1 ns
module phy_mdio_bfm(
	mdc,
	mdio);
input mdc;
inout mdio;

/* tri-state driver */
wire mdio_i;
reg  mdio_o;
reg  mdio_oe;
assign mdio   = mdio_oe ? mdio_o:1'bz;
assign mdio_i = mdio;

/* memory */
parameter N = 32;
integer n;
reg [15:0] mem_data [N-1:0];
reg [15:0] reg_data_o;
reg [15:0] reg_data_i;
reg [ 4:0] phy_addr, reg_addr;
reg mem_update, mem_readen;
initial begin			// mem content
	for (n=0; n<N; n=n+1) begin
		mem_data[n] = 16'h0000;
	end
		mem_data[ 0] = 16'h0000;
		mem_data[ 1] = 16'h796d;
		mem_data[ 5] = 16'h55e0;
		mem_data[10] = 16'h3c00;
		mem_data[17] = 16'hac4c;
		mem_data[25] = 16'h0ff3;
end
always @(mem_readen or mem_update) begin
	// mem out
	if (mem_readen)
		reg_data_o = mem_data[reg_addr];
	// mem in
	if (mem_update)
		mem_data[reg_addr] = reg_data_i;
	// self-clear of reset signal
	if (mem_data[0][15] == 1'b1) begin
		mem_data[ 0][15] = 1'b0;
	end
	// AN result update according to configuration
		mem_data[17][15] = mem_data[0][ 6]; // giga result
		mem_data[17][14] = mem_data[0][13]; // fast result
		mem_data[17][13] = mem_data[0][ 8]; // Duplex result
end

/* shift register */
integer i;
reg mdio_load;
reg [15:0] mdio_data;
always @(posedge mdc) begin
	if (mdio_load) begin
			mdio_data = reg_data_o;
	end
	else begin
		for (i=15; i>0; i=i-1) begin
			mdio_data[i] = mdio_data[i-1];
		end
			mdio_data[0] = mdio_i;
	end
end

/* state machine */
reg [2:0] mdio_state;
reg mdio_ctrl;
parameter 
	MDIO_IDLE     = 3'd0,
	MDIO_START    = 3'd1,
	MDIO_OPCODE   = 3'd2,
	MDIO_PHY_ADDR = 3'd3,
	MDIO_REG_ADDR = 3'd4,
	MDIO_TA       = 3'd5,
	MDIO_DATA_IN  = 3'd6,
	MDIO_DATA_OUT = 3'd7;

initial begin
	mdio_state = MDIO_IDLE;
	mdio_oe    = 1'b0;
	mem_update = 1'b0;
	mem_readen = 1'b0;
end
always begin
	case (mdio_state)
	MDIO_IDLE:
	begin
		repeat (1) @(posedge mdc);
		mem_update = 1'b0;
		if (mdio_data[0] == 1'b0)
			mdio_state = MDIO_START;
		else
			mdio_state = MDIO_IDLE;
	end
	MDIO_START:
	begin
		repeat (1) @(posedge mdc);
		if (mdio_data[1:0] == 2'b01)
			mdio_state = MDIO_OPCODE;
		else
			mdio_state = MDIO_IDLE;
	end
	MDIO_OPCODE:
	begin
		repeat (2) @(posedge mdc);
		if      (mdio_data[1:0] == 2'b10) begin
			mdio_ctrl  = 1'b1;		// read
			mdio_state = MDIO_PHY_ADDR;
		end
		else if (mdio_data[1:0] == 2'b01) begin
			mdio_ctrl  = 1'b0;		// write
			mdio_state = MDIO_PHY_ADDR;
		end
		else begin
			mdio_state = MDIO_IDLE;
		end
                        $display("MDIO_TARGET: RW=2'b%2b", mdio_data[1:0]);
	end
	MDIO_PHY_ADDR:
	begin
		repeat (5) @(posedge mdc);
			mdio_state = MDIO_REG_ADDR;
			phy_addr   = mdio_data[4:0];
                        $display("MDIO_TARGET: PHY=5'b%5b", mdio_data[4:0]);
	end
	MDIO_REG_ADDR:
	begin
		repeat (5) @(posedge mdc);
			mdio_state = MDIO_TA;
			reg_addr   = mdio_data[4:0];
			mem_readen = mdio_ctrl;
                        $display("MDIO_TARGET: REG=5'b%5b", mdio_data[4:0]);
	end
	MDIO_TA:
	begin
		repeat (1) @(posedge mdc);
			mdio_load = mdio_ctrl;
			mdio_oe   = #2 mdio_ctrl;
			mdio_o    = #2 1'b0;
			mem_readen = 1'b0;
		repeat (1) @(posedge mdc);
			mdio_load = 1'b0;
		if (mdio_ctrl)
			mdio_state = MDIO_DATA_IN;
		else
			mdio_state = MDIO_DATA_OUT;
	end
	MDIO_DATA_IN:
	begin
		repeat (16) begin 
			mdio_o = #2 mdio_data[15];
			@(posedge mdc);
		end
			mdio_state = MDIO_IDLE;
			mdio_oe    = 1'b0;
                        $display("MDIO_TARGET: DO=16'h%4h", mdio_data[15:0]);
	end
	MDIO_DATA_OUT:
	begin
		repeat (16) @(posedge mdc);
			reg_data_i = mdio_data[15:0];
			mem_update = 1'b1;
			mdio_state = MDIO_IDLE;
			mdio_oe    = 1'b0;
                        $display("MDIO_TARGET: DI=16'h%4h", mdio_data[15:0]);
	end
	default:
	begin
			mdio_state = MDIO_IDLE;
			mdio_oe    = 1'b0;
			mem_update = 1'b0;
	end
	endcase
end


endmodule

