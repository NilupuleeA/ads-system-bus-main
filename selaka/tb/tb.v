`timescale 1ns/1ps

module tb;

    reg clk;
    reg rstn;
    localparam ADDR_WIDTH = 16;
    localparam DATA_WIDTH = 8;

    top dut();

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    assign dut.clk = clk;

    task master_tx_request(
        input [1:0] master_id,
        input [ADDR_WIDTH-1:0] addr,
        input [DATA_WIDTH-1:0] wdata,
        input wen
    );
        begin
            if (master_id == 0) begin
                dut.m1_addr   = addr;
                dut.m1_wdata  = wdata;
                dut.m1_wen    = wen;
                dut.m1_wvalid = 1;
                @(posedge clk);
                dut.m1_wvalid = 0;
                @(posedge clk);
                @(posedge clk);
                @(posedge clk);
                wait(dut.m1_ready);
            end
            else if (master_id == 1) begin
                dut.m2_addr   = addr;
                dut.m2_wdata  = wdata;
                dut.m2_wen    = wen;
                dut.m2_wvalid = 1;
                @(posedge clk);
                dut.m2_wvalid = 0;
                @(posedge clk);
                @(posedge clk);
                @(posedge clk);
                wait(dut.m2_ready);
            end
        end


    endtask

    task master_write_read;
        input [1:0] master_id;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] wdata;
        begin
            master_tx_request(master_id, addr, wdata, 1);
            master_tx_request(master_id, addr, 8'h00, 0);
        end


    endtask

    initial begin
        rstn = 0;
        dut.rstn = 0;
        #40 
        dut.rstn = 1;

        @(posedge clk);

        // master_tx_request(0, 16'h2ABC, 8'hAA, 1); // Master 1 Write
        master_tx_request(0, 16'h2ABC, 8'h29, 1);  // Master 2 Write

        fork
            master_tx_request(0, 16'h2ABC, 8'h00, 0);  // Master 1 write
            master_write_read(1, 16'h09Ac, 8'h54);  // Master 2 write
        join


        #100;
        $stop;
    end

endmodule
