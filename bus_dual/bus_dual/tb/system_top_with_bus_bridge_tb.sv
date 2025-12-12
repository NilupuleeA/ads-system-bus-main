`timescale 1ns/1ps

module system_top_with_bus_bridge_tb;
    // Clock and stimulus
    logic clk;
    logic btn_reset;
    logic btn_trigger;
    logic [7:0] leds;

    // Device under test
    system_top_with_bus_bridge dut (
        .clk(clk),
        .btn_reset(btn_reset),
        .btn_trigger(btn_trigger),
        .leds(leds)
    );

    // Generate 50 MHz style clock (20 ns period)
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    localparam byte EXPECTED_WRITE_DATA = 8'hA5;

    bit bridge_req_seen;
    bit bridge_ack_seen;
    bit bridge_split_seen;
    bit bridge_data_valid_seen;
    byte bridge_read_value;
    bit m_read_seen;
    byte m_read_value;

    // Monitor key handshake indicators once reset is released.
    always_ff @(posedge clk or negedge dut.rst_n) begin
        if (!dut.rst_n) begin
            bridge_req_seen <= 1'b0;
            bridge_ack_seen <= 1'b0;
            bridge_split_seen <= 1'b0;
            bridge_data_valid_seen <= 1'b0;
            bridge_read_value <= '0;
            m_read_seen <= 1'b0;
            m_read_value <= '0;
        end else begin
            if (dut.bridge_m_req)
                bridge_req_seen <= 1'b1;
            if (dut.bridge_m_ack)
                bridge_ack_seen <= 1'b1;
            if (dut.bridge_m_split_ack)
                bridge_split_seen <= 1'b1;
            if (dut.bridge_m_data_in_valid) begin
                bridge_data_valid_seen <= 1'b1;
                bridge_read_value <= dut.bridge_m_data_in;
            end
            if (dut.m1_data_in_valid) begin
                m_read_seen <= 1'b1;
                m_read_value <= dut.m1_data_in;
            end
        end
    end

    task automatic apply_reset;
        begin
            btn_reset = 1'b1;
            btn_trigger = 1'b0;
            repeat (60) @(posedge clk);
            btn_reset = 1'b0;
            // Allow synchronisers to settle
            repeat (6) @(posedge clk);
        end
    endtask

    task automatic pulse_trigger;
        begin
            btn_trigger <= 1'b1;
            repeat (4) @(posedge clk); // hold long enough for the 2FF synchroniser
            btn_trigger <= 1'b0;
            @(posedge clk);
        end
    endtask

    initial begin : main_test
        apply_reset();

        if (!dut.rst_n) begin
            $fatal(1, "DUT failed to release reset");
        end

        // Basic sanity: LEDs should start cleared after reset.
        if (leds !== 8'h00) begin
            $display("[%0t] INFO: LEDs non-zero after reset (%02h)", $time, leds);
        end

        pulse_trigger();

        // Wait for primary master to see data returned (single transaction focus).
        @(posedge dut.m1_data_in_valid);
        @(posedge clk); // give outputs a cycle to settle

        // Checks for bridge activity
        if (!bridge_req_seen)
            $error("Bridge master never asserted m_req");
        if (!bridge_split_seen)
            $error("Bridge did not assert split acknowledgement toward upstream bus");
        if (!bridge_ack_seen)
            $error("Bridge master never saw m_ack from Bus B");
        if (!bridge_data_valid_seen)
            $error("Bridge master never observed data returning from Bus B");
        else if (bridge_read_value !== EXPECTED_WRITE_DATA)
            $error("Bridge master captured %02h instead of expected %02h",
                   bridge_read_value, EXPECTED_WRITE_DATA);
        if (!m_read_seen)
            $error("Primary master never received read data");

        if (m_read_seen && m_read_value !== EXPECTED_WRITE_DATA)
            $error("Readback mismatch: expected %02h got %02h", EXPECTED_WRITE_DATA, m_read_value);

        if (leds !== EXPECTED_WRITE_DATA)
            $error("LEDs did not reflect downstream write: expected %02h got %02h", EXPECTED_WRITE_DATA, leds);

        if (dut.b_split_s_last_write !== EXPECTED_WRITE_DATA)
            $error("Bus B split slave last write mismatch: expected %02h got %02h",
                   EXPECTED_WRITE_DATA, dut.b_split_s_last_write);

        if (!$isunknown(m_read_value) && m_read_value === EXPECTED_WRITE_DATA &&
            leds === EXPECTED_WRITE_DATA &&
            dut.b_split_s_last_write === EXPECTED_WRITE_DATA &&
            bridge_req_seen && bridge_ack_seen && bridge_split_seen && bridge_data_valid_seen &&
            bridge_read_value === EXPECTED_WRITE_DATA) begin
            $display("[%0t] system_top_with_bus_bridge single-trigger test PASSED", $time);
        end else begin
            $display("[%0t] system_top_with_bus_bridge single-trigger test completed with errors", $time);
        end

        repeat (5) @(posedge clk);
        $finish;
    end

    // Timeout guard to avoid hanging simulations.
    initial begin : timeout_guard
        #200000000; // 200 ms guard
        $fatal(1, "Timeout waiting for bridge transaction to complete");
    end
endmodule
