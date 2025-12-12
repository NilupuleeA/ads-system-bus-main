module slave_interface #(
    parameter ADDR_WIDTH        = 12, 
    parameter DATA_WIDTH        = 8, 
    parameter SPLIT_EN          = 0,
    parameter SPLIT_DELAY       = 4
)
(
    input                       clk, 
    input                       rstn,

	// Signals connecting to slave memory
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg                  mem_wen, 
    output reg                  mem_ren,

	input [DATA_WIDTH-1:0]      mem_rdata, 
    input                       mem_rvalid,

	output reg [DATA_WIDTH-1:0] mem_wdata,
    output reg                  mem_wvalid,
	

	// Signals connecting to serial bus
	input                       bwdata,	
	output reg                  brdata,	
	input                       bmode,	
	input                       bwvalid,	
	output reg                  brvalid,	
	output reg                  sready, 

    input                       split_grant, 
	output reg                  ssplit 
	//output reg [7:0] debug_led_out
);


localparam IDLE                 = 3'b000; 
localparam ADDR                 = 3'b001; 
localparam RDATA                = 3'b010; 
localparam WDATA                = 3'b011;
localparam RDATA_BUS            = 3'b100; 
localparam WDATA_MEM            = 3'b101; 


reg [2:0]                       state;
reg [7:0]                       counter;
reg [7:0]                       split_counter;
reg                             write_done;
reg                             read_done;

reg [ADDR_WIDTH-1:0]            addr;
reg [DATA_WIDTH-1:0]            wdata;
reg [DATA_WIDTH-1:0]            rdata;
reg                             mode;



always @(posedge clk) begin
    if(!rstn) begin
        mem_wdata               <= 'b0;
        mem_addr                <= 'b0;
        mem_wen                 <= 1'b0;
        mem_ren                 <= 1'b0;
        mem_wvalid              <= 1'b0;
        brdata                  <= 1'b0;
        brvalid                 <= 1'b0;
        sready                  <= 1'b1;
        ssplit                  <= 1'b0;
        state                   <= IDLE;
        counter                 <= 'b0;
        split_counter           <= 'b0;
        mode                    <= 1'b0;
        write_done              <= 1'b0;
        read_done               <= 1'b0;
        rdata                   <= 'b0;
        wdata                   <= 'b0;
        addr                    <= 'b0;
		  //debug_led_out <= 'b0;
    end
    else begin
        case (state)
            IDLE : begin                                        // Waiting for valid data (starting from address) from master
                mem_wdata                   <= 'b0;
                mem_addr                    <= 'b0;
                mem_wen                     <= 1'b0;
                mem_ren                     <= 1'b0;
                mem_wvalid                  <= 1'b0;
                brdata                      <= 1'b0;
                brvalid                     <= 1'b0;
                sready                      <= 1'b1;
                ssplit                      <= 1'b0;
                counter                     <= 'b0;
                mode                        <= 1'b0;
                write_done                  <= 1'b0;
                split_counter               <= 'b0;
                rdata                       <= 'b0;
                wdata                       <= 'b0;
                addr                        <= 'b0;
                read_done                   <= 1'b0;

                if(bwvalid) begin
                    state                   <= ADDR;
                    sready                  <= 1'b0;
                    mode                    <= bmode;
                    addr[counter]           <= bwdata;
                    counter                 <= counter + 1;
                end 
                else begin
                    state                   <= IDLE;
                end

            end
            ADDR : begin                                        // Receiving address from master
                if(bwvalid) begin
                    addr[counter]           <= bwdata;
                    counter                 <= counter + 1;
                    if(counter == ADDR_WIDTH-1) begin           //full address received
                        if(mode) begin                          // go to the write stage
                            state           <= WDATA;
                            write_done      <= 1'b0;
                        end
                        else begin                              // go to the read stage
                            state           <= RDATA;
                            read_done       <= 1'b0;
                        end
                        counter             <= 'b0;
                    end
                end
                else begin
                    
                end

                
            end
            RDATA : begin                                       // Sending read data to master
                if (SPLIT_EN) begin                             //split activate
                    ssplit                  <= 1'b1;
                    mem_addr                <= addr;            //set the address and wen signal for the memory read 
                    mem_wen                 <= 1'b0;
                    mem_ren                 <= 1'b1;
                    if(mem_rvalid) begin                        //if read valid received, take that data
                            rdata           <= mem_rdata;
                            read_done       <= 1'b1;
                            //mem_ren         <= 1'b0;
                        end
                    else begin
                        rdata               <= rdata;
                        //mem_ren             <= 1'b1;
                    end
                    if(split_counter == SPLIT_DELAY-1) begin    //simulated split period is done
                        ssplit              <= 1'b0;

                        if (split_grant && read_done) begin
                            split_counter   <= 'b0;
                            state           <= RDATA_BUS;  
                            mem_ren                 <= 1'b0;

                        end
                        else begin
                            state           <= RDATA;
                            split_counter   <= split_counter;
                        end

                    end
                    else begin
                        split_counter       <= split_counter + 1;
                    end
                end
                else begin                                      //read data from memory
                    mem_addr                <= addr;
                    mem_wen                 <= 1'b0;
                    mem_ren                 <= 1'b1;
                    if(mem_rvalid) begin
                        rdata               <= mem_rdata;
                        state               <= RDATA_BUS;   
                        mem_ren             <= 1'b0;      
                    
                    end
                    else begin
                        state               <= RDATA;
                        rdata               <= rdata;
                        mem_ren             <= 1'b1;
                    end
                end
                
            end


           WDATA : begin
                if (bwvalid) begin
                    wdata[counter] <= bwdata;

                    if (counter == DATA_WIDTH-1) begin
                        counter     <= 0;
                        write_done  <= 1'b1;
                        state       <= WDATA_MEM;    // all bits received
                    end
                    else begin
                        counter     <= counter + 1;
                        state       <= WDATA;        // continue shifting
                    end
                end
                else begin
                    state <= WDATA;                  // wait for next serial bit
                end
            end

            WDATA_MEM : begin                                   //write the accumulated serial data to slave memory.
                mem_wen             <= 1'b1;
                mem_ren             <= 1'b0;
                mem_wvalid          <= 1'b1;
                mem_wdata           <= wdata;
                mem_addr            <= addr;
                state               <= IDLE;
            end

            RDATA_BUS : begin                                   //interface is ready to send serial data to bus. 
                brvalid                     <= 1'b1;
					 
                brdata                      <= rdata[counter];
                if (counter == DATA_WIDTH-1) begin
                    counter                 <= 'b0;
                    state                   <= IDLE;
						  //debug_led_out <= 8'b11101011;
                end

                else begin
                    counter                 <= counter + 1;
                    state                   <= RDATA_BUS;
                end
            end    
             
            default: begin
                wdata                       <= wdata;
                addr                        <= addr;
                counter                     <= counter;
                state                       <= IDLE;

            end
                   
        endcase

        
    end
end


endmodule