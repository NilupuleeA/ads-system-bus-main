`timescale 1ns/1ps

module address_decoder_tb;
    logic clk;
    logic rst_n;

    logic bus_data_in;
    logic bus_data_in_valid;
    logic bus_mode;
    logic [2:0] release_valids;

    logic s_1_valid;
    logic s_2_valid;
    logic s_3_valid;
    logic [1:0] sel;

    localparam bit [15:0] ADDR_S1 = 16'h0012; // Slave 1 range
    localparam bit [15:0] ADDR_S2 = 16'h4ABC; // Slave 2 range
    localparam bit [15:0] ADDR_S3 = 16'h8F00; // Slave 3 range

    address_decoder dut (
        .clk(clk),
        .rst_n(rst_n),
        .bus_data_in(bus_data_in),
        .bus_data_in_valid(bus_data_in_valid),
        .bus_mode(bus_mode),
        .release_valids(release_valids),
        .s_1_valid(s_1_valid),
        .s_2_valid(s_2_valid),
        .s_3_valid(s_3_valid),
        .sel(sel)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic reset_design_under_test;
        begin
            rst_n = 1'b0;
            bus_data_in = 1'b0;
            bus_data_in_valid = 1'b0;
            bus_mode = 1'b0;
            repeat (4) @(posedge clk);
            rst_n = 1'b1;
            release_valids = 3'b000;
            @(posedge clk);
        end
    endtask

    task automatic transmit_address(input bit [15:0] addr);
        bus_mode = 1'b0;
        bus_data_in_valid = 1'b0;
        release_valids = 3'b000;
        @(posedge clk);
        for (int i = 0; i < 16; i++) begin
            bus_data_in = addr[i];
            bus_data_in_valid = 1'b1;
            release_valids = 3'b000;
            @(posedge clk);
        end
        bus_data_in_valid = 1'b0;
        bus_data_in = 1'b0;
        release_valids = 3'b000;
        @(posedge clk);
    endtask

    task automatic transmit_data_byte(input bit [7:0] data, input logic [2:0] release_mask);
        bus_mode = 1'b1;
        for (int i = 0; i < 8; i++) begin
            bus_data_in = data[i];
            bus_data_in_valid = 1'b1;
            release_valids = 3'b000;
            @(posedge clk);
        end
        bus_data_in_valid = 1'b0;
        bus_data_in = 1'b0;
        release_valids = release_mask;
        @(posedge clk);
        release_valids = 3'b000;
        @(posedge clk);
    endtask

    task automatic verify_slaves(input logic exp_t1, input logic exp_t2, input logic exp_t3, input logic [1:0] exp_sel);
        if ({s_3_valid, s_2_valid, s_1_valid} !== {exp_t3, exp_t2, exp_t1}) begin
            $error("[%0t] slave valids mismatch. exp=%b%b%b got=%b%b%b", $time,
                   exp_t3, exp_t2, exp_t1,
                   s_3_valid, s_2_valid, s_1_valid);
        end
        if (sel !== exp_sel)
            $error("[%0t] sel mismatch. Expected %b got %b", $time, exp_sel, sel);
    endtask

    initial begin
        reset_design_under_test();

        transmit_address(ADDR_S1);
        verify_slaves(1'b1, 1'b0, 1'b0, 2'b00);
        transmit_data_byte(8'hAA, 3'b001);
        verify_slaves(1'b0, 1'b0, 1'b0, 2'b00);

        transmit_address(ADDR_S2);
        verify_slaves(1'b0, 1'b1, 1'b0, 2'b01);
        transmit_data_byte(8'h55, 3'b010);
        verify_slaves(1'b0, 1'b0, 1'b0, 2'b00);

        transmit_address(ADDR_S3);
        verify_slaves(1'b0, 1'b0, 1'b1, 2'b10);
        transmit_data_byte(8'h5A, 3'b100);
        verify_slaves(1'b0, 1'b0, 1'b0, 2'b00);

        transmit_address(ADDR_S1);
        verify_slaves(1'b1, 1'b0, 1'b0, 2'b00);
        transmit_data_byte(8'hC3, 3'b001);
        verify_slaves(1'b0, 1'b0, 1'b0, 2'b00);

        repeat (5) @(posedge clk);
        $display("[%0t] address_decoder testbench completed.", $time);
        $finish;
    end
endmodule
