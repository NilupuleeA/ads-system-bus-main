`timescale 1ns/1ps

module system_top_bidirectional_tb;

    logic clk;
    logic rst_n_in;
    
    // Board A signals
    logic btn_reset_a;
    logic btn_trigger_a;
    logic [7:0] leds_a;
    
    // UART Ports Board A
    logic uart_tx_req_a;  // A Sends Req
    logic uart_rx_resp_a; // A Recv Resp
    logic uart_rx_req_a;  // A Recv Req
    logic uart_tx_resp_a; // A Sends Resp

    // Board B signals
    logic btn_reset_b;
    logic btn_trigger_b;
    logic [7:0] leds_b;

    // UART Ports Board B
    logic uart_tx_req_b;  // B Sends Req
    logic uart_rx_resp_b; // B Recv Resp
    logic uart_rx_req_b;  // B Recv Req
    logic uart_tx_resp_b; // B Sends Resp

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz
    end

    // Instance A (Board ID 0)
    system_top_bidirectional #(
        .BOARD_ID(0)
    ) dut_a (
        .clk(clk),
        .btn_reset(btn_reset_a),
        .btn_trigger(btn_trigger_a),
        .uart_tx_req(uart_tx_req_a),
        .uart_rx_resp(uart_rx_resp_a),
        .uart_rx_req(uart_rx_req_a),
        .uart_tx_resp(uart_tx_resp_a),
        .leds(leds_a)
    );

    // Instance B (Board ID 1)
    system_top_bidirectional #(
        .BOARD_ID(1)
    ) dut_b (
        .clk(clk),
        .btn_reset(btn_reset_b),
        .btn_trigger(btn_trigger_b),
        .uart_tx_req(uart_tx_req_b),
        .uart_rx_resp(uart_rx_resp_b),
        .uart_rx_req(uart_rx_req_b),
        .uart_tx_resp(uart_tx_resp_b),
        .leds(leds_b)
    );

    // ========================================================================
    // UART Physical Interconnect (2 Full-Duplex Pairs)
    // ========================================================================
    
    // Channel 1: A Requests -> B Responds
    assign uart_rx_req_b  = uart_tx_req_a;  // A's Req TX -> B's Req RX
    assign uart_rx_resp_a = uart_tx_resp_b; // B's Resp TX -> A's Resp RX

    // Channel 2: B Requests -> A Responds
    assign uart_rx_req_a  = uart_tx_req_b;  // B's Req TX -> A's Req RX
    assign uart_rx_resp_b = uart_tx_resp_a; // A's Resp TX -> B's Resp RX


    // Test Sequence
    initial begin
        // Initialize
        rst_n_in = 0;
        btn_reset_a = 1;
        btn_reset_b = 1;
        btn_trigger_a = 0;
        btn_trigger_b = 0;

        // Apply Reset
        #100;
        btn_reset_a = 0;
        btn_reset_b = 0;
        #100;

        $display("Starting Bidirectional Dual-UART Test...");

        // 1. Trigger A to send to B
        $display("Triggering Board A (Master) -> Expecting Board B LEDs to update.");
        @(posedge clk);
        btn_trigger_a = 1;
        #100;
        btn_trigger_a = 0;

        // Wait for transaction
        #300000; 

        if (leds_b === 8'hFF) 
            $display("SUCCESS: Board B LEDs updated to 0xFF!");
        else
            $display("FAILURE: Board B LEDs are %h (expected 0xFF)", leds_b);

        // 2. Trigger B to send to A
        $display("Triggering Board B (Master) -> Expecting Board A LEDs to update.");
        @(posedge clk);
        btn_trigger_b = 1;
        #100;
        btn_trigger_b = 0;

        #300000;

        if (leds_a === 8'hFF) 
            $display("SUCCESS: Board A LEDs updated to 0xFF!");
        else
            $display("FAILURE: Board A LEDs are %h (expected 0xFF)", leds_a);

        $finish;
    end

endmodule