`timescale 1ns / 1ps

module uart_tb;

    // Parameters
    parameter CLOCKS_PER_PULSE = 5208;  // For 9600 baud rate with 50 MHz clock
    parameter DATA_WIDTH = 25;

    // Testbench Signals
    reg clk;
    reg rstn;

    // UART 1 (Transmitter) Signals
    reg [DATA_WIDTH - 1:0] data_input_1;
    reg data_en_1;
    wire tx_1;
    wire tx_busy_1;

    // UART 2 (Receiver) Signals
    wire ready_2;
    wire [DATA_WIDTH - 1:0] data_output_2;
    reg rx_2;

    // Instantiate UART 1 (Transmitter)
    uart #(
        .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
        .TX_DATA_WIDTH(DATA_WIDTH),
        .RX_DATA_WIDTH(8)
    ) uart1 (
        .data_input(data_input_1),
        .data_en(data_en_1),
        .clk(clk),
        .rstn(rstn),
        .tx(tx_1),  // Transmitter output (tx)
        .tx_busy(tx_busy_1),
        .rx(1'b1),  // UART1 does not receive in this test, keep rx high
        .ready(),   // No need to monitor ready for uart1
        .data_output()
    );

    // Instantiate UART 2 (Receiver)
    uart #(
        .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
        .TX_DATA_WIDTH(8),
        .RX_DATA_WIDTH(DATA_WIDTH)
    ) uart2 (
        .data_input(8'b0),  // No input data for uart2
        .data_en(1'b0),
        .clk(clk),
        .rstn(rstn),
        .tx(),  // uart2 will not transmit in this test
        .tx_busy(),
        .rx(tx_1),  // Receive data from uart1's tx line
        .ready(ready_2),  // Signal when data is ready
        .data_output(data_output_2)  // Output received data
    );

    // Clock Generation (50 MHz)
    always #10 clk = ~clk;  // 20ns period

    // Reset Task
    task reset;
    begin
        rstn = 0;
        #100;  // Hold reset for 100ns
        rstn = 1;
    end
    endtask

    // Stimulate UART Transmission
    task transmit_data(input [DATA_WIDTH-1:0] data);
    begin
        @(posedge clk);
        data_input_1 = data;
        data_en_1 = 1;  // Enable transmission
        wait (!tx_busy_1);  // Wait until transmitter is free
        @(posedge clk);
        data_en_1 = 0;  // Disable data enable
    end
    endtask

    // Monitor UART Reception
    task monitor_reception;
    begin
        @(posedge ready_2);  // Wait for data to be ready
        $display("Received Data: %h", data_output_2);  // Display received data
    end
    endtask

    // Test Sequence
    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        data_input_1 = 8'b0;
        data_en_1 = 0;
        rx_2 = 1'b1;  // Idle state for UART RX (high)

        // Apply Reset
        reset;

        // Transmit and Receive Data
        $display("Starting UART Transmission...");
        transmit_data(25'h15234A5);  // Transmit 0xA5
        monitor_reception;  // Monitor and display the received data

        // End simulation
        #200;
        $finish;
    end

endmodule
