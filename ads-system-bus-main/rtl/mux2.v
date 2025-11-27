module mux2 #(
    parameter DATA_WIDTH = 32
) (
    input dsel,
    input [DATA_WIDTH-1:0] d0, d1, 
    output [DATA_WIDTH-1:0] dout
);
    // 0 -> d0
    // 1 -> d1
    assign dout = (dsel) ? d1 : d0;

endmodule