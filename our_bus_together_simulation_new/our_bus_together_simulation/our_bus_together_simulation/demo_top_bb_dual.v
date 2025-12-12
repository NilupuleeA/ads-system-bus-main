module demo_top_bb_dual #(
    parameter ADDR_WIDTH = 16,
    parameter DATA_WIDTH = 8,
    parameter SLAVE_MEM_ADDR_WIDTH = 14,
    parameter BB_ADDR_WIDTH = 14,
    parameter UART_CLOCKS_PER_PULSE = 5208
)(
    input clk,
    input rstn,
    input start_a,
    input start_b,
    input mode_a,
    input mode_b,
    output ready_a,
    output ready_b,
    output [DATA_WIDTH-1:0] LED_a,
    output [DATA_WIDTH-1:0] LED_b,
    output [DATA_WIDTH-1:0] LED_demo_a,
    output [DATA_WIDTH-1:0] LED_demo_b
);

    // UART cross-links between the two demo instances
    wire a_m_u_tx, a_s_u_tx, b_m_u_tx, b_s_u_tx;
    wire a_m_u_rx, a_s_u_rx, b_m_u_rx, b_s_u_rx;

    // Connect master TX of one side to slave RX of the other, and return data path back to the master RX
    assign a_m_u_rx = b_s_u_tx;
    assign b_s_u_rx = a_m_u_tx;

    assign b_m_u_rx = a_s_u_tx;
    assign a_s_u_rx = b_m_u_tx;

    demo_top_bbA #(
        .ADDR_WIDTH(16),
        .DATA_WIDTH(8),
        .SLAVE_MEM_ADDR_WIDTH(14),
        .BB_ADDR_WIDTH(14),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) demo_a (
        .clk(clk),
        .rstn(rstn),
        .start(start_a),
        .ready(ready_a),
        .mode(mode_a),
        .m_u_rx(a_m_u_rx),
        .s_u_rx(a_s_u_rx),
        .m_u_tx(a_m_u_tx),
        .s_u_tx(a_s_u_tx),
        .LED(LED_a),
        .LED_demo(LED_demo_a)
    );

    demo_top_bbB #(
        .ADDR_WIDTH(14),
        .DATA_WIDTH(8),
        .SLAVE_MEM_ADDR_WIDTH(12),
        .BB_ADDR_WIDTH(12),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) demo_b (
        .clk(clk),
        .rstn(rstn),
        .start(start_b),
        .ready(ready_b),
        .mode(mode_b),
        .m_u_rx(b_m_u_rx),
        .s_u_rx(b_s_u_rx),
        .m_u_tx(b_m_u_tx),
        .s_u_tx(b_s_u_tx),
        .LED(LED_b),
        .LED_demo(LED_demo_b)
    );

endmodule
