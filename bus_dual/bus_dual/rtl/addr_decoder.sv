module address_decoder #(
    parameter logic [15:0] TARGET1_BASE = 16'h0000,
    parameter int unsigned TARGET1_SIZE = 16'd2048,
    parameter logic [15:0] TARGET2_BASE = 16'h4000,
    parameter int unsigned TARGET2_SIZE = 16'd4096,
    parameter logic [15:0] TARGET3_BASE = 16'h8000,
    parameter int unsigned TARGET3_SIZE = 16'd4096
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        bus_data_in,
    input  logic        bus_data_in_valid,
    input  logic        bus_mode,          // 1 for data, 0 for address
    input  logic [2:0]  release_valids,    // one-hot release strobes from the bus
    output logic        s_1_valid,
    output logic        s_2_valid,
    output logic        s_3_valid,
    output logic [1:0]  sel
);

    localparam logic [15:0] LIMIT_TARGET1 = TARGET1_BASE + 16'((TARGET1_SIZE > 0) ? (TARGET1_SIZE - 1) : 0);
    localparam logic [15:0] LIMIT_TARGET2 = TARGET2_BASE + 16'((TARGET2_SIZE > 0) ? (TARGET2_SIZE - 1) : 0);
    localparam logic [15:0] LIMIT_TARGET3 = TARGET3_BASE + 16'((TARGET3_SIZE > 0) ? (TARGET3_SIZE - 1) : 0);

    function automatic logic [2:0] decode_s_address(logic [15:0] address);
        logic [2:0] decoded_result;
        decoded_result = 3'b000;

        if ((TARGET1_SIZE != 0) && (address >= TARGET1_BASE) && (address <= LIMIT_TARGET1))
            decoded_result[0] = 1'b1;
        if ((TARGET2_SIZE != 0) && (address >= TARGET2_BASE) && (address <= LIMIT_TARGET2))
            decoded_result[1] = 1'b1;
        if ((TARGET3_SIZE != 0) && (address >= TARGET3_BASE) && (address <= LIMIT_TARGET3))
            decoded_result[2] = 1'b1;

        return decoded_result;
    endfunction

    function automatic logic [1:0] encode_selection(logic [2:0] vector_valid);
        if (vector_valid[2])
            return 2'b10;
        else if (vector_valid[1])
            return 2'b01;
        else
            return 2'b00;
    endfunction

    logic [15:0] shift_addr;
    logic [4:0] count_address_bits;
    logic active_hold;
    logic [2:0] valids_held;
    logic [1:0] sel_held;
    logic [2:0] valids_pending;
    logic [1:0] sel_pending;
    logic load_pending;

    assign sel = sel_held;
    assign s_1_valid = valids_held[0];
    assign s_2_valid = valids_held[1];
    assign s_3_valid = valids_held[2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_addr <= '0;
            count_address_bits <= '0;
            active_hold <= 1'b0;
            valids_held <= 3'b000;
            sel_held <= 2'b00;
            valids_pending <= 3'b000;
            sel_pending <= 2'b00;
            load_pending <= 1'b0;
        end else begin
            logic [2:0] valids_next;
            logic [1:0] sel_next;
            logic       hold_active_next;

            valids_next = valids_held;
            sel_next = sel_held;
            hold_active_next = active_hold;

            if (load_pending) begin
                valids_next = valids_pending;
                sel_next = sel_pending;
                hold_active_next = |valids_pending;
                load_pending <= 1'b0;
            end

            if (|release_valids) begin
                valids_next &= ~release_valids;
                sel_next = encode_selection(valids_next);
                hold_active_next = |valids_next;
            end

            valids_held <= valids_next;
            sel_held <= sel_next;
            active_hold <= hold_active_next;

            if (!bus_mode && bus_data_in_valid && !active_hold) begin
                logic [15:0] next_addr;
                next_addr = {bus_data_in, shift_addr[15:1]};
                shift_addr <= next_addr;

                if (count_address_bits == 5'd15) begin
                    logic [2:0] valids_decoded;
                    logic [1:0] sel_decoded;

                    valids_decoded = decode_s_address(next_addr);
                    sel_decoded = encode_selection(valids_decoded);

                    valids_pending <= valids_decoded;
                    sel_pending <= sel_decoded;
                    load_pending <= 1'b1;
                    count_address_bits <= 5'd0;
                end else begin
                    count_address_bits <= count_address_bits + 5'd1;
                end
            end else if (!bus_mode && !bus_data_in_valid && !active_hold && !load_pending) begin
                shift_addr <= '0;
                count_address_bits <= 5'd0;
            end
        end
    end

endmodule
