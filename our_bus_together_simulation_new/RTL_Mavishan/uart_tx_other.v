module uart_tx_other #(
	parameter DATA_WIDTH  =  16
)(
    input  [DATA_WIDTH-1:0] data_in,  // Input data as a 32-bit register/vector
    input        wr_en,    // Enable wire to start
    input        clk,
    input        clken,    // Clock signal for the transmitter
    output reg   tx,       // A single 1-bit register variable to hold transmitting bit
    output       tx_busy   // Transmitter is busy signal
);

// Define the 4 states using 2-bit encoding
localparam TX_STATE_IDLE  = 2'b00;
localparam TX_STATE_START = 2'b01;
localparam TX_STATE_DATA  = 2'b10;
localparam TX_STATE_STOP  = 2'b11;

reg [43:0] data;           // 44-bit register/vector initialized to 0
reg [5:0]  bit_pos;        // 6-bit register/vector initialized to 0
reg [1:0]  state;          // 2-bit register/vector initialized to IDLE
reg        flag1;
reg        flag2;

// Initialize tx to 1 to indicate idle state
initial begin
    tx = 1'b1;
    data = 32'h0;
    bit_pos = 6'h0;
    state = TX_STATE_IDLE;
    flag1 = 1'b0;
    flag2 = 1'b1;
end

// Toggle flag1 on write enable signal
// always @(posedge wr_en) begin
//     flag1 <= ~flag1;
// end

// Main state machine
always @(posedge clk) begin
    case (state)
        TX_STATE_IDLE: begin
            if (wr_en) begin
                state <= TX_STATE_START; // Transition to START state
                data  <= {2'b11, data_in[DATA_WIDTH-1:DATA_WIDTH/2], 1'b0, // Word 1
                          2'b11, data_in[DATA_WIDTH/2-1:0]};        // Word 0
                bit_pos <= 6'h0; // Reset bit position
                // flag2 <= ~flag2;
            end
        end

        TX_STATE_START: begin
            if (clken) begin
                tx <= 1'b0; // Start bit
                state <= TX_STATE_DATA;
                bit_pos <= 6'h0;
            end
        end

        TX_STATE_DATA: begin
            if (clken) begin
                if (bit_pos == 6'd21) begin
                    state <= TX_STATE_STOP; // Transition to STOP state
                end else begin
                    bit_pos <= bit_pos + 6'h1; // Increment bit position
                end
                tx <= data[bit_pos]; // Transmit data bit
            end
        end

        TX_STATE_STOP: begin
            if (clken) begin
                tx <= 1'b1; // Stop bit
                state <= TX_STATE_IDLE; // Return to IDLE state
            end
        end

        default: begin
            tx <= 1'b1; // Default tx to idle state
            state <= TX_STATE_IDLE;
        end
    endcase
end

// Assign busy signal based on state
assign tx_busy = (state != TX_STATE_IDLE);

endmodule