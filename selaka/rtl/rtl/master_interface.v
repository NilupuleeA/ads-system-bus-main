module master_interface 
#(
    parameter                   ADDR_WIDTH              = 16, 
    parameter                   DATA_WIDTH              = 8,
    parameter                   SLAVE_MEM_ADDR_WIDTH    = 12
)
(
    input                       clk,
    input                       rstn,

    //signals from master
    input [DATA_WIDTH-1:0]      mwdata,                     // write data
    input [ADDR_WIDTH-1:0]      maddr,                      // address data   
    input                       mwvalid,                    // ready valid interface
    output reg [DATA_WIDTH-1:0] mrdata,                     // read data
    output reg                  mrvalid,                    // read valid signal
    output                      mready,                     // ready signal
    input                       wen,                        // write enable signal

    //signals to serial bus
    output reg                  bwdata,                     // write data and address
    input                       brdata,
    output                      bmode,                      // 0 -  read, 1 - write
    output reg                  bwvalid,                    // wdata valid
    input                       brvalid,                    // rdata valid
    input                       bus_busy,

    //signals to arbiter    
    output  reg                 mbreq,
	input                       mbgrant,
	input                       msplit,

	// Acknowledgement from address decoder 
	input                       ack,
	output reg [7:0] test_l
	 
);

    localparam                  SLAVE_DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;


    localparam                  IDLE        = 3'b000;       //waiting for master data 
    localparam                  REQ         = 3'b001;       //received master data and send a request to the arbiter
    localparam                  SLAVE_ADDR  = 3'b010;       //recived grant from arbiter and send slave device address and wait for ack from addr decoder
    localparam                  ADDR        = 3'b011;       //send address to slave memory
    localparam                  RDATA       = 3'b100;       // Read data from slave
    localparam                  WDATA       = 3'b101;       // Write data to slave
    localparam                  SPLIT       = 3'b110;       // Wait for split slave to be ready
	 localparam 					  READ_HOLD   = 3'b111;

    reg [2:0]                   state;                      // state variables 
    reg [DATA_WIDTH-1:0]        wdata;                      // register for save write data
    reg [DATA_WIDTH-1:0]        rdata;                      // register for save read data
    reg [ADDR_WIDTH-1:0]        addr;                       // register for save address data
    reg                         mode;                       // register for save mode data  
    reg [7:0]                   counter;
    reg [7:0]                   timeout;                    // counters
    reg mready_1;

    assign bmode = mode;                                    // 0 - read, 1 - write

    //assign mready = !bus_busy & mready_1;
    assign mready = mready_1;

    always @(posedge clk) begin
        if(!rstn) begin
            wdata <= 'b0;
            rdata <= 'b0;
            addr <= 'b0;
            mode <= 'b0;
            mbreq <= 1'b0;
            counter <= 0;
            state <= IDLE;

            mrdata <= 'b0;
            mrvalid <= 1'b0;
            mready_1 <= 1'b1; 

            bwdata <= 1'b0;
            bwvalid <= 1'b0;
				//test_l <= 8'b00000000;
        end
        else begin
            case (state)
                IDLE: begin
                    wdata <= 'b0;
                    addr <= 'b0;
                    mode <= 'b0;   
                    mbreq <= 1'b0;
                    counter <= 0;
                    timeout <= 0;

                    mready_1 <= 1'b1;               
                    mrdata <= 'b0;
                    mrvalid <= 1'b0;            
                    if(mwvalid) begin                       //receive valid signal from master. save the master data into internal registers. go to the request state
                        wdata <= mwdata;
                        addr <= maddr;
                        mode <= wen;
                        state <= REQ;

                        mready_1 <= 1'b0;
                    end
                    else begin
                        state <= IDLE;
                    end


                end

                REQ: begin
                    mbreq <= 1'b1;                          //send request to arbiter
                    if(mbgrant) begin                       //if arbiter granted the bus access go to send slave device address state
                        state <= SLAVE_ADDR;
                    end
                    else begin
                        state <= REQ;
                    end
                end

                SLAVE_ADDR: begin
                    
                    if (counter == SLAVE_DEVICE_ADDR_WIDTH) begin
                        bwvalid <= 1'b0;
                        if(ack) begin                          //wait for acknowledgement from address decoder
                            counter <= 0;
                            state <= ADDR;                  //go to send address state
                        end
                        else begin
                            state <= SLAVE_ADDR;
                        end

					end else begin
						counter <= counter + 1;
                        bwdata <= addr[SLAVE_MEM_ADDR_WIDTH + counter];
					    bwvalid <= 1'b1;
					end

                end

                ADDR: begin
                    if (counter == SLAVE_MEM_ADDR_WIDTH) begin
                        bwvalid <= 1'b0;
                        if(mode) begin                          //if mode is write go to write data state
                            counter <= 0;
                            state <= WDATA;
                        end
                        else begin                              //if mode is read go to read data state
                            counter <= 0;
                            state <= RDATA;
                        end
                    end else begin
                        counter <= counter + 1;
                        bwdata <= addr[counter];
                        bwvalid <= 1'b1;
                    end

                end

                RDATA: begin
                    if (msplit) begin                           //if split signal is high go to split state
                        state <= SPLIT;
                    end
   
                    else if (counter == DATA_WIDTH) begin
                        counter <= 0;
                        state <= READ_HOLD;
                        mrdata <= rdata;
                        mrvalid <= 1'b1;   
                    end
                    else begin
                        if (brvalid) begin
									//test_l <= 8'b11000011;
                            rdata[counter] <= brdata;
                            counter <= counter + 1;
                        end else begin
                            rdata <= rdata;
                            counter <= counter;
                        end
                        state <= RDATA;
                    end
                end

                WDATA: begin
                    if (counter == DATA_WIDTH) begin
                        bwvalid <= 1'b0;
                        state <= IDLE;
                    end else begin
                        counter <= counter + 1;
                        bwdata <= wdata[counter];
                        bwvalid <= 1'b1;
                    end     

                end

                SPLIT: begin
                    if (!msplit && mbgrant) begin
                        state <= RDATA;
                    end
                    else begin
                        state <= SPLIT;
                    end

                end
					 READ_HOLD: begin
						if(counter == 4) begin
							state <= IDLE;
							counter <= 0;
						
						end
						else begin
							state <= READ_HOLD;
							counter <= counter + 1;
						
						end
					 
					 
					 end

                default: begin
                    wdata <= wdata;
                    rdata <= rdata;
                    addr <= addr;
                    mode <= mode;
                    counter <= counter;
                    timeout <= timeout;
                    mbreq <= mbreq;
                    state <= IDLE;
                
                end

            endcase
        end
    end

	 always @(posedge clk) begin
		 if(!rstn) begin
			test_l <= 8'b00000000;
		 end
		 else begin
			if(mrvalid) test_l <= mrdata;
		 end
	 end
   


endmodule