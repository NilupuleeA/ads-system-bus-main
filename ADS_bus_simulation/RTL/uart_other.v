module uart_other #(
	parameter CLOCKS_PER_PULSE = 5208,
    parameter TX_DATA_WIDTH = 8,
	parameter RX_DATA_WIDTH = 8
)
(
	input [TX_DATA_WIDTH - 1:0] data_input,
	input data_en,
	input clk,
	input rstn,
	output tx,
	output tx_busy,
	input rx,
	output ready,
    output [RX_DATA_WIDTH -1:0] data_output
);

	wire Rxclk_en;
	wire Txclk_en;

	// uart_tx #(
	// 	.CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
	// 	.DATA_WIDTH(TX_DATA_WIDTH)
	// ) transmitter (
	// 	.data_in(data_input),
	// 	.data_en(data_en),
	// 	.clk(clk),
	// 	.rstn(rstn),
	// 	.tx(tx),
	// 	.tx_busy(tx_busy),
	// 	.clken(Txclk_en)
	// );

	uart_tx_other #(
		.DATA_WIDTH(TX_DATA_WIDTH)
	) transmitter (
		.data_in(data_input),  // Input data as a 32-bit register/vector
		.wr_en(data_en),    // Enable wire to start
		.clk(clk),
		.clken(Txclk_en),    // Clock signal for the transmitter
		.tx(tx),       // A single 1-bit register variable to hold transmitting bit
		.tx_busy(tx_busy)   // Transmitter is busy signal
	);


	uart_rx_other #(
		.DATA_WIDTH(RX_DATA_WIDTH)
	) receiver (
		.clk(clk),
		// .rstn(rstn),
		.rx(rx),
		.ready(ready),
		.data_out(data_output),
		.clken(Rxclk_en)
	);	

	baudrate bd (
		.clk_50m(clk),
		.Rxclk_en(Rxclk_en),
		.Txclk_en(Txclk_en)
	);
	
endmodule