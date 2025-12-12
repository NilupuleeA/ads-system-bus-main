module uart_rx_other_16 #(
    parameter DATA_WIDTH = 16
)(
    input  rx,
    output reg ready,
    input  clk,
    input  clken,
    output reg [DATA_WIDTH-1:0] data_out
);
    // Frames expected from uart_tx_other (DATA_WIDTH=16):
    // start bit (0), 8 data bits (low byte LSB-first), 2 stop bits (1),
    // implicit separator bit from TX packer (0), 8 data bits (high byte LSB-first), 2 stop bits (1), final stop from TX state machine.

    localparam RX_IDLE   = 2'b00;
    localparam RX_START  = 2'b01;
    localparam RX_DATA   = 2'b10;
    localparam RX_DONE   = 2'b11;

    reg [1:0] state;
    reg [3:0] sample;       // oversample counter (0-15)
    reg [5:0] bit_idx;      // counts received bits after start bit

    // align initial conditions
    initial begin
        ready    = 1'b0;
        data_out = {DATA_WIDTH{1'b0}};
        state    = RX_IDLE;
        sample   = 4'd0;
        bit_idx  = 6'd0;
    end

    always @(posedge clk) begin
        if (clken) begin
            case (state)
                RX_IDLE: begin
                    ready   <= 1'b0;
                    sample  <= 4'd0;
                    bit_idx <= 6'd0;
                    if (!rx) begin
                        state <= RX_START; // detect start bit low
                    end
                end

                RX_START: begin
                    sample <= sample + 1'b1;
                    if (sample == 4'd7) begin
                        // mid-bit sample of start; stay low expected
                        state  <= RX_DATA;
                        sample <= 4'd0;
                        bit_idx <= 6'd0;
                    end
                end

                RX_DATA: begin
                    sample <= sample + 1'b1;
                    if (sample == 4'd7) begin
                        // sample in middle of bit period
                        // Map payload bits into 16-bit output; ignore stop/separator bits
                        if (bit_idx < 8) begin
                            data_out[bit_idx] <= rx;               // low byte
                        end else if (bit_idx >= 11 && bit_idx < 19) begin
                            data_out[bit_idx-3] <= rx;             // high byte at bit_idx 11-18 -> [8..15]
                        end
                        bit_idx <= bit_idx + 1'b1;
                        if (bit_idx == 6'd21) begin
                            state <= RX_DONE;
                        end
                    end
                end

                RX_DONE: begin
                    ready <= 1'b1;  // pulse ready for one clken after frame complete
                    state <= RX_IDLE;
                end

                default: begin
                    state <= RX_IDLE;
                end
            endcase
        end
    end
endmodule
