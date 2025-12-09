`timescale 1ns/1ps

module demo_top_bb_dual_tb;
    localparam CLK_PERIOD = 20;

    reg clk = 1'b0;
    reg rstn = 1'b0;
    reg start_a = 1'b1;
    reg start_b = 1'b1;
    reg mode_a = 1'b1;
    reg mode_b = 1'b1;
    wire ready_a;
    wire ready_b;
    wire [7:0] LED_a;
    wire [7:0] LED_b;

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    demo_top_bb_dual dut (
        .clk(clk),
        .rstn(rstn),
        .start_a(start_a),
        .start_b(start_b),
        .mode_a(mode_a),
        .mode_b(mode_b),
        .ready_a(ready_a),
        .ready_b(ready_b),
        .LED_a(LED_a),
        .LED_b(LED_b)
    );

    // Simple stimulus: each side writes once, then reads back to exercise both directions
    initial begin
        // Reset
        #(5*CLK_PERIOD);
        rstn = 1'b1;
        repeat (2) @(posedge clk);

        // A writes to B
        mode_a = 1'b1;
        start_a = 1'b0; @(posedge clk); start_a = 1'b1;
        repeat (5) @(posedge clk);
        // wait (ready_a);
        repeat (20) @(posedge clk);
        #8000000;

        // rstn = 1'b0; 
        // repeat (2) @(posedge clk);   
        // rstn = 1'b1;
        // repeat (2) @(posedge clk);

        
        mode_a = 1'b0;
        start_a = 1'b0; repeat (5) @(posedge clk); start_a = 1'b1;
        repeat (5) @(posedge clk);
        //  wait (ready_a);
        repeat (20) @(posedge clk);
        #6000000;

        // // B writes to A
        // mode_b = 1'b1;
        // start_b = 1'b0; @(posedge clk); start_b = 1'b1;
        // wait (ready_b);
        // repeat (20) @(posedge clk);

        // // A reads back (should capture data coming from B)
        // mode_a = 1'b0;
        // start_a = 1'b0; @(posedge clk); start_a = 1'b1;
        // wait (ready_a);
        // repeat (20) @(posedge clk);

        // // B reads back (should capture data coming from A)
        // mode_b = 1'b0;
        // start_b = 1'b0; @(posedge clk); start_b = 1'b1;
        // wait (ready_b);
        // repeat (20) @(posedge clk);

        // $display("LED A = %0h, LED B = %0h", LED_a, LED_b);
        // $finish;
    end

    initial begin
        $dumpfile("demo_top_bb_dual_tb.vcd");
        $dumpvars(0, demo_top_bb_dual_tb);
    end
endmodule
