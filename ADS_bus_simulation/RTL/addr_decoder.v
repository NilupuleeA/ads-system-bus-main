
module addr_decoder #(
    parameter ADDR_WIDTH = 16,
    parameter DEVICE_ADDR_WIDTH = 4
) (
    input clk, rstn,

    input mwdata,       // write data bus
    input mvalid,            // valid from master
    input ssplit,       // split signal from slave
    input split_grant,      // signal from arbiter ending split

    // ready signals from slave
    input sready1, sready2, sready3,

    // valid signals going to slaves
    output mvalid1, mvalid2, mvalid3,

    output reg [1:0] ssel,       // Slave select going to muxes
    output ack              // Acknowledgement going back to master
);

    // Internal signals
    reg [DEVICE_ADDR_WIDTH-1:0] slave_addr;
    reg slave_en;       // Enable slave connection
    wire mvalid_out;
    wire slave_addr_valid;  // Valid slave address
    wire [2:0] sready;
    reg [3:0] counter;
    reg [DEVICE_ADDR_WIDTH-1:0] split_slave_addr;

    // To give the correct wen signals
    dec3 mvalid_decoder (
        .sel(ssel),
        .en(mvalid_out),
        .out1(mvalid1),
        .out2(mvalid2),
        .out3(mvalid3)
    );

    // States
    localparam IDLE  = 2'b00,    
               ADDR  = 2'b01, 	// Receive address from master
               CONNECT = 2'b10,  // Enable correct slave connection
               WAIT = 2'b11;

    // State variables
	reg [1:0] state, next_state;

    // Next state logic
	always @(*) begin
		case (state)
			IDLE    : next_state = (mvalid) ? ADDR : ((split_grant) ? WAIT : IDLE);
			ADDR    : next_state = (counter == DEVICE_ADDR_WIDTH-1) ? CONNECT : ADDR;
			CONNECT : next_state = (slave_addr_valid) ? ((mvalid) ? WAIT : CONNECT) : IDLE;  
            WAIT    : next_state = (sready[slave_addr] | ssplit) ? IDLE : WAIT;
			default: next_state = IDLE;
		endcase
	end
               
    // State transition logic
	always @(posedge clk) begin
		state <= (!rstn) ? IDLE : next_state;
	end

    // Combinational assignments
    assign mvalid_out = mvalid & slave_en;
    assign slave_addr_valid = (slave_addr < 3) & sready[slave_addr];    // check whether ready and valid
    assign ack = (state == CONNECT) & slave_addr_valid;     // If address invalid, do not ack
    assign sready = {sready3, sready2, sready1};

    // Sequential output logic
	always @(posedge clk) begin
		if (!rstn) begin
			slave_addr <= 'b0;
            slave_en <= 0;
            counter <= 'b0;
            ssel <= 'b0;
            split_slave_addr <= 'b0;
		end
		else begin
			case (state)
				IDLE : begin
					slave_en <= 0;

					if (mvalid) begin	// Have to send data
                        slave_addr[0] <= mwdata;
                        counter <= 1;
                    end else if (split_grant) begin 
                        slave_addr <= split_slave_addr;
                        counter <= 'b0;
                    end else begin
                        slave_addr <= slave_addr;
                        counter <= 'b0;
                    end
				end

				ADDR : begin	// Send slave mem address
					slave_addr[counter] <= mwdata;

					if (counter == DEVICE_ADDR_WIDTH-1) begin
						counter <= 'b0;
					end else begin
						counter <= counter + 1;
					end
				end

				CONNECT : begin	// Receive data from slave
                    slave_en <= 1;
                    ssel <= slave_addr[1:0];
				end

                WAIT : begin
                    slave_en <= 1;
                    ssel <= slave_addr[1:0];

                    if (ssplit) 
                        split_slave_addr <= slave_addr;
                    else begin
                        split_slave_addr <= split_slave_addr;
                    end
                end
				
				default: begin
					slave_addr <= slave_addr;
                    slave_en <= slave_en;
                    counter <= counter;
                    ssel <= ssel;
                    split_slave_addr <= split_slave_addr;
				end
			endcase
		end
	end

endmodule