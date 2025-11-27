`timescale 1ns/1ps

module slave_tb;

    // Parameters
    parameter ADDR_WIDTH = 12;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_EN = 1;

    // Testbench signals
    reg clk;
    reg rstn;
    reg swdata;
    reg smode;
    reg mvalid;
    wire srdata;
    wire svalid;

    // Slave module instantiation
    slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_EN(SLAVE_EN)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .swdata(swdata),
        .srdata(srdata),
        .smode(smode),
        .mvalid(mvalid),
        .svalid(svalid),
        .sready(sready),
        .ssplit(ssplit)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Testbench procedure
    initial begin
        // Initialize signals
        rstn = 0;
        swdata = 0;
        smode = 0;  // Read mode initially
        mvalid = 0;

        // Apply reset
        #10 rstn = 1;

        // Test case 1: Write operation
        #10;
        mvalid = 1;
		swdata = 1; //LSB
		smode = 1;
        //swdata = 12'b10011010101;    // Address
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 0;
		#10 swdata = 1; // MSB

        //swdata = 8'b11010101;     // Data
		#10 swdata = 1; // LSB
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 1; // MSB

        // End the write operation
		#100;
		smode = 0;

		#20;

		// Scenario 2: Read from slave memory
		$display("Starting read operation...");
		mvalid = 1;
		smode = 0; // Read mode
		swdata = 1; //LSB

		// Send address (same as write, 12'b10011010101)    
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 0;
		#10 swdata = 1; // MSB

		#100 
        mvalid = 0;
        #20

        // End of simulation
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | rstn=%b | swdata=%h | smode=%b | mvalid=%b | srdata=%h | svalid=%b", 
            $time, rstn, swdata, smode, mvalid, srdata, svalid);
    end

endmodule
