`timescale 1ns/1ps

module system_top_bidirectional #(
    parameter bit BOARD_ID = 0 // 0 for Board A, 1 for Board B
)(
    input  logic       clk,
    input  logic       btn_reset,
    input  logic       btn_trigger,
    
    // UART Channel 1: Initiator Side (Sending Requests, Receiving Responses)
    output logic       uart_tx_req,
    input  logic       uart_rx_resp,

    // UART Channel 2: Target Side (Receiving Requests, Sending Responses)
    input  logic       uart_rx_req,
    output logic       uart_tx_resp,

    output logic [7:0] leds
);
    // ========================================================================
    // Address Map Configuration
    // ========================================================================
    // Board A (BOARD_ID = 0):
    // - Local LED Target:  0x4000 - 0x4FFF (Base 0x4000)
    // - Bridge (Remote):   0x8000 - 0xBFFF (Base 0x8000) -> Maps to Board B's Local LED
    //
    // Board B (BOARD_ID = 1):
    // - Bridge (Remote):   0x4000 - 0x7FFF (Base 0x4000) -> Maps to Board A's Local LED
    // - Local LED Target:  0x8000 - 0xBFFF (Base 0x8000)
//    assign leds[0] = uart_rx_req != uart_tx_resp;
//	 assign leds[1] = uart_rx_resp != uart_tx_req;
    localparam logic [15:0] BRIDGE_BASE_ADDR = (BOARD_ID == 0) ? 16'h8000 : 16'h4000;
    localparam logic [15:0] LOCAL_LED_BASE   = (BOARD_ID == 0) ? 16'h4000 : 16'h8000;
    localparam logic [15:0] REMOTE_LED_ADDR  = BRIDGE_BASE_ADDR + 16'h0004;
    localparam logic [15:0] LOCAL_LED_ADDR   = LOCAL_LED_BASE + 16'h0004;

    localparam int unsigned BRIDGE_SIZE = 16'd8192; // Large enough to cover the remote space
    localparam int unsigned LOCAL_SIZE  = 16'd4096;

    logic ff1_reset_sync, ff2_reset_sync;
    always_ff @(posedge clk) begin
        ff1_reset_sync <= btn_reset;
        ff2_reset_sync <= ff1_reset_sync;
    end
    logic rst_n;
    assign rst_n = ff2_reset_sync;

    logic ff1_trigger_sync, ff2_trigger_sync, prev_trigger_sync;
    always_ff @(posedge clk) begin
        ff1_trigger_sync <= btn_trigger;
        ff2_trigger_sync <= ff1_trigger_sync;
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) prev_trigger_sync <= 1'b0;
        else prev_trigger_sync <= ff2_trigger_sync;
    end
    logic pulse_trigger_m1;
    assign pulse_trigger_m1 = ff2_trigger_sync & ~prev_trigger_sync;

    logic m1_req, m1_address_out_valid, m1_data_out_valid, m1_rw, m1_ready, m1_grant, m1_data_in_valid, m1_ack, m1_split_ack;
    logic [15:0] m1_address_out;
    logic [7:0] m1_data_out, m1_data_in;

    logic m2_req, m2_address_out_valid, m2_data_out_valid, m2_rw, m2_ready, m2_grant, m2_data_in_valid, m2_ack, m2_split_ack;
    logic [15:0] m2_address_out;
    logic [7:0] m2_data_out, m2_data_in;

    logic s1_ready, s1_ack, s1_data_out_valid, s1_address_in_valid, s1_data_in_valid, s1_rw;
    logic [15:0] s1_address_in;
    logic [7:0] s1_data_out, s1_data_in;

    logic s2_ready, s2_ack, s2_data_out_valid, s2_address_in_valid, s2_data_in_valid, s2_rw;
    logic [15:0] s2_address_in;
    logic [7:0] s2_data_out, s2_data_in;
    logic [7:0] local_led_val;

    logic split_s_ready, split_s_ack, split_s_split_ack, split_s_data_out_valid, split_s_req, split_s_grant;
    logic split_s_address_in_valid, split_s_data_in_valid, split_s_rw;
    logic [15:0] split_s_address_in;
    logic [7:0] split_s_data_out, split_s_data_in;

    master #(
        .WRITE_ADDR(REMOTE_LED_ADDR),
        .READ_ADDR(REMOTE_LED_ADDR),
        .MEM_INIT_DATA(8'h7A)
    ) u_master_btn (
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

    bus_bridge_master_uart_wrapper u_bridge_master (
        .clk(clk), .rst_n(rst_n),
        .uart_rx(uart_rx_req),
        .uart_tx(uart_tx_resp),
        .m_req(m2_req),
        .m_address_out(m2_address_out),
        .m_address_out_valid(m2_address_out_valid),
        .m_data_out(m2_data_out),
        .m_data_out_valid(m2_data_out_valid),
        .m_rw(m2_rw),
        .m_ready(m2_ready),
        .m_grant(m2_grant),
        .m_data_in(m2_data_in),
        .m_data_in_valid(m2_data_in_valid),
        .m_ack(m2_ack),
        .m_split_ack(m2_split_ack)
    );

    bus_bridge_s_uart_wrapper #(
        .BRIDGE_BASE_ADDR(BRIDGE_BASE_ADDR),
        .TARGET0_SIZE(BRIDGE_SIZE),
        .TARGET1_SIZE(0),
        .TARGET2_SIZE(0),
        .BUSB_TARGET0_BASE(BRIDGE_BASE_ADDR), 
        .BUSB_TARGET1_BASE(16'h0000),
        .BUSB_TARGET2_BASE(16'h0000)
    ) u_bridge_slave (
        .clk(clk), .rst_n(rst_n),
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
        .split_s_last_write(), 
        .uart_tx(uart_tx_req),
        .uart_rx(uart_rx_resp)
    );

    slave #(
        .INTERNAL_ADDR_BITS(12)
    ) u_s_leds (
        .clk(clk), .rst_n(rst_n),
        .s_address_in(s2_address_in),
        .s_address_in_valid(s2_address_in_valid),
        .s_data_in(s2_data_in),
        .s_data_in_valid(s2_data_in_valid),
        .s_rw(s2_rw),
        .s_data_out(s2_data_out),
        .s_data_out_valid(s2_data_out_valid),
        .s_ack(s2_ack),
        .s_ready(s2_ready),
        .s_last_write(local_led_val)
    );
    
    assign leds = local_led_val;

    slave #( .INTERNAL_ADDR_BITS(11) ) u_s_dummy (
        .clk(clk), .rst_n(rst_n),
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

    bus #(
        .TARGET1_BASE(16'h0000),
        .TARGET1_SIZE(16'd2048),
        .TARGET2_BASE(LOCAL_LED_BASE),
        .TARGET2_SIZE(LOCAL_SIZE),
        .TARGET3_BASE(BRIDGE_BASE_ADDR),
        .TARGET3_SIZE(BRIDGE_SIZE)
    ) u_bus (
        .clk(clk), 
        .rst_n(rst_n),
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
        .s1_ready(s1_ready),
        .s1_ack(s1_ack),
        .s1_data_out(s1_data_out),
        .s1_data_out_valid(s1_data_out_valid),
        .s1_address_in(s1_address_in),
        .s1_address_in_valid(s1_address_in_valid),
        .s1_data_in(s1_data_in),
        .s1_data_in_valid(s1_data_in_valid),
        .s1_rw(s1_rw),
        .s2_ready(s2_ready),
        .s2_ack(s2_ack),
        .s2_data_out(s2_data_out),
        .s2_data_out_valid(s2_data_out_valid),
        .s2_address_in(s2_address_in),
        .s2_address_in_valid(s2_address_in_valid),
        .s2_data_in(s2_data_in),
        .s2_data_in_valid(s2_data_in_valid),
        .s2_rw(s2_rw),
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
endmodule
