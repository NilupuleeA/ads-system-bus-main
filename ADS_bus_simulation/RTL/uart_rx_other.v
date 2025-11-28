module uart_rx_other #(
	parameter DATA_WIDTH  =  32
)
(
    input  logic rx,
    output logic ready,       // default 1-bit register
    input  logic clk,
    input  logic clken,
    output logic [DATA_WIDTH-1:0] data_out
);

// Initialization
initial begin
    ready = 1'b0;          // initialize ready to 0
    data_out = 32'b0;     // initialize data_out to 0
end

// Define the 4 states using 2-bit encoding
parameter RX_STATE_START    = 2'b00;
parameter RX_STATE_DATA     = 2'b01;
parameter RX_STATE_STOP     = 2'b10;
parameter READY_CLEARING    = 2'b11;

logic [1:0] words = 0;
logic [1:0] state = RX_STATE_START; // 2-bit register/vector, initially 00
logic [3:0] sample = 0;             // 4-bit register for sampling
logic [3:0] bit_pos = 0;            // 4-bit register for bit position
logic [7:0] scratch = 8'b0;         // 8-bit register initialized to 0

always_ff @(posedge clk) begin
    if (clken) begin
        case (state)
            RX_STATE_START: begin
                if (!rx || sample != 0) begin
                    sample <= sample + 4'b1; // increment sample
                    // ready <= 1'b1;
                end
                if (sample == 15) begin
                    state <= RX_STATE_DATA; // transition to DATA state
                    bit_pos <= 0;
                    sample <= 0;
                    scratch <= 0;
                    ready <= 1'b0;
                end
            end

            RX_STATE_DATA: begin
                sample <= sample + 4'b1; // increment sample
                if (sample == 4'h8) begin
                    scratch[bit_pos[2:0]] <= rx;
                    bit_pos <= bit_pos + 4'b1; // increment bit position
                end
                if (bit_pos == 8 && sample == 15) begin
                    state <= RX_STATE_STOP; // transition to STOP state
                end
            end

            RX_STATE_STOP: begin
                if (sample == 15 || (sample >= 8 && !rx)) begin
                    state <= READY_CLEARING;
                    case (words)
                        2'b00: data_out[7:0]   <= scratch;
                        2'b01: data_out[15:8]  <= scratch;
                        2'b10: data_out[23:16] <= scratch;
                        2'b11: data_out[31:24] <= scratch;
                    endcase
                    sample <= 0;
                    words <= words + 1'b1;
                    if (words == 2'b11)
						words <= 0;
                        ready <= 1'b1;
                end else begin
                    sample <= sample + 4'b1;
                end
            end

            READY_CLEARING: begin
                state <= RX_STATE_START;
        
            end

            default: begin
                state <= RX_STATE_START; // default to START state
            end
        endcase
    end
end

endmodule