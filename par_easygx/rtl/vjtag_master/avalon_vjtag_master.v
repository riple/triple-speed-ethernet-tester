module avalon_vjtag_master (avm_mj_clk,avm_mj_reset,avm_mj_waitrequest,avm_mj_irq,avm_mj_address,avm_mj_read,avm_mj_write,
                            avm_mj_writedata,avm_mj_readdata,avm_mj_resetrequest);

parameter data_width = 32,
          addr_width = 32,
          jtag_instance_index = 0;

// avalon-mm master interface signals
input  avm_mj_clk,avm_mj_reset;
input  avm_mj_waitrequest;
input  [31:0] avm_mj_irq;
output [addr_width-1:0] avm_mj_address;
output avm_mj_read,avm_mj_write;
output [data_width-1:0] avm_mj_writedata;
input  [data_width-1:0] avm_mj_readdata;
output avm_mj_resetrequest;


////////////////////////////
// ueser added functions
////////////////////////////
/* user added virtual jtag scan chain registers */
reg [addr_width-1:0] addr_out_vj_scr;
reg [data_width-1:0] data_out_vj_scr;
reg [data_width-1:0] data_in_vj_scr;
reg [35:0] stat_in_vj_scr;
reg out_en_vj_scr;
reg in_en_vj_scr;
reg reset_en_vj_scr;

/* user added parallel update registers which are loaded from scan chain registers */
reg [addr_width-1:0] addr_out;
reg [data_width-1:0] data_out;

/* user added parallel capture registers which are loaded to scan chain registers */
reg [data_width-1:0] data_in;
reg [35:0] stat_in;

/* user added single event registers which are updated when dscan exited */
reg out_en;
reg in_en;
reg reset_en;
 
