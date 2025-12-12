`timescale 1ns/1ps

module slave_interface_tb;

    // DUT parameters
    localparam ADDR_WIDTH = 12;
    localparam DATA_WIDTH = 8;

    // Clock / Reset
    reg clk;
    reg rstn;

    // Serial bus
    reg bwdata;
    reg bmode;          // 1 = write, 0 = read
    reg bwvalid;
    wire brdata;
    wire brvalid;
    wire sready;

    // Memory signals
    wire [ADDR_WIDTH-1:0] mem_addr;
    wire mem_wen;
    wire mem_wvalid;
    wire [DATA_WIDTH-1:0] mem_wdata;

    reg  [DATA_WIDTH-1:0] mem_rdata;
    reg  mem_rvalid;

    // Split signals
    reg  split_grant;
    wire ssplit;

    //-----------------------------------------------------
    // DUT Instance
    //-----------------------------------------------------
    slave_interface #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SPLIT_EN(0)
    ) dut (
        .clk(clk),
        .rstn(rstn),

        .mem_addr(mem_addr),
        .mem_wen(mem_wen),
        .mem_rdata(mem_rdata),
        .mem_rvalid(mem_rvalid),
        .mem_wdata(mem_wdata),
        .mem_wvalid(mem_wvalid),

        .bwdata(bwdata),
        .brdata(brdata),
        .bmode(bmode),
        .bwvalid(bwvalid),
        .brvalid(brvalid),
        .sready(sready),

        .split_grant(split_grant),
        .ssplit(ssplit)
    );

    //-----------------------------------------------------
    // Clock
    //-----------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //-----------------------------------------------------
    // Reset
    //-----------------------------------------------------
    initial begin
        rstn = 0;
        bwdata = 0;
        bmode = 0;
        bwvalid = 0;
        split_grant = 0;
        mem_rdata = 0;
        mem_rvalid = 0;
        #40 rstn = 1;
    end

    //-----------------------------------------------------
    // Task: send 12-bit address (LSB-first)
    //-----------------------------------------------------
    task send_address(input [11:0] addr);
        integer i;
        begin
            $display("[TB] Sending address = %h", addr);
            for (i = 0; i < 12; i = i + 1) begin
                @(posedge clk);
                bwdata  = addr[i];
                bwvalid = 1'b1;
            end
            @(posedge clk);
            bwvalid = 0;
        end
    endtask

    //-----------------------------------------------------
    // Task: send 8-bit write data (LSB-first)
    //-----------------------------------------------------
    task send_wdata(input [7:0] data);
        integer i;
        begin
            $display("[TB] Sending WDATA = %h", data);
            for (i = 0; i < 8; i = i + 1) begin
                @(posedge clk);
                bwdata  = data[i];
                bwvalid = 1'b1;
            end
            @(posedge clk);
            bwvalid = 0;
        end
    endtask

    //-----------------------------------------------------
    // Fake memory read response generator
    //-----------------------------------------------------
    task respond_read(input [7:0] rd_value);
        begin
            @(posedge clk);
            mem_rdata  = rd_value;
            mem_rvalid = 1;
            @(posedge clk);
            mem_rvalid = 0;
        end
    endtask

    //-----------------------------------------------------
    // Monitor serial read response
    //-----------------------------------------------------
    always @(posedge clk) begin
        if (brvalid)
            $display("[TB] Read bit from slave = %0d", brdata);
    end

    //-----------------------------------------------------
    // Test sequence
    //-----------------------------------------------------
    initial begin
        @(posedge rstn);
        @(posedge clk);

        // -------------------------------------------------
        // WRITE TRANSACTION
        // -------------------------------------------------
        bmode = 1'b1;     // write mode
        $display("\n========== WRITE TRANSACTION ==========\n");
        send_address(12'hA5F);
        send_wdata(8'h3C);

        repeat(10) @(posedge clk);

        // -------------------------------------------------
        // READ TRANSACTION
        // -------------------------------------------------
        bmode = 1'b0;     // read mode
        $display("\n========== READ TRANSACTION ==========\n");
        send_address(12'h0F3);

        // After DUT enters RDATA, it will assert mem_addr
        // We respond with one cycle of memory read valid
        respond_read(8'h9A);

        // Wait until read bits are shifted out on bus
        repeat(20) @(posedge clk);

        $display("\n------ TEST FINISHED ------");
        $stop;
    end

endmodule
