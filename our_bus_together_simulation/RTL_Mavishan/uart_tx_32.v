// 32-bit UART transmitter compatible with uart_rx_other (4 bytes, LSB-first per byte)
module uart_tx_32 #(
    parameter DATA_WIDTH = 32
)(
    input  clk,
    input  clken,           // baud tick enable
    input  wr_en,           // pulse to start transmission
    input  [DATA_WIDTH-1:0] data_in,
    output reg tx,
    output reg tx_busy
);
    localparam S_IDLE  = 3'd0;
    localparam S_START = 3'd1;
    localparam S_DATA  = 3'd2;
    localparam S_STOP  = 3'd3;

    reg [2:0] state;
    reg [2:0] bit_idx;      // 0..7 within a byte
    reg [1:0] byte_idx;     // 0..3 across the 32-bit word
    reg [7:0] shreg;

    // Select byte based on byte_idx, LSB-first byte order
    function automatic [7:0] pick_byte;
        input [1:0] idx;
        input [DATA_WIDTH-1:0] din;
        begin
            case (idx)
                2'd0: pick_byte = din[7:0];
                2'd1: pick_byte = din[15:8];
                2'd2: pick_byte = din[23:16];
                default: pick_byte = din[31:24];
            endcase
        end
    endfunction

    initial begin
        tx      = 1'b1;
        tx_busy = 1'b0;
        state   = S_IDLE;
        bit_idx = 3'd0;
        byte_idx= 2'd0;
        shreg   = 8'h00;
    end

    always @(posedge clk) begin
        if (state == S_IDLE) begin
            if (wr_en) begin
                tx_busy <= 1'b1;
                byte_idx<= 2'd0;
                shreg   <= pick_byte(2'd0, data_in);
                state   <= S_START;
            end else begin
                tx_busy <= 1'b0;
                tx      <= 1'b1;
            end
        end else if (clken) begin
            case (state)
                S_START: begin
                    tx      <= 1'b0;      // start bit
                    bit_idx <= 3'd0;
                    state   <= S_DATA;
                end

                S_DATA: begin
                    tx <= shreg[bit_idx];
                    if (bit_idx == 3'd7) begin
                        state <= S_STOP;
                    end
                    bit_idx <= bit_idx + 3'd1;
                end

                S_STOP: begin
                    tx <= 1'b1;           // stop bit
                    if (byte_idx == 2'd3) begin
                        state   <= S_IDLE;
                        tx_busy <= 1'b0;
                    end else begin
                        byte_idx<= byte_idx + 2'd1;
                        shreg   <= pick_byte(byte_idx + 2'd1, data_in);
                        state   <= S_START;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end
endmodule

// Convenience wrapper: include baudrate generator and expose Txclk_en
// module uart_tx_32_with_baud #(
//     parameter DATA_WIDTH = 32
// )(
//     input  clk_50m,
//     input  wr_en,
//     input  [DATA_WIDTH-1:0] data_in,
//     output tx,
//     output tx_busy,
//     output Txclk_en   // exported in case caller wants it
// );
//     wire Rxclk_dummy;

//     baudrate baud_inst (
//         .clk_50m(clk_50m),
//         .Rxclk_en(Rxclk_dummy),
//         .Txclk_en(Txclk_en)
//     );

//     uart_tx_32 #(.DATA_WIDTH(DATA_WIDTH)) tx_inst (
//         .clk(clk_50m),
//         .clken(Txclk_en),
//         .wr_en(wr_en),
//         .data_in(data_in),
//         .tx(tx),
//         .tx_busy(tx_busy)
//     );
// endmodule
