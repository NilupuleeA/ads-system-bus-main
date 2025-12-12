`timescale 1ns/1ps


module uart_tx_vip;

    // Clock & reset
    reg clk = 0;
    reg rstn = 0;

    // UART lines
    reg rx = 1'b1;   // idle high
    wire tx;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rstn = 0;
        #100;
        rstn = 1;
    end

    localparam CLK_PER_PULSE = 10; 
    localparam PULSE_TIME = CLK_PER_PULSE * 10; 

    task uart_send_bit;
        input bit_val;
        begin
            rx = bit_val;
            #(PULSE_TIME);
        end
    endtask

    task uart_send_byte;
        input [7:0] bytee;
        integer i;
        begin
            uart_send_bit(1'b0);            //start bit
            for (i = 0; i < 8; i=i+1)       //data bits
                uart_send_bit(bytee[i]);
            uart_send_bit(1'b1);            //stop bit
            #(PULSE_TIME);
        end
    endtask

    task uart_send_packet;
        input mode;
        input [11:0] addr;   
        input [7:0] data;
        reg [20:0] pkt;
        integer i;
        begin
            pkt = {mode, data, addr}; 
            
            uart_send_bit(1'b0);            //start bit
            for (i=0; i<21; i=i+1)          //data bits
                uart_send_bit(pkt[i]);
            uart_send_bit(1'b1);            //stop bit;
            #(PULSE_TIME);
        end
    endtask

    initial begin
        #200;
        uart_send_packet(1'b1, 12'h100, 8'hA5);
    end


endmodule