`timescale 1ns/1ps

module combined_top (
    input  logic clk,
    input  logic btn_reset,
    input  logic btn_trigger,
    input  logic start,
    input  logic mode,
    output logic ready,
	 output [7:0] LED
);
    // Internal UART cross-connection wires
    logic uart_a_to_b;  // system_top_with_bus_bridge_a.uart_tx -> demo_top_bb.m_u_rx
    logic uart_b_to_a;  // demo_top_bb.m_u_tx -> system_top_with_bus_bridge_a.uart_rx
	 logic [7:0] LED_wire;
    // Instantiate system_top_with_bus_bridge_a (Bus A side)
    system_top_with_bus_bridge_a u_system_a (
        .clk(clk),
        .btn_reset(btn_reset),
        .btn_trigger(btn_trigger),
        .uart_rx(uart_b_to_a),      // Receives from demo_top_bb.m_u_tx
        .uart_tx(uart_a_to_b)       // Transmits to demo_top_bb.m_u_rx
    );

    // Instantiate demo_top_bb (Bus B side)
    demo_top_bb #(
        .ADDR_WIDTH(16),
        .DATA_WIDTH(8),
        .SLAVE_MEM_ADDR_WIDTH(13),
        .BB_ADDR_WIDTH(13),
        .UART_CLOCKS_PER_PULSE(5208)
    ) u_demo_bb (
        .clk(clk),
        .rstn(~btn_reset),           // demo_top_bb uses active-low reset
        .start(start),
        .ready(ready),
        .mode(mode),
        .m_u_rx(uart_a_to_b),       // Receives from system_top_with_bus_bridge_a.uart_tx
        .s_u_rx(1'b1),              // Idle high (no secondary UART connection)
        .m_u_tx(uart_b_to_a),       // Transmits to system_top_with_bus_bridge_a.uart_rx
        .s_u_tx(),
        .LED(LED_wire)
    );

	 assign LED = LED_wire;
	 
endmodule
