`timescale 1ns/1ps

// This TB has both masters for convenience
// But only 1 will be tested

module master2_slave3_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 12;
    parameter DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;

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
    wire        m1_ack;
    wire        m1_split;

    // Master 2
    wire        m2_rdata;	// read data
	wire         m2_wdata;	// write data and address
	wire         m2_mode;	// 0 -  read; 1 - write
	wire         m2_mvalid;	// wdata valid
	wire        m2_svalid;	// rdata valid
	wire         m2_breq;
	wire        m2_bgrant;
    wire        m2_ack;
    wire        m2_split;

    // Slave 1
    wire        s1_rdata;	// read data
	wire        s1_wdata;	// write data and address
	wire        s1_mode;	// 0 -  read; 1 - write
	wire        s1_mvalid;	// wdata valid
	wire        s1_svalid;	// rdata valid
    wire        s1_ready;

    // Slave 2
    wire        s2_rdata;	// read data
	wire        s2_wdata;	// write data and address
	wire        s2_mode;	// 0 -  read; 1 - write
	wire        s2_mvalid;	// wdata valid
	wire        s2_svalid;	// rdata valid
    wire        s2_ready;

    // Slave 3
    wire        s3_rdata;	// read data
	wire        s3_wdata;	// write data and address
	wire        s3_mode;	// 0 -  read; 1 - write
	wire        s3_mvalid;	// wdata valid
	wire        s3_svalid;	// rdata valid
    wire        s3_ready;
    wire        s3_split;

    wire        split_grant;

    // Instantiate masters
    master_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
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
        .mbgrant(m1_bgrant),
        .ack(m1_ack),
        .msplit(m1_split)
    );

    master_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
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
        .mbgrant(m2_bgrant),
        .ack(m2_ack),
        .msplit(m2_split)
    );

    // Initialize slave
    slave #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave1 (
        .clk(clk),
        .rstn(rstn),
        .srdata(s1_rdata),
        .swdata(s1_wdata),
        .smode(s1_mode),
        .svalid(s1_svalid),
        .mvalid(s1_mvalid),
        .sready(s1_ready),
        .ssplit(),
        .split_grant(0)
    );

    slave #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) slave2 (
        .clk(clk),
        .rstn(rstn),
        .srdata(s2_rdata),
        .swdata(s2_wdata),
        .smode(s2_mode),
        .svalid(s2_svalid),
        .mvalid(s2_mvalid),
        .sready(s2_ready),
        .ssplit(),
        .split_grant(0)
    );

    slave #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SPLIT_EN(1)
    ) slave3 (
        .clk(clk),
        .rstn(rstn),
        .srdata(s3_rdata),
        .swdata(s3_wdata),
        .smode(s3_mode),
        .svalid(s3_svalid),
        .mvalid(s3_mvalid),
        .sready(s3_ready),
        .ssplit(s3_split),
        .split_grant(split_grant)
    );

    // Bus
    bus_m2_s3 #(
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
        .m1_ack(m1_ack),
        .m1_split(m1_split),
    
        // Master 2 connections
        .m2_rdata(m2_rdata),
        .m2_wdata(m2_wdata),
        .m2_mode(m2_mode),
        .m2_mvalid(m2_mvalid),
        .m2_svalid(m2_svalid),
        .m2_breq(m2_breq),
        .m2_bgrant(m2_bgrant),
        .m2_ack(m2_ack),
        .m2_split(m2_split),

        // Slave 1 connections
        .s1_rdata(s1_rdata),
        .s1_wdata(s1_wdata),
        .s1_mode(s1_mode),
        .s1_mvalid(s1_mvalid),
        .s1_svalid(s1_svalid),
        .s1_ready(s1_ready),

        .s2_rdata(s2_rdata),
        .s2_wdata(s2_wdata),
        .s2_mode(s2_mode),
        .s2_mvalid(s2_mvalid),
        .s2_svalid(s2_svalid),
        .s2_ready(s2_ready),

        .s3_rdata(s3_rdata),
        .s3_wdata(s3_wdata),
        .s3_mode(s3_mode),
        .s3_mvalid(s3_mvalid),
        .s3_svalid(s3_svalid),
        .s3_ready(s3_ready),
        .s3_split(s3_split),

        .split_grant(split_grant)
    );

    wire s_ready;
    assign s_ready = s1_ready & s2_ready & s3_ready;

    // Generate Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period is 10 units
    end

    integer i;
    reg [ADDR_WIDTH-1:0] rand_addr1, rand_addr2, rand_addr3;
    reg [DATA_WIDTH-1:0] rand_data1, rand_data2;
    reg [DATA_WIDTH-1:0] slave_mem_data1, slave_mem_data2;
    reg [1:0] slave_id1, slave_id2;

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
        for (i = 0; i < 20; i = i + 1) begin

            // Generate random address and data
            rand_addr1 = $random & 14'h3FFF;
            rand_data1 = $random;
            rand_addr2 = $random & 14'h3FFF;
            rand_data2 = $random;

            slave_id1 = rand_addr1[ADDR_WIDTH-DEVICE_ADDR_WIDTH+:2];
            slave_id2 = rand_addr2[ADDR_WIDTH-DEVICE_ADDR_WIDTH+:2];

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

            if (slave_id1 == 2'b00)  slave_mem_data1 = slave1.sm.memory[d1_addr[11:0]];
            else if (slave_id1 == 2'b01)  slave_mem_data1 = slave2.sm.memory[d1_addr[11:0]];
            else if (slave_id1 == 2'b10)  slave_mem_data1 = slave3.sm.memory[d1_addr[11:0]];

            if (slave_id1 != 2'b11 && slave_mem_data1 != d1_wdata) begin
                $display("Master 1 write failed at iteration %0d: location %0x, expected %x, actual %x", 
                            i, d1_addr, d1_wdata, slave_mem_data1);
            end else begin
                $display("Master 1 write to %0x successful at iteration %0d", d1_addr, i);
            end

            if (slave_id2 == 2'b00)  slave_mem_data2 = slave1.sm.memory[d2_addr[11:0]];
            else if (slave_id2 == 2'b01)  slave_mem_data2 = slave2.sm.memory[d2_addr[11:0]];
            else if (slave_id2 == 2'b10)  slave_mem_data2 = slave3.sm.memory[d2_addr[11:0]];


            if (slave_id2 != 2'b11 && slave_mem_data2 != d2_wdata) begin
                $display("Master 2 write failed at iteration %0d: location %0x, expected %x, actual %x", 
                            i, d2_addr, d2_wdata, slave_mem_data2);
            end else begin
                $display("Master 2 write to %0x successful at iteration %0d", d2_addr, i);
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

            if (slave_id1 != 2'b11 && d1_wdata != d1_rdata) begin
                $display("Master 1 read failed at iteration %0d: location %0x, expected %x, actual %x", 
                            i, d1_addr, d1_wdata, d1_rdata);
            end else begin
                $display("Master 1 read from %0x successful at iteration %0d", d1_addr, i);
            end

            if (slave_id2 != 2'b11 && d2_wdata != d2_rdata) begin
                $display("Master 2 read failed at iteration %0d: location %0x, expected %x, actual %x", 
                            i, d2_addr, d2_wdata, d2_rdata);
            end else begin
                $display("Master 2 read from %0x successful at iteration %0d", d2_addr, i);
            end

            // Master 2 write and master 1 read
            rand_addr3 = $random & 14'h3FFF;
            slave_id1 = rand_addr3[ADDR_WIDTH-DEVICE_ADDR_WIDTH+:2];

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

            if (slave_id1 == 2'b00)  slave_mem_data1 = slave1.sm.memory[d2_addr[11:0]];
            else if (slave_id1 == 2'b01)  slave_mem_data1 = slave2.sm.memory[d2_addr[11:0]];
            else if (slave_id1 == 2'b10)  slave_mem_data1 = slave3.sm.memory[d2_addr[11:0]];

            if (slave_id1 != 2'b11 && slave_mem_data1 != d2_wdata) begin
                $display("Master 2 write failed at iteration %0d: location %0x, expected %x, actual %x", 
                            i, d2_addr, d2_wdata, slave_mem_data1);
            end else begin
                $display("Master 2 write to %0x successful at iteration %0d", d2_addr, i);
            end

            if (slave_id1 != 2'b11 && d2_wdata != d1_rdata) begin
                $display("Master 1 read failed at iteration %0d: location %0x, expected %x, actual %x", 
                            i, d1_addr, d2_wdata, d1_rdata);
            end else begin
                $display("Master 1 read from %0x successful at iteration %0d", d1_addr, i);
            end

            // Small delay before next iteration
            #10;

        end

        #10 $finish;
    end


endmodule