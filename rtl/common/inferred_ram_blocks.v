//// Quartus II Verilog Template
//// Single port RAM with single read/write address 

//module single_port_ram 
//#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
//(
//	input [(DATA_WIDTH-1):0] data,
//	input [(ADDR_WIDTH-1):0] addr,
//	input we, clk,
//	output [(DATA_WIDTH-1):0] q
//);

//	// Declare the RAM variable
//        (* ram_style = "block" *)
//	reg [DATA_WIDTH-1:0] mem_data[2**ADDR_WIDTH-1:0];

//	// Variable to hold the registered read address
//	reg [ADDR_WIDTH-1:0] addr_reg;

//	always @ (posedge clk)
//	begin
//		// Write
//		if (we)
//			mem_data[addr] <= data;

//		addr_reg <= addr;
//	end

//	// Continuous assignment implies read returns NEW data.
//	// This is the natural behavior of the TriMatrix memory
//	// blocks in Single Port mode.  
//	assign q = mem_data[addr_reg];

//endmodule



//// Quartus II Verilog Template
//// Single port RAM with single read/write address and initial contents 
//// specified with an initial block

//module single_port_ram_with_init
//#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
//(
//	input [(DATA_WIDTH-1):0] data,
//	input [(ADDR_WIDTH-1):0] addr,
//	input we, clk,
//	output [(DATA_WIDTH-1):0] q
//);

//	// Declare the RAM variable
//        (* ram_style = "block" *)
//	reg [DATA_WIDTH-1:0] mem_data[2**ADDR_WIDTH-1:0];

//	// Variable to hold the registered read address
//	reg [ADDR_WIDTH-1:0] addr_reg;

//	// Specify the initial contents.  You can also use the $readmemb
//	// system task to initialize the RAM variable from a text file.
//	// See the $readmemb template page for details.
//	initial 
//	begin : INIT
//		integer i;
//		for(i = 0; i < 2**ADDR_WIDTH; i = i + 1)
//			mem_data[i] = {DATA_WIDTH{1'b1}};
//	end 

//	always @ (posedge clk)
//	begin
//		// Write
//		if (we)
//			mem_data[addr] <= data;

//		addr_reg <= addr;
//	end

//	// Continuous assignment implies read returns NEW data.
//	// This is the natural behavior of the TriMatrix memory
//	// blocks in Single Port mode.  
//	assign q = mem_data[addr_reg];

//endmodule




// Quartus II Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

`timescale 1ns/1ns
module simple_dual_port_ram_single_clock
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] read_addr, write_addr,
	input we, clk,
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the RAM variable
        (* ram_style = "block" *)
	reg [DATA_WIDTH-1:0] mem_data[2**ADDR_WIDTH-1:0];

	always @ (posedge clk)
	begin
		// Write
		if (we)
			mem_data[write_addr] <= data;

		// Read (if read_addr == write_addr, return OLD data).	To return
		// NEW data, use = (blocking write) rather than <= (non-blocking write)
		// in the write assignment.	 NOTE: NEW data may require extra bypass
		// logic around the RAM.
		q <= mem_data[read_addr];
	end

endmodule




//// Quartus II Verilog Template
//// Simple Dual Port RAM with separate read/write addresses and
//// separate read/write clocks

//module simple_dual_port_ram_dual_clock
//#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
//(
//	input [(DATA_WIDTH-1):0] data,
//	input [(ADDR_WIDTH-1):0] read_addr, write_addr,
//	input we, read_clock, write_clock,
//	output reg [(DATA_WIDTH-1):0] q
//);
	
//	// Declare the RAM variable
//        (* ram_style = "block" *)
//	reg [DATA_WIDTH-1:0] mem_data[2**ADDR_WIDTH-1:0];
	
//	always @ (posedge write_clock)
//	begin
//		// Write
//		if (we)
//			mem_data[write_addr] <= data;
//	end
	
//	always @ (posedge read_clock)
//	begin
//		// Read 
//		q <= mem_data[read_addr];
//	end
	
//endmodule




//// Quartus II Verilog Template
//// True Dual Port RAM with single clock

//module true_dual_port_ram_single_clock
//#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
//(
//	input [(DATA_WIDTH-1):0] data_a, data_b,
//	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
//	input we_a, we_b, clk,
//	output reg [(DATA_WIDTH-1):0] q_a, q_b
//);

//	// Declare the RAM variable
//        (* ram_style = "block" *)
//	reg [DATA_WIDTH-1:0] mem_data[2**ADDR_WIDTH-1:0];

//	// Port A 
//	always @ (posedge clk)
//	begin
//		if (we_a) 
//		begin
//			mem_data[addr_a] <= data_a;
//			q_a <= data_a;
//		end
//		else 
//		begin
//			q_a <= mem_data[addr_a];
//		end 
//	end 

//	// Port B 
//	always @ (posedge clk)
//	begin
//		if (we_b) 
//		begin
//			mem_data[addr_b] <= data_b;
//			q_b <= data_b;
//		end
//		else 
//		begin
//			q_b <= mem_data[addr_b];
//		end 
//	end

//endmodule




// Quartus II Verilog Template
// True Dual Port RAM with dual clocks

`timescale 1ns/1ns
module true_dual_port_ram_dual_clock
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data_a, data_b,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input we_a, we_b, clk_a, clk_b,
	output reg [(DATA_WIDTH-1):0] q_a, q_b
);

	// Declare the RAM variable
        (* ram_style = "block" *)
	reg [DATA_WIDTH-1:0] mem_data[2**ADDR_WIDTH-1:0];

	always @ (posedge clk_a)
	begin
		// Port A 
		if (we_a) 
		begin
			mem_data[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= mem_data[addr_a];
		end 
	end

	always @ (posedge clk_b)
	begin
		// Port B 
		if (we_b) 
		begin
			mem_data[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= mem_data[addr_b];
		end 
	end

endmodule





