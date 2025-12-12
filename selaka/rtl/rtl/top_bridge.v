`timescale 1ns/1ps

module top_bridge(
    input                   clk,
    input                   rstn,
    // UART interface
    input                   bb_u_rx,
    output                  bb_u_tx
);

    parameter ADDR_WIDTH            = 16;
    parameter DATA_WIDTH            = 8;
    parameter SLAVE_MEM_ADDR_WIDTH  = 12;
    parameter BB_ADDR_WIDTH         = 12;   // bridge address width (user-specified)
    parameter UART_CLOCKS_PER_PULSE = 5208;   // small for simulation

    // Clock & Reset



    // ================================
    // MASTER 2 SIMPLE INTERFACE (to TB)
    // ================================
    // (We keep master 2 as-is)
    reg  [ADDR_WIDTH-1:0]  m2_addr;
    reg  [DATA_WIDTH-1:0]  m2_wdata;
    reg                    m2_wvalid;
    reg                    m2_wen;
    wire [DATA_WIDTH-1:0]  m2_rdata;
    wire                   m2_rvalid;
    wire                   m2_ready;


    // ================================
    // SERIAL BUS INTERNAL WIRES
    // ================================

    // Master 1 wires (to be driven by bus_bridge_master)
    wire m1_bwdata, m1_brdata, m1_bmode, m1_bwvalid, m1_brvalid;
    wire m1_breq, m1_bgrant, m1_split, m1_ack;

    // Master 2 wires
    wire m2_bwdata, m2_brdata, m2_bmode, m2_bwvalid, m2_brvalid;
    wire m2_breq, m2_bgrant, m2_split, m2_ack;


    // Slave wires (S1, S2, S3)
    wire s1_wdata, s1_rdata, s1_mode, s1_wvalid, s1_rvalid, s1_ready;
    wire s2_wdata, s2_rdata, s2_mode, s2_wvalid, s2_rvalid, s2_ready;
    wire s3_wdata, s3_rdata, s3_mode, s3_wvalid, s3_rvalid, s3_ready,  s3_split, s3_split_grant;



    // ================================
    // BUS BRIDGE MASTER (replaces Master 1)
    // ================================
    bus_bridge_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .BB_ADDR_WIDTH(BB_ADDR_WIDTH),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) bb_master1 (
        .clk(clk),
        .rstn(rstn),

        // Serial bus side (map to serial_bus m1 signals)
        .mrdata(m1_brdata),   // read data (input to bridge)
        .mwdata(m1_bwdata),   // write data (output from bridge)
        .mmode(m1_bmode),     // mode output (0 read, 1 write)
        .mvalid(m1_bwvalid),  // write-valid (start transaction)
        .svalid(m1_brvalid),  // read-valid (input from bus)
        .mbreq(m1_breq),      // bus request
        .mbgrant(m1_bgrant),  // bus grant (from arbiter / serial_bus)
        .msplit(m1_split),    // split indicator (from bus)
        .ack(m1_ack),         // address decoder ack (tie as needed in serial_bus)

        // UART
        .u_tx(bb_u_tx),
        .u_rx(bb_u_rx)
    );

    // ================================
    // MASTER 2 INSTANCE
    // ================================
    master_interface #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) master2_inst (
        .clk(clk),
        .rstn(rstn),

        .mwdata(m2_wdata),
        .maddr(m2_addr),
        .mwvalid(m2_wvalid),
        .mrdata(m2_rdata),
        .mrvalid(m2_rvalid),
        .mready(m2_ready),
        .wen(m2_wen),

        .bwdata(m2_bwdata),
        .brdata(m2_brdata),
        .bmode(m2_bmode),
        .bwvalid(m2_bwvalid),
        .brvalid(m2_brvalid),

        .mbreq(m2_breq),
        .mbgrant(m2_bgrant),
        .msplit(m2_split),
        .ack(m2_ack)
    );

    //--------------------------------
    // SLAVES (3 units)
    //--------------------------------

    // Slave 1: Normal (SPLIT disabled)
    slave #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SPLIT_EN(0)
    ) slave1 (
        .clk(clk),
        .rstn(rstn),

        .bwdata(s1_wdata),
        .brdata(s1_rdata),
        .bmode(s1_mode),
        .bwvalid(s1_wvalid),
        .brvalid(s1_rvalid),
        .sready(s1_ready),

        .split_grant(1'b0),
        .ssplit()
    );

    // Slave 2: Normal
    slave #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SPLIT_EN(0)
    ) slave2 (
        .clk(clk),
        .rstn(rstn),

        .bwdata(s2_wdata),
        .brdata(s2_rdata),
        .bmode(s2_mode),
        .bwvalid(s2_wvalid),
        .brvalid(s2_rvalid),
        .sready(s2_ready),

        .split_grant(1'b0),
        .ssplit()
    );

    // Slave 3: SPLIT enabled
    slave #(
        .ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SPLIT_EN(1),
        .SPLIT_DELAY(20)
    ) slave3 (
        .clk(clk),
        .rstn(rstn),

        .bwdata(s3_wdata),
        .brdata(s3_rdata),
        .bmode(s3_mode),
        .bwvalid(s3_wvalid),
        .brvalid(s3_rvalid),
        .sready(s3_ready),

        .split_grant(s3_split_grant),
        .ssplit(s3_split)
    );

    //--------------------------------
    // SERIAL BUS INSTANCE
    //--------------------------------
    serial_bus #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) bus_inst (
        .clk(clk),
        .rstn(rstn),

        // MASTER 1 wires (now driven by bus bridge)
        .m1_wdata(m1_bwdata),
        .m1_rdata(m1_brdata),
        .m1_mode(m1_bmode),
        .m1_wvalid(m1_bwvalid),
        .m1_rvalid(m1_brvalid),
        .m1_breq(m1_breq),
        .m1_bgrant(m1_bgrant),
        .m1_split(m1_split),
        .m1_ack(m1_ack),

        // MASTER 2
        .m2_wdata(m2_bwdata),
        .m2_rdata(m2_brdata),
        .m2_mode(m2_bmode),
        .m2_wvalid(m2_bwvalid),
        .m2_rvalid(m2_brvalid),
        .m2_breq(m2_breq),
        .m2_bgrant(m2_bgrant),
        .m2_split(m2_split),
        .m2_ack(m2_ack),

        // SLAVES
        .s1_wdata(s1_wdata), .s1_rdata(s1_rdata), .s1_mode(s1_mode),
        .s1_wvalid(s1_wvalid), .s1_rvalid(s1_rvalid), .s1_ready(s1_ready),

        .s2_wdata(s2_wdata), .s2_rdata(s2_rdata), .s2_mode(s2_mode),
        .s2_wvalid(s2_wvalid), .s2_rvalid(s2_rvalid), .s2_ready(s2_ready),

        .s3_wdata(s3_wdata), .s3_rdata(s3_rdata), .s3_mode(s3_mode),
        .s3_wvalid(s3_wvalid), .s3_rvalid(s3_rvalid), .s3_ready(s3_ready),
        .s3_split(s3_split), .s3_split_grant(s3_split_grant)
    );



endmodule
