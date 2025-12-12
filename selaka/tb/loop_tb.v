`timescale 1ns / 1ps

module loop_tb;

    // Clock and Reset
    reg clk;
    reg rstn;

    // User input switches
    reg master_sel_sw;
    reg mode_sw;
    reg [1:0] device_addr_sw;
    reg [5:0] slave_mem_addr_sw;
    reg [7:0] m_write_data_sw;
    reg start;

    // Outputs
    wire [7:0] s_mem_1;
    wire [7:0] s_mem_2;
    wire [7:0] m_read_data;

    // Clock generation: 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;  // 10 ns period

    // DUT instantiation
    dual_bus_loop_fpga dut (
        .clk(clk),
        .rstn(rstn),
        .master_sel_sw(master_sel_sw),
        .mode_sw(mode_sw),
        .device_addr_sw(device_addr_sw),
        .slave_mem_addr_sw(slave_mem_addr_sw),
        .m_write_data_sw(m_write_data_sw),
        .s_mem_1(s_mem_1),
        .s_mem_2(s_mem_2),
        .m_read_data(m_read_data),
        .start(start)
    );

    // Reset sequence
    initial begin
        rstn = 0;
        start = 0;
        master_sel_sw = 0;
        mode_sw = 0;
        device_addr_sw = 2'b00;
        slave_mem_addr_sw = 6'b000000;
        m_write_data_sw = 8'h00;

        #50;
        rstn = 1;
    end

    // Test procedure: two write transactions
    initial begin
        // Wait for reset release
        @(posedge rstn);
        #20;

        // -------------------------------
        // Transaction 1: Master A writes to Slave 1
        // -------------------------------
        master_sel_sw = 0;           // select Master A
        mode_sw = 1;                 // write mode
        device_addr_sw = 2'b00;      // slave 1
        slave_mem_addr_sw = 6'd5;    // address 5
        m_write_data_sw = 8'hAA;     // data 0xAA
        start = 1;
        #10;
        start = 0;

        // Wait for transaction to complete
        #200;

        // -------------------------------
        // Transaction 2: Master B writes to Slave 2
        // -------------------------------
        master_sel_sw = 1;           // select Master B
        mode_sw = 1;                 // write mode
        device_addr_sw = 2'b01;      // slave 2
        slave_mem_addr_sw = 6'd10;   // address 10
        m_write_data_sw = 8'h55;     // data 0x55
        start = 1;
        #10;
        start = 0;

        // Wait for transaction to complete
        #200;

        $stop;
    end



endmodule
