import bus_bridge_pkg::*;

module bus_bridge #(
    parameter logic [15:0] BRIDGE_BASE_ADDR = 16'h8000,
    parameter int unsigned TARGET0_SIZE = 16'd2048,
    parameter int unsigned TARGET1_SIZE = 16'd4096,
    parameter int unsigned TARGET2_SIZE = 16'd4096,
    parameter logic [15:0] BUSB_TARGET0_BASE = 16'h0000,
    parameter logic [15:0] BUSB_TARGET1_BASE = 16'h4000,
    parameter logic [15:0] BUSB_TARGET2_BASE = 16'h8000
)(
    input  logic clk,
    input  logic rst_n,
    input  logic split_grant,
    input  logic [15:0] s_address_in,
    input  logic s_address_in_valid,
    input  logic [7:0] s_data_in,
    input  logic s_data_in_valid,
    input  logic s_rw,
    output logic split_req,
    output logic [7:0] s_data_out,
    output logic s_data_out_valid,
    output logic s_ack,
    output logic s_split_ack,
    output logic s_ready,
    output logic [7:0] split_s_last_write,
    output logic m_req,
    output logic [15:0] m_address_out,
    output logic m_address_out_valid,
    output logic [7:0] m_data_out,
    output logic m_data_out_valid,
    output logic m_rw,
    output logic m_ready,
    input  logic m_grant,
    input  logic [7:0] m_data_in,
    input  logic m_data_in_valid,
    input  logic m_ack,
    input  logic m_split_ack
);

    logic serial_request;
    logic serial_response;

    bus_bridge_s_uart_wrapper #(
        .BRIDGE_BASE_ADDR(BRIDGE_BASE_ADDR),
        .TARGET0_SIZE(TARGET0_SIZE),
        .TARGET1_SIZE(TARGET1_SIZE),
        .TARGET2_SIZE(TARGET2_SIZE),
        .BUSB_TARGET0_BASE(BUSB_TARGET0_BASE),
        .BUSB_TARGET1_BASE(BUSB_TARGET1_BASE),
        .BUSB_TARGET2_BASE(BUSB_TARGET2_BASE)
    ) u_bridge_slave (
        .clk(clk),
        .rst_n(rst_n),
        .split_grant(split_grant),
        .s_address_in(s_address_in),
        .s_address_in_valid(s_address_in_valid),
        .s_data_in(s_data_in),
        .s_data_in_valid(s_data_in_valid),
        .s_rw(s_rw),
        .split_req(split_req),
        .s_data_out(s_data_out),
        .s_data_out_valid(s_data_out_valid),
        .s_ack(s_ack),
        .s_split_ack(s_split_ack),
        .s_ready(s_ready),
        .split_s_last_write(split_s_last_write),
        .uart_tx(serial_request),
        .uart_rx(serial_response)
    );

    bus_bridge_master_uart_wrapper u_bridge_master (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(serial_request),
        .uart_tx(serial_response),
        .m_req(m_req),
        .m_address_out(m_address_out),
        .m_address_out_valid(m_address_out_valid),
        .m_data_out(m_data_out),
        .m_data_out_valid(m_data_out_valid),
        .m_rw(m_rw),
        .m_ready(m_ready),
        .m_grant(m_grant),
        .m_data_in(m_data_in),
        .m_data_in_valid(m_data_in_valid),
        .m_ack(m_ack),
        .m_split_ack(m_split_ack)
    );

endmodule
