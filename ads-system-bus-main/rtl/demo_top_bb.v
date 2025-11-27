module demo_top_bb #(
	parameter ADDR_WIDTH = 16, 
	parameter DATA_WIDTH = 8,
	parameter SLAVE_MEM_ADDR_WIDTH = 13,
    parameter BB_ADDR_WIDTH = 13,
    parameter UART_CLOCKS_PER_PULSE = 5208
)(
	input clk, rstn,

    input start,
	output ready,
	input mode,					// 0 - read, 1 - write

    input m_u_rx,
    input s_u_rx,
    output m_u_tx,
    output s_u_tx
);


	wire [DATA_WIDTH-1:0] d1_wdata;   // write data
	wire [DATA_WIDTH-1:0] d1_rdata; 	// read data
	wire [ADDR_WIDTH-1:0] d1_addr; 
	wire d1_start, m1_ready;
    reg d1_valid;
    reg m1_rw_mode;
    wire s_ready;     // slaves are ready


    // Signals connecting to master device
    reg [4:0] memaddr;
    reg memwen;


    top_with_bb_v1 #(
        .ADDR_WIDTH(ADDR_WIDTH), 
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH ),
        .BB_ADDR_WIDTH(BB_ADDR_WIDTH),
        .UART_CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE)
    ) bus (
        .clk(clk), 
        .rstn(rstn),
        .d1_wdata(d1_wdata),   
        .d1_rdata(d1_rdata), 
        .d1_addr(d1_addr), 
        .d1_valid(d1_valid), 
        .m1_ready(m1_ready), 
        .m1_rw_mode(m1_rw_mode), 
        .s_ready(s_ready), 
        .m_u_rx(m_u_rx),
        .s_u_rx(s_u_rx),
        .m_u_tx(m_u_tx), 
        .s_u_tx(s_u_tx)
    );

    master_bram memory (
        .address(memaddr),
        .clock(clk),
        .data(d1_rdata),
        .wren(memwen),
        .q(d1_wdata)
    );

    wire edge_start;
    reg start_prev;

    assign d1_start = edge_start;
    assign edge_start = (start_prev) & (!start);

    // Buffer the start signal
    always @(posedge clk) begin
        if (!rstn) start_prev <= 1'b1;
        else start_prev <= start; 
    end

    localparam [15:0] ADDR = 16'b0100_0000_0000_0001;
    localparam [4:0] WRITE_OFFSET = 16;

    localparam IDLE = 2'b00,
            READ = 2'b01,
            SEND = 2'b10,
            DONE = 2'b11;

    // State variables
	reg [1:0] state, next_state;
    reg [1:0] counter;
    reg [1:0] idx;

    // Next state logic
	always @(*) begin
		case (state)
			IDLE    : next_state = (d1_start) ? ((!mode) ? SEND : READ) : IDLE;
			READ    : next_state = (counter == 1) ? SEND : READ;
			SEND    : next_state = (counter == 1) ? DONE : SEND; 
            DONE    : next_state = (m1_ready) ? IDLE : DONE;
			default: next_state = IDLE;
		endcase
	end

    // State transition logic
	always @(posedge clk) begin
		state <= (!rstn) ? IDLE : next_state;
	end

    assign ready = (state == IDLE);
    assign d1_addr = ADDR;

    always @(posedge clk) begin
        if (!rstn) begin
            memaddr <= 'b0;
            memwen <= 0;
            d1_valid <= 0;
            m1_rw_mode <= 0;
        end 
        else begin
            case (state)
                IDLE : begin
                    d1_valid <= 0;
                    memwen <= 0;
                    counter <= 'b0;

                    if (d1_start) begin
                        m1_rw_mode <= mode;

                        if (mode) begin     // write to new location, otherwise read from same location
                            memaddr <= d1_addr[4:0];
                        end else begin
                            memaddr <= WRITE_OFFSET + d1_addr[4:0];
                        end
                        
                    end else begin
                        m1_rw_mode <= m1_rw_mode;
                        memaddr <= memaddr;
                    end
                end

                READ : begin
                    d1_valid <= 0;
                    counter <= counter ^ 1;
                end

                SEND : begin
                    d1_valid <= 1;
                    counter <= counter ^ 1;
                end

                DONE : begin
                    d1_valid <= 0;
                    if (m1_ready) begin
                        memwen <= (!m1_rw_mode);
                    end 
                    else begin
                        memwen <= 0;
                    end
                end

                default: begin
                    memaddr <= memaddr;
                    memwen <= memwen;
                    d1_valid <= d1_valid;
                    m1_rw_mode <= m1_rw_mode;
                    counter <= counter;
                end

            endcase
        end
    end


endmodule
