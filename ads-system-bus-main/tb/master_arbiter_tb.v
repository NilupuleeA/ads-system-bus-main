`timescale 1ns/1ps

module master_arbiter_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter DEVICE_ADDR_WIDTH = 4;

    // DUT Signals
    reg clk, rstn;
    reg [DATA_WIDTH-1:0] dwdata;  // Write data to the DUT
    wire [DATA_WIDTH-1:0] drdata; // Read data from the DUT
    reg [ADDR_WIDTH-1:0] daddr;
    reg dvalid; 				  // Ready valid interface
    wire dready;
    reg dmode;					  // 0 - read, 1 - write

    reg mrdata;					  // Read data from serial bus
    wire mwdata;				  // Write data to serial bus
    wire mmode;					  // 0 - read, 1 - write
    wire mvalid;				  // Write data valid
    reg svalid;					  // Read data valid from serial bus
    wire ack;

    // Arbiter signals
    wire breq1, bgrant1, bgrant2, msel;

    // Decoder signals
    wire mvalid1, mvalid2, mvalid3;
    wire ssel;

    // Instantiate the DUT (Device Under Test)
    master_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master (
        .clk(clk),
        .rstn(rstn),
        .dwdata(dwdata),
        .drdata(drdata),
        .daddr(daddr),
        .dvalid(dvalid),
        .dready(dready),
        .dmode(dmode),
        .mrdata(mrdata),
        .mwdata(mwdata),
        .mmode(mmode),
        .mvalid(mvalid),
        .svalid(svalid),
        .mbreq(breq1),
        .mbgrant(bgrant1),
        .ack(ack)
    );

    arbiter arb (
        .clk(clk),
        .rstn(rstn),
        .breq1(breq1),
        .breq2(0),
        .bgrant1(bgrant1),
        .bgrant2(bgrant2),
        .msel(msel)
    );

    addr_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEVICE_ADDR_WIDTH(DEVICE_ADDR_WIDTH)
    ) decoder (
        .clk(clk),
        .rstn(rstn),
        .mwdata(mwdata),
        .mvalid(mvalid),
        .mvalid1(mvalid1),
        .mvalid2(mvalid2),
        .mvalid3(mvalid3),
        .ssel(ssel),
        .ack(ack)
    );

    // Generate Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period is 10 units
    end

    // Test Stimulus
    initial begin
        // Reset the DUT
        rstn = 0;
        dvalid = 0;
        svalid = 0;
        dwdata = 8'b0;
        daddr = 16'b0;
        dmode = 0;
        mrdata = 0;
        #15 rstn = 1; // Release reset after 15 time units

        // Write Operation: Sending data to the bus
        wait (dready == 1);
        @(posedge clk);
        daddr = 16'h9234;  // Set address
        dwdata = 8'hAA;    // Write data value
        dmode = 1;         // Set mode to write
        dvalid = 1;        // Assert valid signal

        #20;
        dvalid = 0;

        wait (dready == 1);

        #50 $finish;
    end


endmodule