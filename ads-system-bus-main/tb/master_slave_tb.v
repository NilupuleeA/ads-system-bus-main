`timescale 1ns/1ps

module master_slave_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 12;

    // DUT Signals
    reg clk, rstn;
    reg [DATA_WIDTH-1:0] dwdata;  // Write data to the DUT
    wire [DATA_WIDTH-1:0] drdata; // Read data from the DUT
    reg [ADDR_WIDTH-1:0] daddr;
    reg dvalid; 				  // Ready valid interface
    wire dready;
    reg dmode;					  // 0 - read, 1 - write

    wire mrdata;					  // Read data from serial bus
    wire mwdata;				  // Write data to serial bus
    wire mmode;					  // 0 - read, 1 - write
    wire mvalid;				  // Write data valid
    wire svalid;					  // Read data valid from serial bus
    wire sready;

    // Arbiter signals
    wire breq1, bgrant1, bgrant2, msel;

    // Instantiate the DUT (Device Under Test)
    master_port_v1 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master_dev (
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
        .mbgrant(bgrant1)
    );

    // Initialize slave
    slave #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_dev (
        .clk(clk),
        .rstn(rstn),
        .srdata(mrdata),
        .swdata(mwdata),
        .smode(mmode),
        .svalid(svalid),
        .mvalid(mvalid),
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
        .sready3(1)
    );

    // Generate Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period is 10 units
    end

    integer i;
    reg [ADDR_WIDTH-1:0] rand_addr;
    reg [DATA_WIDTH-1:0] rand_data;

    // Test Stimulus
    initial begin

        // Reset the DUT
        rstn = 0;
        dvalid = 0;
        dwdata = 8'b0;
        daddr = 16'b0;
        dmode = 0;
        #15 rstn = 1; // Release reset after 15 time units

        // Repeat the write and read tests 10 times
        for (i = 0; i < 10; i = i + 1) begin
            // Generate random address and data
            rand_addr = $random & 12'hFFF;
            rand_data = $random;

            // Write Operation: Sending data to the bus
            wait (dready == 1);
            @(posedge clk);
            daddr = rand_addr[ADDR_WIDTH-1:0];  // Set address with random value
            dwdata = rand_data[DATA_WIDTH-1:0]; // Write data value
            dmode = 1;                          // Set mode to write
            dvalid = 1;                         // Assert valid signal

            #20;
            dvalid = 0;
            wait (dready == 1 && sready == 1);

            #20;
            if (slave_dev.sm.memory[daddr[11:0]] != dwdata) begin
                $display("Write failed at iteration %0d: location %x, expected %x, actual %x", i, daddr[11:0], dwdata, slave_dev.sm.memory[daddr[11:0]]);
            end else begin
                $display("Write successful at iteration %0d", i);
            end

            // Read operation
            @(posedge clk);
            daddr = rand_addr[ADDR_WIDTH-1:0]; // Use the same address for read
            dmode = 0;                         // Set mode to read
            dvalid = 1;                        // Assert valid signal

            #20;
            dvalid = 0;
            wait (dready == 1 && sready == 1);

            #20;
            if (slave_dev.sm.memory[daddr[11:0]] != drdata) begin
                $display("Read failed at iteration %0d: location %x, expected %x, actual %x", i, daddr[11:0], slave_dev.sm.memory[daddr[11:0]], drdata);
            end else begin
                $display("Read successful at iteration %0d", i);
            end

            // Small delay before next iteration
            #10;
        end

        #10 $finish;
    end


endmodule