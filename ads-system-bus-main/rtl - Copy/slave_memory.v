module slave_memory #(parameter ADDR_WIDTH = 12, DATA_WIDTH = 8, MEM_SIZE = 4096)
(

	input clk, rstn, wen, ren,
	
	input [ADDR_WIDTH-1:0] addr, //input address of slave
	input [DATA_WIDTH-1:0] wdata, // data to be written in the slave

	output [DATA_WIDTH-1:0] rdata, // data to be read from the slave
	output rvalid
);

	localparam MEM_ADDR_WIDTH = $clog2(MEM_SIZE);
	localparam NUM_LOCATIONS = MEM_SIZE / (DATA_WIDTH / 8);

	reg [DATA_WIDTH - 1:0] memory [NUM_LOCATIONS - 1:0];

	integer i;
	
	always @(posedge clk) begin
		if (!rstn) begin
			// Reset memory when rstn is low
			for (i = 0; i < NUM_LOCATIONS; i = i + 1) begin
				memory[i] <= {DATA_WIDTH{1'b0}};
			end
		end else begin
			if (wen) begin
				memory[addr[MEM_ADDR_WIDTH - 1 : 0]] <= wdata;
			end
		end
	end
	
	assign rvalid = 1'b1;
	assign rdata = (ren==1'b1) ? memory[addr[MEM_ADDR_WIDTH - 1 : 0]]: 8'd0; 

	endmodule
