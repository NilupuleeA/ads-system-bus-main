// module uart_tx #(
// 	parameter CLOCKS_PER_PULSE = 16,
//               DATA_WIDTH  =  8
// )
// (
// 	input [DATA_WIDTH -1:0] data_in,
// 	input data_en,
// 	input clk,
// 	input rstn,
// 	output reg tx,
// 	output tx_busy
// );

// 	localparam TX_IDLE  = 2'b00,    
// 	           TX_START = 2'b01, 
// 	           TX_DATA  = 2'b11,  
// 			   TX_END   = 2'b10;

// 	// State variable
// 	reg [1:0] state;

// 	// Data and control signals
// 	reg [DATA_WIDTH -1:0] data;
// 	reg [$clog2(DATA_WIDTH)-1:0] c_bits;
// 	reg [$clog2(CLOCKS_PER_PULSE)-1:0] c_clocks;
	
// 	// Sequential logic
// 	always @(posedge clk or negedge rstn) begin
// 		if (!rstn) begin
// 			c_clocks <= 0;
// 			c_bits <= 0;
// 			data <= 0;
// 			tx <= 1'b1;
// 			state <= TX_IDLE;
// 		end else begin 
// 			case (state)
// 				TX_IDLE: begin
// 					if (data_en) begin
// 						state <= TX_START;
// 						data <= data_in;
// 						c_bits <= 0;
// 						c_clocks <= 0;
// 					end else tx <= 1'b1;
// 				end
// 				TX_START: begin
// 					if (c_clocks == CLOCKS_PER_PULSE-1) begin
// 						state <= TX_DATA;
// 						c_clocks <= 0;
// 					end else begin
// 						tx <= 1'b0;
// 						c_clocks <= c_clocks + 1;
// 					end
// 				end
// 				TX_DATA: begin
// 					if (c_clocks == CLOCKS_PER_PULSE-1) begin
// 						c_clocks <= 0;
// 						if (c_bits == DATA_WIDTH-1) begin
// 							state <= TX_END;
// 						end else begin
// 							c_bits <= c_bits + 1;
// 							tx <= data[c_bits];
// 						end
// 					end else begin
// 						tx <= data[c_bits];
// 						c_clocks <= c_clocks + 1;
// 					end
// 				end
// 				TX_END: begin
// 					if (c_clocks == CLOCKS_PER_PULSE-1) begin
// 						state <= TX_IDLE;
// 						c_clocks <= 0;
// 					end else begin
// 						tx <= 1'b1;
// 						c_clocks <= c_clocks + 1;
// 					end
// 				end
// 				default: state <= TX_IDLE;
// 			endcase
// 		end
// 	end
	
// 	// Output to indicate busy state
// 	assign tx_busy = (state != TX_IDLE);
	
// endmodule


module uart_tx #(
	parameter DATA_WIDTH  =  16
)(
    input  logic [DATA_WIDTH-1:0] data_in,  // Input data as a 32-bit register/vector
    input  logic       wr_en,    // Enable wire to start
    input  logic       clk,
    input  logic       clken,    // Clock signal for the transmitter
    output logic       tx,       // A single 1-bit register variable to hold transmitting bit
    output logic       tx_busy   // Transmitter is busy signal
);

// Initialize tx to 1 to indicate idle state
initial begin
    tx = 1'b1;
end

// Define the 4 states using 2-bit encoding
parameter TX_STATE_IDLE  = 2'b00;
parameter TX_STATE_START = 2'b01;
parameter TX_STATE_DATA  = 2'b10;
parameter TX_STATE_STOP  = 2'b11;

logic [43:0] data = 32'h0;           // 44-bit register/vector initialized to 0
logic [5:0]  bit_pos = 6'h0;         // 6-bit register/vector initialized to 0
logic [1:0]  state = TX_STATE_IDLE; // 2-bit register/vector initialized to IDLE
logic        flag1 = 1'b0;
logic        flag2 = 1'b1;

// Toggle flag1 on write enable signal
// always_ff @(posedge wr_en) begin
//     flag1 <= ~flag1;
// end

// Main state machine
always_ff @(posedge clk) begin
    case (state)
        TX_STATE_IDLE: begin
            if (wr_en) begin
                state <= TX_STATE_START; // Transition to START state
                data  <= {2'b11, data_in[15:8], 1'b0, // Word 1
                          2'b11, data_in[7:0]};        // Word 0
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