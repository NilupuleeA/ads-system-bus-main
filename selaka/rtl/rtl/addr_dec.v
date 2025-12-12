module addr_dec #(
    parameter ADDR_WIDTH = 16,
    parameter DEVICE_ADDR_WIDTH = 4,
    parameter NUM_SLAVE = 3
)
(
    input clk,
    input rstn,
    input addr_valid,           //device address valid will come via this line
    input addr_data,            //device address will come via this line
    input [NUM_SLAVE-1:0] sready,
    input split,                //slave notify split signal (cannot performe txn at this moment)
    input split_grant,          //bus notifies split grant signal (can performe txn now)

    output reg [1:0] ssel,
    output reg ack,              //acknowledge to master : slvave device address received : send the data to slave
    output reg [2:0] mvalid
);

/*
Notes

2025/10/30
maked the mvalid combinantional. now mvalid goes high as soon as addr_valid is high in connect and wait phases(address and data sending phases)
chagned the testbench to simulate correct sready behavior.


*/

localparam IDLE             = 2'b00;
localparam S_ADDR_RECEIVE   = 2'b01;
localparam S_CONNECT        = 2'b10;
localparam WAIT_TXN         = 2'b11;

reg [1:0] state; 
reg [DEVICE_ADDR_WIDTH-1:0] slave_addr;
reg [DEVICE_ADDR_WIDTH-1:0] slave_split_addr;
reg split_pending;

reg [3:0] counter, wait_counter;
wire [2:0] slave_ready_in;

assign slave_ready_in = sready;



always @(*) begin
    if(state == S_CONNECT | state == WAIT_TXN) begin
        if(addr_valid) begin
            mvalid = 3'b000;
            mvalid[slave_addr] = 1'b1 ;
        end
        else begin
            mvalid = 3'b000;
        end
    end
    else begin
        mvalid = 3'b000;
    end
    
end

always @(posedge clk) begin
    if (!rstn) begin
        state <= IDLE;
        slave_addr <= 0;
        ssel    <= 0;
        ack   <= 0;
        counter <= 0;
        wait_counter <= 0;
        split_pending <= 0;
        slave_split_addr <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                ack <= 0;
                ssel <= 0;
                wait_counter <= 'b0;
                if (addr_valid) begin
                    slave_addr[0] <= addr_data;
                    counter <= 1;
                    state <= S_ADDR_RECEIVE;
                end
                else if (split_grant) begin
                    split_pending <= 1'b0;
                    slave_split_addr <= 'b0;
                    state <= WAIT_TXN;
                    ssel <= slave_split_addr;
                    slave_addr <= slave_split_addr;
                end
                else begin
                    state <= IDLE;
                end

            end
            S_ADDR_RECEIVE: begin                   // Receive slave address bits(only devvice address bits)
                slave_addr[counter] <= addr_data;
                counter <= counter + 1;
                if (counter == DEVICE_ADDR_WIDTH-1) begin
                    state <= S_CONNECT;
                    counter <= 0;
                end
                else begin
                    state <= S_ADDR_RECEIVE;
                end

                
            end
            S_CONNECT: begin
                if(slave_ready_in[slave_addr] & slave_addr <= NUM_SLAVE-1) begin  //check slave address is valid and slave is available
                    ack <= 1;                                           //notify the master that address is received and slave is ready
                    ssel <= slave_addr;                                 //select the slave    
                    if(addr_valid) begin                                //if master started to send transaction (start with slvae memory address) 
                        state <= WAIT_TXN;
                    end
                    else begin                                          //wait until master starts transaction
                        state <= S_CONNECT;
                    end
                end
                else begin
                    state <= IDLE;                                      //invalid slave address or slave is not ready, go to idle state   
                end
                
            end
            WAIT_TXN: begin 
                if(split) begin
                    if(split_pending) begin
                        if(slave_addr != slave_split_addr) begin
                            state <= WAIT_TXN;
                            split_pending <= split_pending;
                            slave_split_addr <= slave_split_addr;
                            //add this part. now non split txn can continue during the pending split
                            if(slave_ready_in[slave_addr]) begin
                                state <= IDLE;                                 
                                wait_counter <= 0;
                            end
                        end
                        else begin
                            state <= IDLE;
                            split_pending <= split_pending;
                            slave_split_addr <= slave_split_addr;
                        end
                    end
                    else begin
                        state <= IDLE;
                        split_pending <= 1'b1;
                        slave_split_addr <= slave_addr;
                        
                    end
                end

                else if (slave_ready_in[slave_addr]) begin
                    state <= IDLE;                                  //wait until slave is ready or split grant received
                    wait_counter <= 0;
                end
                
                else begin
                    state <= WAIT_TXN;                                      //slave is not ready and no split grant, go to idle state
                    wait_counter <= wait_counter + 1;
                end
                
            end
            default: begin
                state <= IDLE;
            end
            

        endcase 
    end
    
end

endmodule