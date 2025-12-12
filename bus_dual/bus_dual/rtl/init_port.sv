module m_port(
    input logic clk,
    input logic rst_n,
    input logic m_req,
    input logic arbiter_grant,
    input logic [7:0] m_data_out,
    input logic m_data_out_valid,
    input logic [15:0] m_address_out,
    input logic m_address_out_valid,
    input logic m_rw, // 1 for write, 0 for read
    input logic m_ready,
    input logic s_split,
    input logic s_ack,
    input logic bus_data_in_valid,
    input logic bus_data_in,
    output logic bus_data_out,
    output logic m_grant,
    output logic [7:0] m_data_in,
    output logic m_data_in_valid,
    output logic bus_data_out_valid,
    output logic arbiter_req,
    output logic bus_mode, // 1 for data, 0 for address
    output logic m_ack,
    output logic bus_m_ready,
    output logic bus_m_rw,
    output logic m_split_ack
);

assign m_grant = arbiter_grant;
assign arbiter_req = m_req;
assign bus_m_rw = m_rw;
assign bus_m_ready = m_ready;
logic reg_ack_init;
logic pending_ack_read;
logic pending_read_data;
logic [7:0] buffer_read_data;

assign m_ack = reg_ack_init;
assign m_split_ack = s_split;

logic [15:0] shift_tx;
logic [4:0] remaining_tx_bits;
logic active_tx;
logic [7:0] shift_rx;
logic [2:0] count_rx_bit;
logic [15:0] address_pending;
logic pending_addr;
logic [7:0] data_pending;
logic pending_data;
logic is_read_addr;
logic expected_read_data;
logic ready_rx_byte;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_tx <= '0;
        remaining_tx_bits <= '0;
        active_tx <= 1'b0;
        bus_data_out <= 1'b0;
        bus_data_out_valid <= 1'b0;
        address_pending <= '0;
        pending_addr <= 1'b0;
        data_pending <= '0;
        pending_data <= 1'b0;
        is_read_addr <= 1'b0;
        expected_read_data <= 1'b0;
        bus_mode <= 1'b0;
    end else begin
        bus_data_out_valid <= 1'b0;

        if (ready_rx_byte)
            expected_read_data <= 1'b0;

        if (arbiter_grant && m_req) begin
            if (m_address_out_valid) begin
                address_pending <= m_address_out;
                pending_addr <= 1'b1;
                is_read_addr <= (m_rw == 1'b0);
            end

            if (m_data_out_valid) begin
                data_pending <= m_data_out;
                pending_data <= 1'b1;
            end
        end

        if (active_tx) begin
            bus_data_out <= shift_tx[0];
            bus_data_out_valid <= 1'b1;
            shift_tx <= {1'b0, shift_tx[15:1]};

            if (remaining_tx_bits == 5'd1) begin
                active_tx <= 1'b0;
                remaining_tx_bits <= '0;
            end else begin
                remaining_tx_bits <= remaining_tx_bits - 5'd1;
            end
        end else begin
            if (pending_addr) begin
                shift_tx <= address_pending;
                remaining_tx_bits <= 5'd16;
                active_tx <= 1'b1;
                bus_mode <= 1'b0;
                pending_addr <= 1'b0;
                expected_read_data <= is_read_addr;
            end else if (pending_data) begin
                shift_tx <= {8'd0, data_pending};
                remaining_tx_bits <= 5'd8;
                active_tx <= 1'b1;
                bus_mode <= 1'b1;
                pending_data <= 1'b0;
                expected_read_data <= 1'b0;
            end else begin
                bus_mode <= expected_read_data ? 1'b1 : 1'b0;
            end
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    logic data_complete_now;

    if (!rst_n) begin
        shift_rx <= '0;
        count_rx_bit <= '0;
        m_data_in <= '0;
        m_data_in_valid <= 1'b0;
        ready_rx_byte <= 1'b0;
        reg_ack_init <= 1'b0;
        pending_ack_read <= 1'b0;
        pending_read_data <= 1'b0;
        buffer_read_data <= '0;
    end else begin
        logic valid_data_now;
        logic [7:0] value_data_now;
        logic now_release_data;
        logic [7:0] value_release_data;

        valid_data_now = 1'b0;
        value_data_now = '0;
        now_release_data = 1'b0;
        value_release_data = buffer_read_data;
        m_data_in_valid <= 1'b0;
        ready_rx_byte <= 1'b0;
        reg_ack_init <= 1'b0;

        // Only sample the shared bus when the master is not actively driving.
        if (bus_data_in_valid && !active_tx) begin
            logic [7:0] next_rx;
            next_rx = shift_rx;
            next_rx[count_rx_bit] = bus_data_in;

            if (count_rx_bit == 3'd7) begin
                count_rx_bit <= 3'd0;
                shift_rx <= '0;
                ready_rx_byte <= 1'b1;
                valid_data_now = 1'b1;
                value_data_now = next_rx;

                if (expected_read_data || pending_ack_read || pending_read_data) begin
                    buffer_read_data <= next_rx;
                    pending_read_data <= 1'b1;
                end else begin
                    m_data_in <= next_rx;
                    m_data_in_valid <= 1'b1;
                end
            end else begin
                count_rx_bit <= count_rx_bit + 3'd1;
                shift_rx <= next_rx;
            end
        end

        // Ack handling: pair read data with ACK when both are available.
        if (s_ack) begin
            if (valid_data_now || pending_read_data || pending_ack_read || expected_read_data) begin
                if (valid_data_now) begin
                    now_release_data = 1'b1;
                    value_release_data = value_data_now;
                    reg_ack_init <= 1'b1;
                    pending_read_data <= 1'b0;
                    pending_ack_read <= 1'b0;
                end else if (pending_read_data) begin
                    now_release_data = 1'b1;
                    value_release_data = buffer_read_data;
                    reg_ack_init <= 1'b1;
                    pending_read_data <= 1'b0;
                    pending_ack_read <= 1'b0;
                end else begin
                    pending_ack_read <= 1'b1;
                end
            end else begin
                reg_ack_init <= 1'b1;
            end
        end

        if (!s_ack && pending_ack_read && valid_data_now) begin
            now_release_data = 1'b1;
            value_release_data = value_data_now;
            reg_ack_init <= 1'b1;
            pending_ack_read <= 1'b0;
            pending_read_data <= 1'b0;
        end

        if (now_release_data) begin
            m_data_in <= value_release_data;
            m_data_in_valid <= 1'b1;
        end
    end
end

endmodule
