module slave_with_bram #(parameter ADDR_WIDTH = 12, DATA_WIDTH = 8, MEM_SIZE = 4096)
(
    input clk, rstn,
    // Signals connecting to serial bus
	input swdata,	// write data and address from master
	output srdata,	// read data to the master
	input smode,	// 0 -  read, 1 - write, from master
	input mvalid,	// wdata valid - (recieving data and address from master)
	output svalid,	// rdata valid - (sending data from slave)
    output sready, //slave is ready for transaction
	output reg [DATA_WIDTH-1:0] demo_data
	 
);

	wire [DATA_WIDTH-1:0] smemrdata;
	wire smemwen;
    wire smemren; 
	wire [ADDR_WIDTH-1:0] smemaddr; 
	wire [DATA_WIDTH-1:0] smemwdata;
    wire rvalid;
		 
	
	always @(posedge clk) begin
		 if (!rstn)
			  demo_data <= 8'b0;                   // reset to zero
		 else if (smemwen)
			  demo_data <= smemwdata;            // write new data when enabled
	end
	
    slave_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) sp (
        .clk(clk), 
        .rstn(rstn),
        .smemrdata(smemrdata),
        .smemwen(smemwen), 
        .smemren(smemren),
        .smemaddr(smemaddr), 
        .smemwdata(smemwdata),
        .swdata(swdata),
        .srdata(srdata),
        .smode(smode),
        .mvalid(mvalid),	
        .svalid(svalid),	
        .sready(sready),
        .rvalid(rvalid),
        .ssplit(),
        .split_grant(0)
    );


    slave_memory_bram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) sm (
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