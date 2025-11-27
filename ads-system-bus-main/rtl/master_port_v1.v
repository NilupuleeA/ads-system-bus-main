module master_port_v1 #(parameter ADDR_WIDTH = 16, DATA_WIDTH = 8)
(
	input clk, rstn,

	// Signals connecting to master device
	input [DATA_WIDTH-1:0] dwdata, // write data
	output [DATA_WIDTH-1:0] drdata,	// read data
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
	input mbgrant
);
	localparam SLAVE_ADDR_WIDTH = 4;	// Part of address to identify slave
	localparam SLAVE_MEM_ADDR_WIDTH = ADDR_WIDTH - SLAVE_ADDR_WIDTH;	// part of address to identify memory address

	/* Internal signals */

	// registers to accept data from master device and slave
	reg [DATA_WIDTH-1:0] wdata;
	reg [ADDR_WIDTH-1:0] addr;
	reg mode;
	reg [DATA_WIDTH-1:0] rdata;

	// counters
	reg [7:0] counter;

	// States
    localparam IDLE  = 3'b000,    
               ADDR  = 3'b001, 	// Send address to slave
               RDATA = 3'b010,    // Read data from slave
			   WDATA = 3'b011,	// Write data to slave
			   REQ 	 = 3'b101;	// Request bus access

	// State variables
	reg [2:0] state, next_state;

	// Next state logic
	always @(*) begin
		case (state)
			IDLE  : next_state = (dvalid) ? REQ : IDLE;
			REQ	  : next_state = (mbgrant) ? ADDR : REQ;
			ADDR  : next_state = (counter == SLAVE_MEM_ADDR_WIDTH-1) ? ((mode) ? WDATA : RDATA) : ADDR;
			RDATA : next_state = (svalid && (counter == DATA_WIDTH-1)) ? IDLE : RDATA;
			WDATA : next_state = (counter == DATA_WIDTH-1) ? IDLE : WDATA;
			default: next_state = IDLE;
		endcase
	end

	// State transition logic
	always @(posedge clk) begin
		state <= (!rstn) ? IDLE : next_state;
	end

	// Combinational output assignments
	assign dready = (state == IDLE);
	assign drdata = rdata;
	assign mmode = mode;
	assign mbreq = (state != IDLE);		// Keep bus request while master is in need of the bus

	// Sequential output logic
	always @(posedge clk) begin
		if (!rstn) begin
			wdata <= 'b0;
			rdata <= 'b0;
			addr <= 'b0;
			mode <= 0;
			counter <= 'b0;
			mvalid <= 0;
			mwdata <= 0;
		end
		else begin
			case (state)
				IDLE : begin
					counter <= 'b0;
					mvalid <= 0;

					if (dvalid) begin	// Have to send data
						wdata <= dwdata;
						addr <= daddr;
						mode <= dmode;
					end else begin
						wdata <= wdata;
						addr <= addr;
						mode <= mode;
					end
				end

				REQ : begin
					
				end

				ADDR : begin	// Send slave mem address
					mwdata <= addr[counter];
					mvalid <= 1'b1;

					if (counter == SLAVE_MEM_ADDR_WIDTH-1) begin
						counter <= 'b0;
					end else begin
						counter <= counter + 1;
					end
				end

				RDATA : begin	// Receive data from slave
					mvalid <= 1'b0;
					if (svalid) begin
						rdata[counter] <= mrdata;

						if (counter == DATA_WIDTH-1) begin
							counter <= 'b0;
						end else begin
							counter <= counter + 1;
						end 

					end else begin
						rdata <= rdata;
						counter <= counter;
					end
				end

				WDATA : begin	// Send data to slave
					mwdata <= wdata[counter];
					mvalid <= 1'b1;

					if (counter == DATA_WIDTH-1) begin
						counter <= 'b0;
					end else begin
						counter <= counter + 1;
					end
				end

				default: begin
					wdata <= wdata;
					rdata <= rdata;
					addr <= addr;
					mode <= mode;
					counter <= counter;
					mvalid <= mvalid;
					mwdata <= mwdata;
				end
			endcase
		end
	end


endmodule
