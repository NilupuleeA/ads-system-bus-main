//module demo_master #(
//	parameter ADDR_WIDTH = 16, 
//	parameter DATA_WIDTH = 8,
//	parameter SLAVE_MEM_ADDR_WIDTH = 12,
//    parameter SLAVE_COUNT = 3,
//    parameter [0:(4 * ADDR_WIDTH-1)] ADDRS = {16'h0009, 16'h1001, 16'h2002, 16'h0009}
//)(
//	input clk, rstn,
//	
//	// Signals connecting to serial bus
//	input mrdata,	// read data
//	output mwdata,	// write data and address
//	output mmode,	// 0 -  read, 1 - write
//	output mvalid,	// wdata valid
//	input svalid,	// rdata valid
//	input debug,
//	// Signals to arbiter
//	output mbreq,
//	input mbgrant,
//    input msplit,
//
//	// Acknowledgement from address decoder 
//	input ack,
//
//    // Control signals
//    input start,
//    input mode,
//    output ready,
//    output reg [DATA_WIDTH-1:0] demo_masdata
//);
//
//    localparam DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;
//    localparam [4:0] WRITE_OFFSET = 16;
//
//    // Signals connecting to master device
//	wire [DATA_WIDTH-1:0] dwdata; // write data
//	wire [DATA_WIDTH-1:0] drdata;	// read data
//	wire [ADDR_WIDTH-1:0] daddr;
//	reg dvalid; 			 		// ready valid interface
//	wire dready;
//	reg dmode;					// 0 - read, 1 - write
//
//    reg [4:0] memaddr;
//    reg memwen;
//
//   /* always @(posedge clk) begin
//		 if (!rstn)
//			  demo_masdata <= 8'b0;                   // reset to zero
//		 else if (!memwen)
//			  demo_masdata <= drdata;            // write new data when enabled
//	end */
//
//    master_port #(
//        .ADDR_WIDTH(ADDR_WIDTH),
//        .DATA_WIDTH(DATA_WIDTH),
//        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
//    ) dut (
//        .clk(clk),
//        .rstn(rstn),
//        .dwdata(dwdata),
//        .drdata(drdata),
//        .daddr(daddr),
//        .dvalid(dvalid),
//        .dready(dready),
//        .dmode(dmode),
//        .mrdata(mrdata),
//        .mwdata(mwdata),
//        .mmode(mmode),
//        .mvalid(mvalid),
//        .svalid(svalid),
//        .mbreq(mbreq),
//        .mbgrant(mbgrant),
//        .ack(ack),
//        .msplit(msplit)
//    );
//
//    master_bram memory (
//        .address(memaddr),
//        .clock(clk),
//        .data(drdata),
//        .wren(memwen),
//        .q(dwdata)
//    );
//
//    localparam IDLE = 3'b000,
//               READ = 3'b001,
//               SEND = 3'b010,
//               DONE = 3'b011,
//					DEBUG = 3'b100;
//
//    // State variables
//	reg [2:0] state, next_state;
//    reg [1:0] counter;
//    reg [1:0] idx;
//
//    // Next state logic
//	always @(*) begin
//		case (state)
//			IDLE    : next_state = (start) ? ((debug) ? DEBUG: ((!mode) ? SEND : READ)) : IDLE;
//			READ    : next_state = (counter == 1) ? SEND : READ;
//			SEND    : next_state = (counter == 1) ? DONE : SEND; 
//         DONE    : next_state = (dready) ? IDLE : DONE;
//			DEBUG	  : next_state = (!debug) ? IDLE : DEBUG;
//			default: next_state = IDLE;
//		endcase
//	end
//
//    // State transition logic
//	always @(posedge clk) begin
//		state <= (!rstn) ? IDLE : next_state;
//	end
//
//    assign ready = (state == IDLE);
//    assign daddr = ADDRS[(ADDR_WIDTH * idx)+:ADDR_WIDTH];
//
//    always @(posedge clk) begin
//        if (!rstn) begin
//            memaddr <= 'b0;
//            memwen <= 0;
//            dvalid <= 0;
//            dmode <= 0;
//            idx <= 2'b00;
//				demo_masdata <= 0;
//        end 
//        else begin
//            case (state)
//                IDLE : begin
//                    dvalid <= 0;
//                    memwen <= 0;
//                    counter <= 'b0;
//
//                    if (start) begin
//                        dmode <= mode;
//
//                        if (mode) begin     // write to new location, otherwise read from same location
//                            memaddr <= daddr[3:0];
//                        end else begin
//                            memaddr <= WRITE_OFFSET + daddr[3:0];
//                        end
//                        
//                    end else begin
//                        dmode <= dmode;
//                        memaddr <= memaddr;
//                    end
//                end
//
//                READ : begin
//                    dvalid <= 0;
//                    counter <= counter ^ 1;
//                end
//
//                SEND : begin
//                    dvalid <= 1;
//                    counter <= counter ^ 1;
//                end
//
//                DONE : begin
//                    dvalid <= 0;
//                    if (dready) begin
//                        memwen <= (!dmode);   // dmode = 0 (write), memwen = 1; (read)
//                        idx <= idx + 2'b01;
//                    end 
//                    else begin
//                        memwen <= 0;
//                        idx <= idx;
//                    end
//                end
//					 
//					 DEBUG : begin
//						 memaddr <= 5'b0;
//						 memwen <= 1'b0;
//						 demo_masdata <= 	dwdata;
//						 
//					end
//                default: begin
//                    memaddr <= memaddr;
//                    memwen <= memwen;
//                    dvalid <= dvalid;
//                    dmode <= dmode;
//                    counter <= counter;
//                    idx <= idx;
//                end
//
//            endcase
//        end
//    end
//
//endmodule




