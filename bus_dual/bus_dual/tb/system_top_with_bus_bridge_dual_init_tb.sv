`timescale 1ns/1ps

module system_top_with_bus_bridge_dual_m_tb;
    localparam logic [15:0] INIT1_ADDR = 16'h8004;
    localparam logic [15:0] INIT2_ADDR = 16'h9004;
    localparam logic [7:0] INIT1_DATA = 8'hA5;
    localparam logic [7:0] INIT2_DATA = 8'h5A;
    localparam logic [15:0] TARGET1_BASE_ADDR = 16'h0000;
    localparam int unsigned TARGET1_SIZE = 16'd2048;
    localparam logic [15:0] TARGET2_BASE_ADDR = 16'h4000;
    localparam int unsigned TARGET2_SIZE = 16'd4096;
    localparam logic [15:0] BRIDGE_BASE_ADDR = 16'h8000;
    localparam int unsigned BRIDGE_TARGET0_SIZE = 16'd4096;
    localparam int unsigned BRIDGE_TARGET1_SIZE = 16'd2048;
    localparam int unsigned BRIDGE_TARGET2_SIZE = 16'd4096;
    localparam int unsigned BRIDGE_ADDR_SPACE = BRIDGE_TARGET0_SIZE + BRIDGE_TARGET1_SIZE + BRIDGE_TARGET2_SIZE;

    // Clock and reset.
    logic clk;
    logic rst_n;

    // Stimulus triggers for the masters.
    logic m1_trigger;
    logic m2_trigger;

    // Initiator 1 signals.
    logic         m1_req;
    logic [15:0]  m1_address_out;
    logic         m1_address_out_valid;
    logic [7:0]   m1_data_out;
    logic         m1_data_out_valid;
    logic         m1_rw;
    logic         m1_ready;
    logic         m1_grant;
    logic [7:0]   m1_data_in;
    logic         m1_data_in_valid;
    logic         m1_ack;
    logic         m1_split_ack;
    logic         m1_done;
    logic [7:0]   m1_read_data;

    // Initiator 2 signals.
    logic         m2_req;
    logic [15:0]  m2_address_out;
    logic         m2_address_out_valid;
    logic [7:0]   m2_data_out;
    logic         m2_data_out_valid;
    logic         m2_rw;
    logic         m2_ready;
    logic         m2_grant;
    logic [7:0]   m2_data_in;
    logic         m2_data_in_valid;
    logic         m2_ack;
    logic         m2_split_ack;
    logic         m2_done;
    logic [7:0]   m2_read_data;

    // Bus A slave interfaces.
    logic [15:0]  s1_address_in;
    logic         s1_address_in_valid;
    logic [7:0]   s1_data_in;
    logic         s1_data_in_valid;
    logic [7:0]   s1_data_out;
    logic         s1_data_out_valid;
    logic         s1_ack;
    logic         s1_ready;
    logic         s1_rw;
    logic [7:0]   s1_last_write;

    logic [15:0]  s2_address_in;
    logic         s2_address_in_valid;
    logic [7:0]   s2_data_in;
    logic         s2_data_in_valid;
    logic [7:0]   s2_data_out;
    logic         s2_data_out_valid;
    logic         s2_ack;
    logic         s2_ready;
    logic         s2_rw;
    logic [7:0]   s2_last_write;

    // Bus A split-slave style wiring (terminates in the bridge).
    logic         split_s_ready;
    logic         split_s_ack;
    logic         split_s_split_ack;
    logic [7:0]   split_s_data_out;
    logic         split_s_data_out_valid;
    logic         split_s_req;
    logic [15:0]  split_s_address_in;
    logic         split_s_address_in_valid;
    logic [7:0]   split_s_data_in;
    logic         split_s_data_in_valid;
    logic         split_s_rw;
    logic         split_s_grant;
    logic [7:0]   split_s_last_write;

    // Bridge master side (Bus B interface).
    logic         bridge_m_req;
    logic [15:0]  bridge_m_address_out;
    logic         bridge_m_address_out_valid;
    logic [7:0]   bridge_m_data_out;
    logic         bridge_m_data_out_valid;
    logic         bridge_m_rw;
    logic         bridge_m_ready;
    logic         bridge_m_grant;
    logic [7:0]   bridge_m_data_in;
    logic         bridge_m_data_in_valid;
    logic         bridge_m_ack;
    logic         bridge_m_split_ack;

    // Bus B slave interfaces.
    logic [15:0]  b_s1_address_in;
    logic         b_s1_address_in_valid;
    logic [7:0]   b_s1_data_in;
    logic         b_s1_data_in_valid;
    logic [7:0]   b_s1_data_out;
    logic         b_s1_data_out_valid;
    logic         b_s1_ack;
    logic         b_s1_ready;
    logic         b_s1_rw;
    logic [7:0]   b_s1_last_write;

    logic [15:0]  b_s2_address_in;
    logic         b_s2_address_in_valid;
    logic [7:0]   b_s2_data_in;
    logic         b_s2_data_in_valid;
    logic [7:0]   b_s2_data_out;
    logic         b_s2_data_out_valid;
    logic         b_s2_ack;
    logic         b_s2_ready;
    logic         b_s2_rw;
    logic [7:0]   b_s2_last_write;

    logic [15:0]  b_split_s_address_in;
    logic         b_split_s_address_in_valid;
    logic [7:0]   b_split_s_data_in;
    logic         b_split_s_data_in_valid;
    logic [7:0]   b_split_s_data_out;
    logic         b_split_s_data_out_valid;
    logic         b_split_s_ack;
    logic         b_split_s_ready;
    logic         b_split_s_split_ack;
    logic         b_split_s_req;
    logic         b_split_s_grant;
    logic [7:0]   b_split_s_last_write;

    // Unused Bus B master outputs.
    logic         b_m2_grant;
    logic [7:0]   b_m2_data_in;
    logic         b_m2_data_in_valid;
    logic         b_m2_ack;
    logic         b_m2_split_ack;

    // Tracking flags.
    logic m1_ack_seen;
    logic m2_ack_seen;
    logic m1_split_ack_seen;
    logic m2_split_ack_seen;

    // Clock generation.
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // Reset and stimulus sequencing.
    initial begin
        rst_n = 1'b0;
        m1_trigger = 1'b0;
        m2_trigger = 1'b0;
        repeat (8) @(posedge clk);
        rst_n = 1'b1;
        repeat (4) @(posedge clk);
        m1_trigger = 1'b1;
        @(posedge clk);
        m1_trigger = 1'b0;
        wait (m1_done);

        repeat (4) @(posedge clk);
        m2_trigger = 1'b1;
        @(posedge clk);
        m2_trigger = 1'b0;
        wait (m2_done);

        @(posedge clk);
        if (m1_read_data !== INIT1_DATA)
            $error("Initiator 1 readback %02h, expected %02h", m1_read_data, INIT1_DATA);
        if (m2_read_data !== INIT2_DATA)
            $error("Initiator 2 readback %02h, expected %02h", m2_read_data, INIT2_DATA);
        if (!m1_ack_seen)
            $error("Initiator 1 never observed ACK");
        if (!m1_split_ack_seen)
            $error("Initiator 1 never observed split ACK");
        if (!m2_ack_seen)
            $error("Initiator 2 never observed ACK");
        if (m2_split_ack_seen)
            $error("Initiator 2 unexpectedly observed split ACK");
        if (b_split_s_last_write !== INIT1_DATA)
            $error("Bus B split slave last write %02h, expected %02h", b_split_s_last_write, INIT1_DATA);
        if (b_s1_last_write !== INIT2_DATA)
            $error("Bus B s1 last write %02h, expected %02h", b_s1_last_write, INIT2_DATA);
        if (b_s2_last_write !== 8'h00)
            $display("INFO: Bus B s2 saw write %02h", b_s2_last_write);
        if (m1_read_data === INIT1_DATA && m2_read_data === INIT2_DATA && m1_ack_seen && m2_ack_seen && m1_split_ack_seen && !m2_split_ack_seen && b_split_s_last_write === INIT1_DATA && b_s1_last_write === INIT2_DATA)
            $display("[%0t] Dual-master bridge test PASSED", $time);
        else
            $display("[%0t] Dual-master bridge test completed with issues", $time);
        repeat (5) @(posedge clk);
        $finish;
    end

    // Timeout guard.
    initial begin
        #200000;
        $fatal(1, "Timeout waiting for dual-master bridge test to complete");
    end

    // Track acknowledgements.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m1_ack_seen <= 1'b0;
            m2_ack_seen <= 1'b0;
            m1_split_ack_seen <= 1'b0;
            m2_split_ack_seen <= 1'b0;
        end else begin
            if (m1_ack)
                m1_ack_seen <= 1'b1;
            if (m2_ack)
                m2_ack_seen <= 1'b1;
            if (m1_split_ack)
                m1_split_ack_seen <= 1'b1;
            if (m2_split_ack)
                m2_split_ack_seen <= 1'b1;
        end
    end

    // Initiator instances.
    master #(
        .WRITE_ADDR(INIT1_ADDR),
        .READ_ADDR(INIT1_ADDR),
        .MEM_INIT_DATA(INIT1_DATA)
    ) u_master_1 (
        .clk(clk),
        .rst_n(rst_n),
        .trigger(m1_trigger),
        .m_grant(m1_grant),
        .m_ack(m1_ack),
        .m_split_ack(m1_split_ack),
        .m_data_in(m1_data_in),
        .m_data_in_valid(m1_data_in_valid),
        .m_req(m1_req),
        .m_address_out(m1_address_out),
        .m_address_out_valid(m1_address_out_valid),
        .m_data_out(m1_data_out),
        .m_data_out_valid(m1_data_out_valid),
        .m_rw(m1_rw),
        .m_ready(m1_ready),
        .done(m1_done),
        .read_data_value(m1_read_data)
    );

    master #(
        .WRITE_ADDR(INIT2_ADDR),
        .READ_ADDR(INIT2_ADDR),
        .MEM_INIT_DATA(INIT2_DATA)
    ) u_master_2 (
        .clk(clk),
        .rst_n(rst_n),
        .trigger(m2_trigger),
        .m_grant(m2_grant),
        .m_ack(m2_ack),
        .m_split_ack(m2_split_ack),
        .m_data_in(m2_data_in),
        .m_data_in_valid(m2_data_in_valid),
        .m_req(m2_req),
        .m_address_out(m2_address_out),
        .m_address_out_valid(m2_address_out_valid),
        .m_data_out(m2_data_out),
        .m_data_out_valid(m2_data_out_valid),
        .m_rw(m2_rw),
        .m_ready(m2_ready),
        .done(m2_done),
        .read_data_value(m2_read_data)
    );

    // Target instances on Bus A (not directly exercised in this test).
    slave #(
        .INTERNAL_ADDR_BITS(11)
    ) u_s_1 (
        .clk(clk),
        .rst_n(rst_n),
        .s_address_in(s1_address_in),
        .s_address_in_valid(s1_address_in_valid),
        .s_data_in(s1_data_in),
        .s_data_in_valid(s1_data_in_valid),
        .s_rw(s1_rw),
        .s_data_out(s1_data_out),
        .s_data_out_valid(s1_data_out_valid),
        .s_ack(s1_ack),
        .s_ready(s1_ready),
        .s_last_write(s1_last_write)
    );

    slave #(
        .INTERNAL_ADDR_BITS(11)
    ) u_s_2 (
        .clk(clk),
        .rst_n(rst_n),
        .s_address_in(s2_address_in),
        .s_address_in_valid(s2_address_in_valid),
        .s_data_in(s2_data_in),
        .s_data_in_valid(s2_data_in_valid),
        .s_rw(s2_rw),
        .s_data_out(s2_data_out),
        .s_data_out_valid(s2_data_out_valid),
        .s_ack(s2_ack),
        .s_ready(s2_ready),
        .s_last_write(s2_last_write)
    );

    // Bus bridge instance (acts as Bus A split slave, Bus B master).
    bus_bridge #(
        .BRIDGE_BASE_ADDR(BRIDGE_BASE_ADDR),
        .TARGET0_SIZE(BRIDGE_TARGET0_SIZE),
        .TARGET1_SIZE(BRIDGE_TARGET1_SIZE),
        .TARGET2_SIZE(BRIDGE_TARGET2_SIZE),
        .BUSB_TARGET0_BASE(16'h8000),
        .BUSB_TARGET1_BASE(16'h0000),
        .BUSB_TARGET2_BASE(16'h4000)
    ) u_bus_bridge (
        .clk(clk),
        .rst_n(rst_n),
        .split_grant(split_s_grant),
        .s_address_in(split_s_address_in),
        .s_address_in_valid(split_s_address_in_valid),
        .s_data_in(split_s_data_in),
        .s_data_in_valid(split_s_data_in_valid),
        .s_rw(split_s_rw),
        .split_req(split_s_req),
        .s_data_out(split_s_data_out),
        .s_data_out_valid(split_s_data_out_valid),
        .s_ack(split_s_ack),
        .s_split_ack(split_s_split_ack),
        .s_ready(split_s_ready),
        .split_s_last_write(split_s_last_write),
        .m_req(bridge_m_req),
        .m_address_out(bridge_m_address_out),
        .m_address_out_valid(bridge_m_address_out_valid),
        .m_data_out(bridge_m_data_out),
        .m_data_out_valid(bridge_m_data_out_valid),
        .m_rw(bridge_m_rw),
        .m_ready(bridge_m_ready),
        .m_grant(bridge_m_grant),
        .m_data_in(bridge_m_data_in),
        .m_data_in_valid(bridge_m_data_in_valid),
        .m_ack(bridge_m_ack),
        .m_split_ack(bridge_m_split_ack)
    );

    // Bus B slave instances.
    slave #(
        .INTERNAL_ADDR_BITS(11)
    ) u_b_s_1 (
        .clk(clk),
        .rst_n(rst_n),
        .s_address_in(b_s1_address_in),
        .s_address_in_valid(b_s1_address_in_valid),
        .s_data_in(b_s1_data_in),
        .s_data_in_valid(b_s1_data_in_valid),
        .s_rw(b_s1_rw),
        .s_data_out(b_s1_data_out),
        .s_data_out_valid(b_s1_data_out_valid),
        .s_ack(b_s1_ack),
        .s_ready(b_s1_ready),
        .s_last_write(b_s1_last_write)
    );

    slave #(
        .INTERNAL_ADDR_BITS(12)
    ) u_b_s_2 (
        .clk(clk),
        .rst_n(rst_n),
        .s_address_in(b_s2_address_in),
        .s_address_in_valid(b_s2_address_in_valid),
        .s_data_in(b_s2_data_in),
        .s_data_in_valid(b_s2_data_in_valid),
        .s_rw(b_s2_rw),
        .s_data_out(b_s2_data_out),
        .s_data_out_valid(b_s2_data_out_valid),
        .s_ack(b_s2_ack),
        .s_ready(b_s2_ready),
        .s_last_write(b_s2_last_write)
    );

    split_s #(
        .INTERNAL_ADDR_BITS(12),
        .READ_LATENCY(4)
    ) u_b_split_s (
        .clk(clk),
        .rst_n(rst_n),
        .split_grant(b_split_s_grant),
        .s_address_in(b_split_s_address_in),
        .s_address_in_valid(b_split_s_address_in_valid),
        .s_data_in(b_split_s_data_in),
        .s_data_in_valid(b_split_s_data_in_valid),
        .s_rw(b_split_s_rw),
        .split_req(b_split_s_req),
        .s_data_out(b_split_s_data_out),
        .s_data_out_valid(b_split_s_data_out_valid),
        .s_ack(b_split_s_ack),
        .s_split_ack(b_split_s_split_ack),
        .s_ready(b_split_s_ready),
        .split_s_last_write(b_split_s_last_write)
    );

    // Bus A interconnect.
    bus #(
        .TARGET1_BASE(TARGET1_BASE_ADDR),
        .TARGET1_SIZE(TARGET1_SIZE),
        .TARGET2_BASE(TARGET2_BASE_ADDR),
        .TARGET2_SIZE(TARGET2_SIZE),
        .TARGET3_BASE(BRIDGE_BASE_ADDR),
        .TARGET3_SIZE(BRIDGE_ADDR_SPACE)
    ) u_bus_a (
        .clk(clk),
        .rst_n(rst_n),
        // Initiator 1
        .m1_req(m1_req),
        .m1_data_out(m1_data_out),
        .m1_data_out_valid(m1_data_out_valid),
        .m1_address_out(m1_address_out),
        .m1_address_out_valid(m1_address_out_valid),
        .m1_rw(m1_rw),
        .m1_ready(m1_ready),
        .m1_grant(m1_grant),
        .m1_data_in(m1_data_in),
        .m1_data_in_valid(m1_data_in_valid),
        .m1_ack(m1_ack),
        .m1_split_ack(m1_split_ack),
        // Initiator 2
        .m2_req(m2_req),
        .m2_data_out(m2_data_out),
        .m2_data_out_valid(m2_data_out_valid),
        .m2_address_out(m2_address_out),
        .m2_address_out_valid(m2_address_out_valid),
        .m2_rw(m2_rw),
        .m2_ready(m2_ready),
        .m2_grant(m2_grant),
        .m2_data_in(m2_data_in),
        .m2_data_in_valid(m2_data_in_valid),
        .m2_ack(m2_ack),
        .m2_split_ack(m2_split_ack),
        // Target 1
        .s1_ready(s1_ready),
        .s1_ack(s1_ack),
        .s1_data_out(s1_data_out),
        .s1_data_out_valid(s1_data_out_valid),
        .s1_address_in(s1_address_in),
        .s1_address_in_valid(s1_address_in_valid),
        .s1_data_in(s1_data_in),
        .s1_data_in_valid(s1_data_in_valid),
        .s1_rw(s1_rw),
        // Target 2
        .s2_ready(s2_ready),
        .s2_ack(s2_ack),
        .s2_data_out(s2_data_out),
        .s2_data_out_valid(s2_data_out_valid),
        .s2_address_in(s2_address_in),
        .s2_address_in_valid(s2_address_in_valid),
        .s2_data_in(s2_data_in),
        .s2_data_in_valid(s2_data_in_valid),
        .s2_rw(s2_rw),
        // Split slave (bridge)
        .split_s_ready(split_s_ready),
        .split_s_ack(split_s_ack),
        .split_s_split_ack(split_s_split_ack),
        .split_s_data_out(split_s_data_out),
        .split_s_data_out_valid(split_s_data_out_valid),
        .split_s_req(split_s_req),
        .split_s_address_in(split_s_address_in),
        .split_s_address_in_valid(split_s_address_in_valid),
        .split_s_data_in(split_s_data_in),
        .split_s_data_in_valid(split_s_data_in_valid),
        .split_s_rw(split_s_rw),
        .split_s_grant(split_s_grant)
    );

    // Bus B interconnect.
    bus #(
        .TARGET1_BASE(16'h0000),
        .TARGET1_SIZE(16'd2048),
        .TARGET2_BASE(16'h4000),
        .TARGET2_SIZE(16'd4096),
        .TARGET3_BASE(16'h8000),
        .TARGET3_SIZE(16'd4096)
    ) u_bus_b (
        .clk(clk),
        .rst_n(rst_n),
        // Initiator 1 (bridge)
        .m1_req(bridge_m_req),
        .m1_data_out(bridge_m_data_out),
        .m1_data_out_valid(bridge_m_data_out_valid),
        .m1_address_out(bridge_m_address_out),
        .m1_address_out_valid(bridge_m_address_out_valid),
        .m1_rw(bridge_m_rw),
        .m1_ready(bridge_m_ready),
        .m1_grant(bridge_m_grant),
        .m1_data_in(bridge_m_data_in),
        .m1_data_in_valid(bridge_m_data_in_valid),
        .m1_ack(bridge_m_ack),
        .m1_split_ack(bridge_m_split_ack),
        // Initiator 2 (unused)
        .m2_req(1'b0),
        .m2_data_out(8'd0),
        .m2_data_out_valid(1'b0),
        .m2_address_out(16'd0),
        .m2_address_out_valid(1'b0),
        .m2_rw(1'b1),
        .m2_ready(1'b1),
        .m2_grant(b_m2_grant),
        .m2_data_in(b_m2_data_in),
        .m2_data_in_valid(b_m2_data_in_valid),
        .m2_ack(b_m2_ack),
        .m2_split_ack(b_m2_split_ack),
        // Target 1
        .s1_ready(b_s1_ready),
        .s1_ack(b_s1_ack),
        .s1_data_out(b_s1_data_out),
        .s1_data_out_valid(b_s1_data_out_valid),
        .s1_address_in(b_s1_address_in),
        .s1_address_in_valid(b_s1_address_in_valid),
        .s1_data_in(b_s1_data_in),
        .s1_data_in_valid(b_s1_data_in_valid),
        .s1_rw(b_s1_rw),
        // Target 2
        .s2_ready(b_s2_ready),
        .s2_ack(b_s2_ack),
        .s2_data_out(b_s2_data_out),
        .s2_data_out_valid(b_s2_data_out_valid),
        .s2_address_in(b_s2_address_in),
        .s2_address_in_valid(b_s2_address_in_valid),
        .s2_data_in(b_s2_data_in),
        .s2_data_in_valid(b_s2_data_in_valid),
        .s2_rw(b_s2_rw),
        // Split slave
        .split_s_ready(b_split_s_ready),
        .split_s_ack(b_split_s_ack),
        .split_s_split_ack(b_split_s_split_ack),
        .split_s_data_out(b_split_s_data_out),
        .split_s_data_out_valid(b_split_s_data_out_valid),
        .split_s_req(b_split_s_req),
        .split_s_address_in(b_split_s_address_in),
        .split_s_address_in_valid(b_split_s_address_in_valid),
        .split_s_data_in(b_split_s_data_in),
        .split_s_data_in_valid(b_split_s_data_in_valid),
        .split_s_rw(b_split_s_rw),
        .split_s_grant(b_split_s_grant)
    );
endmodule
