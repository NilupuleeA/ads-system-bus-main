`timescale 1ns/1ps

// This TB has both masters for convenience
// But only 1 will be tested

module top_bram_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 12;
    parameter DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;

    // External signals
    reg clk, rstn;
    reg [DATA_WIDTH-1:0] d1_wdata, d2_wdata;  // Write data to the DUT
    wire [DATA_WIDTH-1:0] d1_rdata, d2_rdata; // Read data from the DUT
    reg [ADDR_WIDTH-1:0] d1_addr, d2_addr;
    reg d1_valid, d2_valid; 				  // Ready valid interface
    wire d1_ready, d2_ready;
    reg d1_mode, d2_mode;					  // 0 - read, 1 - write
    wire s_ready;
    
    top_with_bram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),

        .d1_wdata(d1_wdata),
        .d1_rdata(d1_rdata),
        .d1_addr(d1_addr),
        .d1_valid(d1_valid),
        .d1_ready(d1_ready),
        .d1_mode(d1_mode),

        .d2_wdata(d2_wdata),
        .d2_rdata(d2_rdata),
        .d2_addr(d2_addr),
        .d2_valid(d2_valid),
        .d2_ready(d2_ready),
        .d2_mode(d2_mode),

        .s_ready(s_ready)
    );

    // Generate Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period is 10 units
    end

    integer i;
    reg [ADDR_WIDTH-1:0] rand_addr1, rand_addr2, rand_addr3;
    reg [DATA_WIDTH-1:0] rand_data1, rand_data2;
    reg [DATA_WIDTH-1:0] slave_mem_data1, slave_mem_data2;
    reg [1:0] slave_id1, slave_id2;

    task random_delay;
        integer delay;
        begin
            delay = $urandom % 10;  // Generate a random delay multiplier between 0 and 4
            $display("Random delay: %d", delay * 10);
            #(delay * 10);  // Delay in multiples of 10 time units (clock period)
        end
    endtask

    // Test Stimulus
    initial begin

        // Reset the DUT
        rstn = 0;
        d1_valid = 0;
        d1_wdata = 8'b0;
        d1_addr = 16'b0;
        d1_mode = 0;
        d2_valid = 0;
        d2_wdata = 8'b0;
        d2_addr = 16'b0;
        d2_mode = 0;

        #15 rstn = 1; // Release reset after 15 time units

        // Slave 1 is the 2K slave

        // Repeat the write and read tests 10 times
        for (i = 0; i < 10; i = i + 1) begin

            // Generate random address and data
            rand_addr1 = $random & 14'h3FFF;
            rand_data1 = $random;
            rand_addr2 = $random & 14'h3FFF;
            rand_data2 = $random;

            slave_id1 = rand_addr1[ADDR_WIDTH-DEVICE_ADDR_WIDTH+:2];
            slave_id2 = rand_addr2[ADDR_WIDTH-DEVICE_ADDR_WIDTH+:2];

            // Write Operation: Sending data to the bus
            // Do 2 request next to each other from different masters

            wait (d1_ready == 1 && d2_ready == 1 && s_ready == 1);
            @(posedge clk);
            d1_addr = rand_addr1[ADDR_WIDTH-1:0];  // Set address with random value
            d1_wdata = rand_data1[DATA_WIDTH-1:0]; // Write data value
            d1_mode = 1;                          // Set mode to write
            d1_valid = 1;                         // Assert valid signal

            random_delay();

            // Make request from m2
            @(posedge clk)
            d2_addr = rand_addr2[ADDR_WIDTH-1:0];  // Set address with random value
            d2_wdata = rand_data2[DATA_WIDTH-1:0]; // Write data value
            d2_mode = 1;                          // Set mode to write
            d2_valid = 1;                         // Assert valid signal

            #20;
            d1_valid = 0;
            d2_valid = 0;

            wait (d1_ready == 1 && d2_ready == 1 && s_ready == 1);

            #20;

            // if (slave_id1 == 2'b00)  slave_mem_data1 = dut.slave1.sm.memory[d1_addr[10:0]];
            // else if (slave_id1 == 2'b01)  slave_mem_data1 = dut.slave2.sm.memory[d1_addr[11:0]];
            // else if (slave_id1 == 2'b10)  slave_mem_data1 = dut.slave3.sm.memory[d1_addr[11:0]];

            // if (slave_id1 != 2'b11 && slave_mem_data1 != d1_wdata) begin
            //     $display("Master 1 write failed at iteration %0d: location %x, expected %x, actual %x", 
            //                 i, d1_addr, d1_wdata, slave_mem_data1);
            // end else begin
            //     $display("Master 1 write to %0x successful at iteration %0d", d1_addr, i);
            // end

            // if (slave_id2 == 2'b00)  slave_mem_data2 = dut.slave1.sm.memory[d2_addr[10:0]];
            // else if (slave_id2 == 2'b01)  slave_mem_data2 = dut.slave2.sm.memory[d2_addr[11:0]];
            // else if (slave_id2 == 2'b10)  slave_mem_data2 = dut.slave3.sm.memory[d2_addr[11:0]];


            // if (slave_id2 != 2'b11 && slave_mem_data2 != d2_wdata) begin
            //     $display("Master 2 write failed at iteration %0d: location %x, expected %x, actual %x", 
            //                 i, d2_addr, d2_wdata, slave_mem_data2);
            // end else begin
            //     $display("Master 2 write to %0x successful at iteration %0d", d2_addr, i);
            // end

            // Read operation: make both requests on the same clock cycle
            @(posedge clk);
            d1_mode = 0;                         // Set mode to read
            d1_valid = 1;                        // Assert valid signal
            d2_mode = 0;
            d2_valid = 1;

            #20;
            d1_valid = 0;
            d2_valid = 0;
            wait (d1_ready == 1 && d2_ready == 1 && s_ready == 1);

            #20;

            if (slave_id1 != 2'b11 && d1_wdata != d1_rdata) begin
                $display("Master 1 read failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, d1_addr, d1_wdata, d1_rdata);
            end else begin
                $display("Master 1 read from %0x successful at iteration %0d", d1_addr, i);
            end

            if (slave_id2 != 2'b11 && d2_wdata != d2_rdata) begin
                $display("Master 2 read failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, d2_addr, d2_wdata, d2_rdata);
            end else begin
                $display("Master 2 read from %0x successful at iteration %0d", d2_addr, i);
            end

            // Master 2 write and master 1 read
            rand_addr3 = $random & 14'h3FFF;
            slave_id1 = rand_addr3[ADDR_WIDTH-DEVICE_ADDR_WIDTH+:2];

            @(posedge clk);
            d2_addr = rand_addr3[ADDR_WIDTH-1:0];  // Set address with random value
            d2_wdata = rand_data1 + rand_data2; // Write data value
            d2_mode = 1;                          // Set mode to write
            d2_valid = 1;                         // Assert valid signal
            
            random_delay();
            @(posedge clk)
            d1_addr = d2_addr;
            d1_mode = 0;                         // Set mode to read
            d1_valid = 1;                        // Assert valid signal

            #20;
            d1_valid = 0;
            d2_valid = 0;
            wait (d1_ready == 1 && d2_ready == 1 && s_ready == 1);

            #20;

            // if (slave_id1 == 2'b00)  slave_mem_data1 = dut.slave1.sm.memory[d2_addr[10:0]];
            // else if (slave_id1 == 2'b01)  slave_mem_data1 = dut.slave2.sm.memory[d2_addr[11:0]];
            // else if (slave_id1 == 2'b10)  slave_mem_data1 = dut.slave3.sm.memory[d2_addr[11:0]];

            // if (slave_id1 != 2'b11 && slave_mem_data1 != d2_wdata) begin
            //     $display("Master 2 write failed at iteration %0d: location %x, expected %x, actual %x", 
            //                 i, d2_addr, d2_wdata, slave_mem_data1);
            // end else begin
            //     $display("Master 2 write to %0x successful at iteration %0d", d2_addr, i);
            // end

            if (slave_id1 != 2'b11 && d2_wdata != d1_rdata) begin
                $display("Master 1 read failed at iteration %0d: location %x, expected %x, actual %x", 
                            i, d1_addr, d2_wdata, d1_rdata);
            end else begin
                $display("Master 1 read from %0x successful at iteration %0d", d1_addr, i);
            end

            // Small delay before next iteration
            #10;

        end

        #10 $finish;
    end


endmodule