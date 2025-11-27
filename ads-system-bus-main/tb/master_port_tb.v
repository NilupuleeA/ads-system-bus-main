`timescale 1ns/1ps

module master_port_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;

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

    // Instantiate the DUT (Device Under Test)
    master_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
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
        .svalid(svalid)
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
        daddr = 16'h1234;  // Set address
        dwdata = 8'hAA;    // Write data value
        dmode = 1;         // Set mode to write
        dvalid = 1;        // Assert valid signal

        #20;

        wait (dready == 1);

        #10 $finish;
    end


endmodule