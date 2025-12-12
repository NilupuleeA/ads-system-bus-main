import bus_bridge_pkg::*;

module bus_bridge_master_if(
    input  logic clk,
    input  logic rst_n,
    input  logic req_valid,
    output logic req_ready,
    input  bus_bridge_req_t req_payload,
    output logic resp_valid,
    input  logic resp_ready,
    output bus_bridge_resp_t resp_payload,
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

    typedef enum logic [1:0] {
        BI_IDLE,
        BI_SEND,
        BI_WAIT_ACK,
        BI_RESP_HOLD
    } master_state_t;

    master_state_t state;
    bus_bridge_req_t active_req;
    bus_bridge_resp_t response_buffer;
    logic m_req_reg;
    logic m_address_valid_reg;
    logic m_data_valid_reg;
    logic m_rw_reg;
    logic address_captured;
    logic data_captured;
    logic [7:0] read_data_buffer;
    logic read_data_valid;
    logic resp_valid_reg;
    logic pending_read_ack;

    assign req_ready = (state == BI_IDLE);
    assign m_address_out = active_req.addr;
    assign m_address_out_valid = m_address_valid_reg;
    assign m_data_out = active_req.write_data;
    assign m_data_out_valid = m_data_valid_reg;
    assign m_req = m_req_reg;
    assign m_rw = m_rw_reg;
    assign m_ready = 1'b1;
    assign resp_valid = resp_valid_reg;
    assign resp_payload = response_buffer;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= BI_IDLE;
            active_req <= '0;
            response_buffer <= '0;
            m_req_reg <= 1'b0;
            m_address_valid_reg <= 1'b0;
            m_data_valid_reg <= 1'b0;
            m_rw_reg <= 1'b1;
            address_captured <= 1'b0;
            data_captured <= 1'b0;
            read_data_buffer <= '0;
            read_data_valid <= 1'b0;
            resp_valid_reg <= 1'b0;
            pending_read_ack <= 1'b0;
        end else begin
            if (m_data_in_valid) begin
                read_data_buffer <= m_data_in;
                read_data_valid <= 1'b1;
            end

            case (state)
                BI_IDLE: begin
                    m_req_reg <= 1'b0;
                    m_address_valid_reg <= 1'b0;
                    m_data_valid_reg <= 1'b0;
                    resp_valid_reg <= 1'b0;
                    read_data_valid <= 1'b0;
                    pending_read_ack <= 1'b0;
                    address_captured <= 1'b0;
                    data_captured <= 1'b0;
                    if (req_valid) begin
                        active_req <= req_payload;
                        m_req_reg <= 1'b1;
                        m_rw_reg <= req_payload.is_write;
                        m_address_valid_reg <= 1'b1;
                        m_data_valid_reg <= req_payload.is_write;
                        address_captured <= 1'b0;
                        data_captured <= ~req_payload.is_write;
                        state <= BI_SEND;
                    end
                end

                BI_SEND: begin
                    if (!address_captured && m_grant && m_address_valid_reg) begin
                        address_captured <= 1'b1;
                        m_address_valid_reg <= 1'b0;
                    end

                    if (active_req.is_write && !data_captured && m_grant && m_data_valid_reg) begin
                        data_captured <= 1'b1;
                        m_data_valid_reg <= 1'b0;
                    end

                    if (address_captured && data_captured) begin
                        state <= BI_WAIT_ACK;
                    end
                end

                BI_WAIT_ACK: begin
                    if (m_split_ack)
                        m_req_reg <= 1'b0;

                    if (m_ack) begin
                        m_req_reg <= 1'b0;
                        if (active_req.is_write || read_data_valid) begin
                            response_buffer.is_write <= active_req.is_write;
                            response_buffer.read_data <= active_req.is_write ? 8'h00 : read_data_buffer;
                            resp_valid_reg <= 1'b1;
                            pending_read_ack <= 1'b0;
                            if (!active_req.is_write)
                                read_data_valid <= 1'b0;
                            state <= BI_RESP_HOLD;
                        end else begin
                            pending_read_ack <= 1'b1;
                        end
                    end

                    if (!active_req.is_write && pending_read_ack && read_data_valid) begin
                        response_buffer.is_write <= 1'b0;
                        response_buffer.read_data <= read_data_buffer;
                        resp_valid_reg <= 1'b1;
                        pending_read_ack <= 1'b0;
                        read_data_valid <= 1'b0;
                        state <= BI_RESP_HOLD;
                    end
                end

                BI_RESP_HOLD: begin
                    if (resp_ready) begin
                        resp_valid_reg <= 1'b0;
                        state <= BI_IDLE;
                    end
                end

                default: state <= BI_IDLE;
            endcase
        end
    end
endmodule
