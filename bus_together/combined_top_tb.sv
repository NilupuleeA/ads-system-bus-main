`timescale 1ns/1ps

module combined_top_tb;

    // Clock and reset signals
    logic clk;
    logic btn_reset;
    logic btn_trigger;
    logic start;
    logic mode;
    logic ready;

    // Clock generation: 100 MHz (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Instantiate the DUT (Device Under Test)
    combined_top u_dut (
        .clk(clk),
        .btn_reset(btn_reset),
        .btn_trigger(btn_trigger),
        .start(start),
        .mode(mode),
        .ready(ready)
    );

    // Test sequence
    initial begin
        // Initialize signals
        btn_reset = 1'b1;
        btn_trigger = 1'b0;
        start = 1'b1;
        mode = 1'b0;

        // Apply reset
        #100;
        btn_reset = 1'b0;
        #200;

        // Wait for system to stabilize
        #500;

        // Test 1: Trigger a write operation from Bus A
        $display("[%0t] Test 1: Triggering write from Bus A", $time);
        btn_trigger = 1'b1;
        #20;
        btn_trigger = 1'b0;
        
        // Wait for transaction to complete
        #50000;

        // Test 2: Trigger a read operation from Bus B
        $display("[%0t] Test 2: Triggering read from Bus B (mode=0)", $time);
        mode = 1'b0;
        start = 1'b0;
        #20;
        start = 1'b1;
        
        // Wait for ready signal
        wait(ready == 1'b1);
        $display("[%0t] Bus B read operation completed", $time);
        #1000;

        // Test 3: Trigger a write operation from Bus B
        $display("[%0t] Test 3: Triggering write from Bus B (mode=1)", $time);
        mode = 1'b1;
        start = 1'b0;
        #20;
        start = 1'b1;
        
        // Wait for ready signal
        wait(ready == 1'b1);
        $display("[%0t] Bus B write operation completed", $time);
        #1000;

        // Test 4: Another trigger from Bus A
        $display("[%0t] Test 4: Another trigger from Bus A", $time);
        btn_trigger = 1'b1;
        #20;
        btn_trigger = 1'b0;
        
        #50000;

        $display("[%0t] Simulation completed", $time);
        $finish;
    end

    // Timeout watchdog
    initial begin
        #500000;
        $display("[%0t] ERROR: Simulation timeout", $time);
        $finish;
    end

    // Optional: Monitor key signals
    initial begin
        $display("Time\t\tReset\tTrigger\tStart\tMode\tReady");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b", 
                 $time, btn_reset, btn_trigger, start, mode, ready);
    end

endmodule
