import bus_bridge_pkg::*;

module bus_bridge_s_if #(
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
    output logic req_valid,
    input  logic req_ready,
    output bus_bridge_req_t req_payload,
    input  logic resp_valid,
    output logic resp_ready,
    input  bus_bridge_resp_t resp_payload
);

    localparam int unsigned SPAN_TOTAL = TARGET0_SIZE + TARGET1_SIZE + TARGET2_SIZE;

    typedef enum logic [2:0] {
        STATE_TGT_IDLE,
        STATE_TGT_WAIT_WR_DATA,
        STATE_TGT_SEND_REQUEST,
        STATE_TGT_WAIT_RESP,
        STATE_TGT_WAIT_RD_GRANT
    } bridge_s_state_t;

    bridge_s_state_t present_state;
    logic [15:0] address_busb_current;
    logic [7:0] data_write_current;
    logic is_write_current;
    logic uses_split_path_current;
    logic [7:0] data_read_pending;
    logic [7:0] data_write_inflight;
    bus_bridge_req_t buffer_request;

    function automatic logic [15:0] map_address_to_busb(
        input logic [15:0] address,
        output logic is_valid
    );
        int unsigned address_offset;
        logic [15:0] address_mapped;

        is_valid = 1'b0;
        address_mapped = 16'd0;
        if (address < BRIDGE_BASE_ADDR)
            return address_mapped;

        address_offset = int'(address) - int'(BRIDGE_BASE_ADDR);
        if (address_offset >= SPAN_TOTAL)
            return address_mapped;

        if (address_offset < TARGET0_SIZE) begin
            is_valid = 1'b1;
            address_mapped = BUSB_TARGET0_BASE + 16'(address_offset);
        end else if (address_offset < (TARGET0_SIZE + TARGET1_SIZE)) begin
            is_valid = 1'b1;
            address_mapped = BUSB_TARGET1_BASE + 16'(address_offset - TARGET0_SIZE);
        end else begin
            is_valid = 1'b1;
            address_mapped = BUSB_TARGET2_BASE + 16'(address_offset - TARGET0_SIZE - TARGET1_SIZE);
        end

        return address_mapped;
    endfunction

    assign s_ready = 1'b1;
    assign req_payload = buffer_request;
    assign resp_ready = (present_state == STATE_TGT_WAIT_RESP);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            present_state <= STATE_TGT_IDLE;
            req_valid <= 1'b0;
            split_req <= 1'b0;
            s_data_out <= '0;
            s_data_out_valid <= 1'b0;
            s_ack <= 1'b0;
            s_split_ack <= 1'b0;
            split_s_last_write <= '0;
            address_busb_current <= '0;
            data_write_current <= '0;
            is_write_current <= 1'b0;
            uses_split_path_current <= 1'b0;
            data_read_pending <= '0;
            data_write_inflight <= '0;
            buffer_request <= '0;
        end else begin
            s_data_out_valid <= 1'b0;
            s_ack <= 1'b0;
            s_split_ack <= 1'b0;

            case (present_state)
                STATE_TGT_IDLE: begin
                    split_req <= 1'b0;
                    if (s_address_in_valid) begin
                        logic valid_mapped;
                        logic [15:0] address_mapped;
                        int unsigned address_offset;
                        logic uses_split_now;

                        address_mapped = map_address_to_busb(s_address_in, valid_mapped);
                        address_busb_current <= address_mapped;
                        is_write_current <= s_rw;
                        data_write_current <= s_data_in;
                        address_offset = 0;
                        if (valid_mapped && (s_address_in >= BRIDGE_BASE_ADDR))
                            address_offset = int'(s_address_in) - int'(BRIDGE_BASE_ADDR);
                        uses_split_now = valid_mapped && (address_offset < TARGET0_SIZE);
                        uses_split_path_current <= uses_split_now;

                        s_split_ack <= 1'b1;

                        if (!valid_mapped) begin
                            s_ack <= 1'b1;
                            s_data_out <= 8'h00;
                            s_data_out_valid <= (s_rw == 1'b0);
                            present_state <= STATE_TGT_IDLE;
                        end else if (s_rw && !s_data_in_valid) begin
                            present_state <= STATE_TGT_WAIT_WR_DATA;
                        end else begin
                            present_state <= STATE_TGT_SEND_REQUEST;
                        end
                    end
                end

                STATE_TGT_WAIT_WR_DATA: begin
                    if (s_data_in_valid) begin
                        data_write_current <= s_data_in;
                        present_state <= STATE_TGT_SEND_REQUEST;
                    end
                end

                STATE_TGT_SEND_REQUEST: begin
                    buffer_request.is_write <= is_write_current;
                    buffer_request.addr <= address_busb_current;
                    buffer_request.write_data <= data_write_current;
                    req_valid <= 1'b1;

                    if (req_valid && req_ready) begin
                        req_valid <= 1'b0;
                        data_write_inflight <= data_write_current;
                        present_state <= STATE_TGT_WAIT_RESP;
                    end
                end

                STATE_TGT_WAIT_RESP: begin
                    split_req <= 1'b0;
                    if (resp_valid && resp_ready) begin
                        if (resp_payload.is_write) begin
                            s_ack <= 1'b1;
                            split_s_last_write <= data_write_inflight;
                            present_state <= STATE_TGT_IDLE;
                        end else if (uses_split_path_current) begin
                            data_read_pending <= resp_payload.read_data;
                            split_req <= 1'b1;
                            present_state <= STATE_TGT_WAIT_RD_GRANT;
                        end else begin
                            s_data_out <= resp_payload.read_data;
                            s_data_out_valid <= 1'b1;
                            s_ack <= 1'b1;
                            split_req <= 1'b0;
                            present_state <= STATE_TGT_IDLE;
                        end
                    end
                end

                STATE_TGT_WAIT_RD_GRANT: begin
                    split_req <= 1'b1;
                    if (split_grant) begin
                        split_req <= 1'b0;
                        s_data_out <= data_read_pending;
                        s_data_out_valid <= 1'b1;
                        s_ack <= 1'b1;
                        present_state <= STATE_TGT_IDLE;
                    end
                end

                default: present_state <= STATE_TGT_IDLE;
            endcase

        end
    end
endmodule
