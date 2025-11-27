`timescale 1ns/1ps

module master2_slave1_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 12;

    // External signals
    reg clk, rstn;
    reg [DATA_WIDTH-1:0] d1_wdata, d2_wdata;  // Write data to the DUT
    wire [DATA_WIDTH-1:0] d1_rdata, d2_rdata; // Read data from the DUT
    reg [ADDR_WIDTH-1:0] d1_addr, d2_addr;
    reg d1_valid, d2_valid; 				  // Ready valid interface
    wire d1_ready, d2_ready;
    reg d1_mode, d2_mode;					  // 0 - read, 1 - write

    // Bus signals
    // Master 1
    wire        m1_rdata;	// read data
	wire         m1_wdata;	// write data and address
	wire         m1_mode;	// 0 -  read; 1 - write
	wire         m1_mvalid;	// wdata valid
	wire        m1_svalid;	// rdata valid
	wire         m1_breq;
	wire        m1_bgrant;

    // Master 2
    wire        m2_rdata;	// read data
	wire         m2_wdata;	// write data and address
	wire         m2_mode;	// 0 -  read; 1 - write
	wire         m2_mvalid;	// wdata valid
	wire        m2_svalid;	// rdata valid
	wire         m2_breq;
	wire        m2_bgrant;

    // Slave 1
    wire         s_rdata;	// read data
	wire        s_wdata;	// write data and address
	wire        s_mode;	// 0 -  read; 1 - write
	wire        s_mvalid;	// wdata valid
	wire         s_svalid;	// rdata valid
    wire         s_ready;

    // Instantiate masters
    master_port_v1 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master1 (
        .clk(clk),
        .rstn(rstn),
        .dwdata(d1_wdata),
        .drdata(d1_rdata),
        .daddr(d1_addr),
        .dvalid(d1_valid),
        .dready(d1_ready),
        .dmode(d1_mode),
        .mrdata(m1_rdata),
        .mwdata(m1_wdata),
        .mmode(m1_mode),
        .mvalid(m1_mvalid),
        .svalid(m1_svalid),
        .mbreq(m1_breq),
        .mbgrant(m1_bgrant)
    );

    master_port_v1 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master2 (
        .clk(clk),
        .rstn(rstn),
        .dwdata(d2_wdata),
        .drdata(d2_rdata),
        .daddr(d2_addr),
        .dvalid(d2_valid),
        .dready(d2_ready),
        .dmode(d2_mode),
        .mrdata(m2_rdata),
        .mwdata(m2_wdata),
        .mmode(m2_mode),
        .mvalid(m2_mvalid),
        .svalid(m2_svalid),
        .mbreq(m2_breq),
        .mbgrant(m2_bgrant)
    );

    // Initialize slave
    slave #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave_dev (
        .clk(clk),
        .rstn(rstn),
        .srdata(s_rdata),
        .swdata(s_wdata),
        .smode(s_mode),
        .svalid(s_svalid),
        .mvalid(s_mvalid),
        .sready(s_ready)
    );

    // Bus
    bus_m2_s1 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) bus (
        .clk(clk),
        .rstn(rstn),

        // Master 1 connections
        .m1_rdata(m1_rdata),
        .m1_wdata(m1_wdata),
        .m1_mode(m1_mode),
        .m1_mvalid(m1_mvalid),
        .m1_svalid(m1_svalid),
        .m1_breq(m1_breq),
        .m1_bgrant(m1_bgrant),
    
        // Master 2 connections
        .m2_rdata(m2_rdata),
        .m2_wdata(m2_wdata),
        .m2_mode(m2_mode),
        .m2_mvalid(m2_mvalid),
        .m2_svalid(m2_svalid),
        .m2_breq(m2_breq),
        .m2_bgrant(m2_bgrant),

        // Slave 1 connections
        .s_rdata(s_rdata),
        .s_wdata(s_wdata),
        .s_mode(s_mode),
        .s_mvalid(s_mvalid),
        .s_svalid(s_svalid),
        .s_ready(s_ready)
    );

    // Generate Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period is 10 units
    end

    integer i;
    reg [ADDR_WIDTH-1:0] rand_addr1, rand_addr2, rand_addr3;
    reg [DATA_WIDTH-1:0] rand_data1, rand_data2;

    task random_delay;
        integer delay;
        begin
            delay = $urandom % 10;  // Generate a random delay multiplier between 0 and 4
            $display("Random delay: %d", delay * 10);
            #(delay * 10);  // Delay in multiples of 10 time units (clock period)
        end
    endtask

    // Test Stimulus
    initial begin

        // Reset the DUT
        rstn = 0;
        d1_valid = 0;
        d1_wdata = 8'b0;
        d1_addr = 16'b0;
        d1_mode = 0;

        d2_valid = 0;
        d2_wdata = 8'b0;
        d2_addr = 16'b0;
        d2_mode = 0;

        #15 rstn = 1; // Release reset after 15 time units

        // Repeat the write and read tests 10 times
        for (i = 0; i < 10; i = i + 1) begin
            // Generate random address and data
            rand_addr1 = $random & 12'hFFF;
            rand_data1 = $random;
            rand_addr2 = $random & 12'hFFF;
            rand_data2 = $random;

            // Write Operation: Sending data to the bus
            // Do 2 request next to each other from different masters

            wait (d1_ready == 1 && d2_ready == 1 && s_ready == 1);
            @(posedge clk);
            d1_addr = rand_addr1[ADDR_WIDTH-1:0];  // Set address with random value
            d1_wdata = rand_data1[DATA_WIDTH-1:0]; // Write data value
            d1_mode = 1;                          // Set mode to write
            d1_valid = 1;                         // Assert valid signal

            random_delay();

            // Make request from m2
            @(posedge clk)
            d2_addr = rand_addr2[ADDR_WIDTH-1:0];  // Set address with random value
            d2_wdata = rand_data2[DATA_WIDTH-1:0]; // Write data value
            d2_mode = 1;                          // Set mode to write
            d2_valid = 1;                         // Assert valid signal

            #20;
            d1_valid = 0;
            d2_valid = 0;

            wait (d1_ready == 1 && d2_ready == 1 && s_ready == 1);

            #20;
            if (slave_dev.sm.memory[d1_addr[11:0]] != d1_wdata) begin
                $display("Master 1 write failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, d1_addr[11:0], d1_wdata, slave_dev.sm.memory[d1_addr[11:0]]);
            end else begin
                $display("Master 1 write successful at iteration %0d", i);
            end

            if (slave_dev.sm.memory[d2_addr[11:0]] != d2_wdata) begin
                $display("Master 2 write failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, d2_addr[11:0], d2_wdata, slave_dev.sm.memory[d2_addr[11:0]]);
            end else begin
                $display("Master 2 write successful at iteration %0d", i);
            end

            // Read operation: make both requests on the same clock cycle
            @(posedge clk);
            d1_mode = 0;                         // Set mode to read
            d1_valid = 1;                        // Assert valid signal
            d2_mode = 0;
            d2_valid = 1;

            #20;
            d1_valid = 0;
            d2_valid = 0;
            wait (d1_ready == 1 && d2_ready == 1 && s_ready == 1);

            #20;

            if (d1_wdata != d1_rdata) begin
                $display("Master 1 read failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, d1_addr[11:0], d1_wdata, d1_rdata);
            end else begin
                $display("Master 1 read successful at iteration %0d", i);
            end

            if (d2_wdata != d2_rdata) begin
                $display("Master 2 read failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, d2_addr[11:0], d2_wdata, d2_rdata);
            end else begin
                $display("Master 2 read successful at iteration %0d", i);
            end

            // Master 2 write and master 1 read
            rand_addr3 = $random & 12'hFFF;
            @(posedge clk);
            d2_addr = rand_addr3[ADDR_WIDTH-1:0];  // Set address with random value
            d2_wdata = rand_data1 + rand_data2; // Write data value
            d2_mode = 1;                          // Set mode to write
            d2_valid = 1;                         // Assert valid signal
            
            random_delay();
            @(posedge clk)
            d1_addr = d2_addr;
            d1_mode = 0;                         // Set mode to read
            d1_valid = 1;                        // Assert valid signal

            #20;
            d1_valid = 0;
            d2_valid = 0;
            wait (d1_ready == 1 && d2_ready == 1 && s_ready == 1);

            #20;

            if (slave_dev.sm.memory[d2_addr[11:0]] != d2_wdata) begin
                $display("Master 2 write failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, d2_addr[11:0], d2_wdata, slave_dev.sm.memory[d2_addr[11:0]]);
            end else begin
                $display("Master 2 write successful at iteration %0d", i);
            end

            if (d2_wdata != d1_rdata) begin
                $display("Master 1 read failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, d1_addr[11:0], d2_wdata, d1_rdata);
            end else begin
                $display("Master 1 read successful at iteration %0d", i);
            end

            // Small delay before next iteration
            #10;
        end

        #10 $finish;
    end


endmodule