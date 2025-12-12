module master #(
    parameter logic [15:0] WRITE_ADDR = 16'h0012,
    parameter logic [15:0] READ_ADDR = 16'h0034,
    parameter logic [7:0] MEM_INIT_DATA = 8'hAA
)(
    input  logic clk,
    input  logic rst_n,
    input  logic trigger,
    input  logic m_grant,
    input  logic m_ack,
    input  logic m_split_ack,
    input  logic [7:0] m_data_in,
    input  logic m_data_in_valid,
    output logic m_req,
    output logic [15:0] m_address_out,
    output logic m_address_out_valid,
    output logic [7:0] m_data_out,
    output logic m_data_out_valid,
    output logic m_rw,
    output logic m_ready,
    output logic done,
    output logic [7:0] read_data_value
);

assign m_ready = 1'b1;

logic req_reg;
logic [15:0] address_out_reg;
logic address_valid_reg;
logic [7:0] data_out_reg;
logic data_valid_reg;
logic rw_reg;
logic complete_reg;
// logic [7:0] write_mem;
logic [7:0] mem_write [0:3];
logic [1:0] ptr_write;
logic [7:0] mem_read;
logic sent_addr;
logic sent_data;
logic active_split;
logic ack_resume_split;

typedef enum logic [2:0] {
    STATE_IDLE,
    STATE_WR_REQUEST,
    STATE_WR_HOLD,
    STATE_WR_WAIT_ACK,
    STATE_RD_REQUEST,
    STATE_RD_WAIT,
    STATE_COMPLETE
} fsm_state_t;

fsm_state_t current_state;

assign m_req = req_reg;
assign m_address_out = address_out_reg;
assign m_address_out_valid = address_valid_reg;
assign m_data_out = data_out_reg;
assign m_data_out_valid = data_valid_reg;
assign m_rw = rw_reg;
assign done = complete_reg;
assign read_data_value = mem_read;

initial begin
    for (int i = 0; i < 4; i++) begin
        mem_write[i] <= MEM_INIT_DATA + i[7:0];
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= STATE_IDLE;
        req_reg <= 1'b0;
        address_out_reg <= '0;
        address_valid_reg <= 1'b0;
        data_out_reg <= '0;
        data_valid_reg <= 1'b0;
        rw_reg <= 1'b1;
        ptr_write <= 2'd0;
        mem_read <= 8'h00;
        sent_addr <= 1'b0;
        sent_data <= 1'b0;
        complete_reg <= 1'b0;
        active_split <= 1'b0;
        ack_resume_split <= 1'b0;
    end else begin
        case (current_state)
            STATE_IDLE: begin
                req_reg <= 1'b0;
                address_valid_reg <= 1'b0;
                data_valid_reg <= 1'b0;
                rw_reg <= 1'b1;
                sent_addr <= 1'b0;
                sent_data <= 1'b0;
                complete_reg <= 1'b0;
                active_split <= 1'b0;
                ack_resume_split <= 1'b0;

                if (trigger)
                    current_state <= STATE_WR_REQUEST;
            end
            STATE_WR_REQUEST: begin
                logic address_done;
                logic data_done;

                req_reg <= 1'b1;
                rw_reg <= 1'b1;

                if (!sent_addr) begin
                    address_out_reg <= WRITE_ADDR;
                    address_valid_reg <= 1'b1;
                end else begin
                    address_valid_reg <= 1'b0;
                end

                if (!sent_data) begin
                    // data_out_reg <= mem_write;
                    data_out_reg <= mem_write[ptr_write];
                    data_valid_reg <= 1'b1;
                end else begin
                    data_valid_reg <= 1'b0;
                end

                address_done = sent_addr || (m_grant && address_valid_reg);
                data_done = sent_data || (m_grant && data_valid_reg);

                sent_addr <= address_done;
                sent_data <= data_done;

                if (address_done && data_done)
                    current_state <= STATE_WR_HOLD;
            end
            STATE_WR_HOLD: begin
                req_reg <= 1'b1;
                address_valid_reg <= 1'b0;
                data_valid_reg <= 1'b0;

                if (m_ack) begin
                    req_reg <= 1'b0;
                    sent_addr <= 1'b0;
                    sent_data <= 1'b0;
                    rw_reg <= 1'b0;
                    current_state <= STATE_RD_REQUEST;
                end else if (!m_grant) begin
                    current_state <= STATE_WR_WAIT_ACK;
                end
            end
            STATE_WR_WAIT_ACK: begin
                req_reg <= 1'b1;
                address_valid_reg <= 1'b0;
                data_valid_reg <= 1'b0;
                sent_addr <= 1'b0;
                sent_data <= 1'b0;

                if (m_ack) begin
                    req_reg <= 1'b0;
                    rw_reg <= 1'b0;
                    current_state <= STATE_RD_REQUEST;
                end
            end
            STATE_RD_REQUEST: begin
                logic address_done;

                req_reg <= 1'b1;
                rw_reg <= 1'b0;
                active_split <= 1'b0;
                ack_resume_split <= 1'b0;

                if (!sent_addr) begin
                    address_out_reg <= READ_ADDR;
                    address_valid_reg <= 1'b1;
                end else begin
                    address_valid_reg <= 1'b0;
                end

                data_valid_reg <= 1'b0;

                address_done = sent_addr || (m_grant && address_valid_reg);
                sent_addr <= address_done;

                if (address_done) begin
                    current_state <= STATE_RD_WAIT;
                end
            end
            STATE_RD_WAIT: begin
                address_valid_reg <= 1'b0;
                data_valid_reg <= 1'b0;
                sent_addr <= 1'b0;
                sent_data <= 1'b0;

                if (m_split_ack) begin
                    active_split <= 1'b1;
                    req_reg <= 1'b0;
                end

                if (m_ack) begin
                    req_reg <= 1'b0;
                    if (active_split)
                        ack_resume_split <= 1'b1;
                end

                if (m_data_in_valid && (!active_split || m_ack || ack_resume_split)) begin
                    mem_read <= m_data_in;
                    if (ptr_write == 2'd3)
                        ptr_write <= 2'd0;
                    else
                        ptr_write <= ptr_write + 2'd1;
                    complete_reg <= 1'b1;
                    active_split <= 1'b0;
                    ack_resume_split <= 1'b0;
                    current_state <= STATE_COMPLETE;
                end
            end
            STATE_COMPLETE: begin
                req_reg <= 1'b0;
                address_valid_reg <= 1'b0;
                data_valid_reg <= 1'b0;
                rw_reg <= 1'b0;
                complete_reg <= 1'b1;
                if (!trigger) begin
                    complete_reg <= 1'b0;
                    current_state <= STATE_IDLE;
                end
            end
            default: current_state <= STATE_IDLE;
        endcase
    end
end

endmodule
