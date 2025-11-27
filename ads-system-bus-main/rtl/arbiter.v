//module arbiter
//(
//	input clk, rstn,
//	input breq1, breq2,  //bus requests from 2 masters
//	input sready1, sready2, sreadysp,   //slave ready, sreadysp = split supported slave
//	input ssplit,			// slave split
//	
//	output bgrant1, bgrant2,  //bus grant signals for 2 masters
//	output msel, //master select; 0 - master 1, 1 - master 2
//	output reg msplit1, msplit2,		// Split signals given to master
//	output reg split_grant			// grant access to continue split transaction (send back to slave)
//);
//	
//	//priority based: high priority for master 1 - breq1
//
//	wire sready, sready_nsplit;
//	reg [1:0] split_owner;
//
//	assign sready = sready1 & sready2 & sreadysp;
//	assign sready_nsplit = sready1 & sready2;		// not split slaves are ready
//
//	// Split owner encoding
//	localparam NONE = 2'b00,
//			   SM1 = 2'b01,
//			   SM2 = 2'b10;
//
//	// States
//    localparam IDLE  = 3'b000,    //0
//               M1  = 3'b001, 	// M1 uses bus//1
//			   M2 = 3'b010;	// M2 uses bu3 //3
//
//	// State variables
//	reg [2:0] state, next_state;
//
//	// Next state logic
//	always @(*) begin
//		case (state)
//			IDLE  : begin
//				if (!ssplit) begin	// either split was released or no split was there
//					if (split_owner == SM1) next_state = M1;
//					else if (breq1 & sready) next_state = M1;
//					else if (split_owner == SM2) next_state = M2;
//					else if (breq2 & sready) next_state = M2;
//					else next_state = IDLE;
//				end
//				else begin		// One master is waiting for a split transaction, other master can continue
//					if ((split_owner == SM1) && breq2 && sready_nsplit) next_state = M2;
//					else if ((split_owner == SM2) && breq1 && sready_nsplit) next_state = M1;
//					else next_state = IDLE;
//				end
//			end 
//			M1  : next_state = (!breq1 | (split_owner == NONE && ssplit)) ? IDLE : M1;
//			M2 : next_state = (!breq2 | (split_owner == NONE && ssplit)) ? IDLE : M2;
//			default: next_state = IDLE;
//		endcase
//	end
//
//	// State transition logic
//	always @(posedge clk) begin
//		state <= (!rstn) ? IDLE : next_state;
//	end
//
//	// Combinational output assignments
//	assign bgrant1 = (state == M1);
//	assign bgrant2 = (state == M2);
//	assign msel = (state == M2);
//
//	// Sequential output assignments (for split)
//	always @(posedge clk) begin
//		if (!rstn) begin
//			msplit1 <= 1'b0;
//			msplit2 <= 1'b0;
//			split_owner <= NONE;
//			split_grant <= 1'b0;
//		end
//		else begin
//			case (state)
//
//				M1 : begin
//					if (split_owner == NONE && ssplit) begin
//						msplit1 <= 1'b1;
//						split_owner <= SM1;
//						split_grant <= 1'b0;
//					end else if (split_owner == SM1 && !ssplit) begin
//						msplit1 <= 1'b0;
//						split_owner <= NONE;
//						split_grant <= 1'b1;
//					end else begin
//						msplit1 <= msplit1;
//						split_owner <= split_owner;
//						split_grant <= 1'b0;
//					end
//				end
//
//				M2 : begin
//					if (split_owner == NONE && ssplit) begin
//						msplit2 <= 1'b1;
//						split_owner <= SM2;
//						split_grant <= 1'b0;
//					end else if (split_owner == SM2 && !ssplit) begin
//						msplit2 <= 1'b0;
//						split_owner <= NONE;
//						split_grant <= 1'b1;
//					end else begin
//						msplit2 <= msplit2;
//						split_owner <= split_owner;
//						split_grant <= 1'b0;
//					end
//				end
//
//				default : begin
//					msplit1 <= msplit1;
//					msplit2 <= msplit2;
//					split_owner <= split_owner;
//					split_grant <= split_grant;
//				end
//			endcase
//		end
//	end
//
//endmodule

module arbiter (
    input  wire clk, rstn,
    input  wire breq1, breq2,          // bus requests from 2 masters
    input  wire sready1, sready2, sreadysp, // slave ready signals
    input  wire ssplit,                // slave split

    output wire bgrant1, bgrant2,      // bus grants
    output wire msel,                  // master select (0 - M1, 1 - M2)
    output reg  msplit1, msplit2,      // split signals to masters
    output reg  split_grant            // split grant back to slave
);

    // Combine ready signals
    wire sready        = sready1 & sready2 & sreadysp;
    wire sready_nsplit = sready1 & sready2;

    // Split owner encoding
    localparam NONE = 2'b00,
               SM1  = 2'b01,
               SM2  = 2'b10;

    reg [1:0] split_owner;

    // FSM states
    localparam IDLE = 3'b000,
               M1   = 3'b001,
               M2   = 3'b010;

    reg [2:0] state;

    // Outputs derived directly from state
    assign bgrant1 = (state == M1);
    assign bgrant2 = (state == M2);
    assign msel    = (state == M2);

    // Unified FSM
    always @(posedge clk) begin
        if (!rstn) begin
            state        <= IDLE;
            msplit1      <= 1'b0;
            msplit2      <= 1'b0;
            split_owner  <= NONE;
            split_grant  <= 1'b0;
        end else begin
            // Default values (hold)
            split_grant <= 1'b0;

            case (state)
                //-----------------------------------
                IDLE: begin
                    if (!ssplit) begin
                        if (split_owner == SM1)       state <= M1;
                        else if (breq1 && sready)     state <= M1;
                        else if (split_owner == SM2)  state <= M2;
                        else if (breq2 && sready)     state <= M2;
                        else                          state <= IDLE;
                    end else begin
                        if ((split_owner == SM1) && breq2 && sready_nsplit)
                            state <= M2;
                        else if ((split_owner == SM2) && breq1 && sready_nsplit)
                            state <= M1;
                        else
                            state <= IDLE;
                    end
                end

                //-----------------------------------
                M1: begin
                    if (!breq1 || (split_owner == NONE && ssplit))
                        state <= IDLE;
                    else
                        state <= M1;

                    // Split handling
                    if (split_owner == NONE && ssplit) begin
                        msplit1     <= 1'b1;
                        split_owner <= SM1;
                    end else if (split_owner == SM1 && !ssplit) begin
                        msplit1     <= 1'b0;
                        split_owner <= NONE;
                        split_grant <= 1'b1;
                    end
                end

                //-----------------------------------
                M2: begin
                    if (!breq2 || (split_owner == NONE && ssplit))
                        state <= IDLE;
                    else
                        state <= M2;

                    // Split handling
                    if (split_owner == NONE && ssplit) begin
                        msplit2     <= 1'b1;
                        split_owner <= SM2;
                    end else if (split_owner == SM2 && !ssplit) begin
                        msplit2     <= 1'b0;
                        split_owner <= NONE;
                        split_grant <= 1'b1;
                    end
                end

                //-----------------------------------
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

