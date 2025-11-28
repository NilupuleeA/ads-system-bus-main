`timescale 1ns/1ps

module master_port_tb;

    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 12;
    parameter SLAVE_DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;
    parameter CLK_PERIOD = 10;

    // DUT signals
    reg clk, rstn;
    reg [DATA_WIDTH-1:0] dwdata;
    wire [DATA_WIDTH-1:0] drdata;
    reg [ADDR_WIDTH-1:0] daddr;
    reg dvalid;
    wire dready;
    reg dmode;
    reg mrdata;
    wire mwdata;
    wire mmode;
    wire mvalid;
    reg svalid;
    wire mbreq;
    reg mbgrant;
    reg msplit;
    reg ack;

    // Instantiate DUT
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
        .msplit(msplit),
        .ack(ack)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test variables
    integer i;
    reg [DATA_WIDTH-1:0] expected_data;

    // Test stimulus
    initial begin
        // Initialize signals
        rstn = 0;
        dwdata = 0;
        daddr = 0;
        dvalid = 0;
        dmode = 0;
        mrdata = 0;
        svalid = 0;
        mbgrant = 0;
        msplit = 0;
        ack = 0;

        // Apply reset
        #(CLK_PERIOD*2);
        rstn = 1;
        #(CLK_PERIOD*2);

        $display("========================================");
        $display("Test 1: Write Operation");
        $display("========================================");
        
        // Test 1: Write transaction
        @(posedge clk);
        daddr = 16'hA5B3;
        dwdata = 8'hCD;
        dmode = 1'b1; // Write mode
        dvalid = 1'b1;
        
        @(posedge clk);
        dvalid = 1'b0;
        
        // Wait for bus request
        wait(mbreq == 1);
        $display("Time=%0t: Bus request asserted", $time);
        
        // Grant bus access
        @(posedge clk);
        mbgrant = 1'b1;
        
        // Wait for slave device address transmission
        @(posedge clk);
        mbgrant = 1'b0;
        
        // Collect slave device address bits
        for (i = 0; i < SLAVE_DEVICE_ADDR_WIDTH; i = i + 1) begin
            wait(mvalid == 1);
            @(posedge clk);
            $display("Time=%0t: SADDR bit[%0d] = %b", $time, i, mwdata);
        end
        
        // Acknowledge address
        @(posedge clk);
        ack = 1'b1;
        @(posedge clk);
        ack = 1'b0;
        
        // Collect memory address bits
        for (i = 0; i < SLAVE_MEM_ADDR_WIDTH; i = i + 1) begin
            wait(mvalid == 1);
            @(posedge clk);
            $display("Time=%0t: ADDR bit[%0d] = %b", $time, i, mwdata);
        end
        
        // Collect write data bits
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            wait(mvalid == 1);
            @(posedge clk);
            $display("Time=%0t: WDATA bit[%0d] = %b", $time, i, mwdata);
        end
        
        // Wait for completion
        wait(dready == 1);
        $display("Time=%0t: Write transaction completed\n", $time);
        
        #(CLK_PERIOD*5);

        $display("========================================");
        $display("Test 2: Read Operation");
        $display("========================================");
        
        // Test 2: Read transaction
        @(posedge clk);
        daddr = 16'h1234;
        dmode = 1'b0; // Read mode
        dvalid = 1'b1;
        expected_data = 8'h5A;
        
        @(posedge clk);
        dvalid = 1'b0;
        
        // Wait for bus request
        wait(mbreq == 1);
        $display("Time=%0t: Bus request asserted", $time);
        
        // Grant bus access
        @(posedge clk);
        mbgrant = 1'b1;
        
        @(posedge clk);
        mbgrant = 1'b0;
        
        // Collect slave device address
        for (i = 0; i < SLAVE_DEVICE_ADDR_WIDTH; i = i + 1) begin
            wait(mvalid == 1);
            @(posedge clk);
        end
        
        // Acknowledge address
        @(posedge clk);
        ack = 1'b1;
        @(posedge clk);
        ack = 1'b0;
        
        // Collect memory address
        for (i = 0; i < SLAVE_MEM_ADDR_WIDTH; i = i + 1) begin
            wait(mvalid == 1);
            @(posedge clk);
        end
        
        // Send read data bits
        @(posedge clk);
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            svalid = 1'b1;
            mrdata = expected_data[i];
            @(posedge clk);
        end
        svalid = 1'b0;
        
        // Wait for completion and verify
        wait(dready == 1);
        #(CLK_PERIOD);
        if (drdata == expected_data)
            $display("Time=%0t: Read data CORRECT: Expected=0x%h, Got=0x%h\n", $time, expected_data, drdata);
        else
            $display("Time=%0t: Read data ERROR: Expected=0x%h, Got=0x%h\n", $time, expected_data, drdata);
        
        #(CLK_PERIOD*5);

        $display("========================================");
        $display("Test 3: Read with SPLIT");
        $display("========================================");
        
        // Test 3: Read with split transaction
        @(posedge clk);
        daddr = 16'h9876;
        dmode = 1'b0; // Read mode
        dvalid = 1'b1;
        expected_data = 8'hAB;
        
        @(posedge clk);
        dvalid = 1'b0;
        
        // Wait for bus request and grant
        wait(mbreq == 1);
        @(posedge clk);
        mbgrant = 1'b1;
        @(posedge clk);
        mbgrant = 1'b0;
        
        // Send slave device address
        for (i = 0; i < SLAVE_DEVICE_ADDR_WIDTH; i = i + 1) begin
            wait(mvalid == 1);
            @(posedge clk);
        end
        
        @(posedge clk);
        ack = 1'b1;
        @(posedge clk);
        ack = 1'b0;
        
        // Send memory address
        for (i = 0; i < SLAVE_MEM_ADDR_WIDTH; i = i + 1) begin
            wait(mvalid == 1);
            @(posedge clk);
        end
        
        // Assert split signal
        @(posedge clk);
        msplit = 1'b1;
        $display("Time=%0t: SPLIT asserted", $time);
        
        #(CLK_PERIOD*10);
        
        // Release split and grant bus
        msplit = 1'b0;
        mbgrant = 1'b1;
        $display("Time=%0t: SPLIT released, bus granted", $time);
        
        @(posedge clk);
        mbgrant = 1'b0;
        
        // Send read data
        @(posedge clk);
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            svalid = 1'b1;
            mrdata = expected_data[i];
            @(posedge clk);
        end
        svalid = 1'b0;
        
        wait(dready == 1);
        #(CLK_PERIOD);
        if (drdata == expected_data)
            $display("Time=%0t: SPLIT Read CORRECT: Expected=0x%h, Got=0x%h\n", $time, expected_data, drdata);
        else
            $display("Time=%0t: SPLIT Read ERROR: Expected=0x%h, Got=0x%h\n", $time, expected_data, drdata);
        
        #(CLK_PERIOD*5);

        $display("========================================");
        $display("Test 4: Timeout Test (No ACK)");
        $display("========================================");
        
        // Test 4: Timeout scenario
        @(posedge clk);
        daddr = 16'hFFFF;
        dwdata = 8'h99;
        dmode = 1'b1;
        dvalid = 1'b1;
        
        @(posedge clk);
        dvalid = 1'b0;
        
        wait(mbreq == 1);
        @(posedge clk);
        mbgrant = 1'b1;
        @(posedge clk);
        mbgrant = 1'b0;
        
        // Send slave device address
        for (i = 0; i < SLAVE_DEVICE_ADDR_WIDTH; i = i + 1) begin
            wait(mvalid == 1);
            @(posedge clk);
        end
        
        // Do NOT send ACK - let it timeout
        $display("Time=%0t: Waiting for timeout...", $time);
        
        wait(dready == 1);
        $display("Time=%0t: Timeout occurred, returned to IDLE\n", $time);
        
        #(CLK_PERIOD*5);

        $display("========================================");
        $display("All tests completed!");
        $display("========================================");
        
        #(CLK_PERIOD*10);
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | State=%b | dready=%b | mbreq=%b | mvalid=%b | mwdata=%b | svalid=%b | mrdata=%b", 
                 $time, dut.state, dready, mbreq, mvalid, mwdata, svalid, mrdata);
    end

    // Waveform dump
    initial begin
        $dumpfile("master_port_tb.vcd");
        $dumpvars(0, master_port_tb);
    end

endmodule