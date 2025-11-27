`timescale 1ns/1ps

module demo_top_tb;
    // Parameters
	localparam ADDR_WIDTH = 16;
	localparam DATA_WIDTH = 8;
	localparam SLAVE_MEM_ADDR_WIDTH = 12;

    // DUT Signals
    reg clk, rstn;
    reg start;
    reg d1_mode, d2_mode;
    reg d1_en, d2_en;
    wire d1_ready, d2_ready;

    demo_top #(
        .ADDR_WIDTH(ADDR_WIDTH), 
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    )top_dut(
        .clk(clk), 
        .rstn(rstn),
        .start(start),
        .d1_ready(d1_ready), 
        .d2_ready(d2_ready),
        .d1_mode(d1_mode), 
        .d2_mode(d2_mode),				
        .d1_en(d1_en), 
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
        start = 1;
        d1_en = 0;
        d2_en = 0;
        d1_mode = 0;
        d2_mode = 0;
        #15 rstn = 1; // Release reset after 15 time units



        // Write Operation: Sending data to the bus master 1
        wait (d1_ready == 1 && d2_ready == 1);
        @(posedge clk);
        d1_mode = 1;
        d1_en = 1;
        d2_en = 0;
        start = 0;

        #20;
        start = 1;
        wait (d1_ready == 1 && d2_ready == 1);

        #20;

        // Read operation: Master 1
        @(posedge clk);
        d1_mode = 0;                         // Set mode to read
        start = 0;                        // Assert valid signal

        #20;
        start = 1;
        wait (d1_ready == 1 && d2_ready == 1);

        // Write Operation: Sending data to the bus master 2
        @(posedge clk);
        d2_mode = 1;
        d1_en = 0;
        d2_en = 1;
        start = 0;

        #20;
        start = 1;
        wait (d1_ready == 1 && d2_ready == 1);

        #20;

        // Read operation: Master 1
        @(posedge clk);
        d2_mode = 0;                         // Set mode to read
        start = 0;                        // Assert valid signal

        #20;
        start = 1;
        wait (d1_ready == 1 && d2_ready == 1);

        //Both masters
        //Write operation
        @(posedge clk);
        d1_mode = 1;
        d2_mode = 1;
        d1_en = 1;
        d2_en = 1;
        start = 0;

        #20;
        start = 1;
        wait (d1_ready == 1 && d2_ready == 1);

        #20;
        //Read
        @(posedge clk);
        d1_mode = 0;
        d2_mode = 0;
        start = 0;

        #20;
        start = 1;
        wait (d1_ready == 1 && d2_ready == 1);

        // Small delay before next iteration
        #10;


        #10 $finish;
    end


endmodule