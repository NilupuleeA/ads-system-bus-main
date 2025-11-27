`timescale 1ns / 1ps

module uart_other_tb;

    // Parameters
    parameter CLOCKS_PER_PULSE = 5208;  // For 9600 baud rate with 50 MHz clock
    parameter DATA_WIDTH = 25;

    // Testbench Signals
    reg clk;
    reg rstn;

    // UART 1 (Transmitter) Signals
    reg [DATA_WIDTH - 1:0] data_input_1, data_input_2;
    reg data_en_1, data_en_2;
    wire tx_1;
    wire tx_busy_1, tx_nbusy_2;

    // UART 2 (Receiver) Signals
    wire ready_2, ready_1;
    wire [DATA_WIDTH - 1:0] data_output_2, data_output_1;
    wire rx_2;

    // Instantiate UART 1 (Transmitter)
    uart #(
        .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE),
        .TX_DATA_WIDTH(DATA_WIDTH),
        .RX_DATA_WIDTH(DATA_WIDTH)
    ) uart1 (
        .data_input(data_input_1),
        .data_en(data_en_1),
        .clk(clk),
        .rstn(rstn),
        .tx(tx_1),  // Transmitter output (tx)
        .tx_busy(tx_busy_1),
        .rx(rx_2),  // UART1 does not receive in this test, keep rx high
        .ready(ready_1),   // No need to monitor ready for uart1
        .data_output(data_output_1)
    );

    // Instantiate UART 2 (Receiver)
    /*uart #(
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
    );*/

    uart_other #(
        .DATA_WIDTH(DATA_WIDTH),
        .BAUD_RATE(9600),
        .CLK_FREQ(50_000_000)
    ) uart2 (
        .sig_rx(tx_1),
        .data_rx(data_output_2),
        .valid_rx(ready_2),
        .ready_rx(0),
        .sig_tx(rx_2),
        .data_tx(data_input_2),
        .valid_tx(data_en_2),
        .ready_tx(tx_nbusy_2),
        .clk(clk),
        .rstn(rstn)
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

    task transmit_data_2(input [DATA_WIDTH-1:0] data);
    begin
        @(posedge clk);
        data_input_2 = data;
        data_en_2 = 1;  // Enable transmission
        wait (tx_nbusy_2);  // Wait until transmitter is free
        @(posedge clk);
        @(posedge clk);
        data_en_2 = 0;  // Disable data enable
    end
    endtask

    // Monitor UART Reception
    task monitor_reception_2;
    begin
        @(posedge ready_1);  // Wait for data to be ready
        $display("Received Data: %h", data_output_1);  // Display received data
    end
    endtask

    // Test Sequence
    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        data_input_1 = 8'b0;
        data_en_1 = 0;
        data_input_2 = 8'b0;
        data_en_2 = 0;

        // Apply Reset
        reset;

        // Transmit and Receive Data
        $display("Starting UART Transmission...");
        transmit_data(25'h15234A5);  // Transmit 0xA5
        monitor_reception;  // Monitor and display the received data

        #20;
        transmit_data(25'h15234DD);  // Transmit 0xA5
        monitor_reception;  // Monitor and display the received data

        #100;
        $display("Starting UART Transmission...");
        transmit_data_2(25'h15234A5);  // Transmit 0xA5
        monitor_reception_2;  // Monitor and display the received data

        #20;
        transmit_data_2(25'h15234DD);  // Transmit 0xA5
        monitor_reception_2;  // Monitor and display the received data

        // End simulation
        #200;
        $finish;
    end

endmodule
