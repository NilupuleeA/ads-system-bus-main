`timescale 1ns/1ps

module m_port_tb;
    logic clk;
    logic rst_n;

    logic m_req;
    logic arbiter_grant;
    logic [7:0] m_data_out;
    logic m_data_out_valid;
    logic [15:0] m_address_out;
    logic m_address_out_valid;
    logic m_rw;
    logic m_ready;
    logic s_split;
    logic s_ack;
    logic bus_data_in_valid;
    logic bus_data_in;

    logic bus_data_out;
    logic m_grant;
    logic [7:0] m_data_in;
    logic m_data_in_valid;
    logic bus_data_out_valid;
    logic arbiter_req;
    logic bus_mode;
    logic m_ack;
    logic bus_m_ready;
    logic bus_m_rw;
    logic m_split_ack;

    localparam bit [15:0] TEST_ADDR = 16'hA55A;
    localparam bit [7:0] TEST_DATA_WR = 8'h3C;
    localparam bit [7:0] TEST_DATA_RD = 8'h96;
    localparam bit [15:0] TEST_ADDR_RD1 = 16'h1357;
    localparam bit [15:0] TEST_ADDR_RD2 = 16'h2468;
    localparam bit [15:0] TEST_ADDR_RD3 = 16'h9ACE;

    m_port dut (
        .clk(clk),
        .rst_n(rst_n),
        .m_req(m_req),
        .arbiter_grant(arbiter_grant),
        .m_data_out(m_data_out),
        .m_data_out_valid(m_data_out_valid),
        .m_address_out(m_address_out),
        .m_address_out_valid(m_address_out_valid),
        .m_rw(m_rw),
        .m_ready(m_ready),
        .s_split(s_split),
        .s_ack(s_ack),
        .bus_data_in_valid(bus_data_in_valid),
        .bus_data_in(bus_data_in),
        .bus_data_out(bus_data_out),
        .m_grant(m_grant),
        .m_data_in(m_data_in),
        .m_data_in_valid(m_data_in_valid),
        .bus_data_out_valid(bus_data_out_valid),
        .arbiter_req(arbiter_req),
        .bus_mode(bus_mode),
        .m_ack(m_ack),
        .bus_m_ready(bus_m_ready),
        .bus_m_rw(bus_m_rw),
        .m_split_ack(m_split_ack)
    );

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    int count_read_valid;
    int count_ack_pulse;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_read_valid <= 0;
            count_ack_pulse <= 0;
        end else begin
            if (m_data_in_valid)
                count_read_valid <= count_read_valid + 1;
            if (m_ack)
                count_ack_pulse <= count_ack_pulse + 1;
        end
    end

    task automatic reset_design_under_test;
        begin
            rst_n = 1'b0;
            repeat (4) @(posedge clk);
            rst_n = 1'b1;
            @(posedge clk);
        end
    endtask

    task automatic transmit_address_data(input bit [15:0] addr, input bit [7:0] data);
        bit [23:0] bits_captured;
        bit [15:0] address_received;
        bit [7:0] data_received;
        int idx_bit;

        bits_captured = '0;
        address_received = '0;
        data_received = '0;
        idx_bit = 0;

        m_req = 1'b1;
        arbiter_grant = 1'b1;
        m_rw = 1'b1;
        m_address_out = addr;
        m_address_out_valid = 1'b1;
        m_data_out = data;
        m_data_out_valid = 1'b1;

        @(posedge clk);
        m_address_out_valid = 1'b0;
        m_data_out_valid = 1'b0;

        while (idx_bit < 24) begin
            @(posedge clk);
            if (bus_data_out_valid) begin
                bits_captured[idx_bit] = bus_data_out;
                if (idx_bit < 16) begin
                    if (bus_mode !== 1'b0)
                        $error("[%0t] bus_mode should be 0 during address bits", $time);
                end else begin
                    if (bus_mode !== 1'b1)
                        $error("[%0t] bus_mode should be 1 during data bits", $time);
                end
                idx_bit++;
            end
        end

        address_received = bits_captured[15:0];
        data_received = bits_captured[23:16];

        if (address_received !== addr)
            $error("[%0t] Address serialisation mismatch. Expected %h, got %h", $time, addr, address_received);
        else
            $display("[%0t] Address serialisation OK (%h)", $time, address_received);

        if (data_received !== data)
            $error("[%0t] Data serialisation mismatch. Expected %h, got %h", $time, data, data_received);
        else
            $display("[%0t] Data serialisation OK (%h)", $time, data_received);

        m_req = 1'b0;
        arbiter_grant = 1'b0;
        m_rw = 1'b0;

        repeat (2) @(posedge clk);

        if (bus_mode !== 1'b0)
            $error("[%0t] bus_mode should return to 0 when idle", $time);
    endtask

    task automatic issue_read_addr(input bit [15:0] addr);
        bit [15:0] captured;
        int bit_idx;

        captured = '0;
        bit_idx = 0;

        m_req = 1'b1;
        arbiter_grant = 1'b1;
        m_rw = 1'b0;
        m_address_out = addr;
        m_address_out_valid = 1'b1;
        m_data_out_valid = 1'b0;
        m_data_out = '0;

        @(posedge clk);
        m_address_out_valid = 1'b0;

        while (bit_idx < 16) begin
            @(posedge clk);
            if (bus_data_out_valid) begin
                captured[bit_idx] = bus_data_out;
                if (bus_mode !== 1'b0)
                    $error("[%0t] bus_mode should be 0 during read address bits", $time);
                bit_idx++;
            end
        end

        m_req = 1'b0;
        arbiter_grant = 1'b0;

        if (captured !== addr)
            $error("[%0t] Read address serialisation mismatch. Expected %h, got %h", $time, addr, captured);
        else
            $display("[%0t] Read address serialisation OK (%h)", $time, captured);

        @(posedge clk);
        if (bus_mode !== 1'b1)
            $error("[%0t] bus_mode should be 1 while awaiting read data", $time);
    endtask

    task automatic drive_read_data(
        input bit [7:0] data,
        input int ack_timing_cycles, // <0: ack before data, 0: ack immediately after data bits, >0: ack after data by N cycles
        input string scenario_name
    );
    
        int ack_count_before;
        bit ack_seen_pre_data;
            
        m_req = 1'b0;
        arbiter_grant = 1'b0;
        m_rw = 1'b0;

        repeat (2) @(posedge clk);

        ack_count_before = count_ack_pulse;

        // Ack asserted before data
        if (ack_timing_cycles < 0) begin
            s_ack = 1'b1;
            @(posedge clk);
            s_ack = 1'b0;
        end

        ack_seen_pre_data = 1'b0;

        for (int i = 0; i < 8; i++) begin
            bus_data_in = data[i];
            bus_data_in_valid = 1'b1;
            @(posedge clk);
            if (m_ack)
                ack_seen_pre_data = 1'b1;
        end

        bus_data_in_valid = 1'b0;
        bus_data_in = 1'b0;

        if (ack_timing_cycles == 0) begin
            s_ack = 1'b1;
            @(posedge clk);
            s_ack = 1'b0;
        end else if (ack_timing_cycles > 0) begin
            repeat (ack_timing_cycles) @(posedge clk);
            s_ack = 1'b1;
            @(posedge clk);
            s_ack = 1'b0;
        end

        while (!m_data_in_valid) begin
            if (m_ack)
                ack_seen_pre_data = 1'b1;
            @(posedge clk);
        end

        if (m_data_in !== data)
            $error("[%0t] %s: Read data mismatch. Expected %h, got %h", $time, scenario_name, data, m_data_in);
        else
            $display("[%0t] %s: Read data deserialisation OK (%h)", $time, scenario_name, m_data_in);

        if (!m_ack)
            $error("[%0t] %s: m_ack missing when read data valid", $time, scenario_name);

        if (ack_seen_pre_data && ack_timing_cycles < 0)
            $error("[%0t] %s: m_ack should not assert before read data valid", $time, scenario_name);

        if ((count_ack_pulse - ack_count_before) != 1)
            $error("[%0t] %s: Expected exactly one m_ack pulse, observed %0d", $time, scenario_name, count_ack_pulse - ack_count_before);

        repeat (2) @(posedge clk);
    endtask

    initial begin
        m_req = 1'b0;
        arbiter_grant = 1'b0;
        m_data_out = '0;
        m_data_out_valid = 1'b0;
        m_address_out = '0;
        m_address_out_valid = 1'b0;
        m_rw = 1'b0;
        m_ready = 1'b1;
        s_split = 1'b0;
        s_ack = 1'b0;
        bus_data_in_valid = 1'b0;
        bus_data_in = 1'b0;
        rst_n = 1'b0;

        reset_design_under_test();

        transmit_address_data(TEST_ADDR, TEST_DATA_WR);

        @(posedge clk);
        if (m_grant !== arbiter_grant || arbiter_req !== m_req ||
            bus_m_ready !== m_ready || bus_m_rw !== m_rw)
            $error("[%0t] Control pass-through checks failed", $time);

        s_ack = 1'b1;
        s_split = 1'b1;
        @(posedge clk);
        if (m_ack !== s_ack || m_split_ack !== s_split)
            $error("[%0t] Target handshake pass-through failed", $time);
        s_ack = 1'b0;
        s_split = 1'b0;

        issue_read_addr(TEST_ADDR_RD1);
        drive_read_data(TEST_DATA_RD, -1, "early ACK before data");

        issue_read_addr(TEST_ADDR_RD2);
        drive_read_data(TEST_DATA_RD ^ 8'hFF, 0, "ACK same cycle as data");

        issue_read_addr(TEST_ADDR_RD3);
        drive_read_data(TEST_DATA_RD ^ 8'h5A, 2, "ACK after data");

        if (count_read_valid != 3)
            $error("[%0t] Expected three read-valid pulses, observed %0d", $time, count_read_valid);

        repeat (5) @(posedge clk);
        $display("[%0t] m_port testbench completed.", $time);
        $finish;
    end
endmodule
