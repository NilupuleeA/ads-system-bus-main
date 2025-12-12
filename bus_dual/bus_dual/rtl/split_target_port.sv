module split_s_port(
    input logic clk,
    input logic rst_n,
    input logic split_req,
    input logic arbiter_grant,
    input logic [7:0] s_data_out,
    input logic s_data_out_valid,
    input logic s_rw, // 1 for write, 0 for read
    input logic s_ready,
    input logic s_split_ack,
    input logic s_ack,
    input logic decoder_valid,
    input logic bus_data_in_valid,
    input logic bus_data_in,
    input logic bus_mode, // 1 for data, 0 for address
    output logic bus_data_out,
    output logic split_grant,
    output logic [7:0] s_data_in,
    output logic s_data_in_valid,
    output logic [15:0] s_address_in,
    output logic s_address_in_valid,
    output logic bus_data_out_valid,
    output logic arbiter_split_req,
    output logic split_ack,
    output logic bus_s_ready,
    output logic bus_s_rw,
    output logic bus_split_ack,
    output logic bus_s_ack
);

assign split_grant = arbiter_grant;
assign arbiter_split_req = split_req;
assign bus_s_rw = s_rw;
assign bus_s_ready = s_ready;
assign bus_s_ack = s_ack;
assign bus_split_ack = s_split_ack;
assign split_ack = s_split_ack;

logic [7:0] shift_transmit;
logic [3:0] remaining_tx_bits;
logic active_transmit;
logic [15:0] shift_rx_addr;
logic [4:0] count_address_bits;
logic [15:0] buffer_addr;
logic pending_addr;
logic expect_data_addr;
logic [7:0] shift_rx_data;
logic [2:0] count_data_bits;
logic [7:0] buffer_data;
logic pending_data;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_transmit <= '0;
        remaining_tx_bits <= '0;
        active_transmit <= 1'b0;
        bus_data_out <= 1'b0;
        bus_data_out_valid <= 1'b0;
    end else begin
        bus_data_out_valid <= 1'b0;

        if (active_transmit) begin
            bus_data_out <= shift_transmit[0];
            bus_data_out_valid <= 1'b1;
            shift_transmit <= {1'b0, shift_transmit[7:1]};

            if (remaining_tx_bits == 4'd1) begin
                active_transmit <= 1'b0;
                remaining_tx_bits <= '0;
            end else begin
                remaining_tx_bits <= remaining_tx_bits - 4'd1;
            end
        end else if (s_data_out_valid) begin
            shift_transmit <= s_data_out;
            remaining_tx_bits <= 4'd8;
            active_transmit <= 1'b1;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_rx_addr <= '0;
        count_address_bits <= '0;
        buffer_addr <= '0;
        pending_addr <= 1'b0;
        expect_data_addr <= 1'b0;
        shift_rx_data <= '0;
        count_data_bits <= '0;
        buffer_data <= '0;
        pending_data <= 1'b0;
        s_address_in <= '0;
        s_address_in_valid <= 1'b0;
        s_data_in <= '0;
        s_data_in_valid <= 1'b0;
    end else begin
        s_address_in_valid <= 1'b0;
        s_data_in_valid <= 1'b0;

        if (pending_addr && decoder_valid) begin
            if (!expect_data_addr) begin
                s_address_in <= buffer_addr;
                s_data_in <= '0;
                s_address_in_valid <= 1'b1;
                pending_addr <= 1'b0;
                expect_data_addr <= 1'b0;
            end else if (pending_data) begin
                s_address_in <= buffer_addr;
                s_data_in <= buffer_data;
                s_address_in_valid <= 1'b1;
                s_data_in_valid <= 1'b1;
                pending_addr <= 1'b0;
                expect_data_addr <= 1'b0;
                pending_data <= 1'b0;
                buffer_data <= '0;
            end
        end

        if (pending_addr && !decoder_valid && !bus_data_in_valid && !bus_mode) begin
            pending_addr <= 1'b0;
            expect_data_addr <= 1'b0;
            pending_data <= 1'b0;
            buffer_data <= '0;
        end

        if (bus_data_in_valid && !active_transmit) begin
            if (!bus_mode && !pending_addr) begin
                logic [15:0] updated_addr;
                updated_addr = shift_rx_addr;
                updated_addr[count_address_bits] = bus_data_in;

                if (count_address_bits == 5'd15) begin
                    buffer_addr <= updated_addr;
                    pending_addr <= 1'b1;
                    expect_data_addr <= s_rw;
                    shift_rx_addr <= '0;
                    count_address_bits <= 5'd0;
                end else begin
                    shift_rx_addr <= updated_addr;
                    count_address_bits <= count_address_bits + 5'd1;
                end
            end else if (bus_mode && pending_addr && expect_data_addr && !pending_data) begin
                logic [7:0] updated_data;
                updated_data = shift_rx_data;
                updated_data[count_data_bits] = bus_data_in;

                if (count_data_bits == 3'd7) begin
                    buffer_data <= updated_data;
                    pending_data <= 1'b1;
                    shift_rx_data <= '0;
                    count_data_bits <= 3'd0;
                end else begin
                    shift_rx_data <= updated_data;
                    count_data_bits <= count_data_bits + 3'd1;
                end
            end
        end
    end
end

endmodule
