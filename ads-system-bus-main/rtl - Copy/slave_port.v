module slave_port #(parameter ADDR_WIDTH = 12, DATA_WIDTH = 8, SPLIT_EN = 0)
(
	input clk, rstn,

	// Slave memory interface
	input [DATA_WIDTH-1:0] smemrdata,
	input rvalid,
	output reg smemwen, smemren,
	output reg [ADDR_WIDTH-1:0] smemaddr,
	output reg [DATA_WIDTH-1:0] smemwdata,

	// Serial bus interface
	input swdata,
	output reg srdata,
	input smode,
	input mvalid,
	input split_grant,
	output reg svalid,
	output sready,
	output ssplit,
	output reg [DATA_WIDTH-1:0] demo_data,
	input debug
);

	/* Internal signals */
	reg [DATA_WIDTH-1:0] wdata;
	reg [ADDR_WIDTH-1:0] addr;
	wire [DATA_WIDTH-1:0] rdata;
	reg mode;
	reg [7:0] counter;
	localparam LATENCY = 4;
	reg [LATENCY-1:0] rcounter;

	// State encoding
	localparam IDLE   = 4'b0000,
	           ADDR   = 4'b0001,
	           RDATA  = 4'b0010,
	           WDATA  = 4'b0011,
	           SREADY = 4'b0101,
	           SPLIT  = 4'b0100,
	           WAIT   = 4'b0110,
	           RVALID = 4'b0111,
	           DEBUG  = 4'b1000;

	reg [3:0] state;

	assign rdata  = smemrdata;
	assign sready = (state == IDLE);
	assign ssplit = (state == SPLIT);

	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			state <= IDLE;
			wdata <= 'b0;
			addr <= 'b0;
			counter <= 'b0;
			svalid <= 0;
			smemren <= 0;
			smemwen <= 0;
			mode <= 0;
			smemaddr <= 0;
			smemwdata <= 0;
			srdata <= 0;
			rcounter <= 'b0;
			demo_data <= 'b0;
		end else begin
			case (state)

				/* ---------------------- IDLE ---------------------- */
				IDLE: begin
					counter <= 'b0;
					svalid <= 0;
					smemren <= 0;
					smemwen <= 0;

					if (mvalid) begin
						mode <= smode;
						addr[counter] <= swdata;
						counter <= counter + 1;
						state <= ADDR;
					end else begin
						state <= IDLE;
					end
				end

				/* ---------------------- ADDR ---------------------- */
				ADDR: begin
					svalid <= 0;
					if (mvalid) begin
						addr[counter] <= swdata;
						if (counter == ADDR_WIDTH-1) begin
							counter <= 0;
							state <= (mode) ? WDATA : SREADY;
						end else begin
							counter <= counter + 1;
							state <= ADDR;
						end
					end else begin
						state <= ADDR;
					end
				end

				/* ---------------------- SREADY ---------------------- */
				SREADY: begin
					svalid <= 0;
					if (mode) begin
						smemwen <= 1;
						smemwdata <= wdata;
						smemaddr <= addr;
						state <= DEBUG;
					end else begin
						smemren <= 1;
						smemaddr <= addr;
						state <= (SPLIT_EN) ? SPLIT : RVALID;
					end
				end

				/* ---------------------- RVALID ---------------------- */
				RVALID: begin
					if (rvalid)
						state <= RDATA;
					else
						state <= RVALID;
				end

				/* ---------------------- SPLIT ---------------------- */
				SPLIT: begin
					rcounter <= rcounter + 1;
					if (rcounter == LATENCY)
						state <= WAIT;
					else
						state <= SPLIT;
				end

				/* ---------------------- WAIT ---------------------- */
				WAIT: begin
					rcounter <= 0;
					if (split_grant)
						state <= RDATA;
					else
						state <= WAIT;
				end

				/* ---------------------- RDATA ---------------------- */
				RDATA: begin
					srdata <= rdata[counter];
					svalid <= 1;
					if (counter == DATA_WIDTH-1) begin
						counter <= 0;
						state <= IDLE;
					end else begin
						counter <= counter + 1;
						state <= RDATA;
					end
				end

				/* ---------------------- WDATA ---------------------- */
				WDATA: begin
					svalid <= 0;
					if (mvalid) begin
						wdata[counter] <= swdata;
						if (counter == DATA_WIDTH-1) begin
							counter <= 0;
							state <= SREADY;
						end else begin
							counter <= counter + 1;
							state <= WDATA;
						end
					end else begin
						state <= WDATA;
					end
				end

				/* ---------------------- DEBUG ---------------------- */
				DEBUG: begin
					smemaddr <= addr;
					smemren <= 1;
					smemwen <= 0;
					demo_data <= smemrdata;
					state <= IDLE;
				end

				default: state <= IDLE;
			endcase
		end
	end
endmodule


