`timescale 1ns/1ps

module addr_dec_tb;

    // DUT parameters
    parameter ADDR_WIDTH = 16;
    parameter DEVICE_ADDR_WIDTH = 4;
    parameter NUM_SLAVE = 3;

    // Signals
    reg clk;
    reg rstn;
    reg addr_valid;
    reg addr_data;
    reg [NUM_SLAVE-1:0] sready;
    reg split;
    reg split_grant;

    wire [DEVICE_ADDR_WIDTH-1:0] ssel;
    wire ack;

    wire [1:0] state_out;
    wire [3:0] counter_out;
    wire [2:0] mvalid;

    // DUT instantiation
    addr_dec #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEVICE_ADDR_WIDTH(DEVICE_ADDR_WIDTH),
        .NUM_SLAVE(NUM_SLAVE)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .addr_valid(addr_valid),
        .addr_data(addr_data),
        .sready(sready),
        .split(split),
        .split_grant(split_grant),
        .ssel(ssel),
        .ack(ack),
        .state_out(state_out),
        .counter_out(counter_out),
        .mvalid(mvalid)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to send DEVICE_ADDR_WIDTH-bit slave address LSB first
    task send_addr(input [DEVICE_ADDR_WIDTH-1:0] addr);
        integer i;
        begin
            addr_valid = 1'b1;
            for (i = 0; i < DEVICE_ADDR_WIDTH; i = i + 1) begin
                addr_data = addr[i];
                @(posedge clk);
            end
            addr_valid = 1'b0;
            addr_data = 1'b0;
            @(posedge clk);
        end
    endtask

    task send_data_addr(input [ADDR_WIDTH-DEVICE_ADDR_WIDTH-1:0] addr);
        integer i;
        begin
            addr_valid<=1'b1;
            for (i = 0; i < ADDR_WIDTH-DEVICE_ADDR_WIDTH; i = i + 1) begin
                addr_data = addr[i];
                if(i>=1) begin
                    sready = 3'b011; //stop sending address after 2 bits to simulate split transaction
                end
                
                @(posedge clk);
            end
            addr_valid = 1'b0;
            addr_data = 1'b0;
            sready = 3'b011;
            @(posedge clk);
        end
    endtask

    // Test sequence
    initial begin
        // Initialization
        rstn = 0;
        addr_valid = 0;
        addr_data = 0;
        sready = {NUM_SLAVE{1'b1}}; // all slaves ready
        split = 0;
        split_grant = 0;

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);  
        rstn = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        

        send_addr(2);
        @(posedge clk);

        wait (ack == 1);
        send_data_addr(10);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        $finish;
    end


endmodule
