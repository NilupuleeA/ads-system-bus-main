module addr_convert #(
    parameter BB_ADDR_WIDTH = 12,
    parameter BUS_ADDR_WIDTH = 16,
    parameter BUS_MEM_ADDR_WIDTH = 12
) (
    input  [BB_ADDR_WIDTH-1:0] bb_addr,
    output [BUS_ADDR_WIDTH-1:0] bus_addr
);
    // Map lower BB_ADDR_WIDTH-1 bits to BUS_MEM_ADDR_WIDTH LSBs
    assign bus_addr[BUS_MEM_ADDR_WIDTH-1:0] = bb_addr[BB_ADDR_WIDTH-2:0];

    // Map MSB of BB address
    assign bus_addr[BUS_MEM_ADDR_WIDTH] = bb_addr[BB_ADDR_WIDTH-1];

    // Upper bits of bus address
    assign bus_addr[BUS_ADDR_WIDTH-1:BUS_MEM_ADDR_WIDTH+1] = { (BUS_ADDR_WIDTH-BUS_MEM_ADDR_WIDTH-1){1'b0} };

endmodule
