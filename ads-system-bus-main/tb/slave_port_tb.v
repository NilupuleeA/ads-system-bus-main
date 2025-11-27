module slave_port_tb;

	// Parameters
	localparam ADDR_WIDTH = 12;
	localparam DATA_WIDTH = 8;

	// Signals
	reg clk, rstn;
	reg [DATA_WIDTH-1:0] smemrdata; // Data read from the slave memory
	reg swdata;	// Write data and address from master
	reg smode;	// Mode: 0 - Read, 1 - Write, from master
	reg mvalid;	// Valid signal from master

	wire smemwen, smemren; // Memory write/read enables
	wire [ADDR_WIDTH-1:0] smemaddr; // Address to slave memory
	wire [DATA_WIDTH-1:0] smemwdata; // Data written to slave memory
	wire srdata;	// Data read by master
	wire svalid;	// Data valid signal to master

	// DUT instance
	slave_port #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) dut (
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
		.svalid(svalid)
	);

	// Clock generation
	always #5 clk = ~clk;

	initial begin
		// Initialize signals
		clk = 0;
		rstn = 0;
		smemrdata = 8'b0;
		swdata = 0;
		smode = 0;
		mvalid = 0;

		// Reset the DUT
		#10;
		rstn = 1;

		// Scenario 1: Write to slave memory
		#10;
		$display("Starting write operation...");
		mvalid = 1;
		swdata = 1;
		smode = 1; // Write mode

		// Send address (e.g., 12'b110100110101)101011001011
		//#10 swdata = 1; // LSB first
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1; // LSB

		// Send write data (e.g., 8'b10101010)
		#10 swdata = 1; // MSB first
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0; // LSB

		#10 mvalid = 0;

		// End the write operation
		#100;
		smode = 0;

		#20;

		// Scenario 2: Read from slave memory
		$display("Starting read operation...");
		mvalid = 1;
		smode = 0; // Read mode
		swdata = 1;

		// Send address (same as write, 12'b110100110101)
		// #10 swdata = 1; // MSB first
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1;
		#10 swdata = 0;
		#10 swdata = 1; // LSB

		#10 mvalid = 0;

		// Simulate data ready in slave memory (e.g., 8'b11001100)
		#10;
		smemrdata = 8'b11001100; // Example data returned from slave memory

		#80; // Allow time for reading

		// End the read operation
		#10;
		mvalid = 0;

		// Wait and finish
		#100;
		$finish;
	end



endmodule

