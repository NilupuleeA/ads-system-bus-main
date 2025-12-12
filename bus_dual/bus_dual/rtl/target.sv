module slave #(
    parameter int INTERNAL_ADDR_BITS = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [15:0] s_address_in,
    input  logic s_address_in_valid,
    input  logic [7:0] s_data_in,
    input  logic s_data_in_valid,
    input  logic s_rw,
    output logic [7:0] s_data_out,
    output logic s_data_out_valid,
    output logic s_ack,
    output logic s_ready,
    output logic [7:0] s_last_write
);

    localparam int WIDTH_ADDR = (INTERNAL_ADDR_BITS > 0) ? INTERNAL_ADDR_BITS : 1;
    // localparam int MEM_DEPTH = 1 << WIDTH_ADDR;
    localparam int DEPTH_MEM = 16;

    // logic [7:0] mem [0:DEPTH_MEM-1];
    logic [7:0] storage [0:15];
    // logic [WIDTH_ADDR-1:0] idx_pending_addr;
    logic [3:0] idx_pending_addr;
    logic write_pending;

    logic [7:0] value_last_write;
    assign s_ready = 1'b1;

    assign s_last_write = value_last_write;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_data_out <= '0;
            s_data_out_valid <= 1'b0;
            s_ack <= 1'b0;
            idx_pending_addr <= '0;
            write_pending <= 1'b0;
            value_last_write <= '0;
        end else begin
            s_data_out_valid <= 1'b0;
            s_ack <= 1'b0;

            if (write_pending && s_data_in_valid) begin
                // storage[idx_pending_addr] <= s_data_in;
                storage[idx_pending_addr] <= s_data_in;
                s_ack <= 1'b1;
                write_pending <= 1'b0;
                value_last_write <= s_data_in;
            end

            if (s_address_in_valid) begin
                // idx_pending_addr <= s_address_in[WIDTH_ADDR-1:0];
                idx_pending_addr <= s_address_in[3:0];

                if (s_rw) begin
                    if (s_data_in_valid) begin
                        // storage[s_address_in[WIDTH_ADDR-1:0]] <= s_data_in;
                        storage[s_address_in[3:0]] <= s_data_in;
                        s_ack <= 1'b1;
                        write_pending <= 1'b0;
                        value_last_write <= s_data_in;
                    end else begin
                        write_pending <= 1'b1;
                    end
                end else begin
                    // s_data_out <= storage[s_address_in[WIDTH_ADDR-1:0]];
                    s_data_out <= storage[s_address_in[3:0]];
                    s_data_out_valid <= 1'b1;
                    s_ack <= 1'b1;
                    write_pending <= 1'b0;
                end
            end
        end
    end
endmodule
