module mux3 #(
    parameter DATA_WIDTH = 32
) (
    input [1:0] dsel,
    input [DATA_WIDTH-1:0] d0, d1, d2,
    output reg [DATA_WIDTH-1:0] dout
);
    // 00 -> d0
    // 01 -> d1
    // 10 or 11 -> d2
    always @(*) begin
        case (dsel)
            2'b00: dout = d0;
            2'b01: dout = d1;
            2'b10: dout = d2;
            default: dout = d2;
        endcase
    end

endmodule