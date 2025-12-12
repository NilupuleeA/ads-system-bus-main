`timescale 1ns/1ps

module arbiter_tb;

    // DUT signals
    reg clk;
    reg rstn;

    reg breq1;
    reg breq2;
    reg sready1;
    reg sready2;
    reg sreadysp;
    reg ssplit;

    wire bgrant1;
    wire bgrant2;
    wire msel;
    wire msplit1;
    wire msplit2;
    wire split_grant;

    // DUT instantiation
    arbiter dut (
        .clk(clk),
        .rstn(rstn),
        .breq1(breq1),
        .breq2(breq2),
        .sready1(sready1),
        .sready2(sready2),
        .sreadysp(sreadysp),
        .ssplit(ssplit),
        .bgrant1(bgrant1),
        .bgrant2(bgrant2),
        .msel(msel),
        .msplit1(msplit1),
        .msplit2(msplit2),
        .split_grant(split_grant)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset task
    task reset_dut;
        begin
            rstn = 0;
            breq1 = 0; breq2 = 0;
            sready1 = 1; sready2 = 1; sreadysp = 1;
            ssplit = 0;
            @(posedge clk);
            rstn = 1;
            @(posedge clk);
        end
    endtask

    // Master request task
    task request_master(input reg master1, input reg master2);
        begin
            breq1 = master1;
            breq2 = master2;
            @(posedge clk);
            @(posedge clk);
        end
    endtask

    // Slave split task
    task slave_split(input reg ssplit_val);
        begin
            ssplit = ssplit_val;
            @(posedge clk);
        end
    endtask

    // Slave ready task
    task set_slave_ready(input reg r1, input reg r2, input reg rsp);
        begin
            sready1 = r1;
            sready2 = r2;
            sreadysp = rsp;
            @(posedge clk);
        end
    endtask

    // Test sequence
    initial begin
        // Reset DUT
        reset_dut();
        set_slave_ready(1, 1, 1);
        // @(posedge clk);
        // @(posedge clk);
        // request_master(1, 0);
        // @(posedge clk);
        // @(posedge clk);
        // request_master(0, 0);
        // @(posedge clk);
        // @(posedge clk);
        // request_master(0, 1);
        // @(posedge clk);
        // @(posedge clk);
        // request_master(0, 0);
        // //slave_split(1);
        // @(posedge clk);
        // @(posedge clk);
        // request_master(1, 1);
        // @(posedge clk);
        // @(posedge clk);
        // request_master(0, 0);
        //slave_split(0);

        @(posedge clk);
        request_master(1, 0);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        slave_split(1);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        slave_split(0);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);




        $finish;
    end



endmodule
