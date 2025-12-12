`timescale 1ns/1ps

module system_integration_tb;
    // Clock and reset
    logic clk;
    logic rst_n;

    // Initiator stimulus
    logic m_req;
    logic [7:0] m_data_out;
    logic m_data_out_valid;
    logic [15:0] m_address_out;
    logic m_address_out_valid;
    logic m_rw;
    logic m_ready;
    logic s_split;
    logic s_ack;
    logic trigger;
    logic done;
    logic [7:0] read_data_value;

    // Initiator outputs / bus lines
    logic bus_serial;
    logic bus_serial_valid;
    logic bus_mode;
    logic m_grant;
    logic [7:0] m_data_in;
    logic m_data_in_valid;
    logic arbiter_req;
    logic m_ack;
    logic bus_m_ready;
    logic bus_m_rw;
    logic m_split_ack;

    // Connections to arbiter
    logic arbiter_grant;

    // Target port facing signals
    logic bus_data_out_from_slave;
    logic bus_data_out_valid_from_slave;
    logic [7:0] s_data_in;
    logic s_data_in_valid;
    logic [15:0] s_address_in;
    logic s_address_in_valid;
    logic bus_s_ready;
    logic bus_s_rw;
    logic bus_split_ack;
    logic bus_s_ack;
    logic arbiter_split_req;

    // Target core side signals
    logic split_req;
    logic split_grant;
    logic [7:0] s_data_out;
    logic s_data_out_valid;
    logic s_ready;
    logic s_split_ack;
    logic s_rw_dir;
    logic [7:0] split_s_last_write;

    // Address decoder outputs
    logic s_1_valid;
    logic s_2_valid;
    logic s_3_valid;
    logic [1:0] sel;
    logic [2:0] decoder_release_valids;

    // Constants for the scenario (choose address in Slave 3 range 1000 xxxx xxxx xxxx)
    localparam bit [15:0] TARGET3_ADDR = 16'h800A;
    localparam bit [7:0] TARGET_WRITE_DATA = 8'h5C;

    // Initiator core
    master #(
        .WRITE_ADDR(TARGET3_ADDR),
        .READ_ADDR(TARGET3_ADDR),
        .MEM_INIT_DATA(TARGET_WRITE_DATA)
    ) u_master (
        .clk(clk),
        .rst_n(rst_n),
        .trigger(trigger),
        .m_grant(m_grant),
        .m_ack(m_ack),
        .m_split_ack(m_split_ack),
        .m_data_in(m_data_in),
        .m_data_in_valid(m_data_in_valid),
        .m_req(m_req),
        .m_address_out(m_address_out),
        .m_address_out_valid(m_address_out_valid),
        .m_data_out(m_data_out),
        .m_data_out_valid(m_data_out_valid),
        .m_rw(m_rw),
        .m_ready(m_ready),
        .done(done),
        .read_data_value(read_data_value)
    );

    // Instantiate master port
    m_port u_m_port (
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
        .bus_data_in_valid(bus_data_out_valid_from_slave),
        .bus_data_in(bus_data_out_from_slave),
        .bus_data_out(bus_serial),
        .m_grant(m_grant),
        .m_data_in(m_data_in),
        .m_data_in_valid(m_data_in_valid),
        .bus_data_out_valid(bus_serial_valid),
        .arbiter_req(arbiter_req),
        .bus_mode(bus_mode),
        .m_ack(m_ack),
        .bus_m_ready(bus_m_ready),
        .bus_m_rw(bus_m_rw),
        .m_split_ack(m_split_ack)
    );

    // Instantiate split slave port (receives serial stream)
    split_s_port u_split_s_port (
        .clk(clk),
        .rst_n(rst_n),
        .split_req(split_req),
        .arbiter_grant(arbiter_grant),
        .s_data_out(s_data_out),
        .s_data_out_valid(s_data_out_valid),
        .s_rw(s_rw_dir),
        .s_ready(s_ready),
        .s_split_ack(s_split_ack),
        .s_ack(s_ack),
        .decoder_valid(s_3_valid),
        .bus_data_in_valid(bus_serial_valid),
        .bus_data_in(bus_serial),
        .bus_mode(bus_mode),
        .bus_data_out(bus_data_out_from_slave),
        .split_grant(split_grant),
        .s_data_in(s_data_in),
        .s_data_in_valid(s_data_in_valid),
        .s_address_in(s_address_in),
        .s_address_in_valid(s_address_in_valid),
        .bus_data_out_valid(bus_data_out_valid_from_slave),
        .arbiter_split_req(arbiter_split_req),
        .split_ack(),
        .bus_s_ready(bus_s_ready),
        .bus_s_rw(bus_s_rw),
        .bus_split_ack(bus_split_ack),
        .bus_s_ack(bus_s_ack)
    );

    assign s_split = bus_split_ack;
    assign s_rw_dir = bus_m_rw;

    split_s #(
        .INTERNAL_ADDR_BITS(12),
        .READ_LATENCY(4)
    ) u_split_s (
        .clk(clk),
        .rst_n(rst_n),
        .split_grant(split_grant),
        .s_address_in(s_address_in),
        .s_address_in_valid(s_address_in_valid),
        .s_data_in(s_data_in),
        .s_data_in_valid(s_data_in_valid),
        .s_rw(s_rw_dir),
        .split_req(split_req),
        .s_data_out(s_data_out),
        .s_data_out_valid(s_data_out_valid),
        .s_ack(s_ack),
        .s_split_ack(s_split_ack),
        .s_ready(s_ready),
        .split_s_last_write(split_s_last_write)
    );

    // Instantiate address decoder observing the same bus
    address_decoder u_address_decoder (
        .clk(clk),
        .rst_n(rst_n),
        .bus_data_in(bus_serial),
        .bus_data_in_valid(bus_serial_valid),
        .bus_mode(bus_mode),
        .release_valids(decoder_release_valids),
        .s_1_valid(s_1_valid),
        .s_2_valid(s_2_valid),
        .s_3_valid(s_3_valid),
        .sel(sel)
    );

    assign decoder_release_valids = {bus_s_ack, 2'b00};

    // Instantiate arbiter, only request/grant 1 used
    logic arbiter_grant_m1;
    logic arbiter_grant_split;

    arbiter u_arbiter (
        .clk(clk),
        .rst_n(rst_n),
        .req_m_1(arbiter_req),
        .req_m_2(1'b0),
        .req_split(arbiter_split_req),
        .grant_m_1(arbiter_grant_m1),
        .grant_m_2(),
        .grant_split(arbiter_grant_split),
        .sel()
    );

    assign arbiter_grant = arbiter_grant_m1 | arbiter_grant_split;

    // Clock generation (100 MHz)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic reset_design_under_test;
        begin
            rst_n = 1'b0;
            repeat (5) @(posedge clk);
            rst_n = 1'b1;
            @(posedge clk);
        end
    endtask

    bit flag_decoder_s3_write_seen;
    bit flag_decoder_s3_read_seen;
    bit flag_decoder_wrong_s_seen;
    bit flag_in_read_phase;
    int count_m_data_valid;
    int count_write_ack;
    int count_read_ack;
    int count_split_ack;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            flag_decoder_s3_write_seen <= 1'b0;
            flag_decoder_s3_read_seen <= 1'b0;
            flag_decoder_wrong_s_seen <= 1'b0;
            flag_in_read_phase <= 1'b0;
            count_m_data_valid <= 0;
        end else begin
            if (m_split_ack)
                flag_in_read_phase <= 1'b1;
            else if (done)
                flag_in_read_phase <= 1'b0;

            if (s_3_valid && sel == 2'b10) begin
                if (flag_in_read_phase)
                    flag_decoder_s3_read_seen <= 1'b1;
                else
                    flag_decoder_s3_write_seen <= 1'b1;
            end
            if (s_1_valid || s_2_valid || (s_3_valid && sel != 2'b10))
                flag_decoder_wrong_s_seen <= 1'b1;
            if (m_split_ack)
                count_m_data_valid <= 0;
            else if (m_data_in_valid)
                count_m_data_valid <= count_m_data_valid + 1;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_write_ack <= 0;
            count_read_ack <= 0;
            count_split_ack <= 0;
        end else begin
            if (bus_s_ack && bus_s_rw)
                count_write_ack <= count_write_ack + 1;
            else if (bus_s_ack && !bus_s_rw)
                count_read_ack <= count_read_ack + 1;

            if (bus_split_ack)
                count_split_ack <= count_split_ack + 1;
        end
    end

    // Display slave activity once both address and data arrive together
    always @(posedge clk) begin
        if (s_address_in_valid && s_data_in_valid) begin
            $display("[%0t] Target observed %s to addr %h with data %h", $time,
                     bus_s_rw ? "WRITE" : "READ",
                     s_address_in,
                     s_data_in);
        end
    end

    always @(posedge clk) begin
        if (m_data_in_valid) begin
            $display("[%0t] Initiator received data %h", $time, m_data_in);
        end
    end

    initial begin
        trigger = 1'b0;

        reset_design_under_test();

        @(posedge clk);
        trigger <= 1'b1;
        @(posedge clk);
        trigger <= 1'b0;

        wait (done);

        if (!flag_decoder_s3_write_seen)
            $error("Address decoder never asserted slave 3 valid during write phase");

        if (!flag_decoder_s3_read_seen)
            $error("Address decoder did not indicate slave 3 during read phase");

        if (flag_decoder_wrong_s_seen)
            $error("Address decoder asserted an unexpected slave selection");

        if (count_write_ack != 1)
            $error("Unexpected number of write ACK pulses: %0d", count_write_ack);

        if (count_read_ack != 1)
            $error("Unexpected number of read ACK pulses: %0d", count_read_ack);

        if (count_split_ack != 1)
            $error("Unexpected number of split acknowledgements: %0d", count_split_ack);

        if (count_m_data_valid != 1)
            $error("Initiator should have seen exactly one data-valid pulse during read, observed %0d", count_m_data_valid);

        if (read_data_value !== TARGET_WRITE_DATA)
            $error("Read data mismatch. Expected %h, got %h", TARGET_WRITE_DATA, read_data_value);

        repeat (5) @(posedge clk);

        $display("[%0t] System integration test completed.", $time);
        $finish;
    end

endmodule
