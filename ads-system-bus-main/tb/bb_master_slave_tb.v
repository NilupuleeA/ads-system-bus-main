`timescale 1ns/1ps

module bb_master_slave_tb;
    // Parameters
    localparam ADDR_WIDTH = 16;
    localparam DATA_WIDTH = 8;
    localparam SLAVE_MEM_ADDR_WIDTH = 13;
    localparam BB_ADDR_WIDTH = 13;

    localparam DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;
    localparam UART_RX_DATA_WIDTH = DATA_WIDTH + BB_ADDR_WIDTH + 1;    // Receive all 3 info
    localparam UART_TX_DATA_WIDTH = DATA_WIDTH;     // Transmit only read data
    localparam UART_CLOCKS_PER_PULSE = 5208;

    // External signals
    reg clk, rstn;
    reg [DATA_WIDTH-1:0] d1_wdata;  // Write data to the DUT
    wire [DATA_WIDTH-1:0] d1_rdata; // Read data from the DUT
    reg [ADDR_WIDTH-1:0] d1_addr;
    reg d1_valid; 				  // Ready valid interface
    wire d1_ready;
    reg d1_mode;					  // 0 - read, 1 - write

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

    // UART connection
    wire u_tx, u_rx;

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

    bus_bridge_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .BB_ADDR_WIDTH(BB_ADDR_WIDTH),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) bb_master (
        .clk(clk),
        .rstn(rstn),
        .mrdata(m2_rdata),
        .mwdata(m2_wdata),
        .mmode(m2_mode),
        .mvalid(m2_mvalid),
        .svalid(m2_svalid),
        .mbreq(m2_breq),
        .mbgrant(m2_bgrant),
        .ack(m2_ack),
        .msplit(m2_split),
        .u_tx(u_rx),
        .u_rx(u_tx)
    );

    // Initialize slaves
    bus_bridge_slave #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) bb_slave (
        .clk(clk),
        .rstn(rstn),
        .swdata(s3_wdata),
        .srdata(s3_rdata),
        .smode(s3_mode),
        .mvalid(s3_mvalid),
        .split_grant(0),
        .svalid(s3_svalid),
        .sready(s3_ready),
        .ssplit(),
        .u_tx(u_tx),
        .u_rx(u_rx)
    );

    slave #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(2048)
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
        .MEM_SIZE(4096)
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
        .s3_split(0),

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
    reg slave_id;

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

        #15 rstn = 1; // Release reset after 15 time units

        // Repeat the write and read tests 10 times
        for (i = 0; i < 5; i = i + 1) begin

            // Generate random address and data
            rand_addr1 = $random & 14'h3FFF;
            rand_data1 = $random;
            rand_addr2 = $random & 12'hFFF;
            rand_data2 = $random;
            slave_id = i & 1;

            // Write request to random location in slave 0 across bus bridge
            wait (d1_ready == 1 && bb_slave.u_tx_busy == 0);
            d1_wdata = rand_data2;
            d1_addr = {3'b010, slave_id, rand_addr2[11:0]};
            d1_mode = 1;
            d1_valid = 1;

            #20 d1_valid = 0;

            // Send read request
            if (slave_id == 0) begin
                @(posedge s1_ready);
            end else begin
                @(posedge s2_ready);
            end
            

            d1_addr = {2'b00, slave_id, 1'b0, rand_addr2[11:0]};
            d1_mode = 0;
            d1_valid = 1;

            #20 d1_valid = 0;

            wait (d1_ready == 1 && s_ready == 1);

            if (rand_data2 != d1_rdata) begin
                $display("Bus bridge write or read failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, rand_addr2[11:0], rand_data2, d1_rdata);
            end else begin
                $display("Bus bridge write and read successful at iteration %0d", i);
            end
        end

        #10 $finish;
    end


endmodule