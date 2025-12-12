`timescale 1ns/1ps

module arbiter_tb;
    logic clk;
    logic rst_n;
    logic req_m_1;
    logic req_m_2;
    logic req_split;
    logic grant_m_1;
    logic grant_m_2;
    logic grant_split;
    logic [1:0] sel;

    arbiter dut (
        .clk(clk),
        .rst_n(rst_n),
        .req_m_1(req_m_1),
        .req_m_2(req_m_2),
        .req_split(req_split),
        .grant_m_1(grant_m_1),
        .grant_m_2(grant_m_2),
        .grant_split(grant_split),
        .sel(sel)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task automatic reset_dut;
        begin
            rst_n = 0;
            req_m_1 = 0;
            req_m_2 = 0;
            req_split = 0;
            repeat (2) @(posedge clk);
            rst_n = 1;
            @(posedge clk);
        end
    endtask

    initial begin
        reset_dut();

        // Scenario: Both request simultaneously
        $display("[%0t] Asserting req_m_1 and req_m_2 simultaneously", $time);
        req_m_1 <= 1;
        req_m_2 <= 1;
        
        @(posedge clk); // Wait for state transition (IDLE -> GRANT)
        // In the RTL, state update is on posedge clk. Output is combinational based on state.
        // Cycle 1: inputs setup.
        // Posedge 1: State transition logic sees inputs. State updates.
        // Cycle 2: New state is valid. Outputs valid.
        
        @(posedge clk); 

        // Check priority (Initiator 1 should win)
        if (grant_m_1 && !grant_m_2 && sel == 2'b01) begin
            $display("[%0t] Priority Check PASS: Initiator 1 granted (grant_m_1=%b, grant_m_2=%b, sel=%b)", 
                     $time, grant_m_1, grant_m_2, sel);
        end else begin
            $error("[%0t] Priority Check FAIL: Expected Init 1 granted. Got grant_m_1=%b, grant_m_2=%b, sel=%b", 
                   $time, grant_m_1, grant_m_2, sel);
        end

        // Simulate Init 1 holding bus for a bit
        repeat (3) @(posedge clk);

        // Init 1 finishes
        $display("[%0t] De-asserting req_m_1 (Init 1 done)", $time);
        req_m_1 <= 0;
        // req_m_2 stays high

        // Arbiter logic:
        // ST_GRANT_INIT1: if (!req_m_1) following_state = ST_IDLE;
        // ST_IDLE: ... if (req_m_2) ...
        
        @(posedge clk); // Transitions ST_GRANT_INIT1 -> ST_IDLE
        // At this point output should be all 0s (IDLE)

        @(posedge clk); // Transitions ST_IDLE -> ST_GRANT_INIT2
        // Now Init 2 should have it
        
        if (!grant_m_1 && grant_m_2 && sel == 2'b10) begin
            $display("[%0t] Handover Check PASS: Initiator 2 granted (grant_m_1=%b, grant_m_2=%b, sel=%b)", 
                     $time, grant_m_1, grant_m_2, sel);
        end else begin
            $error("[%0t] Handover Check FAIL: Expected Init 2 granted. Got grant_m_1=%b, grant_m_2=%b, sel=%b", 
                   $time, grant_m_1, grant_m_2, sel);
        end

        // Simulate Init 2 holding bus
        repeat (3) @(posedge clk);

        // Init 2 finishes
        $display("[%0t] De-asserting req_m_2 (Init 2 done)", $time);
        req_m_2 <= 0;

        @(posedge clk); // Transitions ST_GRANT_INIT2 -> ST_IDLE
        @(posedge clk); 

        if (!grant_m_1 && !grant_m_2 && sel == 2'b00) begin
             $display("[%0t] Idle Check PASS: Bus idle", $time);
        end else begin
             $error("[%0t] Idle Check FAIL: Bus not idle. grant_m_1=%b, grant_m_2=%b, sel=%b", 
                    $time, grant_m_1, grant_m_2, sel);
        end

        $display("[%0t] arbiter_tb completed", $time);
        $finish;
    end

endmodule
