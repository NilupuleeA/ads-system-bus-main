module top_with_bb_v1 #(
	parameter ADDR_WIDTH = 16, 
	parameter DATA_WIDTH = 8,
	parameter SLAVE_MEM_ADDR_WIDTH = 12,
    parameter BB_ADDR_WIDTH = 13,
    parameter UART_CLOCKS_PER_PULSE = 5208
)(
	input clk, rstn,

	// Signals connecting to master device
	input [DATA_WIDTH-1:0] d1_wdata,   // write data
	output [DATA_WIDTH-1:0] d1_rdata, 	// read data
	input [ADDR_WIDTH-1:0] d1_addr, 
	input d1_valid, 			 		// ready valid interface
	output m1_ready, 
	input m1_rw_mode, 					// 0 - read, 1 - write

    output s_ready,      // slaves are ready

    // UART signals
    input m_u_rx, s_u_rx,
    output m_u_tx, s_u_tx,
    output [DATA_WIDTH-1:0] LED,
    output [DATA_WIDTH-1:0] demo_data,
    output [DATA_WIDTH-1:0] LED_demo
);

	wire [DATA_WIDTH-1:0] demo_data_wire, LED_demo_1;
	
	assign LED_demo = demo_data_wire;
    // assign demo_data = demo_data_wire;
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

    wire [DATA_WIDTH-1:0] LED_wire_1, LED_wire_2;
    wire [DATA_WIDTH-1:0] demo_data_s1;

	 
	 
	 
    assign LED = LED_wire_1;
	 
	 
	 
    assign demo_data = demo_data_s1;
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
        .dready(m1_ready),
        .dmode(m1_rw_mode),
        .mrdata(m1_rdata),
        .mwdata(m1_wdata),
        .mmode(m1_mode),
        .mvalid(m1_mvalid),
        .svalid(m1_svalid),
        .mbreq(m1_breq),
        .mbgrant(m1_bgrant),
        .ack(m1_ack),
        .msplit(m1_split),
		  .demo_data(demo_data_wire)
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
        .u_tx(m_u_tx),
        .u_rx(m_u_rx),
		  .LEDs(LED_wire_1),
          .LED_demo(LED_demo_1)
    );

    // Initialize slave
    slave_with_bram #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(2048)
    ) slave1 (
        .clk(clk), 
        .rstn(rstn),
        .swdata(s1_wdata),
        .srdata(s1_rdata),
        .smode(s1_mode),
        .mvalid(s1_mvalid),
        .svalid(s1_svalid),
        .sready(s1_ready),
        .demo_data(demo_data_s1),
        .LED()
    );

    slave_with_bram #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(4096)
    ) slave2 (
        .clk(clk), 
        .rstn(rstn),
        .swdata(s2_wdata),
        .srdata(s2_rdata),
        .smode(s2_mode),
        .mvalid(s2_mvalid),
        .svalid(s2_svalid),
        .sready(s2_ready),
        .LED(LED_wire_2)
    );

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
        .svalid(s3_svalid),
        .sready(s3_ready),
        .ssplit(),
        .split_grant(1'b0),
        .u_tx(s_u_tx),
        .u_rx(s_u_rx)
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
        .s3_split(1'b0),

        .split_grant()
    );

    assign s_ready = s1_ready & s2_ready & s3_ready;

endmodule