module demo_master #(
    parameter ADDR_WIDTH = 16, 
    parameter DATA_WIDTH = 8,
    parameter SLAVE_MEM_ADDR_WIDTH = 12,
    parameter SLAVE_COUNT = 3,
    parameter [0:(4 * ADDR_WIDTH-1)] ADDRS = {16'h0009, 16'h1001, 16'h2002, 16'h0009}
)(
    input clk, rstn,

    // Serial bus interface
    input mrdata,
    output mwdata,
    output mmode,
    output mvalid,
    input svalid,
    input debug,

    // Arbiter signals
    output mbreq,
    input mbgrant,
    input msplit,

    // Address decoder ack
    input ack,

    // Control signals
    input start,
    input mode,
    output ready,
    output reg [DATA_WIDTH-1:0] demo_masdata
);

    localparam DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;
    localparam [4:0] WRITE_OFFSET = 16;

    // Master port interface
    wire [DATA_WIDTH-1:0] dwdata;
    wire [DATA_WIDTH-1:0] drdata;
    wire [ADDR_WIDTH-1:0] daddr;
    reg dvalid;
    wire dready;
    reg dmode;

    // Local memory interface
    reg [4:0] memaddr;
    reg memwen;

    // Instantiate master port
    master_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .dwdata(dwdata),
        .drdata(drdata),
        .daddr(daddr),
        .dvalid(dvalid),
        .dready(dready),
        .dmode(dmode),
        .mrdata(mrdata),
        .mwdata(mwdata),
        .mmode(mmode),
        .mvalid(mvalid),
        .svalid(svalid),
        .mbreq(mbreq),
        .mbgrant(mbgrant),
        .ack(ack),
        .msplit(msplit)
    );

    // Local memory (block RAM)
    master_bram memory (
        .address(memaddr),
        .clock(clk),
        .data(drdata),
        .wren(memwen),
        .q(dwdata)
    );

    // FSM states
    localparam IDLE  = 3'b000,
               READ  = 3'b001,
               SEND  = 3'b010,
               DONE  = 3'b011,
               DEBUG = 3'b100;

    reg [2:0] state;
    reg [1:0] counter;
    reg [1:0] idx;

    assign ready = (state == IDLE);
    assign daddr = ADDRS[(ADDR_WIDTH * idx) +: ADDR_WIDTH];

    // Unified FSM block
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            memaddr <= 'b0;
            memwen <= 1'b0;
            dvalid <= 1'b0;
            dmode <= 1'b0;
            idx <= 2'b00;
            counter <= 'b0;
            demo_masdata <= 'b0;
        end else begin
            case (state)

                /* -------------------- IDLE -------------------- */
                IDLE: begin
                    dvalid <= 0;
                    memwen <= 0;
                    counter <= 0;

                    if (start) begin
                        dmode <= mode;
                        if (debug)
                            state <= DEBUG;
                        else
                            state <= (mode) ? READ : SEND;

                        if (mode)
                            memaddr <= daddr[3:0];
                        else
                            memaddr <= WRITE_OFFSET + daddr[3:0];
                    end else begin
                        state <= IDLE;
                    end
                end

                /* -------------------- READ -------------------- */
                READ: begin
                    dvalid <= 0;
                    counter <= counter ^ 1;
                    if (counter == 1)
                        state <= SEND;
                    else
                        state <= READ;
                end

                /* -------------------- SEND -------------------- */
                SEND: begin
                    dvalid <= 1;
                    counter <= counter ^ 1;
                    if (counter == 1)
                        state <= DONE;
                    else
                        state <= SEND;
                end

                /* -------------------- DONE -------------------- */
                DONE: begin
                    dvalid <= 0;
                    if (dready) begin
                        memwen <= !dmode; // if read (dmode=0), enable write to mem
                        idx <= idx + 1;
                        state <= IDLE;
                    end else begin
                        memwen <= 0;
                        state <= DONE;
                    end
                end

                /* -------------------- DEBUG -------------------- */
                DEBUG: begin
                    memaddr <= 5'b0;
                    memwen <= 1'b0;
                    demo_masdata <= dwdata;
                    if (!debug)
                        state <= IDLE;
                    else
                        state <= DEBUG;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
