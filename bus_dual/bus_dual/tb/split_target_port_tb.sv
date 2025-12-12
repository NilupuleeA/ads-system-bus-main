`timescale 1ns/1ps

module split_s_port_tb;
    // Clock and reset
    logic clk;
    logic rst_n;

    // Target-facing stimulus
    logic split_req;
    logic arbiter_grant;
    logic [7:0] s_data_out;
    logic s_data_out_valid;
    logic s_rw;
    logic s_ready;
    logic s_split_ack;
    logic s_ack;
    logic bus_data_in_valid;
    logic bus_data_in;
    logic bus_mode;

    // DUT outputs
    logic bus_data_out;
    logic split_grant;
    logic [7:0] s_data_in;
    logic s_data_in_valid;
    logic [15:0] s_address_in;
    logic s_address_in_valid;
    logic bus_data_out_valid;
    logic arbiter_split_req;
    logic split_ack;
    logic bus_s_ready;
    logic bus_s_rw;
    logic bus_split_ack;
    logic bus_s_ack;
    logic decoder_valid;

    localparam bit [7:0] TEST_WRITE_DATA = 8'hC5;
    localparam bit [7:0] TEST_READ_DATA  = 8'h2F;
    localparam bit [15:0] TEST_READ_ADDR = 16'h1234;

    split_s_port dut (
        .clk(clk),
        .rst_n(rst_n),
        .split_req(split_req),
        .arbiter_grant(arbiter_grant),
        .s_data_out(s_data_out),
        .s_data_out_valid(s_data_out_valid),
        .s_rw(s_rw),
        .s_ready(s_ready),
        .s_split_ack(s_split_ack),
        .s_ack(s_ack),
        .decoder_valid(decoder_valid),
        .bus_data_in_valid(bus_data_in_valid),
        .bus_data_in(bus_data_in),
        .bus_mode(bus_mode),
        .bus_data_out(bus_data_out),
        .split_grant(split_grant),
        .s_data_in(s_data_in),
        .s_data_in_valid(s_data_in_valid),
        .s_address_in(s_address_in),
        .s_address_in_valid(s_address_in_valid),
        .bus_data_out_valid(bus_data_out_valid),
        .arbiter_split_req(arbiter_split_req),
        .split_ack(split_ack),
        .bus_s_ready(bus_s_ready),
        .bus_s_rw(bus_s_rw),
        .bus_split_ack(bus_split_ack),
        .bus_s_ack(bus_s_ack)
    );

    // Clock generation (50 MHz)
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    task automatic reset_design_under_test;
        begin
            rst_n = 1'b0;
            repeat (4) @(posedge clk);
            rst_n = 1'b1;
            @(posedge clk);
        end
    endtask

    task automatic transmit_write_byte(input bit [7:0] data);
        bit [7:0] bits_captured;
        int idx;

        bits_captured = '0;
        idx = 0;

        s_rw = 1'b1;
        s_data_out = data;
        s_data_out_valid = 1'b1;
        @(posedge clk);
        s_data_out_valid = 1'b0;

        while (idx < 8) begin
            @(posedge clk);
            if (bus_data_out_valid) begin
                bits_captured[idx] = bus_data_out;
                idx++;
            end
        end

        if (bits_captured !== data) begin
            $error("[%0t] Target write serialisation mismatch. Expected %h, got %h", $time, data, bits_captured);
        end else begin
            $display("[%0t] Target write serialisation OK (%h)", $time, bits_captured);
        end

        repeat (2) @(posedge clk);
    endtask

    task automatic transmit_address_stream(input bit [15:0] addr);
        bus_mode = 1'b0;
        bus_data_in_valid = 1'b0;
        @(posedge clk);

        for (int i = 0; i < 16; i++) begin
            bus_data_in = addr[i];
            bus_data_in_valid = 1'b1;
            @(posedge clk);
        end

        bus_data_in_valid = 1'b0;
        bus_data_in = 1'b0;
        @(posedge clk);
    endtask

    task automatic transmit_data_byte_stream(input bit [7:0] data);
        bus_mode = 1'b1;

        for (int i = 0; i < 8; i++) begin
            bus_data_in = data[i];
            bus_data_in_valid = 1'b1;
            @(posedge clk);
        end

        bus_data_in_valid = 1'b0;
        bus_data_in = 1'b0;
        @(posedge clk);
    endtask

    task automatic execute_bus_transaction(input bit [15:0] addr, input bit [7:0] data);
        transmit_address_stream(addr);

        if (s_address_in_valid || s_data_in_valid)
            $error("[%0t] Valids should not assert before full transaction", $time);

        transmit_data_byte_stream(data);

        wait (s_address_in_valid && s_data_in_valid);

        if (s_address_in !== addr)
            $error("[%0t] Address capture mismatch. Expected %h, got %h", $time, addr, s_address_in);
        else
            $display("[%0t] Address capture OK (%h)", $time, s_address_in);

        if (s_data_in !== data)
            $error("[%0t] Data capture mismatch. Expected %h, got %h", $time, data, s_data_in);
        else
            $display("[%0t] Data capture OK (%h)", $time, s_data_in);

        @(posedge clk);

        if (s_address_in_valid || s_data_in_valid)
            $error("[%0t] Valids should deassert after single pulse", $time);
    endtask

    // Count read-valid pulses for sanity
    int count_data_valid;
    int count_address_valid;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count_data_valid <= 0;
        else if (s_data_in_valid)
            count_data_valid <= count_data_valid + 1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count_address_valid <= 0;
        else if (s_address_in_valid)
            count_address_valid <= count_address_valid + 1;
    end

    initial begin
        split_req = 1'b0;
        arbiter_grant = 1'b0;
        s_data_out = '0;
        s_data_out_valid = 1'b0;
        s_rw = 1'b0;
        s_ready = 1'b0;
        s_split_ack = 1'b0;
        s_ack = 1'b0;
        bus_data_in_valid = 1'b0;
        bus_data_in = 1'b0;
        bus_mode = 1'b0;
        rst_n = 1'b0;
        decoder_valid = 1'b1;

        reset_design_under_test();

        split_req = 1'b1;
        arbiter_grant = 1'b1;
        s_ready = 1'b1;
        s_split_ack = 1'b1;
        s_ack = 1'b1;
        @(posedge clk);
        if (split_grant !== arbiter_grant || arbiter_split_req !== split_req ||
            bus_s_ready !== s_ready || bus_s_rw !== s_rw ||
            bus_split_ack !== s_split_ack || bus_s_ack !== s_ack) begin
            $error("[%0t] Control pass-through checks failed", $time);
        end
        s_split_ack = 1'b0;
        s_ack = 1'b0;

        transmit_write_byte(TEST_WRITE_DATA);
        execute_bus_transaction(TEST_READ_ADDR, TEST_READ_DATA);

        if (count_data_valid != 1)
            $error("[%0t] Expected exactly one data-valid pulse, observed %0d", $time, count_data_valid);

        if (count_address_valid != 1)
            $error("[%0t] Expected exactly one address-valid pulse, observed %0d", $time, count_address_valid);

        repeat (5) @(posedge clk);
        $display("[%0t] split_s_port testbench completed.", $time);
        $finish;
    end

endmodule
