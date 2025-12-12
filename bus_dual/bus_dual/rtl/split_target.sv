module split_s #(
    parameter int INTERNAL_ADDR_BITS = 8,
    parameter int READ_LATENCY = 4
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
    output logic [7:0] split_s_last_write
);

    localparam int WIDTH_ADDR = (INTERNAL_ADDR_BITS > 0) ? INTERNAL_ADDR_BITS : 1;
    // localparam int MEM_DEPTH = 1 << WIDTH_ADDR;
    localparam int DEPTH_MEM = 16;
    localparam int WIDTH_LATENCY = (READ_LATENCY > 0) ? $clog2(READ_LATENCY + 1) : 1;

    // logic [7:0] mem [0:DEPTH_MEM-1];
    logic [7:0] memory [0:15];
    logic [15:0] address_pending;
    // logic [WIDTH_ADDR-1:0] index_addr;
    logic [3:0] index_addr;
    logic [WIDTH_LATENCY-1:0] cnt_latency;
    logic [7:0] value_last_write;

    typedef enum logic [2:0] {
        STATE_IDLE,
        STATE_WAIT_WR_DATA,
        STATE_RD_DEFER,
        STATE_RD_REQUEST,
        STATE_RD_SEND
    } split_state_t;

    split_state_t current_state;

    assign s_ready = 1'b1;
    assign split_s_last_write = value_last_write;
    // assign index_addr = address_pending[WIDTH_ADDR-1:0];
    assign index_addr = address_pending[3:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            split_req <= 1'b0;
            s_data_out <= '0;
            s_data_out_valid <= 1'b0;
            s_ack <= 1'b0;
            s_split_ack <= 1'b0;
            value_last_write <= '0;
            address_pending <= '0;
            cnt_latency <= '0;
            current_state <= STATE_IDLE;
        end else begin
            split_req <= 1'b0;
            s_data_out_valid <= 1'b0;
            s_ack <= 1'b0;
            s_split_ack <= 1'b0;

            case (current_state)
                STATE_IDLE: begin
                    if (s_address_in_valid) begin
                        address_pending <= s_address_in;
                        if (s_rw) begin
                            if (s_data_in_valid) begin
                                // memory[s_address_in[WIDTH_ADDR-1:0]] <= s_data_in;
                                memory[s_address_in[3:0]] <= s_data_in;
                                s_ack <= 1'b1;
                                value_last_write <= s_data_in;
                                current_state <= STATE_IDLE;
                            end else begin
                                current_state <= STATE_WAIT_WR_DATA;
                            end
                        end else begin
                            if (READ_LATENCY > 0) begin
                                s_split_ack <= 1'b1;
                                cnt_latency <= (READ_LATENCY > 0) ? READ_LATENCY - 1 : '0;
                                current_state <= STATE_RD_DEFER;
                            end else begin
                                current_state <= STATE_RD_REQUEST;
                            end
                        end
                    end
                end

                STATE_WAIT_WR_DATA: begin
                    if (s_data_in_valid) begin
                        // memory[address_pending[WIDTH_ADDR-1:0]] <= s_data_in;
                        memory[address_pending[3:0]] <= s_data_in;
                        s_ack <= 1'b1;
                        value_last_write <= s_data_in;
                        current_state <= STATE_IDLE;
                    end
                end

                STATE_RD_DEFER: begin
                    if (cnt_latency == '0) begin
                        current_state <= STATE_RD_REQUEST;
                    end else begin
                        cnt_latency <= cnt_latency - 1'b1;
                    end
                end

                STATE_RD_REQUEST: begin
                    split_req <= 1'b1;
                    if (split_grant) begin
                        split_req <= 1'b0;
                        current_state <= STATE_RD_SEND;
                    end
                end

                STATE_RD_SEND: begin
                    s_data_out <= memory[index_addr];
                    s_data_out_valid <= 1'b1;
                    s_ack <= 1'b1;
                    current_state <= STATE_IDLE;
                end

                default: current_state <= STATE_IDLE;
            endcase
        end
    end
endmodule
