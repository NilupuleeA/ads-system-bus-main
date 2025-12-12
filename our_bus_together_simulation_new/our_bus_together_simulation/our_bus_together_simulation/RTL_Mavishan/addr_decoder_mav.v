
module addr_decoder_mav #(
    parameter ADDR_WIDTH = 16,
    parameter DEVICE_ADDR_WIDTH = 4
) (
    input clk, rstn,

    input mwdata,       
    input mvalid,       
    input ssplit,       
    input split_grant,  

    input sready1, sready2, sready3,

    output mvalid1, mvalid2, mvalid3,

    output reg [1:0] ssel, 
    output ack             
);

    reg [DEVICE_ADDR_WIDTH-1:0] slave_addr;
    reg slave_en;       
    wire mvalid_out;
    wire slave_addr_valid;
    wire [2:0] sready;
    reg [3:0] counter;
    reg [DEVICE_ADDR_WIDTH-1:0] split_slave_addr;

    dec3 mvalid_decoder (
        .sel(ssel),
        .en(mvalid_out),
        .out1(mvalid1),
        .out2(mvalid2),
        .out3(mvalid3)
    );

    localparam IDLE  = 2'b00,    
               ADDR  = 2'b01, 	
               CONNECT = 2'b10, 
               WAIT = 2'b11;

	reg [1:0] state, next_state;

	always @(*) begin
		case (state)
			IDLE    : next_state = (mvalid) ? ADDR : ((split_grant) ? WAIT : IDLE);
			ADDR    : next_state = (counter == DEVICE_ADDR_WIDTH-1) ? CONNECT : ADDR;
			CONNECT : next_state = (slave_addr_valid) ? ((mvalid) ? WAIT : CONNECT) : IDLE;  
            WAIT    : next_state = (sready[slave_addr] | ssplit) ? IDLE : WAIT;
			default: next_state = IDLE;
		endcase
	end
               
	always @(posedge clk) begin
		state <= (!rstn) ? IDLE : next_state;
	end

    assign mvalid_out = mvalid & slave_en;
    assign slave_addr_valid = (slave_addr < 3) & sready[slave_addr];    
    assign ack = (state == CONNECT) & slave_addr_valid;  
    assign sready = {sready3, sready2, sready1};

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

					if (mvalid) begin	
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

				ADDR : begin	
					slave_addr[counter] <= mwdata;

					if (counter == DEVICE_ADDR_WIDTH-1) begin
						counter <= 'b0;
					end else begin
						counter <= counter + 1;
					end
				end

				CONNECT : begin	
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