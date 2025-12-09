
// Behavioral model of altsyncram for simulation
// This replaces the Altera-specific altsyncram megafunction

`timescale 1 ps / 1 ps

module altsyncram (
    address_a,
    address_b,
    clock0,
    clock1,
    data_a,
    data_b,
    rden_a,
    rden_b,
    wren_a,
    wren_b,
    q_a,
    q_b,
    aclr0,
    aclr1,
    addressstall_a,
    addressstall_b,
    byteena_a,
    byteena_b,
    clocken0,
    clocken1,
    clocken2,
    clocken3,
    eccstatus
);

    parameter width_a = 8;
    parameter widthad_a = 5;
    parameter numwords_a = 32;
    parameter outdata_reg_a = "UNREGISTERED";
    parameter width_byteena_a = 1;
    parameter width_b = 1;
    parameter widthad_b = 1;
    parameter numwords_b = 0;
    parameter outdata_reg_b = "UNREGISTERED";
    parameter width_byteena_b = 1;
    parameter clock_enable_input_a = "BYPASS";
    parameter clock_enable_output_a = "BYPASS";
    parameter clock_enable_input_b = "BYPASS";
    parameter clock_enable_output_b = "BYPASS";
    parameter intended_device_family = "unused";
    parameter lpm_hint = "unused";
    parameter lpm_type = "altsyncram";
    parameter operation_mode = "SINGLE_PORT";
    parameter byte_size = 8;
    parameter read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ";
    parameter read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ";
    parameter init_file = "UNUSED";
    parameter init_file_layout = "UNUSED";
    parameter maximum_depth = 0;
    parameter optimize_for_speed = "AUTO";
    parameter power_up_uninitialized = "FALSE";
    parameter ram_block_type = "AUTO";
    parameter rdcontrol_reg_b = "CLOCK1";
    parameter read_during_write_mode_mixed_ports = "DONT_CARE";
    parameter outdata_aclr_a = "NONE";
    parameter outdata_aclr_b = "NONE";
    parameter indata_reg_b = "CLOCK1";
    parameter wrcontrol_wraddress_reg_b = "CLOCK1";

    input [widthad_a-1:0] address_a;
    input [widthad_b-1:0] address_b;
    input clock0;
    input clock1;
    input [width_a-1:0] data_a;
    input [width_b-1:0] data_b;
    input rden_a;
    input rden_b;
    input wren_a;
    input wren_b;
    output [width_a-1:0] q_a;
    output [width_b-1:0] q_b;
    input aclr0;
    input aclr1;
    input addressstall_a;
    input addressstall_b;
    input [width_byteena_a-1:0] byteena_a;
    input [width_byteena_b-1:0] byteena_b;
    input clocken0;
    input clocken1;
    input clocken2;
    input clocken3;
    output [7:0] eccstatus;

    // Internal memory array
    reg [width_a-1:0] mem [0:numwords_a-1];
    reg [width_a-1:0] q_a_reg;
    reg [width_a-1:0] q_a_unreg;

    integer i;

    // Initialize memory
    initial begin
        for (i = 0; i < numwords_a; i = i + 1) begin
            mem[i] = {width_a{1'b0}};
        end
        
        // Load init file if specified
        if (init_file != "UNUSED" && init_file != "") begin
            $readmemh(init_file, mem);
        end
    end

    // Write operation
    always @(posedge clock0) begin
        if (wren_a && address_a < numwords_a) begin
            mem[address_a] <= data_a;
        end
    end

    // Read operation (unregistered)
    always @(*) begin
        if (address_a < numwords_a) begin
            q_a_unreg = mem[address_a];
        end else begin
            q_a_unreg = {width_a{1'b0}};
        end
    end

    // Read operation (registered)
    always @(posedge clock0) begin
        if (rden_a && address_a < numwords_a) begin
            q_a_reg <= mem[address_a];
        end
    end

    // Output mux based on registered or unregistered
    assign q_a = (outdata_reg_a == "CLOCK0" || outdata_reg_a == "CLOCK1") ? q_a_reg : q_a_unreg;
    assign q_b = {width_b{1'b0}};
    assign eccstatus = 8'b0;

endmodule
