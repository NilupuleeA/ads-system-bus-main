`timescale 1ns/1ps

module s_integration_tb;
    logic clk;
    logic rst_n;

    localparam bit [15:0] WRITE_ADDR = 16'h0532;
    localparam bit [7:0] WRITE_DATA = 8'h9E;
    localparam bit [15:0] READ_ADDR  = WRITE_ADDR;

    logic [7:0] s_data_out;
    logic s_data_out_valid;
    logic s_rw;
    logic s_ready;
    logic s_ack;
    logic [7:0] s_last_write;

    logic bus_data_in;
    logic bus_data_in_valid;
    logic bus_mode;
    logic bus_data_out;
    logic bus_data_out_valid;
    logic [7:0] s_data_in;
    logic s_data_in_valid;
    logic [15:0] s_address_in;
    logic s_address_in_valid;
    logic bus_s_ready;
    logic bus_s_rw;
    logic bus_s_ack;
    logic decoder_valid;

    logic [7:0] data_serial_readback;
    int count_write_ack;
    int count_read_ack;

    slave #(
        .INTERNAL_ADDR_BITS(11)
    ) u_slave (
        .clk(clk),
        .rst_n(rst_n),
        .s_address_in(s_address_in),
        .s_address_in_valid(s_address_in_valid),
        .s_data_in(s_data_in),
        .s_data_in_valid(s_data_in_valid),
        .s_rw(s_rw),
        .s_data_out(s_data_out),
        .s_data_out_valid(s_data_out_valid),
        .s_ack(s_ack),
        .s_ready(s_ready),
        .s_last_write(s_last_write)
    );

    s_port u_s_port (
        .clk(clk),
        .rst_n(rst_n),
        .s_data_out(s_data_out),
        .s_data_out_valid(s_data_out_valid),
        .s_rw(s_rw),
        .s_ready(s_ready),
        .s_ack(s_ack),
        .decoder_valid(decoder_valid),
        .bus_data_in_valid(bus_data_in_valid),
        .bus_data_in(bus_data_in),
        .bus_mode(bus_mode),
        .bus_data_out(bus_data_out),
        .s_data_in(s_data_in),
        .s_data_in_valid(s_data_in_valid),
        .s_address_in(s_address_in),
        .s_address_in_valid(s_address_in_valid),
        .bus_data_out_valid(bus_data_out_valid),
        .bus_s_ready(bus_s_ready),
        .bus_s_rw(bus_s_rw),
        .bus_s_ack(bus_s_ack)
    );

    always @(posedge clk) begin
        if (rst_n) begin
            if (bus_s_ack !== s_ack) begin
                $error("s_ack pass-through mismatch");
            end
            if (bus_s_ready !== s_ready) begin
                $error("s_ready pass-through mismatch");
            end
            if (bus_s_rw !== s_rw) begin
                $error("s_rw pass-through mismatch");
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_write_ack <= 0;
            count_read_ack <= 0;
        end else begin
            if (bus_s_ack && bus_s_rw) begin
                count_write_ack <= count_write_ack + 1;
            end else if (bus_s_ack && !bus_s_rw) begin
                count_read_ack <= count_read_ack + 1;
            end
        end
    end

    task automatic transmit_serial_data(input bit [15:0] value, input int width, input logic mode_bit);
        begin
            for (int i = 0; i < width; i++) begin
                bus_data_in <= value[i];
                bus_data_in_valid <= 1'b1;
                bus_mode <= mode_bit;
                @(posedge clk);
            end
            bus_data_in_valid <= 1'b0;
            bus_mode <= 1'b0;
            @(posedge clk);
        end
    endtask

    task automatic execute_write(input bit [15:0] addr, input bit [7:0] data);
        begin
            s_rw <= 1'b1;
            @(posedge clk);
            transmit_serial_data(addr, 16, 1'b0);
            transmit_serial_data({8'h00, data}, 8, 1'b1);
        end
    endtask

    task automatic execute_read(input bit [15:0] addr);
        begin
            s_rw <= 1'b0;
            @(posedge clk);
            transmit_serial_data(addr, 16, 1'b0);
        end
    endtask

    task automatic receive_read_data(output bit [7:0] data);
        int bit_idx;
        begin
            data = '0;
            bit_idx = 0;
            while (bit_idx < 8) begin
                @(posedge clk);
                if (bus_data_out_valid) begin
                    data[bit_idx] = bus_data_out;
                    bit_idx++;
                end
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        bus_data_in = 1'b0;
        bus_data_in_valid = 1'b0;
        bus_mode = 1'b0;
        s_rw = 1'b0;
        data_serial_readback = '0;
        decoder_valid = 1'b0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);

        decoder_valid = 1'b1;
        execute_write(WRITE_ADDR, WRITE_DATA);
        wait (count_write_ack == 1);
        s_rw <= 1'b0;
        @(posedge clk);

        execute_read(READ_ADDR);
        receive_read_data(data_serial_readback);
        wait (count_read_ack == 1);

        decoder_valid = 1'b0;

        if (data_serial_readback !== WRITE_DATA) begin
            $error("Read data mismatch. Expected %h, got %h", WRITE_DATA, data_serial_readback);
        end

        if (count_write_ack != 1) begin
            $error("Unexpected write ACK count %0d", count_write_ack);
        end

        if (count_read_ack != 1) begin
            $error("Unexpected read ACK count %0d", count_read_ack);
        end

        $display("[%0t] slave integration test completed.", $time);
        $finish;
    end
endmodule
