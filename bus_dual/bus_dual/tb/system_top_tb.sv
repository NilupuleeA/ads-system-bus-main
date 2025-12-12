`timescale 1ns/1ps

module system_top_tb;
    // Clock and reset stimulus
    logic clk;
    logic btn_reset;
    logic btn_trigger;
    logic btn_trigger2;
    logic [7:0] leds;

    // Device under test
    system_top dut (
        .clk(clk),
        .btn_reset(btn_reset),
        .btn_trigger(btn_trigger),
        .btn_trigger2(btn_trigger2),
        .leds(leds)
    );

    // Generate 50 MHz equivalent clock (20 ns period)
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // Simple task to assert trigger for one cycle
    task automatic pulse_trigger1;
        begin
            btn_trigger <= 1'b1;
            @(posedge clk);
            btn_trigger <= 1'b0;
        end
    endtask

    task automatic pulse_trigger2;
        begin
            btn_trigger2 <= 1'b1;
            @(posedge clk);
            btn_trigger2 <= 1'b0;
        end
    endtask

    // Scoreboard state
    byte led_history [0:5];
    int trigger_count;
    bit distinct_value_seen;
    byte prev_led_value;

    initial begin
        // Initial conditions
        btn_reset = 1'b1; // active-low reset inside DUT
        btn_trigger = 1'b0;
        btn_trigger2 = 1'b0;
        trigger_count = 0;
        for (int i = 0; i < 5; i++) begin 
		  led_history[i] = '0;
		  end

        // Hold reset asserted for a few cycles then release and keep low
        repeat (5) @(posedge clk);
        btn_reset = 1'b0;
        repeat (10) @(posedge clk);

        // Issue triggers to both masters
        prev_led_value = leds;
        distinct_value_seen = 1'b0;

        // Master 1 Trigger
        $display("[%0t] Triggering Master 1...", $time);
        pulse_trigger1();
        trigger_count++;
        @(posedge dut.m1_data_in_valid);
        @(posedge clk);
        $display("[%0t] M1 Done. LED value %02h", $time, leds);
        
        // Master 2 Trigger
        $display("[%0t] Triggering Master 2...", $time);
        pulse_trigger2();
        trigger_count++;
        @(posedge dut.m2_data_in_valid);
        @(posedge clk);
        $display("[%0t] M2 Done. LED value %02h", $time, leds);

         // Master 1 Trigger again to see change back
        $display("[%0t] Triggering Master 1 again...", $time);
        pulse_trigger1();
        trigger_count++;
        @(posedge dut.m1_data_in_valid);
        @(posedge clk);
        $display("[%0t] M1 Done. LED value %02h", $time, leds);

        $display("[%0t] System top testbench completed after %0d triggers", $time, trigger_count);
        $finish;
    end
endmodule
