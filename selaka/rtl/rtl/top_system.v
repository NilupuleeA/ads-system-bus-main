module top_system (
    input clk,
    input rstn
);

    // -----------------------------------------
    //  Wires between masters and master_interface
    // -----------------------------------------

    // MASTER 1 CPU-side signals
    wire [15:0] m1_addr;
    wire [7:0]  m1_wdata;
    wire        m1_wvalid;
    wire        m1_wen;

    wire [7:0]  m1_rdata;
    wire        m1_rvalid;
    wire        m1_ready;

    // MASTER 2 CPU-side signals
    wire [15:0] m2_addr;
    wire [7:0]  m2_wdata;
    wire        m2_wvalid;
    wire        m2_wen;

    wire [7:0]  m2_rdata;
    wire        m2_rvalid;
    wire        m2_ready;



    // -----------------------------------------
    //  Wires between master_interface and bus
    // -----------------------------------------

    // Master 1 <-> Bus
    wire        m1_bwdata;
    wire        m1_brdata;
    wire        m1_bmode;
    wire        m1_bwvalid;
    wire        m1_brvalid;
    wire        m1_breq;
    wire        m1_bgrant;
    wire        m1_split;
    wire        m1_ack;

    // Master 2 <-> Bus
    wire        m2_bwdata;
    wire        m2_brdata;
    wire        m2_bmode;
    wire        m2_bwvalid;
    wire        m2_brvalid;
    wire        m2_breq;
    wire        m2_bgrant;
    wire        m2_split;
    wire        m2_ack;


    // -----------------------------------------
    // Slave wires
    // -----------------------------------------

    // Slave 1
    wire        s1_wdata;
    wire        s1_rdata;
    wire        s1_wvalid;
    wire        s1_rvalid;
    wire        s1_ready;

    // Slave 2
    wire        s2_wdata;
    wire        s2_rdata;
    wire        s2_wvalid;
    wire        s2_rvalid;
    wire        s2_ready;

    // Slave 3
    wire        s3_wdata;
    wire        s3_rdata;
    wire        s3_wvalid;
    wire        s3_rvalid;
    wire        s3_ready;
    wire        s3_split;
    wire        s3_split_grant;


    // ----------------------------------------------------------
    //  MASTER INTERFACE 1
    // ----------------------------------------------------------
    master_interface #(.ADDR_WIDTH(16), .DATA_WIDTH(8)) M1_IF (
        .clk(clk),
        .rstn(rstn),

        .mwdata(m1_wdata),
        .maddr(m1_addr),
        .mwvalid(m1_wvalid),
        .mrdata(m1_rdata),
        .mrvalid(m1_rvalid),
        .mready(m1_ready),
        .wen(m1_wen),

        .bwdata(m1_bwdata),
        .brdata(m1_brdata),
        .bmode(m1_bmode),
        .bwvalid(m1_bwvalid),
        .brvalid(m1_brvalid),

        .mbreq(m1_breq),
        .mbgrant(m1_bgrant),
        .msplit(m1_split),
        .ack(m1_ack)
    );

    // ----------------------------------------------------------
    //  MASTER INTERFACE 2
    // ----------------------------------------------------------
    master_interface #(.ADDR_WIDTH(16), .DATA_WIDTH(8)) M2_IF (
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


    // ----------------------------------------------------------
    //  SERIAL BUS INSTANCE
    // ----------------------------------------------------------
    serial_bus BUS (
        .clk(clk),
        .rstn(rstn),

        // MASTER 1
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

        // SLAVE 1
        .s1_wdata(s1_wdata),
        .s1_rdata(s1_rdata),
        .s1_mode(/*not used yet*/),
        .s1_wvalid(s1_wvalid),
        .s1_rvalid(s1_rvalid),
        .s1_ready(s1_ready),

        // SLAVE 2
        .s2_wdata(s2_wdata),
        .s2_rdata(s2_rdata),
        .s2_mode(),
        .s2_wvalid(s2_wvalid),
        .s2_rvalid(s2_rvalid),
        .s2_ready(s2_ready),

        // SLAVE 3
        .s3_wdata(s3_wdata),
        .s3_rdata(s3_rdata),
        .s3_mode(),
        .s3_wvalid(s3_wvalid),
        .s3_rvalid(s3_rvalid),
        .s3_ready(s3_ready),
        .s3_split(s3_split),
        .s3_split_grant(s3_split_grant)
    );



    // ----------------------------------------------------------
    // Dummy slaves (for now)
    // ----------------------------------------------------------
    assign s1_ready = 1;
    assign s2_ready = 1;
    assign s3_ready = 1;
    assign s1_rdata = 0;
    assign s2_rdata = 0;
    assign s3_rdata = 0;
    assign s1_rvalid = 0;
    assign s2_rvalid = 0;
    assign s3_rvalid = 0;
    assign s3_split = 0;

endmodule
