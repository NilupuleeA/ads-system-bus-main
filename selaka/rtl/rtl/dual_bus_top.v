`timescale 1ns/1ps

module dual_bus_top;

    // ============================================================
    // Common parameters
    // ============================================================
    localparam ADDR_WIDTH       = 16;
    localparam DATA_WIDTH       = 8;
    localparam SLV_AW           = 12;
    localparam BB_AW            = 12;

    localparam UART_CLOCKS_PER_PULSE = 5;   // 19.2k baud @ 100 MHz

    // ============================================================
    // CLOCK + RESET
    // ============================================================
    reg clk = 0;
    reg rstn = 0;
    always #5 clk = ~clk;

    initial begin
        rstn = 0;
        #200;
        rstn = 1;
    end

    wire                        bus_busy_A;
    wire                        bus_busy_B;

    // ============================================================
    // Master signals for Bus A
    // ============================================================
    reg  [DATA_WIDTH-1:0]       mwdata;
    reg  [ADDR_WIDTH-1:0]       maddr;
    reg                         mwvalid;
    wire [DATA_WIDTH-1:0]       mrdata;    
    wire                        mrvalid;
    wire                        mready;
    reg                         wen;

    // ============================================================
    // UART LINK BETWEEN BUS-A and BUS-B
    // ============================================================
    wire                        uart_A_to_B;   // TX from BUS-A, RX to BUS-B
    wire                        uart_B_to_A;   // (Optional return path) TX from BUS-B, RX to BUS-A

    // ============================================================
    // BUS-A WIRES
    // ============================================================
    // Master 1A = user normal master
    wire                        m1A_bwdata;
    wire                        m1A_brdata;
    wire                        m1A_bmode; 
    wire                        m1A_bwvalid; 
    wire                        m1A_brvalid;
    wire                        m1A_breq; 
    wire                        m1A_bgrant; 
    wire                        m1A_split; 
    wire                        m1A_ack;

    // Master 2A = user normal master
    wire                        m2A_bwdata; 
    wire                        m2A_brdata;
    wire                        m2A_bmode; 
    wire                        m2A_bwvalid; 
    wire                        m2A_brvalid;
    wire                        m2A_breq; 
    wire                        m2A_bgrant; 
    wire                        m2A_split; 
    wire                        m2A_ack;

    // Bus-A slaves
    wire                        s1A_wdata; 
    wire                        s1A_rdata; 
    wire                        s1A_mode; 
    wire                        s1A_wvalid; 
    wire                        s1A_rvalid; 
    wire                        s1A_ready;

    wire                        s2A_wdata; 
    wire                        s2A_rdata; 
    wire                        s2A_mode; 
    wire                        s2A_wvalid; 
    wire                        s2A_rvalid; 
    wire                        s2A_ready;

    wire                        s3A_wdata; 
    wire                        s3A_rdata; 
    wire                        s3A_mode; 
    wire                        s3A_wvalid; 
    wire                        s3A_rvalid; 
    wire                        s3A_ready;
    wire                        s3A_split; 
    wire                        s3A_split_grant;

    // ============================================================
    // BUS-B WIRES
    // ============================================================
    // Master 1B = UART master bridge
    wire                        m1B_bwdata; 
    wire                        m1B_brdata;
    wire                        m1B_bmode; 
    wire                        m1B_bwvalid; 
    wire                        m1B_brvalid;
    wire                        m1B_breq; 
    wire                        m1B_bgrant; 
    wire                        m1B_split; 
    wire                        m1B_ack;

    // Master 1B = Normal master
    wire                        m2B_bwdata; 
    wire                        m2B_brdata;
    wire                        m2B_bmode; 
    wire                        m2B_bwvalid; 
    wire                        m2B_brvalid;
    wire                        m2B_breq; 
    wire                        m2B_bgrant; 
    wire                        m2B_split; 
    wire                        m2B_ack;

    // Slave wires for Bus-B

    wire                        s1B_wdata; 
    wire                        s1B_rdata; 
    wire                        s1B_mode; 
    wire                        s1B_wvalid; 
    wire                        s1B_rvalid; 
    wire                        s1B_ready;

    wire                        s2B_wdata; 
    wire                        s2B_rdata; 
    wire                        s2B_mode; 
    wire                        s2B_wvalid; 
    wire                        s2B_rvalid; 
    wire                        s2B_ready;

    wire                        s3B_wdata; 
    wire                        s3B_rdata; 
    wire                        s3B_mode; 
    wire                        s3B_wvalid; 
    wire                        s3B_rvalid; 
    wire                        s3B_ready;
    wire                        s3B_split; 
    wire                        s3B_split_grant;




    master_interface #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .DATA_WIDTH             (DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH   (SLV_AW)
        
    ) master_A1_interface(
        .clk                    (clk),
        .rstn                   (rstn),

        .mwdata                 (mwdata),
        .maddr                  (maddr),
        .mwvalid                (mwvalid),
        .mrdata                 (mrdata),
        .mrvalid                (mrvalid),
        .mready                 (mready),
        .wen                    (wen),

        .bwdata                 (m1A_bwdata),
        .brdata                 (m1A_brdata),
        .bmode                  (m1A_bmode),
        .bwvalid                (m1A_bwvalid),
        .brvalid                (m1A_brvalid),
        .bus_busy               (bus_busy_A),


        .mbreq                  (m1A_breq),
        .mbgrant                (m1A_bgrant),
        .msplit                 (m1A_split),
        .ack                    (m1A_ack)
    );


    slave #(
        .ADDR_WIDTH             (SLV_AW),
        .DATA_WIDTH             (DATA_WIDTH),
        .SPLIT_EN               (0)
    ) slave_B1 (
        .clk                    (clk),
        .rstn                   (rstn),

        .bwdata                 (s1B_wdata),
        .brdata                 (s1B_rdata),
        .bmode                  (s1B_mode),
        .bwvalid                (s1B_wvalid),
        .brvalid                (s1B_rvalid),
        .sready                 (s1B_ready),

        .split_grant            (1'b0),      
        .ssplit                 ()
    );


    // ============================================================
    // BUS-A: bus_bridge_slave (convert bus access → UART)
    // ============================================================

    // Slaves A
    test_slave_bridge #(
        .ADDR_WIDTH             (SLV_AW),
        .DATA_WIDTH             (DATA_WIDTH),
        .UART_CLOCKS_PER_PULSE  (UART_CLOCKS_PER_PULSE)
    ) bb_slave_A (
        .clk                    (clk),
        .rstn                   (rstn),

        .swdata                 (s1A_wdata),	
        .smode                  (s1A_mode),	
        .mvalid                 (s1A_wvalid),	
        .split_grant            (1'b0), 
        .srdata                 (s1A_rdata),
        .svalid                 (s1A_rvalid),
        .sready                 (s1A_ready), 
        .ssplit                 (),

        .u_tx                   (uart_A_to_B),
        .u_rx                   (uart_B_to_A)
    );

    // ============================================================
    // BUS-B: bus_bridge_master (UART → bus transaction)
    // ============================================================
    test_master_bridge #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .DATA_WIDTH             (DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH   (SLV_AW),
        .UART_CLOCKS_PER_PULSE  (UART_CLOCKS_PER_PULSE)
    ) bb_master_B (
        .clk                    (clk),
        .rstn                   (rstn),

        .mrdata                 (m1B_brdata),
        .mwdata                 (m1B_bwdata),
        .mmode                  (m1B_bmode),
        .mvalid                 (m1B_bwvalid),
        .svalid                 (m1B_brvalid),
        .bus_busy               (bus_busy_B),
        .mbreq                  (m1B_breq),
        .mbgrant                (m1B_bgrant),
        .msplit                 (m1B_split),
        .ack                    (m1B_ack),

        .u_rx                   (uart_A_to_B),
        .u_tx                   (uart_B_to_A)
    );

    // ============================================================
    // SERIAL BUS A
    // ============================================================
    serial_bus #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .DATA_WIDTH             (DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH   (SLV_AW)
    ) busA (
        .clk                    (clk),
        .rstn                   (rstn),
        .bus_busy               (bus_busy_A),

        // Master 1A = UART slave bridge
        .m1_wdata               (m1A_bwdata),
        .m1_rdata               (m1A_brdata),
        .m1_mode                (m1A_bmode),
        .m1_wvalid              (m1A_bwvalid),
        .m1_rvalid              (m1A_brvalid),
        .m1_breq                (m1A_breq),
        .m1_bgrant              (m1A_bgrant),
        .m1_split               (m1A_split),
        .m1_ack                 (m1A_ack),

        // Master 2A (optional user master)
        .m2_wdata               (m2A_bwdata),
        .m2_rdata               (m2A_brdata),
        .m2_mode                (m2A_bmode),
        .m2_wvalid              (m2A_bwvalid),
        .m2_rvalid              (m2A_brvalid),
        .m2_breq                (0),
        .m2_bgrant              (m2A_bgrant),
        .m2_split               (m2A_split),
        .m2_ack                 (m2A_ack),

        // Slaves A
        .s1_wdata               (s1A_wdata),
        .s1_rdata               (s1A_rdata),
        .s1_mode                (s1A_mode),
        .s1_wvalid              (s1A_wvalid),
        .s1_rvalid              (s1A_rvalid),
        .s1_ready               (s1A_ready),

        .s2_wdata               (s2A_wdata),
        .s2_rdata               (s2A_rdata),
        .s2_mode                (s2A_mode),
        .s2_wvalid              (s2A_wvalid),
        .s2_rvalid              (s2A_rvalid),
        .s2_ready               (1'b1),

        .s3_wdata               (s3A_wdata),
        .s3_rdata               (s3A_rdata),
        .s3_mode                (s3A_mode),
        .s3_wvalid              (s3A_wvalid),
        .s3_rvalid              (s3A_rvalid),
        .s3_ready               (1'b1),
        .s3_split               (1'b0),
        .s3_split_grant         (s3A_split_grant)
    );

    // ============================================================
    // SERIAL BUS B
    // ============================================================
    serial_bus #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .DATA_WIDTH             (DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH   (SLV_AW)
    ) busB (
        .clk                    (clk),
        .rstn                   (rstn),
        .bus_busy               (bus_busy_B),

        // Master 1B = UART master bridge
        .m1_wdata               (m1B_bwdata),
        .m1_rdata               (m1B_brdata),
        .m1_mode                (m1B_bmode),
        .m1_wvalid              (m1B_bwvalid),
        .m1_rvalid              (m1B_brvalid),
        .m1_breq                (m1B_breq),
        .m1_bgrant              (m1B_bgrant),
        .m1_split               (m1B_split),
        .m1_ack                 (m1B_ack),

        // NO master 2
        .m2_wdata               (m2B_bwdata),
        .m2_rdata               (m2B_brdata),
        .m2_mode                (m2B_bmode),
        .m2_wvalid              (m2B_bwvalid),
        .m2_rvalid              (m2B_brvalid),
        .m2_breq                (0),
        .m2_bgrant              (m2B_bgrant),
        .m2_split               (m2B_split),
        .m2_ack                 (m2B_ack),

        // Slaves on BUS-B
        .s1_wdata               (s1B_wdata),
        .s1_rdata               (s1B_rdata),
        .s1_mode                (s1B_mode),
        .s1_wvalid              (s1B_wvalid),
        .s1_rvalid              (s1B_rvalid),
        .s1_ready               (s1B_ready),

        .s2_wdata               (s2B_wdata),
        .s2_rdata               (s2B_rdata),
        .s2_mode                (s2B_mode),
        .s2_wvalid              (s2B_wvalid),
        .s2_rvalid              (s2B_rvalid),
        .s2_ready               (1'b1),

        .s3_wdata               (s3B_wdata),
        .s3_rdata               (s3B_rdata),
        .s3_mode                (s3B_mode),
        .s3_wvalid              (s3B_wvalid),
        .s3_rvalid              (s3B_rvalid),
        .s3_ready               (1'b1),
        .s3_split               (1'b0),
        .s3_split_grant         (s3B_split_grant)
    );

endmodule
