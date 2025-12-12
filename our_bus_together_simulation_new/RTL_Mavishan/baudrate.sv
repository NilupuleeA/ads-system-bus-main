module baudrate (
    input  logic clk_50m,
    output logic Rxclk_en,
    output logic Txclk_en
);

// Want to interface to 115200 baud UART for Tx/Rx pair
// Hence, 50000000 / 115200 = 434 Clocks Per Bit.

parameter int RX_ACC_MAX = 50000000 / (115200 * 16); // = (1/115200) / (1/50000000) / 16
parameter int TX_ACC_MAX = 50000000 / 115200;

parameter int RX_ACC_WIDTH = $clog2(RX_ACC_MAX);
parameter int TX_ACC_WIDTH = $clog2(TX_ACC_MAX);

logic [RX_ACC_WIDTH-1:0] rx_acc = 0;
logic [TX_ACC_WIDTH-1:0] tx_acc = 0;

always_ff @(posedge clk_50m) begin: Rx_loop
    if (rx_acc == RX_ACC_MAX[RX_ACC_WIDTH-1:0])
        rx_acc <= 0;
    else
        rx_acc <= rx_acc + 1;

    if (tx_acc == TX_ACC_MAX[TX_ACC_WIDTH-1:0])
        tx_acc <= 0;
    else
        tx_acc <= tx_acc + 1;
end

assign Rxclk_en = (rx_acc == 0);
assign Txclk_en = (tx_acc == 0);

endmodule