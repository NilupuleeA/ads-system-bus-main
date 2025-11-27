`timescale 1ns/1ps

module demo_top_bb_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 13;
    parameter BB_ADDR_WIDTH = 13;
    parameter DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;

    // DUT Signals
    reg clk, rstn;
    reg start;

    wire ready;
	reg mode;

    wire m_u_tx, s_u_tx;
    wire m_u_rx, s_u_rx;

    demo_top_bb #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .BB_ADDR_WIDTH(BB_ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .ready(ready),
        .mode(mode),
        .m_u_tx(m_u_tx),
        .m_u_rx(m_u_rx),
        .s_u_tx(s_u_tx),
        .s_u_rx(s_u_rx)
    );

    assign m_u_rx = s_u_tx;
    assign s_u_rx = m_u_tx;

    // Generate Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period is 10 units
    end

    integer i;

    // Test Stimulus
    initial begin

        // Reset the DUT
        rstn = 0;
        start = 1;
        mode = 0;
        //m_u_rx = 1;
        //s_u_rx = 1;
        #15 rstn = 1; // Release reset after 15 time units

        // Repeat the write and read tests 10 times
        for (i = 0; i < 1; i = i + 1) begin

            // Write Operation: Sending data to the bus
            wait (ready == 1);
            @(posedge clk);
            mode = 1;
            start = 0;

            #20;
            start = 1;
            wait (ready == 1 && dut.bus.bb_slave.u_tx_busy == 0);

            #20;

            /*// Read operation
            @(posedge clk);
            mode = 0;                         // Set mode to read
            start = 0;                        // Assert valid signal

            #20;
            start = 1;
            wait (ready == 1);

            // Small delay before next iteration
            #10;*/
        end

        #10 $finish;
    end


endmodule