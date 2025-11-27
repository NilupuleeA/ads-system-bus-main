`timescale 1ns/1ps

module bb_loop_tb;
    // Parameters
    localparam ADDR_WIDTH = 16;
    localparam DATA_WIDTH = 8;
    localparam SLAVE_MEM_ADDR_WIDTH = 13;
    localparam BB_ADDR_WIDTH = 13;

    localparam DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;
    localparam UART_RX_DATA_WIDTH = DATA_WIDTH + BB_ADDR_WIDTH + 1;    // Receive all 3 info
    localparam UART_TX_DATA_WIDTH = DATA_WIDTH;     // Transmit only read data
    localparam UART_CLOCKS_PER_PULSE = 5208;

    // External signals
    reg clk, rstn;
    reg [DATA_WIDTH-1:0] d1_wdata;  // Write data to the DUT
    wire [DATA_WIDTH-1:0] d1_rdata; // Read data from the DUT
    reg [ADDR_WIDTH-1:0] d1_addr;
    reg d1_valid; 				  // Ready valid interface
    wire d1_ready;
    reg d1_mode;					  // 0 - read, 1 - write

    wire d1_sready;      // slaves are ready

    reg [DATA_WIDTH-1:0] d2_wdata;  // Write data to the DUT
    wire [DATA_WIDTH-1:0] d2_rdata; // Read data from the DUT
    reg [ADDR_WIDTH-1:0] d2_addr;
    reg d2_valid; 				  // Ready valid interface
    wire d2_ready;
    reg d2_mode;					  // 0 - read, 1 - write

    wire d2_sready;      // slaves are ready

    // UART signals
    wire m_u_rx, s_u_rx;
    wire m_u_tx, s_u_tx;

    // Instantiate masters
    top_with_bb #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .BB_ADDR_WIDTH(BB_ADDR_WIDTH),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) bus1 (
        .clk(clk),
        .rstn(rstn),
        .d1_wdata(d1_wdata),
        .d1_rdata(d1_rdata),
        .d1_addr(d1_addr),
        .d1_valid(d1_valid),
        .d1_ready(d1_ready),
        .d1_mode(d1_mode),
        .s_ready(d1_sready),
        .m_u_rx(m_u_rx),
        .m_u_tx(m_u_tx),
        .s_u_rx(s_u_rx),
        .s_u_tx(s_u_tx)
    );

    top_with_bb #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .BB_ADDR_WIDTH(BB_ADDR_WIDTH),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) bus2 (
        .clk(clk),
        .rstn(rstn),
        .d1_wdata(d2_wdata),
        .d1_rdata(d2_rdata),
        .d1_addr(d2_addr),
        .d1_valid(d2_valid),
        .d1_ready(d2_ready),
        .d1_mode(d2_mode),
        .s_ready(d2_sready),
        .m_u_rx(s_u_tx),
        .m_u_tx(s_u_rx),
        .s_u_rx(m_u_tx),
        .s_u_tx(m_u_rx)
    );

    // Generate Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period is 10 units
    end

    integer i;
    reg [ADDR_WIDTH-1:0] rand_addr1, rand_addr2, rand_addr3;
    reg [DATA_WIDTH-1:0] rand_data1, rand_data2;
    reg [DATA_WIDTH-1:0] slave_mem_data1, slave_mem_data2;
    reg [1:0] slave_id1, slave_id2;
    reg slave_id;

    task random_delay;
        integer delay;
        begin
            delay = $urandom % 10;  // Generate a random delay multiplier between 0 and 4
            $display("Random delay: %d", delay * 10);
            #(delay * 10);  // Delay in multiples of 10 time units (clock period)
        end
    endtask

    // Test Stimulus
    initial begin

        // Reset the DUT
        rstn = 0;
        d1_valid = 0;
        d1_wdata = 8'b0;
        d1_addr = 16'b0;
        d1_mode = 0;

        d2_valid = 0;
        d2_wdata = 8'b0;
        d2_addr = 16'b0;
        d2_mode = 0;

        #15 rstn = 1; // Release reset after 15 time units

        // Repeat the write and read tests 10 times
        for (i = 0; i < 10; i = i + 1) begin

            // Generate random address and data
            rand_addr1 = $random & 14'h3FFF;
            rand_data1 = $random;
            rand_addr2 = $random & 12'hFFF;
            rand_data2 = $random;
            slave_id = i & 1;

            // Write request to random location in slave 0 across bus bridge
            wait (d1_ready == 1);
            d1_wdata = rand_data2;
            d1_addr = {3'b010, slave_id, rand_addr2[11:0]};
            d1_mode = 1;
            d1_valid = 1;

            #20 d1_valid = 0;

            // Send read request
            if (slave_id == 0) begin
                @(posedge bus2.s1_ready);
            end else begin
                @(posedge bus2.s2_ready);
            end

            d2_addr = {2'b00, slave_id, 1'b0, rand_addr2[11:0]};
            d2_mode = 0;
            d2_valid = 1;

            #20 d2_valid = 0;

            wait (d2_ready == 1 && d2_sready == 1);

            if (rand_data2 != d2_rdata) begin
                $display("Bus bridge write failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, rand_addr2[11:0], rand_data2, d2_rdata);
            end else begin
                $display("Bus bridge write successful at iteration %0d", i);
            end

            // Read request across bus bridge
            wait (d1_ready == 1);
            d1_wdata = 8'b0;
            d1_addr = {3'b010, slave_id, rand_addr2[11:0]};
            d1_mode = 0;
            d1_valid = 1;

            #20 d1_valid = 0;

            // Send read request
            wait (d1_ready == 1 && d1_sready == 1 && d2_sready == 1);

            if (rand_data2 != d1_rdata) begin
                $display("Bus bridge read failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, rand_addr2[11:0], rand_data2, d1_rdata);
            end else begin
                $display("Bus bridge read successful at iteration %0d", i);
            end

        end

        #10 $finish;
    end


endmodule