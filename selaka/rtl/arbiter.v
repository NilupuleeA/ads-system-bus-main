module arbiter(
    input wire      clk,
    input wire      rstn,

    input wire      breq1,
    input wire      breq2,
    input wire      sready1,
    input wire      sready2,
    input wire      sreadysp,
    input wire      ssplit,

    output reg      bgrant1,
    output reg      bgrant2,
    output reg      msel,
    output reg      msplit1,
    output reg      msplit2,
    output reg      split_grant
);
//bgrant will be high after two clock cycles of breq high and sready high


localparam IDLE     = 2'b00;
localparam M1       = 2'b01;
localparam M2       = 2'b10;

reg [1:0]           state;
reg [1:0]           next_state;
reg [1:0]           split_owner;
wire sready, sready_nsplit;


assign sready = sready1 & sready2 & sreadysp;
assign sready_nsplit = sready1 & sready2;		

localparam NONE     = 2'b00;
localparam SM1   = 2'b01;
localparam SM2   = 2'b10;

always @(posedge clk) begin
   if(!rstn) begin
    bgrant1         <= 1'b0;     
    bgrant2         <= 1'b0;
    msel            <= 1'b0;
    msplit1         <= 1'b0;
    msplit2         <= 1'b0;
    split_grant     <= 1'b0;
    state           <= IDLE;
    next_state      <= IDLE;
    split_owner     <= NONE;
   end 
   else begin
    case(state)
        IDLE: begin
        bgrant1 <= 1'b0;
        bgrant2 <= 1'b0;
        // msel <= 1'b0;
        //here we receive bgrant, split grant two clock cycles after the ssplit is deasserted.
        //we can reduce this to one clock cycle by changing the IDLE state login.arbiter
        //we can sent split_grant and bgrant directly on the idle state. and also deassert the msplit signal here itself.
            if (!ssplit) begin	
					if ((split_owner == SM1) || (breq1 & sready))  state <= M1;
					else if ((split_owner == SM2) || (breq2 & sready)) state <= M2;
					else state <= IDLE;
			end
            else begin		// One master is waiting for a split transaction, other master can continue
					if ((split_owner == SM1) && breq2 && sready_nsplit) state <= M2;
					else if ((split_owner == SM2) && breq1 && sready_nsplit) state <= M1;
					else state <= IDLE;
			end
        end

        M1: begin
            if (split_owner == NONE && ssplit) begin
                msplit1 <= 1'b1;
                split_owner <= SM1;
                split_grant <= 1'b0;
                bgrant1 <= 1'b0;
                bgrant2 <= 1'b0;
                state <= IDLE;
                msel <= 1'b0;
            end 
            else if (split_owner == SM1 && !ssplit) begin
                msplit1 <= 1'b0;
                split_owner <= NONE;
                split_grant <= 1'b1;
                bgrant1 <= 1'b1;
                bgrant2 <= 1'b0;
                msel <= 1'b0;
            end 
            else if (!breq1) begin
                bgrant1 <= 1'b0;
                bgrant2 <= 1'b0;
                msel <= 1'b0;
                state <= IDLE;
            end
            else begin
                msplit1 <= msplit1;
                split_owner <= split_owner;
                split_grant <= 1'b0;
                bgrant1 <= 1'b1;
                bgrant2 <= 1'b0;
                msel <= 1'b0;
            end
        end

        M2: begin
            if (split_owner == NONE && ssplit) begin        //receving split for master 2 current transaction
                msplit2 <= 1'b1;
                split_owner <= SM2;
                split_grant <= 1'b0;
                bgrant1 <= 1'b0;
                bgrant2 <= 1'b0;
                state <= IDLE;
                msel <= 1'b0;
            end 
            else if (split_owner == SM2 && !ssplit) begin   //continue the master 2 split transaction after the split is done
                msplit2 <= 1'b0;
                split_owner <= NONE;
                split_grant <= 1'b1;
                bgrant1 <= 1'b0;
                bgrant2 <= 1'b1;
                msel <= 1'b1;
            end 
             else if (!breq2) begin                         //master 2 release the bus
                bgrant1 <= 1'b0;
                bgrant2 <= 1'b0;
                msel <= 1'b0;
                state <= IDLE;
            end
            else begin
                msplit2 <= msplit2;
                split_owner <= split_owner;
                split_grant <= 1'b0;
                bgrant1 <= 1'b0;
                bgrant2 <= 1'b1;
                msel <= 1'b1;
            end
        end

        default : begin
            msplit1 <= msplit1;
            msplit2 <= msplit2;
            split_owner <= split_owner;
            split_grant <= split_grant;
            bgrant1 <= 1'b0;
            bgrant2 <= 1'b0;
            msel <= 1'b0;
            
        end


    endcase

   end


end




endmodule
