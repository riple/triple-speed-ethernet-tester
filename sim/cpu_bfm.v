/*
 * File   : cpu_bfm.v
 * Date   : 20130922
 * Author : Bibo Yang, ash_riple@hotmail.com
 *
 */

`define NULL 0

`timescale 1 ns/ 1 ns
module cpu_bfm(
    input  wire         up_clk,
    output reg          up_cs,
    output reg          up_wr,
    output reg          up_rd,
    output reg  [31: 0] up_addr,
    output reg  [31: 0] up_data_wr,
    input  wire [31: 0] up_data_rd
);

//    // clock generation
//    initial
//    begin
//        up_clk=1'b0;
//        forever begin
//            #50 up_clk=~up_clk;
//        end
//    end
 
    // internal register to hold the cpu read data
    reg [31:0] up_data_in;

    // read script file
    integer file, r;
    reg [80*8:1] command;
    reg [31:0] data1;
    reg [31:0] data2;
    
    initial
    begin : file_init
        
        `ifdef ENABLE_Y1564
        file = $fopen("cpu_bfm_y1564.txt","r");
        `else
        `ifdef ENABLE_LOOPBACK
        file = $fopen("cpu_bfm_loopback.txt","r");
        `else
        file = $fopen("cpu_bfm.txt","r");
        `endif
        `endif

        if (file == `NULL)
        begin
            $display("Failed to open CPU BFM script file!");
            disable file_init;
        end
    end
    
    initial
    begin : file_read
        while (!$feof(file))
        begin
            r = $fscanf(file, " %s %h %h\n", command, data1, data2);
            case (command)
            "start":
            begin
                $display("CPU Script begins.");
            end
            "stop":
            begin
                $fclose(file);
                $display("CPU Script ends.");
                $stop;
                disable file_read;
            end
            "//":
            begin
                r = $fscanf(file, " %s %s\n", data1, data2);
            end
            "rd":
            begin
                cpu_rd(data1);
                $display("cpu_rd mem[%8h] = %8h", data1, up_data_in);
            end
            "wr":
            begin
                cpu_wr(data1,data2);
                $display("cpu_wr mem[%8h] = %8h", data1, data2);
            end
            "wt":
            begin
                $display("cpu_wt for %d ns", data1);
                #data1;
            end
            "pl":
            begin
                $display("cpu_p1 mem[%8h] = %8h vs. %8h", data1, up_data_rd, data2);
                cpu_pl(data1,data2);
                $display("cpu_p2 mem[%8h] = %8h vs. %8h", data1, up_data_in, data2);
            end
            default:
                $display("CPU Unknown command '%0s'", command);
            endcase
        end
    
        $fclose(file);
    end   

    //************************************/
    // read and write tasks
    //************************************/

    //read
    task cpu_rd;
    input [31:0] rd_addr;
    begin
        up_cs = 1'b0;
        up_addr = 32'd0;
        up_rd = 1'b0;
        up_wr = 1'b0;
        up_data_wr = 32'd0;
        @(posedge up_clk);
        up_cs = 1'b1;
        up_addr = rd_addr;
        up_rd = 1'b1;
        @(posedge up_clk);
        up_cs = 1'b0;
        up_addr = 32'd0;
        up_rd = 1'b0;
        @(posedge up_clk);
        @(posedge up_clk);
        up_data_in = up_data_rd;
    end
    endtask
    
    //write
    task cpu_wr;
    input [31:0] wr_addr;
    input [31:0] wr_data;
    begin
        up_cs = 1'b0;
        up_addr = 32'd0;
        up_rd = 1'b0;
        up_wr = 1'b0;
        up_data_wr = 32'd0;
        @(posedge up_clk);
        up_cs = 1'b1;
        up_addr = wr_addr;
        up_wr = 1'b1;
        up_data_wr = wr_data;
        @(posedge up_clk);
        up_cs = 1'b0;
        up_addr = 32'd0;
        up_wr = 1'b0;
        up_data_wr = 32'd0;
        @(posedge up_clk);
    end
    endtask

    //poll
    task cpu_pl;
    input [31:0] rd_addr;
    input [31:0] poll_mask;
    begin
        up_cs = 1'b0;
        up_addr = 32'd0;
        up_rd = 1'b0;
        up_wr = 1'b0;
        up_data_wr = 32'd0;
        up_data_in = !poll_mask;
        while ((up_data_in & poll_mask) != poll_mask)
        begin
            @(posedge up_clk);
            up_cs = 1'b1;
            up_addr = rd_addr;
            up_rd = 1'b1;
            @(posedge up_clk);
            up_cs = 1'b0;
            up_addr = 32'd0;
            up_rd = 1'b0;
            @(posedge up_clk);
            @(posedge up_clk);
            up_data_in = up_data_rd;
        end
    end
    endtask


endmodule
