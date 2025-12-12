module arbiter(
    input logic clk,
    input logic rst_n,
    input logic req_m_1,
    input logic req_m_2,
    input logic req_split,
    output logic grant_m_1,
    output logic grant_m_2,
    output logic grant_split,
    output logic [1:0] sel
);
    typedef enum logic [1:0] {
        ST_IDLE,
        ST_GRANT_INIT1,
        ST_GRANT_INIT2,
        ST_GRANT_SPLIT_TGT
    } arb_state_t;

    arb_state_t present_state, following_state;

    // State transition
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            present_state <= ST_IDLE;
        else
            present_state <= following_state;
    end

    // Next state logic
    always_comb begin
        following_state = present_state;
        case (present_state)
            ST_IDLE: begin
                if (req_split)
                    following_state = ST_GRANT_SPLIT_TGT;
                else if (req_m_1)
                    following_state = ST_GRANT_INIT1;
                else if (req_m_2)
                    following_state = ST_GRANT_INIT2;
            end
            ST_GRANT_INIT1: begin
                if (!req_m_1)
                    following_state = ST_IDLE;
            end
            ST_GRANT_INIT2: begin
                if (!req_m_2)
                    following_state = ST_IDLE;
            end
            ST_GRANT_SPLIT_TGT: begin
                if (!req_split)
                    following_state = ST_IDLE;
            end
        endcase
    end

    // Output logic
    always_comb begin
        grant_m_1 = 0;
        grant_m_2 = 0;
        grant_split = 0;
        sel = 2'b00;

        case (present_state)
            ST_GRANT_INIT1: begin
                grant_m_1 = 1;
                sel = 2'b01;
            end
            ST_GRANT_INIT2: begin
                grant_m_2 = 1;
                sel = 2'b10;
            end
            ST_GRANT_SPLIT_TGT: begin
                grant_split = 1;
            end
        endcase
    end
endmodule
