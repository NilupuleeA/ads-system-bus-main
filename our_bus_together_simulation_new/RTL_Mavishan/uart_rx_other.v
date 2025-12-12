module uart_rx_other #(
	parameter DATA_WIDTH  =  32
)
(
    input  rx,
    output reg ready,       // default 1-bit register
    input  clk,
    input  clken,
    output reg [DATA_WIDTH-1:0] data_out
);

// Define the 4 states using 2-bit encoding
localparam RX_STATE_START    = 2'b00;
localparam RX_STATE_DATA     = 2'b01;
localparam RX_STATE_STOP     = 2'b10;
localparam READY_CLEARING    = 2'b11;

reg [1:0] words;
reg [1:0] state; // 2-bit register/vector, initially 00
reg [3:0] sample;             // 4-bit register for sampling
reg [3:0] bit_pos;            // 4-bit register for bit position
reg [7:0] scratch;         // 8-bit register initialized to 0

// Initialization
initial begin
    ready = 1'b0;          // initialize ready to 0
    data_out = 32'b0;     // initialize data_out to 0
    words = 0;
    state = RX_STATE_START;
    sample = 0;
    bit_pos = 0;
    scratch = 8'b0;
end

always @(posedge clk) begin
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
                    if (words == 2'b00) begin
                        data_out[7:0] <= scratch;
                    end else if (words == 2'b01 && DATA_WIDTH > 8) begin
                        data_out[15:8] <= scratch;
                    end else if (words == 2'b10 && DATA_WIDTH > 16) begin
                        data_out[23:16] <= scratch;
                    end else if (words == 2'b11 && DATA_WIDTH > 24) begin
                        data_out[31:24] <= scratch;
                    end
                    sample <= 0;
                    words <= words + 1'b1;
                    if (words == 2'b11) begin
						words <= 0;
                        ready <= 1'b1;
                    end
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