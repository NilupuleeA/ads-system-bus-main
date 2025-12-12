// Combined UART transceiver: 32-bit TX (uart_tx_32) + 16-bit RX (uart_rx_other_16) + baudrate
// Interface mirrors uart_other for drop-in use
module uart_other_32_16 #(
    parameter CLOCKS_PER_PULSE = 5208,      // kept for interface parity; baudrate module derives from clk_50m
    parameter TX_DATA_WIDTH    = 32,
    parameter RX_DATA_WIDTH    = 16
)(
    input  [TX_DATA_WIDTH-1:0] data_input,
    input  data_en,
    input  clk,
    input  rstn,
    output tx,
    output tx_busy,
    input  rx,
    output ready,
    output [RX_DATA_WIDTH-1:0] data_output
);
    wire Rxclk_en;
    wire Txclk_en;

    // Baud tick generator (shares clk as 50 MHz ref like existing uart_other)
    baudrate bd (
        .clk_50m(clk),
        .Rxclk_en(Rxclk_en),
        .Txclk_en(Txclk_en)
    );

    // 32-bit transmitter
    uart_tx_32 #(
        .DATA_WIDTH(TX_DATA_WIDTH)
    ) transmitter (
        .clk(clk),
        .clken(Txclk_en),
        .wr_en(data_en),
        .data_in(data_input),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // 16-bit receiver
    uart_rx_other_16 #(
        .DATA_WIDTH(RX_DATA_WIDTH)
    ) receiver (
        .rx(rx),
        .ready(ready),
        .clk(clk),
        .clken(Rxclk_en),
        .data_out(data_output)
    );

endmodule
