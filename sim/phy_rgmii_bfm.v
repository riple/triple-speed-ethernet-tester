/*
 * File   : phy_rgmii.v
 * Date   : 20130816
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`timescale 1ns/1ns
module phy_rgmii_bfm(
        RxClk,
        RxDv,
        RxData,
        TxClk,
        TxEn,
        TxData
        );
    
// I/O
output RxClk;
output RxDv;
output [3:0] RxData;
input  TxClk;
input  TxEn;
input  [3:0] TxData;

wire   phy_giga_mode = top_bench.dut.phy_giga_mode;
wire   phy_link_up   = top_bench.dut.phy_link_up;

// parameter definition
parameter DELAY=10;       // 10 is actually 10.5
parameter CLK_CYCLE=8;          // 8 for 125MHz
parameter INTERCONNECT_MATRIX=2;    // 3=open, 2=packet-feeder, 1=self-loopback, 0='bz
parameter CAPTURE_PKT_NUM=0;            // number of packet to be captured

// clk generation
reg clk_phy_pll;
initial
begin
    clk_phy_pll=1'b0;
    forever begin
        #(CLK_CYCLE/2) clk_phy_pll=~clk_phy_pll;
    end
end

// RxClk
assign RxClk=clk_phy_pll;

// input with delay
wire TxClk_phase_shift;
assign #(1*(CLK_CYCLE/4)) TxClk_phase_shift=RxClk;

reg [4:0] delay_line [0:DELAY];
integer i;

always @(posedge TxClk_phase_shift or negedge TxClk_phase_shift)
begin
    delay_line[0]<={TxEn,TxData};     // non-blocking assignment to induce delay
    for (i=0;i<DELAY;i=i+1)
    begin
        delay_line[i+1]<=delay_line[i]; // non-blocking assignment to induce delay
    end
end

// delay line initialization
initial
begin
    for (i=0;i<=DELAY;i=i+1)
    begin
        delay_line[i]=5'd0;
    end
end

// packet feeder
integer feeder_file, r, t;
integer start_addr, end_addr;
integer index;
reg eof;
reg pcap_endian;
reg [31:0] pcap_4bytes;
reg [31:0] packet_leng;
reg [ 7:0] packet_byte;
reg [ 4:0] feed;
initial
begin : feeder
    $display("PCAP reader begins!");
    feed[4]   = 1'b0;
    feed[3:0] = 4'd0;

    #200;
    @(phy_link_up);

    feeder_file = $fopen("phy_rgmii_rx_source.pcap","rb");
    if (feeder_file == 0)
    begin
        $display("Failed to open pcap_packets file!");
        disable feeder;
    end
    else
    begin
        // test pcap file endian
        r = $fread(pcap_4bytes, feeder_file);
        pcap_endian = (pcap_4bytes == 32'ha1b2c3d4)? 1:0;
        t = $fseek(feeder_file, -4, 1);
        // skip pcap file header 24*8
        t = $fseek(feeder_file, 24, 1);
        // read packet content
        eof = 0;
        while (!eof & !$feof(feeder_file))
        begin : fileread_loop
            // skip frame header (8+4)*8
            start_addr = $ftell(feeder_file);
            t = $fseek(feeder_file, 8+4, 1);
            // get frame length big endian 4*8
            r = $fread(packet_leng, feeder_file);
            packet_leng = pcap_endian? 
                               {packet_leng[31:24], packet_leng[23:16], packet_leng[15: 8], packet_leng[ 7: 0]}:
                               {packet_leng[ 7: 0], packet_leng[15: 8], packet_leng[23:16], packet_leng[31:24]};
            // check whether end of file
            if (r == 0) 
            begin
                eof = 1;
                @(TxClk_phase_shift);
                feed[4]   = 1'b0;
                feed[3:0] = 4'h0;
                disable fileread_loop;
            end
            // send ifg 96bit=12*(4*2)
            repeat (12)
            begin
                @(negedge TxClk_phase_shift);
                feed[4]   = 1'b0;
                feed[3:0] = 4'd0;
                @(posedge TxClk_phase_shift);
                feed[4]   = 1'b0;
                feed[3:0] = 4'd0;
            end
            // send frame pre-amble 55555555_555555d5=8*(4*2)
            repeat (1)
            begin
                @(negedge TxClk_phase_shift);
                feed[4]   = 1'b1;
                feed[3:0] = 4'h5;
            end
            repeat (14)
            begin
                @(        TxClk_phase_shift);
                feed[4]   = 1'b1;
                feed[3:0] = 4'h5;
            end
            repeat (1)
            begin
                @(posedge TxClk_phase_shift);
                feed[4]   = 1'b1;
                feed[3:0] = 4'hd;
            end
            // send frame content
            for (index=0; index<packet_leng; index=index+1)
            begin
                r = $fread(packet_byte, feeder_file);
                @(negedge TxClk_phase_shift);
                feed[4]   = 1'b1;
                feed[3:0] = packet_byte[3:0];
                @(posedge TxClk_phase_shift);
                feed[4]   = 1'b1;
                feed[3:0] = packet_byte[7:4];
                // check whether end of file
                if (r == 0) 
                begin
                    eof = 1;
                    @(TxClk_phase_shift);
                    feed[4]   = 1'b0;
                    feed[3:0] = 4'h0;
                    disable fileread_loop;
                end
            end
            end_addr = $ftell(feeder_file);
        end
        $fclose(feeder_file);
        feed[4]   = 1'b0;
        feed[3:0] = 4'd0;
    end
    $display("PCAP reader ends!");
    if (INTERCONNECT_MATRIX==2) begin
        #2000;
        $stop;
    end
end

// interconnect mux: 3=open, 2=packet-feeder, 1=self-loopback, 0='bz
wire RxDv_d1, RxDv_d2, RxDv_d3;
wire [3:0] RxData_d1, RxData_d2, RxData_d3;
assign RxDv_d1   = (INTERCONNECT_MATRIX==3)? 1'b0:
                  ((INTERCONNECT_MATRIX==2)? feed[  4]: 
                  ((INTERCONNECT_MATRIX==1)? delay_line[DELAY][  4]:
                                             1'bz));
assign RxData_d1 = (INTERCONNECT_MATRIX==3)? 4'd0:
                  ((INTERCONNECT_MATRIX==2)? feed[3:0]:
                  ((INTERCONNECT_MATRIX==1)? delay_line[DELAY][3:0]: 
                                             4'bz));
assign #(1*(CLK_CYCLE/4)) RxDv_d2 = RxDv_d1;
assign #(1*(CLK_CYCLE/4)) RxDv_d3 = RxDv_d2;

assign #(1*(CLK_CYCLE/4)) RxData_d2 = RxData_d1;
assign #(1*(CLK_CYCLE/4)) RxData_d3 = RxData_d2;

`ifdef XILINX
assign RxDv = RxDv_d3;
assign RxData = RxData_d3;
`else
assign RxDv = RxDv_d1;
assign RxData = RxData_d1;
`endif


// packet capture and report
integer reader_file;
reg [7:0] TxData_byte;
reg found_555555d5;
integer pack_num;
integer byte_num;

initial
begin : file_init
  if (CAPTURE_PKT_NUM) begin
    reader_file = $fopen("phy_rgmii_tx_record.pcap","wb");
    if (reader_file == 0)
    begin
        $display("Failed to open phy_rgmii_tx_record.pcap file!");
        disable file_init;
    end
    else
    begin
        // write pcap header
        $fwrite(reader_file,"%u",32'ha1b2c3d4);
        $fwrite(reader_file,"%u",32'h00040002);
        $fwrite(reader_file,"%u",32'h00000000);
        $fwrite(reader_file,"%u",32'h00000000);
        $fwrite(reader_file,"%u",32'h0000ffff);
        $fwrite(reader_file,"%u",32'h00000001);
        pack_num = 0;
        while (1)
        begin
            // wait for frame beginning
            @(posedge TxEn);
            byte_num = 0;
            found_555555d5 = 0;
            // write pcap header
            $fwrite(reader_file,"%u",32'h67452301);
            $fwrite(reader_file,"%u",32'hefcdab89);
            $fwrite(reader_file,"%u",32'hffffffff);
            $fwrite(reader_file,"%u",32'hffffffff);
            // skip pre-amble
            while (found_555555d5 == 0)
            begin
                if (phy_giga_mode) begin
                    @(negedge TxClk_phase_shift);
                    found_555555d5 = (TxData == 4'hd)? 1:found_555555d5;
                end else begin
                    @(posedge TxClk_phase_shift);
                    found_555555d5 = (TxData == 4'hd)? 1:found_555555d5;
                end
            end
            // capture content
            while (TxEn)
            begin
                if (phy_giga_mode) begin
                    @(posedge TxClk_phase_shift);
                    TxData_byte[3:0] = TxData;
                    @(negedge TxClk_phase_shift);
                    TxData_byte[7:4] = TxData;
                end else begin
                    @(posedge TxClk_phase_shift);
                    TxData_byte[3:0] = TxData;
                    @(posedge TxClk_phase_shift);
                    TxData_byte[7:4] = TxData;
                end
                if (TxEn)
                begin
                    $fwrite(reader_file,"%c",TxData_byte);
                    byte_num = byte_num + 1;
                end
            end
            // go back to write packet length
            t = $fseek (reader_file,-byte_num-4-4,1);
            $fwrite(reader_file,"%u",byte_num);
            $fwrite(reader_file,"%u",byte_num);
            // go forward for next frame
            t = $fseek (reader_file, byte_num    ,1);
            pack_num = pack_num + 1;
        end
        $fclose(reader_file);
    end
  end
end


endmodule
