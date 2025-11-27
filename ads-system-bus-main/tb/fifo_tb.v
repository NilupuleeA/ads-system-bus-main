`timescale 1ns/1ps

module fifo_tb;

  // Parameters
  parameter DATA_WIDTH = 8;
  parameter DEPTH = 16;
  parameter CLK_PERIOD = 5; // 10ns clock period (100MHz)

  // Signals
  reg clk;
  reg rstn;
  reg enq;
  reg deq;
  reg [DATA_WIDTH-1:0] data_in;
  wire [DATA_WIDTH-1:0] data_out;
  wire empty;

  // Instantiate the FIFO module
  fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
  ) dut (
    .clk(clk),
    .rstn(rstn),
    .enq(enq),
    .deq(deq),
    .data_in(data_in),
    .data_out(data_out),
    .empty(empty)
  );

  // Clock generation
  always begin
    clk = 1'b0;
    #(CLK_PERIOD/2);
    clk = 1'b1;
    #(CLK_PERIOD/2);
  end

  // Test procedure
  initial begin
    // Initialize signals
    rstn = 1'b0;
    enq = 1'b0;
    deq = 1'b0;
    data_in = 8'h00;

    // Reset the FIFO
    #(CLK_PERIOD*2);
    rstn = 1'b1;
    #(CLK_PERIOD);

    // Test 1: Enqueue multiple items
    repeat(8) begin
      enq = 1'b1;
      data_in = $random;
      #(CLK_PERIOD);
    end
    enq = 1'b0;

    // Test 2: Dequeue multiple items
    #(CLK_PERIOD*2);
    repeat(4) begin
      deq = 1'b1;
      #(CLK_PERIOD);
    end
    deq = 1'b0;

    // Test 3: Alternating enqueue and dequeue
    #(CLK_PERIOD*2);
    repeat(4) begin
      enq = 1'b1;
      data_in = $random;
      #(CLK_PERIOD);
      enq = 1'b0;
      deq = 1'b1;
      #(CLK_PERIOD);
      deq = 1'b0;
    end

    // Test 4: Try to dequeue when empty
    #(CLK_PERIOD*2);
    while (!empty) begin
      deq = 1'b1;
      #(CLK_PERIOD);
    end
    #(CLK_PERIOD);
    deq = 1'b1;
    #(CLK_PERIOD);
    deq = 1'b0;

    // Test 5: Fill the FIFO and try to enqueue more
    #(CLK_PERIOD*2);
    repeat(DEPTH) begin
      enq = 1'b1;
      data_in = $random;
      #(CLK_PERIOD);
    end
    // Try to enqueue one more item
    enq = 1'b1;
    data_in = $random;
    #(CLK_PERIOD);
    enq = 1'b0;

    // End simulation
    #(CLK_PERIOD*10);
    $finish;
  end

  // Monitor
  always @(posedge clk) begin
    if (enq)
      $display("Time %0t: Enqueued data: %h", $time, data_in);
    if (deq && !empty)
      $display("Time %0t: Dequeued data: %h", $time, data_out);
    if (empty)
      $display("Time %0t: FIFO is empty", $time);
  end

endmodule