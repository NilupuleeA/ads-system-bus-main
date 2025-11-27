`timescale 1ns/1ps

module demo_master_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 12;
    parameter DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;

    // DUT Signals
    reg clk, rstn;
    reg start;

    wire d1_ready, d2_ready;
	reg d1_mode, d2_mode;					// 0 - read, 1 - write
    reg d1_en, d2_en;

    demo_top dut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .d1_ready(d1_ready),
        .d1_mode(d1_mode),
        .d1_en(d1_en),
        .d2_ready(d2_ready),
        .d2_mode(d2_mode),
        .d2_en(d2_en)
    );

    // Generate Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period is 10 units
    end

    integer i;

    // Test Stimulus
    initial begin

        // Reset the DUT
        rstn = 0;
        start = 0;
        mode = 0;
        #15 rstn = 1; // Release reset after 15 time units

        // Repeat the write and read tests 10 times
        for (i = 0; i < 10; i = i + 1) begin

            // Write Operation: Sending data to the bus
            wait (ready == 1);
            @(posedge clk);
            mode = 1;
            start = 1;

            #20;
            start = 0;
            wait (ready == 1 && sready == 1);

            #20;

            wait (ready == 1);
            @(posedge clk);
            mode = 1;
            start = 1;

            #20;
            start = 0;
            wait (ready == 1 && sready == 1);

            #20;

            // Read operation
            @(posedge clk);
            mode = 0;                         // Set mode to read
            start = 1;                        // Assert valid signal

            #20;
            start = 0;
            wait (ready == 1 && sready == 1);

            // Small delay before next iteration
            #10;
        end

        #10 $finish;
    end


endmodule