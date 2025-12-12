`timescale 1ns/1ps

module system_top (
    input  logic        clk,
    input  logic        btn_reset,
    input  logic        btn_trigger,
    input  logic        btn_trigger2,
    output logic [7:0]  leds
);
    // Synchronise push-button inputs and derive clean control pulses.
    logic ff1_reset_sync;
    logic ff2_reset_sync;
    always_ff @(posedge clk) begin
        ff1_reset_sync <= btn_reset;
        ff2_reset_sync <= ff1_reset_sync;
    end

    logic rst_n;
    assign rst_n = ~ff2_reset_sync;

    logic ff1_trigger_sync;
    logic ff2_trigger_sync;
    always_ff @(posedge clk) begin
        ff1_trigger_sync <= btn_trigger;
        ff2_trigger_sync <= ff1_trigger_sync;
    end

    logic prev_trigger_sync;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_trigger_sync <= 1'b0;
        end else begin
            prev_trigger_sync <= ff2_trigger_sync;
        end
    end

    logic pulse_trigger_m1;
    assign pulse_trigger_m1 = ff2_trigger_sync & ~prev_trigger_sync;

    logic ff1_trigger2_sync;
    logic ff2_trigger2_sync;
    always_ff @(posedge clk) begin
        ff1_trigger2_sync <= btn_trigger2;
        ff2_trigger2_sync <= ff1_trigger2_sync;
    end

    logic prev_trigger2_sync;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_trigger2_sync <= 1'b0;
        end else begin
            prev_trigger2_sync <= ff2_trigger2_sync;
        end
    end

    logic pulse_trigger_m2;
    assign pulse_trigger_m2 = ff2_trigger2_sync & ~prev_trigger2_sync;

    // Local parameters describing address map expectations.
    localparam bit [15:0] TARGET1_BASE_ADDR = 16'h0000;
    localparam int unsigned TARGET1_SIZE = 16'd2048;
    localparam bit [15:0] TARGET2_BASE_ADDR = 16'h4000;
    localparam int unsigned TARGET2_SIZE = 16'd4096;
    localparam bit [15:0] TARGET3_BASE_ADDR = 16'h8000;
    localparam int unsigned TARGET3_SIZE = 16'd4096;
    localparam bit [15:0] TARGET2_ADDR = TARGET2_BASE_ADDR + 16'h0004;
    localparam bit [15:0] TARGET3_ADDR = TARGET3_BASE_ADDR + 16'h0004;
    localparam bit [7:0]  TARGET3_INIT_WRITE = 8'hA5;
    localparam bit [7:0]  TARGET2_INIT_WRITE = 8'h5A;

    // Initiator 1 wiring (active via push button trigger).
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

    // Initiator 2 remains instantiated for completeness but stays idle.
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

    // Target 1 interface wires.
    logic [15:0]  s1_address_in;
    logic         s1_address_in_valid;
    logic [7:0]   s1_data_in;
    logic         s1_data_in_valid;
    logic         s1_rw;
    logic [7:0]   s1_data_out;
    logic         s1_data_out_valid;
    logic         s1_ack;
    logic         s1_ready;

    // Target 2 interface wires.
    logic [15:0]  s2_address_in;
    logic         s2_address_in_valid;
    logic [7:0]   s2_data_in;
    logic         s2_data_in_valid;
    logic         s2_rw;
    logic [7:0]   s2_data_out;
    logic         s2_data_out_valid;
    logic         s2_ack;
    logic         s2_ready;

    // Split slave (slave 3) interface wires.
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
    logic [7:0]   split_s_last_write;

    // Initiator instantiations.
    master #(
        .WRITE_ADDR(TARGET3_ADDR),
        .READ_ADDR(TARGET3_ADDR),
        .MEM_INIT_DATA(TARGET3_INIT_WRITE)
    ) u_master_1 (
        .clk(clk),
        .rst_n(rst_n),
        .trigger(pulse_trigger_m1),
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
        .done(),
        .read_data_value()
    );

    master #(
        .WRITE_ADDR(TARGET3_ADDR),
        .READ_ADDR(TARGET3_ADDR),
        .MEM_INIT_DATA(TARGET2_INIT_WRITE)
    ) u_master_2 (
        .clk(clk),
        .rst_n(rst_n),
        .trigger(pulse_trigger_m2),
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
        .done(),
        .read_data_value()
    );

    // Target instantiations.
    slave #(
        .INTERNAL_ADDR_BITS(11)
    ) u_s_1 (
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
        .s_last_write()
    );

    slave #(
        .INTERNAL_ADDR_BITS(11)
    ) u_s_2 (
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
        .s_last_write()
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

    // Bus interconnect.
    bus #(
        .TARGET1_BASE(TARGET1_BASE_ADDR),
        .TARGET1_SIZE(TARGET1_SIZE),
        .TARGET2_BASE(TARGET2_BASE_ADDR),
        .TARGET2_SIZE(TARGET2_SIZE),
        .TARGET3_BASE(TARGET3_BASE_ADDR),
        .TARGET3_SIZE(TARGET3_SIZE)
    ) u_bus (
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

    // Drive LEDs with the most recent write observed by the split slave.
    assign leds = split_s_last_write;

endmodule
