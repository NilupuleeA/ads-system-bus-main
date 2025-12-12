`timescale 1ns/1ps

module system_top_uart_dual_fpga_tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic clk;
    logic btn_reset_a;
    logic btn_reset_b;
    logic btn_trigger_a;
    logic uart_a_tx;
    logic uart_a_rx;
    logic uart_b_tx;
    logic uart_b_rx;
    logic [7:0] leds_b;
    wire  m1_done;
    wire [7:0] m1_read_data;

    // Shared 50 MHz clock.
    initial clk = 1'b0;
    always #10 clk = ~clk;

    // Cross-connect UART links between the two top-level designs.
    assign uart_a_rx = uart_b_tx;
    assign uart_b_rx = uart_a_tx;

    system_top_with_bus_bridge_a u_system_a (
        .clk(clk),
        .btn_reset(btn_reset_a),
        .btn_trigger(btn_trigger_a),
        .uart_rx(uart_a_rx),
        .uart_tx(uart_a_tx)
    );

    system_top_with_bus_bridge_b u_system_b (
        .clk(clk),
        .btn_reset(btn_reset_b),
        .uart_rx(uart_b_rx),
        .uart_tx(uart_b_tx),
        .leds(leds_b)
    );

    assign m1_done = u_system_a.u_master_1.done;
    assign m1_read_data = u_system_a.u_master_1.read_data_value;

    initial begin
        btn_reset_a = 1'b1;
        btn_reset_b = 1'b1;
        btn_trigger_a = 1'b0;

        repeat (10) @(posedge clk);
        btn_reset_a = 1'b0;
        btn_reset_b = 1'b0;

        repeat (50) @(posedge clk);
        btn_trigger_a = 1'b1;
        @(posedge clk);
        btn_trigger_a = 1'b0;

        wait (leds_b == 8'hA5);
        $display("[TB] Remote write observed, LEDs = 0x%0h", leds_b);

        wait (m1_done);
        $display("[TB] Initiator read-back complete, data = 0x%0h", m1_read_data);

        if (m1_read_data !== 8'hA5)
            $error("[TB] Unexpected read data: 0x%0h", m1_read_data);

        repeat (500) @(posedge clk);
        $finish;
    end

endmodule
