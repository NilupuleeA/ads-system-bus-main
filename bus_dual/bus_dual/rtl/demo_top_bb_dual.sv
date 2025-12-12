`timescale 1ns/1ps

module demo_top_bb_dual (
	input  logic       clk,
	input  logic       btn_reset,
	input  logic       btn_trigger,
	input  logic       uart_a_rx,
	output logic       uart_a_tx,
	input  logic       uart_b_rx,
	output logic       uart_b_tx,
	output logic [7:0] leds
);

	demo_top_bbA u_system_a (
		.clk(clk),
		.btn_reset(btn_reset),
		.btn_trigger(btn_trigger),
		.uart_a_rx(uart_a_rx),
		.uart_a_tx(uart_a_tx)
	);

	demo_top_bbB u_system_b (
		.clk(clk),
		.btn_reset(btn_reset),
		.uart_b_rx(uart_b_rx),
		.uart_b_tx(uart_b_tx),
		.leds(leds)
	);
endmodule

