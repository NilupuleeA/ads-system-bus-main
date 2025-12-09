`timescale 1ns/1ps

module dual_bus_top_tb;

    // Clock and reset
    logic clk;
    logic rst_n;

    // Control inputs
    logic btn_trigger;
    logic demo_start;
    logic demo_mode;

    // UART wiring for both systems
    logic bridge_target_uart_rx;
    logic bridge_target_uart_tx;
    logic bridge_initiator_uart_rx;
    logic bridge_initiator_uart_tx;
    logic m_uart_rx;
    logic s_uart_rx;
    logic m_uart_tx;
    logic s_uart_tx;

    // Status outputs
    logic [7:0] leds_sys;
    logic [7:0] leds_demo;
    logic       demo_ready;

    dual_bus_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .btn_trigger(btn_trigger),
        .bridge_target_uart_rx(bridge_target_uart_rx),
        .bridge_target_uart_tx(bridge_target_uart_tx),
        .bridge_initiator_uart_rx(bridge_initiator_uart_rx),
        .bridge_initiator_uart_tx(bridge_initiator_uart_tx),
        .demo_start(demo_start),
        .demo_mode(demo_mode),
        .demo_ready(demo_ready),
        .m_uart_rx(m_uart_rx),
        .s_uart_rx(s_uart_rx),
        .m_uart_tx(m_uart_tx),
        .s_uart_tx(s_uart_tx),
        .leds_sys(leds_sys),
        .leds_demo(leds_demo)
    );

    // 50 MHz clock
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // Simple UART loopbacks so each subsystem has a partner
    assign bridge_target_uart_rx    = bridge_target_uart_tx;
    assign bridge_initiator_uart_rx = bridge_initiator_uart_tx;
    assign m_uart_rx                = m_uart_tx;
    assign s_uart_rx                = s_uart_tx;

    // Stimulus
    initial begin
        rst_n       = 1'b0;
        btn_trigger = 1'b0;
        demo_start  = 1'b1; // start signal is edge-detected on a falling edge
        demo_mode   = 1'b1; // write first

        #100;
        rst_n = 1'b1;

        // Kick the symmetric design
        #200;
        btn_trigger = 1'b1;
        #20;
        btn_trigger = 1'b0;

        // Issue a write transaction in the demo design
        #200;
        demo_start = 1'b0;
        #20;
        demo_start = 1'b1;

        // Issue a read transaction after the write completes
        #1000;
        demo_mode  = 1'b0;
        demo_start = 1'b0;
        #20;
        demo_start = 1'b1;

        #4000;
        $finish;
    end

endmodule
