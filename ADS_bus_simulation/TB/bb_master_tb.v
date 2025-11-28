`timescale 1ns/1ps

module bb_master_tb();

    // -----------------------------
    // Parameters
    // -----------------------------
    localparam ADDR_WIDTH = 16;
    localparam DATA_WIDTH = 8;
    localparam SLAVE_MEM_ADDR_WIDTH = 12;
    localparam BB_ADDR_WIDTH = 12;
    localparam UART_CLOCKS_PER_PULSE = 8; // small for simulation

    localparam UART_RX_DATA_WIDTH = 1 + DATA_WIDTH + BB_ADDR_WIDTH;
    localparam UART_TX_DATA_WIDTH = DATA_WIDTH;

    // -----------------------------
    // DUT Signals
    // -----------------------------
    reg clk, rstn;

    wire mrdata;
    wire mwdata;
    wire mmode;
    wire mvalid;
    reg  svalid;

    wire mbreq;
    reg  mbgrant;
    reg  msplit;
    reg  ack;

    wire u_tx;
    reg  u_rx;

    // -----------------------------
    // Instantiate DUT
    // -----------------------------
    bus_bridge_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .BB_ADDR_WIDTH(BB_ADDR_WIDTH),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) dut (
        .clk(clk),
        .rstn(rstn),

        // Master port ↔ bus
        .mrdata(mrdata),
        .mwdata(mwdata),
        .mmode(mmode),
        .mvalid(mvalid),
        .svalid(svalid),

        .mbreq(mbreq),
        .mbgrant(mbgrant),
        .msplit(msplit),
        .ack(ack),

        // UART
        .u_tx(u_tx),
        .u_rx(u_rx)
    );

    // -----------------------------
    // Generate clock
    // -----------------------------
    always #5 clk = ~clk;     // 100 MHz

    // -----------------------------
    // Stub: UART RX (drive u_rx)
    // -----------------------------
    task uart_send(input [UART_RX_DATA_WIDTH-1:0] packet);
        integer i;
        begin
            // start bit
            u_rx = 0;
            #(UART_CLOCKS_PER_PULSE*10);

            // data bits LSB-first
            for (i=0; i<UART_RX_DATA_WIDTH; i=i+1) begin
                u_rx = packet[i];
                #(UART_CLOCKS_PER_PULSE*10);
            end

            // stop bit
            u_rx = 1;
            #(UART_CLOCKS_PER_PULSE*10);
        end
    endtask

    // -----------------------------
    // Stub: simple master bus behavior
    // -----------------------------
    assign mrdata = 1'b1;   // always read '1'

    initial begin
        mbgrant = 0;
        msplit  = 0;
        svalid  = 0;
        ack     = 0;
        #100;
    end

    // Give grant, ack, svalid at appropriate times
    always @(posedge clk) begin
        if (mbreq)
            mbgrant <= 1;
        else
            mbgrant <= 0;

        // after address phase, generate ack
        if (mvalid && mmode == 0) begin
            ack <= 1;
        end else ack <= 0;

        // after ack, return read data bits
        if (mvalid && mmode == 0)
            svalid <= 1;
        else
            svalid <= 0;
    end

    // -----------------------------
    // Test Sequence
    // -----------------------------
    initial begin
        $dumpfile("tb_bus_bridge_master.vcd");
        $dumpvars(0, bb_master_tb);

        clk  = 0;
        rstn = 0;
        u_rx = 1;

        #100;
        rstn = 1;

        // -----------------------------
        // Send a WRITE command via UART
        // mode = 1, data = 0xAA, addr = 0x123
        // Format: {addr, data, mode}
        // -----------------------------
        $display("Sending WRITE command...");
        uart_send({12'h123, 8'hAA, 1'b1});

        #2000;

        // -----------------------------
        // Send a READ command
        // mode = 0, data ignored, addr = 0x055
        // -----------------------------
        $display("Sending READ command...");
        uart_send({12'h055, 8'h00, 1'b0});

        #5000;

        $display("Test Completed");
        $finish;
    end

endmodule
