`timescale 1ns/1ps

module dual_bus_tb;

    reg clk;
    reg rstn;

    dual_bus_top dut();

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    assign dut.clk = clk;

    task bus_transfer;
        input [15:0]            addr;
        input [7:0]             wdata;
        input                   wen;
        begin
            dut.maddr           = addr;
            dut.wen             = wen;
            if (wen == 1) begin
                dut.mwdata      = wdata;
                
            end
            else begin
                dut.mwdata      = 8'b0;
            end
            dut.mwvalid   = 1'b1;
            @(posedge clk);
            dut.mwvalid   = 1'b0;
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            wait (dut.mready == 1);
        end
    endtask

    initial begin
        rstn = 0;
        dut.rstn = 0;
        #40 dut.rstn = 1;

        @(posedge clk);

        bus_transfer(16'h0ABC, 8'h55, 1); // MASTER 1 WRITE
        bus_transfer(16'h02C5, 8'h34, 1); // MASTER 1 WRITE
        bus_transfer(16'h0ABC, 8'b0, 0);  // MASTER 1 READ
        bus_transfer(16'h02C5, 8'b0, 0);  // MASTER 1 READ

        #100;
        $stop;
    end

endmodule