/* ir decoder */
wire [3:0] ir_in;
wire data_in_vj  = (ir_in=='d1)?1'b1:1'b0;
wire stat_in_vj  = (ir_in=='d2)?1'b1:1'b0;
wire data_out_vj = (ir_in=='d3)?1'b1:1'b0;
wire addr_out_vj = (ir_in=='d4)?1'b1:1'b0;
wire in_en_vj    = (ir_in=='d5)?1'b1:1'b0;
wire out_en_vj   = (ir_in=='d6)?1'b1:1'b0;
wire reset_en_vj = (ir_in=='d7)?1'b1:1'b0;

// user defined function to avalon-mm master interface map
assign avm_mj_address = addr_out;
assign avm_mj_writedata = data_out;
assign avm_mj_read = in_en_pending;
assign avm_mj_write = out_en_pending;
assign avm_mj_resetrequest = reset_en_posedge;

reg in_en_d1,in_en_d2,in_en_d3;
reg out_en_d1,out_en_d2,out_en_d3;
reg reset_en_d1,reset_en_d2,reset_en_d3;
wire in_en_posedge    = in_en_d2 && !in_en_d3;
wire out_en_posedge   = out_en_d2 && !out_en_d3;
wire reset_en_posedge = reset_en_d2 && !reset_en_d3;
always @(posedge avm_mj_clk or posedge avm_mj_reset)
begin
  if (avm_mj_reset)
  begin
    in_en_d1 <= 1'b0;    in_en_d2 <= 1'b0;    in_en_d3 <= 1'b0;
    out_en_d1 <= 1'b0;   out_en_d2 <= 1'b0;   out_en_d3 <= 1'b0;
    reset_en_d1 <= 1'b0; reset_en_d2 <= 1'b0; reset_en_d3 <= 1'b0;
  end
  else
  begin
    in_en_d1 <= in_en;       in_en_d2 <= in_en_d1;       in_en_d3 <= in_en_d2;
    out_en_d1 <= out_en;     out_en_d2 <= out_en_d1;     out_en_d3 <= out_en_d2;
    reset_en_d1 <= reset_en; reset_en_d2 <= reset_en_d1; reset_en_d3 <= reset_en_d2;
  end
end

// avalon-mm master interface waitrequest handler
reg in_en_pending;
always @(posedge avm_mj_clk or posedge avm_mj_reset)
begin
  if (avm_mj_reset)
    in_en_pending <= 1'b0;
  else if (in_en_posedge)
  	in_en_pending <= 1'b1;
  else if (!avm_mj_waitrequest)
    in_en_pending <= 1'b0;
  else
    in_en_pending <= in_en_pending;
end

reg out_en_pending;
always @(posedge avm_mj_clk or posedge avm_mj_reset)
begin
  if (avm_mj_reset)
    out_en_pending <= 1'b0;
  else if (out_en_posedge)
    out_en_pending <= 1'b1;
  else if (!avm_mj_waitrequest)
    out_en_pending <= 1'b0;
  else
    out_en_pending <= out_en_pending;
end

// avalon-mm master interface data capture
always @(posedge avm_mj_clk or posedge avm_mj_reset)
begin
  if (avm_mj_reset)
    data_in <= 'd0;
  else if (in_en_pending && !avm_mj_waitrequest)
  	data_in <= avm_mj_readdata;
end

// avalon-mm master interface stat capture
always @(avm_mj_irq[29:0] or out_en_pending or  in_en_pending)
  stat_in <= {avm_mj_irq[31:0], 2'b00, out_en_pending, in_en_pending};


////////////////////
// jtag functions
////////////////////
/* jtag interface signals */
wire tdi, tck, cdr, cir, e1dr, e2dr, pdr, sdr, udr, uir;
reg  tdo;
/* bypass register */
reg  bypass_reg;

/* data_in Instruction Handler */		
always @ (posedge tck)
  if ( data_in_vj && cdr )
    data_in_vj_scr <= data_in;
  else if ( data_in_vj && sdr )
    data_in_vj_scr <= {tdi, data_in_vj_scr[data_width-1:1]};
  
/* stat_in Instruction Handler */
always @ (posedge tck)
  if ( stat_in_vj && cdr )
    stat_in_vj_scr <= stat_in;
  else if ( stat_in_vj && sdr )
    stat_in_vj_scr <= {tdi, stat_in_vj_scr[35:1]};
        
/* data_out Instruction Handler */		
always @ (posedge tck)
  if ( data_out_vj && sdr )
    data_out_vj_scr <= {tdi, data_out_vj_scr[data_width-1:1]};
  else if ( data_out_vj && udr )
    data_out <= data_out_vj_scr;
    
/* addr_out Instruction Handler */
always @ (posedge tck)
  if ( addr_out_vj && sdr )
    addr_out_vj_scr <= {tdi, addr_out_vj_scr[data_width-1:1]};
  else if ( addr_out_vj && udr )
    addr_out <= addr_out_vj_scr;	
 
/* in_en Instruction Handler */	
always @ (posedge tck)
  if (in_en_vj && e1dr)
    in_en <= 1'b1;
  else 
    in_en <= 1'b0;
  
/* out_en Instruction Handler */	
always @ (posedge tck)
  if (out_en_vj && e1dr)
    out_en <= 1'b1;
  else 
    out_en <= 1'b0;
  
/* reset_en Instruction Handler */	
always @ (posedge tck)
  if (reset_en_vj && e1dr)
    reset_en <= 1'b1;
  else 
    reset_en <= 1'b0;

/* Bypass register */
always @ (posedge tck)
  bypass_reg <= tdi;

/* Node TDO Output */
always @ (data_in_vj,stat_in_vj,data_out_vj,addr_out_vj,out_en_vj,in_en_vj,reset_en_vj,
          data_in_vj_scr[0],stat_in_vj_scr[0],data_out_vj_scr[0],addr_out_vj_scr[0],bypass_reg)
begin
  if (data_in_vj)
    tdo <= data_in_vj_scr[0];
  else if (stat_in_vj)
    tdo <= stat_in_vj_scr[0];
  else if (data_out_vj)
    tdo <= data_out_vj_scr[0];
  else if (addr_out_vj)
  	tdo <= addr_out_vj_scr[0];
  else if (in_en_vj)
    tdo <= bypass_reg;
  else if (out_en_vj)
    tdo <= bypass_reg;
  else if (reset_en_vj)
    tdo <= bypass_reg;
  else
    tdo <= bypass_reg;
end

sld_virtual_jtag	sld_virtual_jtag_component (
				.ir_in (ir_in),
				.ir_out (4'b0),
				.tdo (tdo),
				.tdi (tdi),
				.tms (),
				.tck (tck),
				.virtual_state_cir (cir),
				.virtual_state_pdr (pdr),
				.virtual_state_uir (uir),
				.virtual_state_sdr (sdr),
				.virtual_state_cdr (cdr),
				.virtual_state_udr (udr),
				.virtual_state_e1dr (e1dr),
				.virtual_state_e2dr (e2dr),
				.jtag_state_rti (),
				.jtag_state_e1dr (),
				.jtag_state_e2dr (),
				.jtag_state_pir (),
				.jtag_state_tlr (),
				.jtag_state_sir (),
				.jtag_state_cir (),
				.jtag_state_uir (),
				.jtag_state_pdr (),
				.jtag_state_sdrs (),
				.jtag_state_sdr (),
				.jtag_state_cdr (),
				.jtag_state_udr (),
				.jtag_state_sirs (),
				.jtag_state_e1ir (),
				.jtag_state_e2ir ());
	defparam
		sld_virtual_jtag_component.sld_auto_instance_index = "NO",
		sld_virtual_jtag_component.sld_instance_index = jtag_instance_index,
		sld_virtual_jtag_component.sld_ir_width = 4,
		sld_virtual_jtag_component.sld_sim_action = "((1,1,1,2))",
		sld_virtual_jtag_component.sld_sim_n_scan = 1,
		sld_virtual_jtag_component.sld_sim_total_length = 2;
		
endmodule
