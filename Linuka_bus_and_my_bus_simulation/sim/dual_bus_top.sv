`timescale 1ns/1ps

module dual_bus_top (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       btn_trigger,
    // UART pair for the bridge target side of the symmetric design
    input  logic       bridge_target_uart_rx,
    output logic       bridge_target_uart_tx,
    // UART pair for the bridge initiator side of the symmetric design
    input  logic       bridge_initiator_uart_rx,
    output logic       bridge_initiator_uart_tx,
    // Control for the demo design
    input  logic       demo_start,
    input  logic       demo_mode,
    output logic       demo_ready,
    // UARTs for the demo design
    input  logic       m_uart_rx,
    input  logic       s_uart_rx,
    output logic       m_uart_tx,
    output logic       s_uart_tx,
    // Status LEDs
    output logic [7:0] leds_sys,
    output logic [7:0] leds_demo
);

    // Symmetric bus system instance
    system_top_with_bus_bridge_symmetric u_system (
        .clk(clk),
        .btn_reset(rst_n),
        .btn_trigger(btn_trigger),
        .bridge_target_uart_rx(bridge_target_uart_rx),
        .bridge_target_uart_tx(bridge_target_uart_tx),
        .bridge_initiator_uart_rx(bridge_initiator_uart_rx),
        .bridge_initiator_uart_tx(bridge_initiator_uart_tx),
        .leds(leds_sys)
    );

    // Demo bus system instance
    demo_top_bb u_demo (
        .clk(clk),
        .rstn(rst_n),
        .start(demo_start),
        .ready(demo_ready),
        .mode(demo_mode),
        .m_u_rx(m_uart_rx),
        .s_u_rx(s_uart_rx),
        .m_u_tx(m_uart_tx),
        .s_u_tx(s_uart_tx),
        .LED(leds_demo)
    );

endmodule
