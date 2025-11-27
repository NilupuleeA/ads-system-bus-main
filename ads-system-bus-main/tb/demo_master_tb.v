`timescale 1ns/1ps

module demo_master_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 12;
    parameter DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;

    // DUT Signals
    reg clk, rstn;
    reg start, mode;
    wire ready;

    wire mrdata;					  // Read data from serial bus
    wire mwdata;				  // Write data to serial bus
    wire mmode;					  // 0 - read, 1 - write
    wire mvalid;				  // Write data valid
    wire svalid;					  // Read data valid from serial bus
    wire sready;
    wire msplit;

    // Arbiter signals
    wire breq1, bgrant1, bgrant2, msel;

    // Address decoder signals
    wire ack, mvalid1, mvalid2, mvalid3;
    wire [1:0] ssel;

    // Instantiate the DUT (Device Under Test)
    demo_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) master_dev (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .mode(mode),
        .ready(ready),
        .mrdata(mrdata),
        .mwdata(mwdata),
        .mmode(mmode),
        .mvalid(mvalid),
        .svalid(svalid),
        .mbreq(breq1),
        .mbgrant(bgrant1),
        .ack(ack),
        .msplit(msplit)
    );

    // Initialize slave
    slave_with_bram #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_dev (
        .clk(clk),
        .rstn(rstn),
        .srdata(mrdata),
        .swdata(mwdata),
        .smode(mmode),
        .svalid(svalid),
        .mvalid((mvalid1 | mvalid2 | mvalid3)),
        .sready(sready)
    );

    // Arbiter
    arbiter arbiter_dev (
        .clk(clk),
        .rstn(rstn),
        .breq1(breq1),
        .breq2(0),
        .bgrant1(bgrant1),
        .bgrant2(bgrant2),
        .msel(msel),
        .sready1(sready),
        .sready2(1),
        .sreadysp(1),
        .ssplit(0),
        .msplit1(msplit),
        .msplit2(),
        .split_grant()
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
        .sready1(sready),
        .sready2(1'b1),
        .sready3(1'b1),
        .ssel(ssel),
        .ack(ack),
        .ssplit(0),
        .split_grant(0)
    );

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
        start = 0;
        mode = 0;
        #15 rstn = 1; // Release reset after 15 time units

        // Repeat the write and read tests 10 times
        for (i = 0; i < 10; i = i + 1) begin

            // Write Operation: Sending data to the bus
            wait (ready == 1);
            @(posedge clk);
            mode = 1;
            start = 1;

            #20;
            start = 0;
            wait (ready == 1 && sready == 1);

            #20;

            wait (ready == 1);
            @(posedge clk);
            mode = 1;
            start = 1;

            #20;
            start = 0;
            wait (ready == 1 && sready == 1);

            #20;

            // Read operation
            @(posedge clk);
            mode = 0;                         // Set mode to read
            start = 1;                        // Assert valid signal

            #20;
            start = 0;
            wait (ready == 1 && sready == 1);

            // Small delay before next iteration
            #10;
        end

        #10 $finish;
    end


endmodule