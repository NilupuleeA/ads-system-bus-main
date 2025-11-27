
module bus_m2_s3 #(
    parameter ADDR_WIDTH = 16,
    parameter DATA_WIDTH = 8,
    parameter SLAVE_MEM_ADDR_WIDTH = 12
) (
    input clk, rstn,

    // Master 1
    output        m1_rdata,	// read data
	input         m1_wdata,	// write data and address
	input         m1_mode,	// 0 -  read, 1 - write
	input         m1_mvalid,	// wdata valid
	output        m1_svalid,	// rdata valid
	input         m1_breq,
	output        m1_bgrant,
    output        m1_ack,
    output        m1_split,

    // Master 2
    output        m2_rdata,	// read data
	input         m2_wdata,	// write data and address
	input         m2_mode,	// 0 -  read, 1 - write
	input         m2_mvalid,	// wdata valid
	output        m2_svalid,	// rdata valid
	input         m2_breq,
	output        m2_bgrant,
    output        m2_ack,
    output        m2_split,

    // Slave 1
    input         s1_rdata,	// read data
	output        s1_wdata,	// write data and address
	output        s1_mode,	// 0 -  read, 1 - write
	output        s1_mvalid,	// wdata valid
	input         s1_svalid,	// rdata valid
    input         s1_ready,

    // Slave 2
    input         s2_rdata,	// read data
	output        s2_wdata,	// write data and address
	output        s2_mode,	// 0 -  read, 1 - write
	output        s2_mvalid,	// wdata valid
	input         s2_svalid,	// rdata valid
    input         s2_ready,

    // Slave 3
    input         s3_rdata,	// read data
	output        s3_wdata,	// write data and address
	output        s3_mode,	// 0 -  read, 1 - write
	output        s3_mvalid,	// wdata valid
	input         s3_svalid,	// rdata valid
    input         s3_ready,
    input         s3_split,      // s3 is the split slave

    output        split_grant
);
    localparam DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;

    // Internal signals
    wire m_select;      // master select for control
    wire m_wdata, m_mode, m_mvalid;       // master muxed signals
    wire [1:0] s_select;      // Slave select for read mux
    wire m_ack;         // Acknowledgement from addr decoder
    wire s_rdata, s_svalid, s_split;

    // Instantiate modules in bus

    // Bus arbiter
    arbiter bus_arbiter (
        .clk(clk),
        .rstn(rstn),
        .breq1(m1_breq),
        .breq2(m2_breq),
        .bgrant1(m1_bgrant),
        .bgrant2(m2_bgrant),
        .msel(m_select),
        .sready1(s1_ready),
        .sready2(s2_ready),
        .sreadysp(s3_ready),
        .ssplit(s_split),
        .msplit1(m1_split),
        .msplit2(m2_split),
        .split_grant(split_grant)
    );

    // Address decoder
    addr_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEVICE_ADDR_WIDTH(DEVICE_ADDR_WIDTH)
    ) decoder (
        .clk(clk),
        .rstn(rstn),
        .mwdata(m_wdata),
        .mvalid(m_mvalid),
        .mvalid1(s1_mvalid),
        .mvalid2(s2_mvalid),
        .mvalid3(s3_mvalid),
        .sready1(s1_ready),
        .sready2(s2_ready),
        .sready3(s3_ready),
        .ssel(s_select),
        .ack(m_ack),
        .ssplit(s_split),
        .split_grant(split_grant)
    );

    // Write data mux
    mux2 #(.DATA_WIDTH(1)) wdata_mux (
        .dsel(m_select),
        .d0(m1_wdata),
        .d1(m2_wdata),
        .dout(m_wdata)
    );

    // Master control muxes
    mux2 #(.DATA_WIDTH(2)) mctrl_mux (
        .dsel(m_select),
        .d0({m1_mode, m1_mvalid}),
        .d1({m2_mode, m2_mvalid}),
        .dout({m_mode, m_mvalid})
    );

    // Read data mux
    mux3 #(.DATA_WIDTH(1)) rdata_mux (
        .dsel(s_select),
        .d0(s1_rdata),
        .d1(s2_rdata),
        .d2(s3_rdata),
        .dout(s_rdata)
    );

    // Read control mux
    mux3 #(.DATA_WIDTH(1)) rctrl_mux (
        .dsel(s_select),
        .d0(s1_svalid),
        .d1(s2_svalid),
        .d2(s3_svalid),
        .dout(s_svalid)
    );

    // Assignments 
    assign m1_rdata = s_rdata;
    assign m1_svalid = s_svalid;

    assign m2_rdata = s_rdata;
    assign m2_svalid = s_svalid;

    assign s1_wdata = m_wdata;
    assign s1_mode = m_mode;

    assign s2_wdata = m_wdata;
    assign s2_mode = m_mode;

    assign s3_wdata = m_wdata;
    assign s3_mode = m_mode;

    assign m1_ack = m_ack;
    assign m2_ack = m_ack;

    assign s_split = s3_split;

endmodule