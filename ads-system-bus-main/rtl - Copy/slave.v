module slave #(parameter ADDR_WIDTH = 12, DATA_WIDTH = 8, SPLIT_EN = 0, MEM_SIZE = 4096)
(
    input clk, rstn,
    // Signals connecting to serial bus
	input swdata,	// write data and address from master
	output srdata,	// read data to the master
	input smode,	// 0 -  read, 1 - write, from master
	input mvalid,	// wdata valid - (recieving data and address from master)
    input split_grant, // grant bus access in split
	output svalid,	// rdata valid - (sending data from slave)
    output sready, //slave is ready for transaction
    output ssplit
);

	wire [DATA_WIDTH-1:0] smemrdata;
	wire smemwen;
    wire smemren; 
	wire [ADDR_WIDTH-1:0] smemaddr; 
	wire [DATA_WIDTH-1:0] smemwdata;
    wire rvalid;


    slave_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SPLIT_EN(SPLIT_EN)
    )sp(
        .clk(clk), 
        .rstn(rstn),
        .smemrdata(smemrdata),
        .rvalid(rvalid),
        .smemwen(smemwen), 
        .smemren(smemren),
        .smemaddr(smemaddr), 
        .smemwdata(smemwdata),
        .swdata(swdata),
        .srdata(srdata),
        .smode(smode),
        .mvalid(mvalid),	
        .split_grant(split_grant),
        .svalid(svalid),	
        .sready(sready),
        .ssplit(ssplit)
    );


    slave_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    )sm(
        .clk(clk), 
        .rstn(rstn), 
        .wen(smemwen),
        .ren(smemren),
        .addr(smemaddr), 
        .wdata(smemwdata), 
        .rdata(smemrdata),
        .rvalid(rvalid) 
    );

endmodule