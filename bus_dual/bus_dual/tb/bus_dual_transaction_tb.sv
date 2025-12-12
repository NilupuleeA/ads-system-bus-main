`timescale 1ns/1ps

module bus_dual_transaction_tb;
    logic clk;
    logic rst_n;

    localparam bit [15:0] TARGET2_ADDR = 16'h4004;
    localparam bit [15:0] TARGET3_ADDR = 16'h8004;
    localparam bit [7:0] TARGET2_WRITE_DATA = 8'hA7;
    localparam bit [7:0] TARGET3_WRITE_DATA = 8'h5E;

    // Initiator 1 wiring (slaves slave 2)
    logic         m1_trigger;
    logic         m1_done;
    logic         m1_req;
    logic [15:0]  m1_address_out;
    logic         m1_address_out_valid;
    logic [7:0]   m1_data_out;
    logic         m1_data_out_valid;
    logic         m1_rw;
    logic         m1_ready;
    logic         m1_grant;
    logic [7:0]   m1_data_in;
    logic         m1_data_in_valid;
    logic         m1_ack;
    logic         m1_split_ack;

    // Initiator 2 wiring (slaves slave 1)
    logic         m2_trigger;
    logic         m2_done;
    logic         m2_req;
    logic [15:0]  m2_address_out;
    logic         m2_address_out_valid;
    logic [7:0]   m2_data_out;
    logic         m2_data_out_valid;
    logic         m2_rw;
    logic         m2_ready;
    logic         m2_grant;
    logic [7:0]   m2_data_in;
    logic         m2_data_in_valid;
    logic         m2_ack;
    logic         m2_split_ack;
    logic [7:0]   s1_last_write;

    // Target 1 wiring
    logic [15:0]  s1_address_in;
    logic         s1_address_in_valid;
    logic [7:0]   s1_data_in;
    logic         s1_data_in_valid;
    logic         s1_rw;
    logic [7:0]   s1_data_out;
    logic         s1_data_out_valid;
    logic         s1_ack;
    logic [7:0]   s2_last_write;
    logic         s1_ready;

    // Target 2 wiring
    logic [15:0]  s2_address_in;
    logic         s2_address_in_valid;
    logic [7:0]   s2_data_in;
    logic         s2_data_in_valid;
    logic         s2_rw;
    logic [7:0]   s2_data_out;
    logic         s2_data_out_valid;
    logic         s2_ack;
    logic         s2_ready;

    logic [7:0] split_s_last_write;
    // Split slave wiring (kept idle)
    logic [15:0]  split_s_address_in;
    logic         split_s_address_in_valid;
    logic [7:0]   split_s_data_in;
    logic         split_s_data_in_valid;
    logic         split_s_rw;
    logic [7:0]   split_s_data_out;
    logic         split_s_data_out_valid;
    logic         split_s_ack;
    logic         split_s_ready;
    logic         split_s_split_ack;
    logic         split_s_req;
    logic         split_s_grant;

    // Instantiate masters
    master #(
        .WRITE_ADDR(TARGET2_ADDR),
        .READ_ADDR(TARGET2_ADDR),
        .MEM_INIT_DATA(TARGET2_WRITE_DATA)
    ) u_master_1 (
        .clk(clk),
        .rst_n(rst_n),
        .trigger(m1_trigger),
        .m_grant(m1_grant),
        .m_ack(m1_ack),
        .m_split_ack(m1_split_ack),
        .m_data_in(m1_data_in),
        .m_data_in_valid(m1_data_in_valid),
        .m_req(m1_req),
        .m_address_out(m1_address_out),
        .m_address_out_valid(m1_address_out_valid),
        .m_data_out(m1_data_out),
        .m_data_out_valid(m1_data_out_valid),
        .m_rw(m1_rw),
        .m_ready(m1_ready),
        .done(m1_done),
        .read_data_value()
    );

    master #(
        .WRITE_ADDR(TARGET3_ADDR),
        .READ_ADDR(TARGET3_ADDR),
        .MEM_INIT_DATA(TARGET3_WRITE_DATA)
    ) u_master_2 (
        .clk(clk),
        .rst_n(rst_n),
        .trigger(m2_trigger),
        .m_grant(m2_grant),
        .m_ack(m2_ack),
        .m_split_ack(m2_split_ack),
        .m_data_in(m2_data_in),
        .m_data_in_valid(m2_data_in_valid),
        .m_req(m2_req),
        .m_address_out(m2_address_out),
        .m_address_out_valid(m2_address_out_valid),
        .m_data_out(m2_data_out),
        .m_data_out_valid(m2_data_out_valid),
        .m_rw(m2_rw),
        .m_ready(m2_ready),
        .done(m2_done),
        .read_data_value()
    );

    // Instantiate slaves
    slave #(.INTERNAL_ADDR_BITS(11)) u_s_1 (
        .clk(clk),
        .rst_n(rst_n),
        .s_address_in(s1_address_in),
        .s_address_in_valid(s1_address_in_valid),
        .s_data_in(s1_data_in),
        .s_data_in_valid(s1_data_in_valid),
        .s_rw(s1_rw),
        .s_data_out(s1_data_out),
        .s_data_out_valid(s1_data_out_valid),
        .s_ack(s1_ack),
        .s_ready(s1_ready),
        .s_last_write(s1_last_write)
    );

    slave #(.INTERNAL_ADDR_BITS(11)) u_s_2 (
        .clk(clk),
        .rst_n(rst_n),
        .s_address_in(s2_address_in),
        .s_address_in_valid(s2_address_in_valid),
        .s_data_in(s2_data_in),
        .s_data_in_valid(s2_data_in_valid),
        .s_rw(s2_rw),
        .s_data_out(s2_data_out),
        .s_data_out_valid(s2_data_out_valid),
        .s_ack(s2_ack),
        .s_ready(s2_ready),
        .s_last_write(s2_last_write)
    );

    split_s #(
        .INTERNAL_ADDR_BITS(12),
        .READ_LATENCY(4)
    ) u_split_s (
        .clk(clk),
        .rst_n(rst_n),
        .split_grant(split_s_grant),
        .s_address_in(split_s_address_in),
        .s_address_in_valid(split_s_address_in_valid),
        .s_data_in(split_s_data_in),
        .s_data_in_valid(split_s_data_in_valid),
        .s_rw(split_s_rw),
        .split_req(split_s_req),
        .s_data_out(split_s_data_out),
        .s_data_out_valid(split_s_data_out_valid),
        .s_ack(split_s_ack),
        .s_split_ack(split_s_split_ack),
        .s_ready(split_s_ready),
        .split_s_last_write(split_s_last_write)
    );

    // Device under test
    bus u_bus (
        .clk(clk),
        .rst_n(rst_n),
        // Initiator 1
        .m1_req(m1_req),
        .m1_data_out(m1_data_out),
        .m1_data_out_valid(m1_data_out_valid),
        .m1_address_out(m1_address_out),
        .m1_address_out_valid(m1_address_out_valid),
        .m1_rw(m1_rw),
        .m1_ready(m1_ready),
        .m1_grant(m1_grant),
        .m1_data_in(m1_data_in),
        .m1_data_in_valid(m1_data_in_valid),
        .m1_ack(m1_ack),
        .m1_split_ack(m1_split_ack),
        // Initiator 2
        .m2_req(m2_req),
        .m2_data_out(m2_data_out),
        .m2_data_out_valid(m2_data_out_valid),
        .m2_address_out(m2_address_out),
        .m2_address_out_valid(m2_address_out_valid),
        .m2_rw(m2_rw),
        .m2_ready(m2_ready),
        .m2_grant(m2_grant),
        .m2_data_in(m2_data_in),
        .m2_data_in_valid(m2_data_in_valid),
        .m2_ack(m2_ack),
        .m2_split_ack(m2_split_ack),
        // Target 1
        .s1_ready(s1_ready),
        .s1_ack(s1_ack),
        .s1_data_out(s1_data_out),
        .s1_data_out_valid(s1_data_out_valid),
        .s1_address_in(s1_address_in),
        .s1_address_in_valid(s1_address_in_valid),
        .s1_data_in(s1_data_in),
        .s1_data_in_valid(s1_data_in_valid),
        .s1_rw(s1_rw),
        // Target 2
        .s2_ready(s2_ready),
        .s2_ack(s2_ack),
        .s2_data_out(s2_data_out),
        .s2_data_out_valid(s2_data_out_valid),
        .s2_address_in(s2_address_in),
        .s2_address_in_valid(s2_address_in_valid),
        .s2_data_in(s2_data_in),
        .s2_data_in_valid(s2_data_in_valid),
        .s2_rw(s2_rw),
        // Split slave
        .split_s_ready(split_s_ready),
        .split_s_ack(split_s_ack),
        .split_s_split_ack(split_s_split_ack),
        .split_s_data_out(split_s_data_out),
        .split_s_data_out_valid(split_s_data_out_valid),
        .split_s_req(split_s_req),
        .split_s_address_in(split_s_address_in),
        .split_s_address_in_valid(split_s_address_in_valid),
        .split_s_data_in(split_s_data_in),
        .split_s_data_in_valid(split_s_data_in_valid),
        .split_s_rw(split_s_rw),
        .split_s_grant(split_s_grant)
    );

    // Clock generation (100 MHz)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Scoreboard state
    bit s1_write_seen;
    bit s1_read_seen;
    bit s2_write_seen;
    bit s2_read_seen;
    bit split_s_write_seen;
    bit split_s_read_seen;
    bit split_s_split_ack_seen;
    bit split_s_data_out_seen;
    int m1_data_in_count;
    int m2_data_in_count;

    logic [7:0] m1_read_data;
    logic [7:0] m2_read_data;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_write_seen <= 1'b0;
            s1_read_seen <= 1'b0;
            s2_write_seen <= 1'b0;
            s2_read_seen <= 1'b0;
            split_s_write_seen <= 1'b0;
            split_s_read_seen <= 1'b0;
            split_s_split_ack_seen <= 1'b0;
            split_s_data_out_seen <= 1'b0;
            m1_data_in_count <= 0;
            m2_data_in_count <= 0;
            m1_read_data <= '0;
            m2_read_data <= '0;
        end else begin
            if (s1_address_in_valid && s1_rw)
                s1_write_seen <= 1'b1;
            if (s1_address_in_valid && !s1_rw)
                s1_read_seen <= 1'b1;

            if (s2_address_in_valid && s2_rw)
                s2_write_seen <= 1'b1;
            if (s2_address_in_valid && !s2_rw)
                s2_read_seen <= 1'b1;

            if (split_s_address_in_valid && split_s_rw)
                split_s_write_seen <= 1'b1;
            if (split_s_address_in_valid && !split_s_rw)
                split_s_read_seen <= 1'b1;
            if (split_s_split_ack)
                split_s_split_ack_seen <= 1'b1;
            if (split_s_data_out_valid)
                split_s_data_out_seen <= 1'b1;

            if (m1_data_in_valid) begin
                m1_data_in_count <= m1_data_in_count + 1;
                m1_read_data <= m1_data_in;
            end

            if (m2_data_in_valid) begin
                m2_data_in_count <= m2_data_in_count + 1;
                m2_read_data <= m2_data_in;
            end
        end
    end

    // Reset task
    task automatic reset_dut;
        begin
            rst_n = 1'b0;
            repeat (5) @(posedge clk);
            rst_n = 1'b1;
            @(posedge clk);
        end
    endtask

    initial begin
        m1_trigger = 1'b0;
        m2_trigger = 1'b0;

        reset_dut();

        // Optional simultaneous request (both masters)
        // To enable, assert m1_trigger and m2_trigger on the same clock edge
        // @(posedge clk);
        // m1_trigger <= 1'b1;
        // m2_trigger <= 1'b1;
        // @(posedge clk);
        // m1_trigger <= 1'b0;
        // m2_trigger <= 1'b0;
        // wait (m1_done);
        // wait (m2_done);

        // Transaction 1: master 2 to slave 1
        @(posedge clk);
        m2_trigger <= 1'b1;
        @(posedge clk);
        m2_trigger <= 1'b0;
        wait (m2_done);

        // Allow bus to settle before second transaction
        repeat (10) @(posedge clk);

        // Transaction 2: master 1 to slave 2
        m1_trigger <= 1'b1;
        @(posedge clk);
        m1_trigger <= 1'b0;
        wait (m1_done);
        repeat (10) @(posedge clk);

        // Checks for transaction 1 (master 2 -> split slave)
        if (!split_s_write_seen)
            $error("Split slave write was not observed");
        if (!split_s_read_seen)
            $error("Split slave read was not observed");
        if (!split_s_split_ack_seen)
            $error("Split slave split-ack was not observed");
        if (!split_s_data_out_seen)
            $error("Split slave read data was not observed");
        if (s1_write_seen || s1_read_seen)
            $error("Target 1 should remain idle during split slave transaction");
        if (m2_data_in_count != 1)
            $error("Initiator 2 should observe exactly one data-valid pulse, saw %0d", m2_data_in_count);
        if (m2_read_data !== TARGET3_WRITE_DATA)
            $error("Initiator 2 read data mismatch. Expected %h, got %h", TARGET3_WRITE_DATA, m2_read_data);

        // Checks for transaction 2
        if (!s2_write_seen)
            $error("Target 2 write was not observed");
        if (!s2_read_seen)
            $error("Target 2 read was not observed");
        if (m1_data_in_count != 1)
            $error("Initiator 1 should observe exactly one data-valid pulse, saw %0d", m1_data_in_count);
        if (m1_read_data !== TARGET2_WRITE_DATA)
            $error("Initiator 1 read data mismatch. Expected %h, got %h", TARGET2_WRITE_DATA, m1_read_data);

        $display("[%0t] Dual-transaction bus integration test completed successfully.", $time);
        $finish;
    end
endmodule
