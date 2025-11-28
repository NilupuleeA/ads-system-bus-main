module demo_top #(
	parameter ADDR_WIDTH = 16, 
	parameter DATA_WIDTH = 8,
	parameter SLAVE_MEM_ADDR_WIDTH = 12
)(
	input clk, rstn,

    input start,
	output d1_ready, d2_ready,
	input d1_mode, d2_mode,					// 0 - read, 1 - write
    input d1_en, d2_en,

    output [DATA_WIDTH-1:0] demo_data
);
    // External controls
	wire d1_start, d2_start;			 		// ready valid interface

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

    wire        split_grant;

    wire edge_start;
    reg start_prev;

    assign d1_start = (edge_start) & d1_en;
    assign d2_start = (edge_start) & d2_en;
    assign edge_start = (start_prev) & (!start);

    // Buffer the start signal
    always @(posedge clk) begin
        if (!rstn) start_prev <= 1'b1;
        else start_prev <= start; 
    end

    // Instantiate masters
    demo_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .ADDRS({16'h0003, 16'h1003, 16'h1004, 16'h1004})
    ) master1 (
        .clk(clk),
        .rstn(rstn),
        .start(d1_start),
        .mode(d1_mode),
        .ready(d1_ready),
        .mrdata(m1_rdata),
        .mwdata(m1_wdata),
        .mmode(m1_mode),
        .mvalid(m1_mvalid),
        .svalid(m1_svalid),
        .mbreq(m1_breq),
        .mbgrant(m1_bgrant),
        .ack(m1_ack),
        .msplit(m1_split),
        .demo_masdata(demo_data)
    );

    demo_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .ADDRS({16'h0003, 16'h1004, 16'h2005, 16'h0009})
    ) master2 (
        .clk(clk),
        .rstn(rstn),
        .start(d2_start),
        .mode(d2_mode),
        .ready(d2_ready),
        .mrdata(m2_rdata),
        .mwdata(m2_wdata),
        .mmode(m2_mode),
        .mvalid(m2_mvalid),
        .svalid(m2_svalid),
        .mbreq(m2_breq),
        .mbgrant(m2_bgrant),
        .ack(m2_ack),
        .msplit(m2_split),
        .demo_masdata()
    );

    // Initialize slave
    slave_with_bram #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(2048)
    ) slave1 (
        .clk(clk),
        .rstn(rstn),
        .srdata(s1_rdata),
        .swdata(s1_wdata),
        .smode(s1_mode),
        .svalid(s1_svalid),
        .mvalid(s1_mvalid),
        .sready(s1_ready),
        .demo_data()
    );

    slave_with_bram #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(4096)
    ) slave2 (
        .clk(clk),
        .rstn(rstn),
        .srdata(s2_rdata),
        .swdata(s2_wdata),
        .smode(s2_mode),
        .svalid(s2_svalid),
        .mvalid(s2_mvalid),
        .sready(s2_ready),
        .demo_data()
    );

    slave_with_bram #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(4096)
    ) slave3 (
        .clk(clk),
        .rstn(rstn),
        .srdata(s3_rdata),
        .swdata(s3_wdata),
        .smode(s3_mode),
        .svalid(s3_svalid),
        .mvalid(s3_mvalid),
        .sready(s3_ready),
        .demo_data()
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

endmodule