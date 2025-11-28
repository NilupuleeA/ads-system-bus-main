`timescale 1ns/1ps

module bus_bridge_master_tb;
    // Test parameters (override defaults for faster simulation)
    localparam int ADDR_WIDTH             = 16;
    localparam int DATA_WIDTH             = 8;
    localparam int SLAVE_MEM_ADDR_WIDTH   = 12;
    localparam int BB_ADDR_WIDTH          = 12;
    localparam int UART_CLOCKS_PER_PULSE  = 16;
    localparam int UART_RX_DATA_WIDTH     = DATA_WIDTH + BB_ADDR_WIDTH + 1;
    localparam int UART_TX_DATA_WIDTH     = DATA_WIDTH;
    localparam int CLK_PERIOD             = 20; // 50 MHz

    // Clock/reset
    reg clk;
    reg rstn;

    // Serial bus interface wires
    reg  mrdata;
    wire mwdata;
    wire mmode;
    wire mvalid;
    reg  svalid;
    wire mbreq;
    wire mbgrant = 1'b1;
    wire msplit  = 1'b0;
    wire ack     = 1'b1;

    // UART interface
    wire u_tx;
    wire u_rx;

    // Host UART driver/monitor
    reg  [UART_RX_DATA_WIDTH-1:0] host_din;
    reg                          host_en;
    wire                         host_tx_busy;
    wire                         host_ready;
    wire [UART_TX_DATA_WIDTH-1:0] host_dout;

    // Scoreboard
    integer errors;

    // Simple memory-backed slave model
    localparam int SADDR_BITS = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;
    localparam int MEM_DEPTH  = 1 << SLAVE_MEM_ADDR_WIDTH;

    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    reg [ADDR_WIDTH-1:0] active_addr;
    reg [DATA_WIDTH-1:0] write_buffer;
    reg [DATA_WIDTH-1:0] read_buffer;
    reg [DATA_WIDTH-1:0] buffer_next;

    reg [2:0] bus_state;
    localparam [2:0] BUS_IDLE      = 3'd0,
                     BUS_SADDR     = 3'd1,
                     BUS_ADDR      = 3'd2,
                     BUS_WDATA     = 3'd3,
                     BUS_READ_RESP = 3'd4;

    integer saddr_cnt;
    integer addr_cnt;
    integer data_cnt;
    integer resp_cnt;
    reg prev_mbreq;
    wire mbreq_start = mbreq & ~prev_mbreq;

    // Instantiate DUT
    bus_bridge_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .BB_ADDR_WIDTH(BB_ADDR_WIDTH),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) dut (
        .clk   (clk),
        .rstn  (rstn),
        .mrdata(mrdata),
        .mwdata(mwdata),
        .mmode (mmode),
        .mvalid(mvalid),
        .svalid(svalid),
        .mbreq (mbreq),
        .mbgrant(mbgrant),
        .msplit(msplit),
        .ack   (ack),
        .u_tx  (u_tx),
        .u_rx  (u_rx)
    );

    // UART partner (drives commands and captures responses)
    uart #(
        .CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE),
        .TX_DATA_WIDTH(UART_RX_DATA_WIDTH),
        .RX_DATA_WIDTH(UART_TX_DATA_WIDTH)
    ) uart_host (
        .data_input (host_din),
        .data_en    (host_en),
        .clk        (clk),
        .rstn       (rstn),
        .tx         (u_rx),
        .tx_busy    (host_tx_busy),
        .rx         (u_tx),
        .ready      (host_ready),
        .data_output(host_dout)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Reset generation
    initial begin
        rstn = 1'b0;
        #(10*CLK_PERIOD);
        rstn = 1'b1;
    end

    // Memory initialization
    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = '0;
        end
    end

    // Default signal initial values
    initial begin
        host_din   = '0;
        host_en    = 1'b0;
        svalid     = 1'b0;
        mrdata     = 1'b0;
        errors     = 0;
        bus_state   = BUS_IDLE;
        active_addr = '0;
        write_buffer = '0;
        read_buffer  = '0;
        buffer_next  = '0;
        prev_mbreq   = 1'b0;
        saddr_cnt = 0;
        addr_cnt  = 0;
        data_cnt  = 0;
        resp_cnt  = 0;
    end

    // Simple bus/slave behavioral model
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bus_state    <= BUS_IDLE;
            saddr_cnt    <= 0;
            addr_cnt     <= 0;
            data_cnt     <= 0;
            resp_cnt     <= 0;
            svalid       <= 1'b0;
            mrdata       <= 1'b0;
            active_addr  <= '0;
            write_buffer <= '0;
            read_buffer  <= '0;
        end else begin
            prev_mbreq <= mbreq;
            case (bus_state)
                BUS_IDLE: begin
                    svalid      <= 1'b0;
                    mrdata      <= 1'b0;
                    active_addr <= '0;
                    if (mbreq_start) begin
                        bus_state <= BUS_SADDR;
                        saddr_cnt <= 0;
                    end
                end

                BUS_SADDR: begin
                    if (mvalid) begin
                        active_addr[SLAVE_MEM_ADDR_WIDTH + saddr_cnt] <= mwdata;
                        if (saddr_cnt == SADDR_BITS-1) begin
                            saddr_cnt <= 0;
                            addr_cnt  <= 0;
                            bus_state <= BUS_ADDR;
                        end else begin
                            saddr_cnt <= saddr_cnt + 1;
                        end
                    end
                end

                BUS_ADDR: begin
                    if (mvalid) begin
                        active_addr[addr_cnt] <= mwdata;
                        if (addr_cnt == SLAVE_MEM_ADDR_WIDTH-1) begin
                            addr_cnt <= 0;
                            data_cnt <= 0;
                            if (mmode) begin
                                write_buffer <= '0;
                                bus_state <= BUS_WDATA;
                            end else begin
                                read_buffer <= mem[active_addr[SLAVE_MEM_ADDR_WIDTH-1:0]];
                                resp_cnt    <= 0;
                                bus_state   <= BUS_READ_RESP;
                            end
                        end else begin
                            addr_cnt <= addr_cnt + 1;
                        end
                    end
                end

                BUS_WDATA: begin
                    if (mvalid) begin
                        buffer_next = write_buffer;
                        buffer_next[data_cnt] = mwdata;
                        write_buffer <= buffer_next;
                        if (data_cnt == DATA_WIDTH-1) begin
                            mem[active_addr[SLAVE_MEM_ADDR_WIDTH-1:0]] <= buffer_next;
                            data_cnt  <= 0;
                            bus_state <= BUS_IDLE;
                        end else begin
                            data_cnt <= data_cnt + 1;
                        end
                    end
                end

                BUS_READ_RESP: begin
                    if (resp_cnt < DATA_WIDTH) begin
                        svalid <= 1'b1;
                        mrdata <= read_buffer[resp_cnt];
                        resp_cnt <= resp_cnt + 1;
                    end else begin
                        svalid   <= 1'b0;
                        mrdata   <= 1'b0;
                        bus_state <= BUS_IDLE;
                    end
                end

                default: bus_state <= BUS_IDLE;
            endcase
        end
    end

    // Task: send command packet over UART
    task automatic send_uart_packet(input mode,
                                    input [DATA_WIDTH-1:0] data,
                                    input [BB_ADDR_WIDTH-1:0] addr);
        reg [UART_RX_DATA_WIDTH-1:0] payload;
        begin
            payload = {mode, data, addr};
            @(posedge clk);
            wait (!host_tx_busy);
            host_din <= payload;
            host_en  <= 1'b1;
            @(posedge clk);
            host_en  <= 1'b0;
            wait (!host_tx_busy);
        end
    endtask

    // Task: wait for UART response from DUT
    task automatic wait_for_uart_read(output [DATA_WIDTH-1:0] value);
        begin
            wait (host_ready);
            value = host_dout;
            @(posedge clk);
        end
    endtask

    // Task: wait until master port is idle (transaction finished)
    task automatic wait_for_master_idle;
        begin
            wait (mbreq == 1'b0);
            @(posedge clk);
        end
    endtask

    // Stimulus
    reg [DATA_WIDTH-1:0] rx_value;
    localparam [BB_ADDR_WIDTH-1:0] ADDR_A = 12'h055;
    localparam [BB_ADDR_WIDTH-1:0] ADDR_B = 12'h3AC;
    localparam [DATA_WIDTH-1:0]    DATA_A = 8'hDE;
    localparam [DATA_WIDTH-1:0]    DATA_B = 8'h4B;

    initial begin
        wait (rstn);
        repeat (5) @(posedge clk);

        // Write DATA_A then read back
        send_uart_packet(1'b1, DATA_A, ADDR_A);
        wait_for_master_idle();

        send_uart_packet(1'b0, '0, ADDR_A);
        wait_for_uart_read(rx_value);
        if (rx_value !== DATA_A) begin
            errors = errors + 1;
            $display("[ERROR] Readback mismatch at ADDR_A: exp=%0h got=%0h", DATA_A, rx_value);
        end else begin
            $display("[INFO] Readback match at ADDR_A (%0h)", rx_value);
        end

        // Read an unwritten address (expect zero)
        send_uart_packet(1'b0, '0, 12'h222);
        wait_for_uart_read(rx_value);
        if (rx_value !== 0) begin
            errors = errors + 1;
            $display("[ERROR] Default read mismatch at 0x222: exp=00 got=%0h", rx_value);
        end else begin
            $display("[INFO] Default read returned zero as expected");
        end

        // Second write/read pair
        send_uart_packet(1'b1, DATA_B, ADDR_B);
        wait_for_master_idle();

        send_uart_packet(1'b0, '0, ADDR_B);
        wait_for_uart_read(rx_value);
        if (rx_value !== DATA_B) begin
            errors = errors + 1;
            $display("[ERROR] Readback mismatch at ADDR_B: exp=%0h got=%0h", DATA_B, rx_value);
        end else begin
            $display("[INFO] Readback match at ADDR_B (%0h)", rx_value);
        end

        // Report results
        if (errors == 0) begin
            $display("[PASS] bus_bridge_master basic UART transactions succeeded");
        end else begin
            $display("[FAIL] bus_bridge_master TB observed %0d errors", errors);
        end

        #(20*CLK_PERIOD);
        $finish;
    end

endmodule


