
module dec3 (
    input [1:0] sel,
    input en,
    output reg out1, out2, out3
);
    always @(*) begin
        if (en) begin
            case (sel)
                2'b00: {out1, out2, out3} = 3'b100;
                2'b01: {out1, out2, out3} = 3'b010;
                2'b10: {out1, out2, out3} = 3'b001;
                default: {out1, out2, out3} = 3'b000;
            endcase
        end else begin
            {out1, out2, out3} = 3'b000;
        end
    end

endmodule