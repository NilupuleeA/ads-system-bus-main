`timescale 1ns/1ps

module top_bridge_tb;

    // Clock & reset
    reg clk = 0;
    reg rstn = 0;

    // UART lines
    reg bb_u_rx = 1'b1;   // idle high
    wire bb_u_tx;

    // DUT instance
    top_bridge dut (
        .clk(clk),
        .rstn(rstn),
        .bb_u_rx(bb_u_rx),
        .bb_u_tx(bb_u_tx)
    );

    // ------------------------
    // Clock generation
    // ------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz
    end

    // ------------------------
    // Reset
    // ------------------------
    initial begin
        rstn = 0;
        #100;
        rstn = 1;
    end

    // ------------------------
    // UART helper tasks
    // ------------------------
    localparam BIT_TIME = 52080; // adjust for simulation speed

    // Send one UART bit
    task uart_send_bit;
        input bit_val;
        begin
            bb_u_rx = bit_val;
            #(BIT_TIME);
        end
    endtask

    // Send a single byte LSB first
    task uart_send_byte;
        input [7:0] byte;
        integer i;
        begin
            // Start bit
            uart_send_bit(1'b0);
            // Data bits
            for (i = 0; i < 8; i=i+1)
                uart_send_bit(byte[i]);
            // Stop bit
            uart_send_bit(1'b1);
            // Small idle between bytes
            #(BIT_TIME);
        end
    endtask

    // Send example packet: mode + data + address (21 bits now)
    task uart_send_packet;
        input mode;
        input [11:0] addr;   // 12-bit address
        input [7:0] data;
        reg [20:0] pkt;
        integer i;
        begin
            pkt = {mode, data, addr}; // MSB: mode, then data, then addr (12 bits)
            // Start bit
            uart_send_bit(1'b0);
            // Send 21 bits LSB first
            for (i=0; i<21; i=i+1)
                uart_send_bit(pkt[i]);
            // Stop bit
            uart_send_bit(1'b1);
            #(BIT_TIME);
        end
    endtask

    // ------------------------
    // Test sequence
    // ------------------------
    initial begin
        // Wait for reset
        #200;

        $display("[%0t] TB: Sending UART packet to bus bridge master", $time);

        // Example: mode=1 (write), addr=12'h100, data=8'hA5
        uart_send_packet(1'b1, 12'h100, 8'hA5);

        // Send another packet if desired
        #500;
        uart_send_packet(1'b0, 12'h100, 8'h00);

        $display("[%0t] TB: Finished sending UART packets", $time);

        #1000;
        $finish;
    end

endmodule
