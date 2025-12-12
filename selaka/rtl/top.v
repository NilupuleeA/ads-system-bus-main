`timescale 1ns/1ps

module top;

    parameter ADDR_WIDTH            = 16;
    parameter DATA_WIDTH            = 8;
    parameter SLAVE_MEM_ADDR_WIDTH  = 12;

    // Clock & Reset
    reg                             clk;
    reg                             rstn;
    wire                            bus_busy;


    // Master 1 Interface (to TB)
    reg  [ADDR_WIDTH-1:0]           m1_addr;
    reg  [DATA_WIDTH-1:0]           m1_wdata;
    reg                             m1_wvalid;
    reg                             m1_wen;     
    wire [DATA_WIDTH-1:0]           m1_rdata;
    wire                            m1_rvalid;
    wire                            m1_ready;


    // Master 2 Interface (to TB)
    reg  [ADDR_WIDTH-1:0]           m2_addr;
    reg  [DATA_WIDTH-1:0]           m2_wdata;
    reg                             m2_wvalid;
    reg                             m2_wen;
    wire [DATA_WIDTH-1:0]           m2_rdata;
    wire                            m2_rvalid;
    wire                            m2_ready;


    // SERIAL BUS INTERNAL WIRES

    // Master 1 wires
    wire                            m1_bwdata; 
    wire                            m1_brdata; 
    wire                            m1_bmode; 
    wire                            m1_bwvalid; 
    wire                            m1_brvalid;
    wire                            m1_breq; 
    wire                            m1_bgrant; 
    wire                            m1_split; 
    wire                            m1_ack;

    // Master 2 wires
    wire                            m2_bwdata; 
    wire                            m2_brdata; 
    wire                            m2_bmode; 
    wire                            m2_bwvalid; 
    wire                            m2_brvalid;
    wire                            m2_breq; 
    wire                            m2_bgrant; 
    wire                            m2_split; 
    wire                            m2_ack;



    // Slave wires (S1, S2, S3)
    wire                            s1_wdata; 
    wire                            s1_rdata; 
    wire                            s1_mode; 
    wire                            s1_wvalid; 
    wire                            s1_rvalid; 
    wire                            s1_ready;

    wire                            s2_wdata; 
    wire                            s2_rdata; 
    wire                            s2_mode; 
    wire                            s2_wvalid; 
    wire                            s2_rvalid; 
    wire                            s2_ready;

    wire                            s3_wdata; 
    wire                            s3_rdata; 
    wire                            s3_mode; 
    wire                            s3_wvalid; 
    wire                            s3_rvalid; 
    wire                            s3_ready;
    wire                            s3_split;
    wire                            s3_split_grant;


    // Master 1 
    master_interface #(
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .DATA_WIDTH                 (DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH       (SLAVE_MEM_ADDR_WIDTH)
    ) master1_inst (
        .clk                        (clk),
        .rstn                       (rstn),
        .bus_busy                   (bus_busy),

        .mwdata                     (m1_wdata),
        .maddr                      (m1_addr),
        .mwvalid                    (m1_wvalid),
        .mrdata                     (m1_rdata),
        .mrvalid                    (m1_rvalid),
        .mready                     (m1_ready),
        .wen                        (m1_wen),

        .bwdata                     (m1_bwdata),
        .brdata                     (m1_brdata),
        .bmode                      (m1_bmode),
        .bwvalid                    (m1_bwvalid),
        .brvalid                    (m1_brvalid),

        .mbreq                      (m1_breq),
        .mbgrant                    (m1_bgrant),
        .msplit                     (m1_split),
        .ack                        (m1_ack)
    );

    // Master 2
    master_interface #(
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .DATA_WIDTH                 (DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH       (SLAVE_MEM_ADDR_WIDTH)
    ) master2_inst (
        .clk                        (clk),
        .rstn                       (rstn),
        .bus_busy                   (bus_busy),

        .mwdata                     (m2_wdata),
        .maddr                      (m2_addr),
        .mwvalid                    (m2_wvalid),
        .mrdata                     (m2_rdata),
        .mrvalid                    (m2_rvalid),
        .mready                     (m2_ready),
        .wen                        (m2_wen),

        .bwdata                     (m2_bwdata),
        .brdata                     (m2_brdata),
        .bmode                      (m2_bmode),
        .bwvalid                    (m2_bwvalid),
        .brvalid                    (m2_brvalid),

        .mbreq                      (m2_breq),
        .mbgrant                    (m2_bgrant),
        .msplit                     (m2_split),
        .ack                        (m2_ack)
    );


    // Slave 1 4KB Normal
    slave #(
        .ADDR_WIDTH                 (SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH                 (DATA_WIDTH),
        .SPLIT_EN                   (0)
    ) slave1 (
        .clk                        (clk),
        .rstn                       (rstn),

        .bwdata                     (s1_wdata),
        .brdata                     (s1_rdata),
        .bmode                      (s1_mode),
        .bwvalid                    (s1_wvalid),
        .brvalid                    (s1_rvalid),
        .sready                     (s1_ready),

        .split_grant                (1'b0),     
        .ssplit                     ()
    );

    // Slave 2: 4KB Normal
    slave #(
        .ADDR_WIDTH                 (SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH                 (DATA_WIDTH),
        .SPLIT_EN                   (0)
    ) slave2 (
        .clk                        (clk),
        .rstn                       (rstn),

        .bwdata                     (s2_wdata),
        .brdata                     (s2_rdata),
        .bmode                      (s2_mode),
        .bwvalid                    (s2_wvalid),
        .brvalid                    (s2_rvalid),
        .sready                     (s2_ready),

        .split_grant                (1'b0),
        .ssplit                     ()
    );

    // Slave 3: 4KB Split
    slave #(
        .ADDR_WIDTH                 (SLAVE_MEM_ADDR_WIDTH),
        .DATA_WIDTH                 (DATA_WIDTH),
        .SPLIT_EN                   (1),
        .SPLIT_DELAY                (200)
    ) slave3 (
        .clk                        (clk),
        .rstn                       (rstn),

        .bwdata                     (s3_wdata),
        .brdata                     (s3_rdata),
        .bmode                      (s3_mode),
        .bwvalid                    (s3_wvalid),
        .brvalid                    (s3_rvalid),
        .sready                     (s3_ready),

        .split_grant                (s3_split_grant),
        .ssplit                     (s3_split)
    );

    //--------------------------------
    // SERIAL BUS INSTANCE
    //--------------------------------
    serial_bus #(
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .DATA_WIDTH                 (DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH       (SLAVE_MEM_ADDR_WIDTH)
    ) bus_inst (
        .clk                        (clk),
        .rstn                       (rstn),
        .bus_busy                   (bus_busy),

        // MASTER 1
        .m1_wdata                   (m1_bwdata),
        .m1_rdata                   (m1_brdata),
        .m1_mode                    (m1_bmode),
        .m1_wvalid                  (m1_bwvalid),
        .m1_rvalid                  (m1_brvalid),
        .m1_breq                    (m1_breq),
        .m1_bgrant                  (m1_bgrant),
        .m1_split                   (m1_split),
        .m1_ack                     (m1_ack),

        // MASTER 2
        .m2_wdata                   (m2_bwdata),
        .m2_rdata                   (m2_brdata),
        .m2_mode                    (m2_bmode),
        .m2_wvalid                  (m2_bwvalid),
        .m2_rvalid                  (m2_brvalid),
        .m2_breq                    (m2_breq),
        .m2_bgrant                  (m2_bgrant),
        .m2_split                   (m2_split),
        .m2_ack                     (m2_ack),

        // SLAVES
        .s1_wdata                   (s1_wdata), 
        .s1_rdata                   (s1_rdata), 
        .s1_mode                    (s1_mode),
        .s1_wvalid                  (s1_wvalid), 
        .s1_rvalid                  (s1_rvalid), 
        .s1_ready                   (s1_ready),

        .s2_wdata                   (s2_wdata), 
        .s2_rdata                   (s2_rdata), 
        .s2_mode                    (s2_mode),
        .s2_wvalid                  (s2_wvalid), 
        .s2_rvalid                  (s2_rvalid), 
        .s2_ready                   (s2_ready),

        .s3_wdata                   (s3_wdata), 
        .s3_rdata                   (s3_rdata), 
        .s3_mode                    (s3_mode),
        .s3_wvalid                  (s3_wvalid), 
        .s3_rvalid                  (s3_rvalid), 
        .s3_ready                   (s3_ready),
        .s3_split                   (s3_split),
        .s3_split_grant             (s3_split_grant)

    );



endmodule