//module slave_port #(parameter ADDR_WIDTH = 12, DATA_WIDTH = 8, SPLIT_EN = 0)
//(
//	input clk, rstn,
//
//	// Signals connecting to slave memory
//	input [DATA_WIDTH-1:0] smemrdata, // data read from the slave memory
//	input rvalid,
//	output reg smemwen, smemren,
//	output reg [ADDR_WIDTH-1:0] smemaddr, //input address of slave
//	output reg [DATA_WIDTH-1:0] smemwdata, // data written to the slave memory
//
//	// Signals connecting to serial bus
//	input swdata,	// write data and address from master
//	output reg srdata,	// read data to the master
//	input smode,	// 0 -  read, 1 - write, from master
//	input mvalid,	// wdata valid - (recieving data and address from master)
//	input split_grant, //grant to send read data
//	output reg svalid,	// rdata valid - (sending data from slave)
//	output sready, //slave is ready for transaction
//	output ssplit, // 1 - split
//	output reg [DATA_WIDTH-1:0] demo_data,
//	input debug
//);
//
//	/* Internal signals */
//
//	// registers to accept data from master and slave memory
//	reg [DATA_WIDTH-1:0] wdata;  //write data from master
//	reg [ADDR_WIDTH-1:0] addr;
//	wire [DATA_WIDTH-1:0] rdata;	//read data from slave memory
//	reg mode;
//	// counters
//	reg [7:0] counter;
//
//	localparam LATENCY = 4;
//	reg [LATENCY-1:0] rcounter;
//
//	// States
//    localparam IDLE  = 4'b000,    //0
//               ADDR  = 4'b001, 	// Receive address from slave //1
//               RDATA = 4'b010,    // Send data to master //2
//			   WDATA = 4'b011,	// Receive data from master //3
//			   SREADY = 4'b101, //5
//			   SPLIT = 4'b100, // 4
//			   WAIT = 4'b110, //6
//			   RVALID = 4'b111, //7
//				DEBUG = 4'b1000;
//
//	
//	// State variables
//	reg [3:0] state, next_state;
//
//	// Next state logic
//	always @(*) begin
//		case (state)
//			IDLE  : next_state = ((mvalid) ? ADDR : IDLE);
//			ADDR  : next_state = (counter == ADDR_WIDTH-1) ? ((mode) ? WDATA : SREADY) : ADDR;
//			SREADY : next_state = (mode) ? DEBUG : ((SPLIT_EN) ? SPLIT : RVALID); //IDLE instead DEBUG
//			RVALID : next_state = (rvalid) ? RDATA : RVALID;
//			SPLIT : next_state = (rcounter == LATENCY) ? WAIT : SPLIT;
//			WAIT : next_state = (split_grant) ? RDATA : WAIT;
//			RDATA : next_state = (counter == DATA_WIDTH-1) ? IDLE : RDATA;
//			WDATA : next_state = (counter == DATA_WIDTH-1) ? SREADY : WDATA;
//			DEBUG : next_state = IDLE;
//			default: next_state = IDLE;
//		endcase
//	end
//
//	// State transition logic
//	always @(posedge clk) begin
//		state <= (!rstn) ? IDLE : next_state;
//	end
//	
//
//
//	// Combinational output assignments
//	assign rdata =	smemrdata;
//	assign sready = (state == IDLE);
//	assign ssplit = (state == SPLIT);
//
//	// Sequential output logic
//	always @(posedge clk) begin
//		if (!rstn) begin
//			wdata <= 'b0;
//			addr <= 'b0;
//			counter <= 'b0;
//			svalid <= 0;
//			smemren <= 0;
//			smemwen <= 0;
//			mode <= 0;
//			smemaddr <= 0;
//			smemwdata <= 0;
//			srdata <= 0;
//			rcounter <= 'b0;
//			demo_data <= 'b0;
//		end
//		else begin
//			case (state)
//			
//				IDLE : begin
//					counter <= 'b0;
//					svalid <= 0;
//					smemren <= 0;
//					smemwen <= 0;
//					
//					if (mvalid) begin
//						mode <= smode;
//						addr[counter] <= swdata;
//						counter <= counter + 1;						
//					end else begin
//						addr <= addr;
//						counter <= counter;
//						mode <= mode;
//					end
//					
//					
//				end
//				
//				ADDR : begin
//					svalid <= 1'b0;
//					if (mvalid) begin
//						addr[counter] <= swdata;
//
//						if (counter == ADDR_WIDTH-1) begin
//							counter <= 'b0;
//						end else begin
//							counter <= counter + 1;
//						end
//						
//					end else begin
//						addr <= addr;
//						counter <= counter;
//					end
//
//				end
//			
//				SREADY: begin
//
//					svalid <= 1'b0;
//					if (mode) begin
//						smemwen <= 1'b1;
//						smemwdata <= wdata;
//						smemaddr <= addr;
//					end else begin 
//						smemren <= 1'b1;						
//						smemaddr <= addr;
//					end	
//				end
//
//				RVALID: begin
//					//waiting
//				end
//			
//				SPLIT : begin //wait for sometime
//					rcounter <= rcounter + 1;
//				end
//
//				WAIT : begin //wait until grant bus access for split transfer
//					rcounter <= 'b0;
//				end
//
//				RDATA : begin	// Send data to master
//					srdata <= rdata[counter];
//					svalid <= 1'b1;
//
//					if (counter == DATA_WIDTH-1) begin
//						counter <= 'b0;
//					end else begin
//						counter <= counter + 1;
//					end
//					
//				end			
//			
//				WDATA : begin	// Receive data from master	
//					svalid <= 1'b0;
//					if (mvalid) begin
//						wdata[counter] <= swdata;
//			
//						if (counter == DATA_WIDTH-1) begin
////							smemwen <= 1'b1;
//							counter <= 'b0;
//						end else begin
//							counter <= counter + 1;
//						end	
//					end else begin
//						wdata <= wdata;
//						counter <= counter;
//			
//					end
//				end
//				
//				DEBUG: begin
//					smemaddr <= addr;
//					 smemren <= 1'b1;
//					 smemwen <= 1'b0;
//					 demo_data <= 	smemrdata;
//				
//				end
//				
//				default: begin
//					wdata <= wdata;
//					addr <= addr;
//					counter <= counter;
//					svalid <= svalid;
//					smemwen <= smemwen;
//					smemren <= smemren;
//					rcounter <= rcounter;
//				end
//				
//			endcase
//		end
//	end
//
//
//endmodule
