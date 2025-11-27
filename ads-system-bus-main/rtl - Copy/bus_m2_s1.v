
module bus_m2_s1 #(
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

    // Master 2
    output        m2_rdata,	// read data
	input         m2_wdata,	// write data and address
	input         m2_mode,	// 0 -  read, 1 - write
	input         m2_mvalid,	// wdata valid
	output        m2_svalid,	// rdata valid
	input         m2_breq,
	output        m2_bgrant,

    // Slave 1
    input         s_rdata,	// read data
	output        s_wdata,	// write data and address
	output        s_mode,	// 0 -  read, 1 - write
	output        s_mvalid,	// wdata valid
	input         s_svalid,	// rdata valid
    input         s_ready
);

    // Internal signals
    wire m_select;      // master select for control
    wire m_wdata, m_mode, m_mvalid;       // master muxed signals

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
        .sready1(s_ready),
        .sready2(1),
        .sready3(1)
    );

    // Write data mux
    mux2 #(.DATA_WIDTH(1)) wdata_mux (
        .dsel(m_select),
        .d0(m1_wdata),
        .d1(m2_wdata),
        .dout(m_wdata)
    );

    // Control muxes
    mux2 #(.DATA_WIDTH(2)) ctrl_mux (
        .dsel(m_select),
        .d0({m1_mode, m1_mvalid}),
        .d1({m2_mode, m2_mvalid}),
        .dout({m_mode, m_mvalid})
    );

    // Assignments 
    assign m1_rdata = s_rdata;
    assign m1_svalid = s_svalid;

    assign m2_rdata = s_rdata;
    assign m2_svalid = s_svalid;

    assign s_wdata = m_wdata;
    assign s_mode = m_mode;
    assign s_mvalid = m_mvalid;

endmodule