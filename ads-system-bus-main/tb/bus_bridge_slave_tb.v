`timescale 1ns/1ps

module bus_bridge_slave_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 12;
    parameter UART_CLOCKS_PER_PULSE = 5208;
    parameter UART_TX_DATA_WIDTH = DATA_WIDTH + ADDR_WIDTH + 1; 
    // Inputs
    reg clk;
    reg rstn;
    reg swdata;    // Write data from master
    reg smode;      // Read/Write mode from master
    reg mvalid;     // Data valid from master
    reg split_grant; // Split transaction grant
    wire u_rx;       // UART RX data
    reg [DATA_WIDTH - 1:0] data_input_2;
    reg data_en_2;

    // Outputs
    wire srdata;    // Read data to master
    wire svalid;    // Data valid from slave
    wire sready;    // Slave ready
    wire ssplit;    // Split signal
    wire u_tx;      // UART TX data

    // Internal signals
    wire tx_busy_1;
    wire ready_2;
    wire [UART_TX_DATA_WIDTH - 1:0] data_output_2;

    // Instantiate the DUT (Device Under Test)
    bus_bridge_slave #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) bbs1 (
        .clk(clk),
        .rstn(rstn),
        .swdata(swdata),
        .srdata(srdata),
        .smode(smode),
        .mvalid(mvalid),
        .split_grant(split_grant),
        .svalid(svalid),
        .sready(sready),
        .ssplit(ssplit),
        .u_tx(u_tx),
        .u_rx(u_rx)
    );

    // Instantiate UART 2 (Receiver)
    uart #(
        .CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE),
        .TX_DATA_WIDTH(8),
        .RX_DATA_WIDTH(UART_TX_DATA_WIDTH)
    ) uart2 (
        .data_input(data_input_2), 
        .data_en(data_en_2),
        .clk(clk),
        .rstn(rstn),
        .tx(u_rx),  
        .tx_busy(tx_busy_1),
        .rx(u_tx),  
        .ready(ready_2),  // Signal when data is ready
        .data_output(data_output_2)  // Output received data
    );

    // Generate Clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Clock period is 20 units
    end

    // Testbench procedure
    initial begin
        // Initialize signals
        data_input_2 = 8'b0;
        data_en_2 = 1'b0;
        split_grant = 0;
        rstn = 0;
        swdata = 0;
        smode = 0;  // Read mode initially
        mvalid = 0;

        // Apply reset
        #20 rstn = 1;

        ///// Testing Write operation
        #20;
        mvalid = 1;
		swdata = 0; //LSB
		smode = 1;
        //swdata = 12'b100110101010;    // Address
		#20 swdata = 1;
        #20 swdata = 0;
		#20 swdata = 1;
		#20 swdata = 0;
		#20 swdata = 1;
		#20 swdata = 0;
		#20 swdata = 1;
		#20 swdata = 1;
		#20 swdata = 0;
		#20 swdata = 0;
		#20 swdata = 1; // MSB

        //swdata = 8'b11010101;     // Data
		#20 swdata = 1; // LSB
		#20 swdata = 0;
		#20 swdata = 1;
		#20 swdata = 0;
		#20 swdata = 1;
		#20 swdata = 0;
		#20 swdata = 1;
		#20 swdata = 1; // MSB

        begin
            #20
            @(posedge ready_2);  // Wait for data to be ready
            $display("Received Data (Write Mode): %b", data_output_2);  // Display received data
        end
        #20
        ///// Testing Read operation
        // Initialize signals
        data_input_2 = 8'b0;
        data_en_2 = 1'b0;
        split_grant = 0;
        rstn = 0;
        swdata = 0;
        smode = 0;  // Read mode initially
        mvalid = 0;

        // Apply reset
        #20 rstn = 1;

       
        #20
        mvalid = 1;
		swdata = 0; //LSB
		smode = 0;
        //swdata = 12'b100110101010;    // Address
		#20 swdata = 1;
        #20 swdata = 0;
		#20 swdata = 1;
		#20 swdata = 0;
		#20 swdata = 1;
		#20 swdata = 0;
		#20 swdata = 1;
		#20 swdata = 1;
		#20 swdata = 0;
		#20 swdata = 0;
		#20 swdata = 1; // MSB
        begin
            #20
            @(posedge ready_2);  // Wait for data to be ready
            $display("Received Data (Read Mode): %b", data_output_2);  // Display received data
        end
        begin
            #40
            @(posedge clk);
            data_input_2 = 8'b11010100;
            data_en_2 = 1;  // Enable transmission
            wait (!tx_busy_1);  // Wait until transmitter is free
            @(posedge clk);
            data_en_2 = 0;  // Disable data enable
        end
        #100;
        
        // End simulation
        $finish;
    end

endmodule
