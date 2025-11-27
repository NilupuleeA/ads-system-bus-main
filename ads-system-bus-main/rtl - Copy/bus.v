
module bus #(
    parameter ADDR_WIDTH = 16,
    parameter DATA_WIDTH = 32
) (
    input clk, rstn,

    // Master 1
    output [DATA_WIDTH-1:0]     m1_rdata,
    input [DATA_WIDTH-1:0]      m1_wdata,
    input [ADDR_WIDTH-1:0]      m1_addr,
    input                       m1_breq,
    input                       m1_wen,
    input                       m1_ren,

    // Master 2
    output [DATA_WIDTH-1:0]     m2_rdata,
    input [DATA_WIDTH-1:0]      m2_wdata,
    input [ADDR_WIDTH-1:0]      m2_addr,
    input                       m2_breq,
    input                       m2_wen,
    input                       m2_ren,

    // Slave 1
    input [DATA_WIDTH-1:0]       s1_rdata,
    output [DATA_WIDTH-1:0]      s1_wdata,
    output [ADDR_WIDTH-1:0]      s1_addr,
    output                       s1_wen,
    output                       s1_ren,

    // Slave 2
    input [DATA_WIDTH-1:0]       s2_rdata,
    output [DATA_WIDTH-1:0]      s2_wdata,
    output [ADDR_WIDTH-1:0]      s2_addr,
    output                       s2_wen,
    output                       s2_ren,

    // Slave 3
    input [DATA_WIDTH-1:0]       s3_rdata,
    output [DATA_WIDTH-1:0]      s3_wdata,
    output [ADDR_WIDTH-1:0]      s3_addr,
    output                       s3_wen,
    output                       s3_ren
);
    localparam DEVICE_BIT_WIDTH = 2;

    // Internal signals
    wire m_select;
    wire [ADDR_WIDTH-1:0] m_addr;
    wire [DATA_WIDTH-1:0] m_wdata;
    reg [DATA_WIDTH-1:0] s_rdata;
    wire m_wen, m_ren;
    wire [1:0] s_select;

    // Instantiate modules in bus

    // Bus arbiter
    arbiter bus_arbiter (
        .clk(clk),
        .rstn(rstn),
        .breq1(m1_breq),
        .breq2(m2_breq),
        .bgrant(master_select)
    );

    // Address mux
    mux2 addr_mux #(.DATA_WIDTH(ADDR_WIDTH)) (
        .dsel(m_select),
        .d0(m1_addr),
        .d1(m2_addr),
        .dout(m_addr)
    );

    // Write data mux
    mux2 wdata_mux #(.DATA_WIDTH(DATA_WIDTH)) (
        .dsel(m_select),
        .d0(m1_wdata),
        .d1(m2_wdata),
        .dout(m_wdata)
    );

    // Control muxes
    mux2 ctrl_mux #(.DATA_WIDTH(2)) (
        .dsel(m_select),
        .d0({m1_wen, m1_ren}),
        .d1({m2_wen, m2_ren}),
        .dout({m_wen, m_ren})
    );

    // Control decoder
    addr_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEVICE_BIT_WIDTH(DEVICE_BIT_WIDTH)
    ) (
        .addr(m_addr),
        .wen(m_wen),
        .ren(m_ren),
        .wen1(s1_wen),
        .wen2(s2_wen),
        .wen3(s3_wen),
        .ren1(s1_ren),
        .ren2(s2_ren),
        .ren3(s3_ren),
        .read_mux_sel(s_select)
    );

    // Read mux
    mux3 read_mux #(.DATA_WIDTH(DATA_WIDTH)) (
        .dsel(s_select),
        .d0(s1_rdata),
        .d1(s2_rdata),
        .d2(s3_rdata),
        .dout(s_rdata)
    );

    // Assignments 
    assign m1_rdata = s_rdata;
    assign m2_rdata = s_rdata;
    assign m3_rdata = s_rdata;

    assign s1_addr = m_addr;
    assign s2_addr = m_addr;
    assign s3_addr = m_addr;

    assign s1_wdata = m_wdata;
    assign s2_wdata = m_wdata;
    assign s3_wdata = m_wdata;

endmodule