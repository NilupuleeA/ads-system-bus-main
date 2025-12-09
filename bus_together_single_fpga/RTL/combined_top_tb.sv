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
        // Initialize signals: keep Bus B idle
        btn_reset   = 1'b1;
        btn_trigger = 1'b0;
        // start       = 1'b0;
        // mode        = 1'b0;

        // Apply reset
        #100;
        btn_reset = 1'b0;

        // Allow settling time
        #200;

        // Single Bus A trigger after ~4 ms
        #4000000;                  // 4 ms at 1 ns units
        // $display("[%0t] Triggering Bus A", $time);
        btn_trigger = 1'b1;
        #20;
        btn_trigger = 1'b0;

        // Observe for a while then finish
        #100000;
        // $display("[%0t] Simulation completed", $time);
        $finish;
    end

    // Timeout watchdog
    initial begin
        #500000;
        // $display("[%0t] ERROR: Simulation timeout", $time);
        $finish;
    end

    // Optional: Monitor key signals
    initial begin
        $display("Time\t\tReset\tTrigger\tStart\tMode\tReady");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b", 
                 $time, btn_reset, btn_trigger, start, mode, ready);
    end

endmodule
