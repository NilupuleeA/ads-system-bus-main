module mem_test_top (
    input clk, rstn,

    // Control signals
    input start,
    input mode,
    output ready
);
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 12;
    parameter DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;

    wire mrdata;					  // Read data from serial bus
    wire mwdata;				  // Write data to serial bus
    wire mmode;					  // 0 - read, 1 - write
    wire mvalid;				  // Write data valid
    wire svalid;					  // Read data valid from serial bus
    wire sready;

    // Arbiter signals
    wire breq1, bgrant1, msel, ack;

    // Instantiate the DUT (Device Under Test)
    demo_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) master_dev (
        .clk(clk),
        .rstn(rstn),
        .start(!start),
        .mode(mode),
        .ready(ready),
        .mrdata(mrdata),
        .mwdata(mwdata),
        .mmode(mmode),
        .mvalid(mvalid),
        .svalid(svalid),
        .mbreq(breq1),
        .mbgrant(bgrant1),
        .ack(ack)
    );

endmodule