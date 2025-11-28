module master_port #(
	parameter ADDR_WIDTH = 16, 
	parameter DATA_WIDTH = 8,
	parameter SLAVE_MEM_ADDR_WIDTH = 12
)(
	input clk, rstn,

	// Signals connecting to master device
	input [DATA_WIDTH-1:0] dwdata, // write data
	output [DATA_WIDTH-1:0] drdata, // read data
	input [ADDR_WIDTH-1:0] daddr,
	input dvalid, 			 		// ready valid interface
	output dready,
	input dmode,					// 0 - read, 1 - write
	
	// Signals connecting to serial bus
	input mrdata,	// read data
	output reg mwdata,	// write data and address
	output mmode,	// 0 -  read, 1 - write
	output reg mvalid,	// wdata valid
	input svalid,	// rdata valid

	// Signals to arbiter
	output mbreq,
	input mbgrant,
	input msplit,

	// Acknowledgement from address decoder 
	input ack
);

	localparam SLAVE_DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;
	localparam TIMEOUT_TIME = 5;

	// Internal registers
	reg [DATA_WIDTH-1:0] wdata, rdata;
	reg [ADDR_WIDTH-1:0] addr;
	reg mode;
	reg [7:0] counter, timeout;

	// States
	localparam IDLE  = 3'b000,    
	           ADDR  = 3'b001, 	
	           RDATA = 3'b010,    
			   WDATA = 3'b011,	
			   REQ 	 = 3'b100,	
			   SADDR = 3'b101,
			   WAIT  = 3'b110,
			   SPLIT = 3'b111;	

	reg [2:0] state;

	// Combinational outputs
	assign dready = (state == IDLE);
	assign drdata = rdata;
	assign mmode  = mode;
	assign mbreq  = (state != IDLE);

	// Unified sequential + control FSM
	always @(posedge clk) begin
		if (!rstn) begin
			state   <= IDLE;
			wdata   <= 0;
			rdata   <= 0;
			addr    <= 0;
			mode    <= 0;
			counter <= 0;
			mvalid  <= 0;
			mwdata  <= 0;
			timeout <= 0;
		end else begin
			case (state)
				IDLE: begin
					counter <= 0;
					mvalid  <= 0;
					timeout <= 0;

					if (dvalid) begin
						wdata <= dwdata;
						addr  <= daddr;
						mode  <= dmode;
						state <= REQ;
					end
				end

				REQ: begin
					if (mbgrant)
						state <= SADDR;
				end

				SADDR: begin
					mwdata <= addr[SLAVE_MEM_ADDR_WIDTH + counter];
					mvalid <= 1'b1;

					if (counter == SLAVE_DEVICE_ADDR_WIDTH-1) begin
						counter <= 0;
						state   <= WAIT;
					end else begin
						counter <= counter + 1;
					end
				end

				WAIT: begin
					mvalid <= 0;
					timeout <= timeout + 1;
					if (ack)
						state <= ADDR;
					else if (timeout == TIMEOUT_TIME)
						state <= IDLE;
				end

				ADDR: begin
					mwdata <= addr[counter];
					mvalid <= 1'b1;

					if (counter == SLAVE_MEM_ADDR_WIDTH-1) begin
						counter <= 0;
						state   <= (mode) ? WDATA : RDATA;
					end else begin
						counter <= counter + 1;
					end
				end

				RDATA: begin
					mvalid <= 0;
					if (msplit)
						state <= SPLIT;
					else if (svalid) begin
						rdata[counter] <= mrdata;
						if (counter == DATA_WIDTH-1) begin
							counter <= 0;
							state   <= IDLE;
						end else
							counter <= counter + 1;
					end
				end

				WDATA: begin
					mwdata <= wdata[counter];
					mvalid <= 1'b1;

					if (counter == DATA_WIDTH-1) begin
						counter <= 0;
						state   <= IDLE;
					end else begin
						counter <= counter + 1;
					end
				end

				SPLIT: begin
					mvalid <= 0;
					if (!msplit && mbgrant)
						state <= RDATA;
				end

				default: state <= IDLE;
			endcase
		end
	end

endmodule
