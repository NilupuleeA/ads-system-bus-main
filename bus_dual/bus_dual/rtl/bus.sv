module bus #(
    parameter logic [15:0] TARGET1_BASE = 16'h0000,
    parameter int unsigned TARGET1_SIZE = 16'd2048,
    parameter logic [15:0] TARGET2_BASE = 16'h4000,
    parameter int unsigned TARGET2_SIZE = 16'd4096,
    parameter logic [15:0] TARGET3_BASE = 16'h8000,
    parameter int unsigned TARGET3_SIZE = 16'd4096
)(
    input  logic         clk,
    input  logic         rst_n,

    // Initiator 1 interface
    input  logic         m1_req,
    input  logic [7:0]   m1_data_out,
    input  logic         m1_data_out_valid,
    input  logic [15:0]  m1_address_out,
    input  logic         m1_address_out_valid,
    input  logic         m1_rw,
    input  logic         m1_ready,
    output logic         m1_grant,
    output logic [7:0]   m1_data_in,
    output logic         m1_data_in_valid,
    output logic         m1_ack,
    output logic         m1_split_ack,

    // Initiator 2 interface
    input  logic         m2_req,
    input  logic [7:0]   m2_data_out,
    input  logic         m2_data_out_valid,
    input  logic [15:0]  m2_address_out,
    input  logic         m2_address_out_valid,
    input  logic         m2_rw,
    input  logic         m2_ready,
    output logic         m2_grant,
    output logic [7:0]   m2_data_in,
    output logic         m2_data_in_valid,
    output logic         m2_ack,
    output logic         m2_split_ack,

    // Target 1 interface
    input  logic         s1_ready,
    input  logic         s1_ack,
    input  logic [7:0]   s1_data_out,
    input  logic         s1_data_out_valid,
    output logic [15:0]  s1_address_in,
    output logic         s1_address_in_valid,
    output logic [7:0]   s1_data_in,
    output logic         s1_data_in_valid,
    output logic         s1_rw,

    // Target 2 interface
    input  logic         s2_ready,
    input  logic         s2_ack,
    input  logic [7:0]   s2_data_out,
    input  logic         s2_data_out_valid,
    output logic [15:0]  s2_address_in,
    output logic         s2_address_in_valid,
    output logic [7:0]   s2_data_in,
    output logic         s2_data_in_valid,
    output logic         s2_rw,

    // Split slave (slave 3) interface
    input  logic         split_s_ready,
    input  logic         split_s_ack,
    input  logic         split_s_split_ack,
    input  logic [7:0]   split_s_data_out,
    input  logic         split_s_data_out_valid,
    input  logic         split_s_req,
    output logic [15:0]  split_s_address_in,
    output logic         split_s_address_in_valid,
    output logic [7:0]   split_s_data_in,
    output logic         split_s_data_in_valid,
    output logic         split_s_rw,
    output logic         split_s_grant
);

    typedef enum logic [1:0] {
        INIT_NONE = 2'b00,
        INIT_1    = 2'b01,
        INIT_2    = 2'b10
    } m_sel_t;

    // Initiator port wiring
    logic m1_bus_data_out;
    logic m1_bus_data_out_valid;
    logic m1_bus_mode;
    logic m1_bus_data_in;
    logic m1_bus_data_in_valid;
    logic m1_bus_m_ready;
    logic m1_bus_m_rw;
    logic m1_s_ack_int;
    logic m1_s_split_int;
    logic m1_arbiter_req;
    logic m1_arbiter_grant;

    logic m2_bus_data_out;
    logic m2_bus_data_out_valid;
    logic m2_bus_mode;
    logic m2_bus_data_in;
    logic m2_bus_data_in_valid;
    logic m2_bus_m_ready;
    logic m2_bus_m_rw;
    logic m2_s_ack_int;
    logic m2_s_split_int;
    logic m2_arbiter_req;
    logic m2_arbiter_grant;

    // Target port wiring
    logic s1_bus_data_out;
    logic s1_bus_data_out_valid;
    logic s1_bus_s_ack;

    logic s2_bus_data_out;
    logic s2_bus_data_out_valid;
    logic s2_bus_s_ack;

    logic split_port_bus_data_out;
    logic split_port_bus_data_out_valid;
    logic split_port_bus_s_ack;
    logic split_port_bus_split_ack;
    logic split_port_arbiter_split_req;

    logic [1:0] arb_sel_bits;
    m_sel_t active_init;
    logic [1:0] decoder_sel;
    logic       s1_valid;
    logic       s2_valid;
    logic       s3_valid;
    logic       s1_select_hold;
    logic       s2_select_hold;
    logic       s3_select_hold;
    logic       s1_release_pending;
    logic       s2_release_pending;
    logic       s3_release_pending;
    logic       s1_decoder_release;
    logic       s2_decoder_release;
    logic       s3_decoder_release;
    logic [2:0] decoder_release;
    logic [1:0] response_sel;
    logic       split_route_active;
    logic       split_response_pending;
    m_sel_t  s1_owner;
    m_sel_t  s2_owner;
    m_sel_t  s3_owner;
    m_sel_t  response_owner;
        m_sel_t s1_owner_eff;
        m_sel_t s2_owner_eff;
        m_sel_t s3_owner_eff;
    logic       s1_expect_data;
    logic       s1_data_seen;
    logic       s2_expect_data;
    logic       s2_data_seen;
    logic       s3_expect_data;
    logic       s3_data_seen;

    logic forward_data;
    logic forward_valid;
    logic forward_mode;

    logic last_bus_rw;
    logic current_bus_rw;

    m_sel_t split_owner;
    logic      grant_m1;
    logic      grant_m2;
    logic      grant_split;

    logic response_data;
    logic response_valid;
    logic response_ack;

    // Initiator ports
    m_port u_m_port_1 (
        .clk(clk),
        .rst_n(rst_n),
        .m_req(m1_req),
        .arbiter_grant(m1_arbiter_grant),
        .m_data_out(m1_data_out),
        .m_data_out_valid(m1_data_out_valid),
        .m_address_out(m1_address_out),
        .m_address_out_valid(m1_address_out_valid),
        .m_rw(m1_rw),
        .m_ready(m1_ready),
        .s_split(m1_s_split_int),
        .s_ack(m1_s_ack_int),
        .bus_data_in_valid(m1_bus_data_in_valid),
        .bus_data_in(m1_bus_data_in),
        .bus_data_out(m1_bus_data_out),
        .m_grant(m1_grant),
        .m_data_in(m1_data_in),
        .m_data_in_valid(m1_data_in_valid),
        .bus_data_out_valid(m1_bus_data_out_valid),
        .arbiter_req(m1_arbiter_req),
        .bus_mode(m1_bus_mode),
        .m_ack(m1_ack),
        .bus_m_ready(m1_bus_m_ready),
        .bus_m_rw(m1_bus_m_rw),
        .m_split_ack(m1_split_ack)
    );

    m_port u_m_port_2 (
        .clk(clk),
        .rst_n(rst_n),
        .m_req(m2_req),
        .arbiter_grant(m2_arbiter_grant),
        .m_data_out(m2_data_out),
        .m_data_out_valid(m2_data_out_valid),
        .m_address_out(m2_address_out),
        .m_address_out_valid(m2_address_out_valid),
        .m_rw(m2_rw),
        .m_ready(m2_ready),
        .s_split(m2_s_split_int),
        .s_ack(m2_s_ack_int),
        .bus_data_in_valid(m2_bus_data_in_valid),
        .bus_data_in(m2_bus_data_in),
        .bus_data_out(m2_bus_data_out),
        .m_grant(m2_grant),
        .m_data_in(m2_data_in),
        .m_data_in_valid(m2_data_in_valid),
        .bus_data_out_valid(m2_bus_data_out_valid),
        .arbiter_req(m2_arbiter_req),
        .bus_mode(m2_bus_mode),
        .m_ack(m2_ack),
        .bus_m_ready(m2_bus_m_ready),
        .bus_m_rw(m2_bus_m_rw),
        .m_split_ack(m2_split_ack)
    );

    // Target ports
    s_port u_s_port_1 (
        .clk(clk),
        .rst_n(rst_n),
        .s_data_out(s1_data_out),
        .s_data_out_valid(s1_data_out_valid),
        .s_rw(s1_rw),
        .s_ready(s1_ready),
        .s_ack(s1_ack),
        .decoder_valid(s1_valid),
        .bus_data_in_valid(forward_valid),
        .bus_data_in(forward_data),
        .bus_mode(forward_mode),
        .bus_data_out(s1_bus_data_out),
        .s_data_in(s1_data_in),
        .s_data_in_valid(s1_data_in_valid),
        .s_address_in(s1_address_in),
        .s_address_in_valid(s1_address_in_valid),
        .bus_data_out_valid(s1_bus_data_out_valid),
        .bus_s_ready(),
        .bus_s_rw(),
        .bus_s_ack(s1_bus_s_ack)
    );

    s_port u_s_port_2 (
        .clk(clk),
        .rst_n(rst_n),
        .s_data_out(s2_data_out),
        .s_data_out_valid(s2_data_out_valid),
        .s_rw(s2_rw),
        .s_ready(s2_ready),
        .s_ack(s2_ack),
        .decoder_valid(s2_valid),
        .bus_data_in_valid(forward_valid),
        .bus_data_in(forward_data),
        .bus_mode(forward_mode),
        .bus_data_out(s2_bus_data_out),
        .s_data_in(s2_data_in),
        .s_data_in_valid(s2_data_in_valid),
        .s_address_in(s2_address_in),
        .s_address_in_valid(s2_address_in_valid),
        .bus_data_out_valid(s2_bus_data_out_valid),
        .bus_s_ready(),
        .bus_s_rw(),
        .bus_s_ack(s2_bus_s_ack)
    );

    split_s_port u_split_s_port (
        .clk(clk),
        .rst_n(rst_n),
        .split_req(split_s_req),
        .arbiter_grant(grant_split),
        .s_data_out(split_s_data_out),
        .s_data_out_valid(split_s_data_out_valid),
        .s_rw(split_s_rw),
        .s_ready(split_s_ready),
        .s_split_ack(split_s_split_ack),
        .s_ack(split_s_ack),
        .decoder_valid(s3_valid),
        .bus_data_in_valid(forward_valid),
        .bus_data_in(forward_data),
        .bus_mode(forward_mode),
        .bus_data_out(split_port_bus_data_out),
        .split_grant(split_s_grant),
        .s_data_in(split_s_data_in),
        .s_data_in_valid(split_s_data_in_valid),
        .s_address_in(split_s_address_in),
        .s_address_in_valid(split_s_address_in_valid),
        .bus_data_out_valid(split_port_bus_data_out_valid),
        .arbiter_split_req(split_port_arbiter_split_req),
        .split_ack(),
        .bus_s_ready(),
        .bus_s_rw(),
        .bus_split_ack(split_port_bus_split_ack),
        .bus_s_ack(split_port_bus_s_ack)
    );

    // Arbiter and decoder
    arbiter u_arbiter (
        .clk(clk),
        .rst_n(rst_n),
        .req_m_1(m1_arbiter_req),
        .req_m_2(m2_arbiter_req),
        .req_split(split_port_arbiter_split_req),
        .grant_m_1(grant_m1),
        .grant_m_2(grant_m2),
        .grant_split(grant_split),
        .sel(arb_sel_bits)
    );

    assign decoder_release = {s3_decoder_release, s2_decoder_release, s1_decoder_release};

    address_decoder #(
        .TARGET1_BASE(TARGET1_BASE),
        .TARGET1_SIZE(TARGET1_SIZE),
        .TARGET2_BASE(TARGET2_BASE),
        .TARGET2_SIZE(TARGET2_SIZE),
        .TARGET3_BASE(TARGET3_BASE),
        .TARGET3_SIZE(TARGET3_SIZE)
    ) u_address_decoder (
        .clk(clk),
        .rst_n(rst_n),
        .bus_data_in(forward_data),
        .bus_data_in_valid(forward_valid),
        .bus_mode(forward_mode),
        .release_valids(decoder_release),
        .s_1_valid(s1_valid),
        .s_2_valid(s2_valid),
        .s_3_valid(s3_valid),
        .sel(decoder_sel)
    );

    // Hold slave selection until the transaction completes so the ports keep
    // seeing a stable decoder gate. Release occurs once an ACK has been seen
    // and the slave is no longer driving return data.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_select_hold <= 1'b0;
            s2_select_hold <= 1'b0;
            s3_select_hold <= 1'b0;
            s1_release_pending <= 1'b0;
            s2_release_pending <= 1'b0;
            s3_release_pending <= 1'b0;
            s1_decoder_release <= 1'b0;
            s2_decoder_release <= 1'b0;
            s3_decoder_release <= 1'b0;
            s1_owner <= INIT_NONE;
            s2_owner <= INIT_NONE;
            s3_owner <= INIT_NONE;
            s1_expect_data <= 1'b0;
            s1_data_seen   <= 1'b0;
            s2_expect_data <= 1'b0;
            s2_data_seen   <= 1'b0;
            s3_expect_data <= 1'b0;
            s3_data_seen   <= 1'b0;
        end else begin
            s1_decoder_release <= 1'b0;
            s2_decoder_release <= 1'b0;
            s3_decoder_release <= 1'b0;

            // Target 1 hold management.
            if (s1_valid && !s1_select_hold) begin
                s1_select_hold <= 1'b1;
                s1_release_pending <= 1'b0;
                s1_expect_data <= (current_bus_rw == 1'b0);
                s1_data_seen   <= 1'b0;
                if (active_init != INIT_NONE)
                    s1_owner <= active_init;
            end

            if (s1_bus_s_ack)
                s1_release_pending <= 1'b1;

            if (s1_select_hold && s1_bus_data_out_valid)
                s1_data_seen <= 1'b1;

            if (s1_select_hold && s1_release_pending &&
                (!s1_expect_data || (s1_data_seen && !s1_bus_data_out_valid))) begin
                s1_select_hold <= 1'b0;
                s1_release_pending <= 1'b0;
                s1_decoder_release <= 1'b1;
                s1_owner <= INIT_NONE;
                s1_expect_data <= 1'b0;
                s1_data_seen   <= 1'b0;
            end

            // Target 2 mirrors slave 1 behaviour.
            if (s2_valid && !s2_select_hold) begin
                s2_select_hold <= 1'b1;
                s2_release_pending <= 1'b0;
                s2_expect_data <= (current_bus_rw == 1'b0);
                s2_data_seen   <= 1'b0;
                if (active_init != INIT_NONE)
                    s2_owner <= active_init;
            end

            if (s2_bus_s_ack)
                s2_release_pending <= 1'b1;

            if (s2_select_hold && s2_bus_data_out_valid)
                s2_data_seen <= 1'b1;

            if (s2_select_hold && s2_release_pending &&
                (!s2_expect_data || (s2_data_seen && !s2_bus_data_out_valid))) begin
                s2_select_hold <= 1'b0;
                s2_release_pending <= 1'b0;
                s2_decoder_release <= 1'b1;
                s2_owner <= INIT_NONE;
                s2_expect_data <= 1'b0;
                s2_data_seen   <= 1'b0;
            end

            // Split slave: release immediately on split-ACK or after the
            // deferred response has drained.
            if (s3_valid && !s3_select_hold) begin
                s3_select_hold <= 1'b1;
                s3_release_pending <= 1'b0;
                s3_expect_data <= (current_bus_rw == 1'b0);
                s3_data_seen   <= 1'b0;
                if (active_init != INIT_NONE)
                    s3_owner <= active_init;
            end

            if (split_port_bus_split_ack) begin
                s3_select_hold <= 1'b0;
                s3_release_pending <= 1'b0;
                s3_decoder_release <= 1'b1;
                s3_owner <= INIT_NONE;
                s3_expect_data <= 1'b0;
                s3_data_seen   <= 1'b0;
            end else begin
                if (split_port_bus_s_ack)
                    s3_release_pending <= 1'b1;

                if (s3_select_hold && split_port_bus_data_out_valid)
                    s3_data_seen <= 1'b1;

                if (s3_select_hold && s3_release_pending &&
                    (!s3_expect_data || (s3_data_seen && !split_port_bus_data_out_valid))) begin
                    s3_select_hold <= 1'b0;
                    s3_release_pending <= 1'b0;
                    s3_decoder_release <= 1'b1;
                    s3_owner <= INIT_NONE;
                    s3_expect_data <= 1'b0;
                    s3_data_seen   <= 1'b0;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            active_init <= INIT_NONE;
        end else begin
            if (grant_m1) begin
                active_init <= INIT_1;
            end else if (grant_m2) begin
                active_init <= INIT_2;
            end else if ((active_init == INIT_1 && !m1_arbiter_req) ||
                         (active_init == INIT_2 && !m2_arbiter_req)) begin
                active_init <= INIT_NONE;
            end
        end
    end

    // Forward bus multiplexing
    always_comb begin
        forward_data  = 1'b0;
        forward_valid = 1'b0;
        forward_mode  = 1'b0;

        if (grant_split) begin
            forward_mode = 1'b1;
        end else begin
            unique case (active_init)
                INIT_1: begin
                    forward_data  = m1_bus_data_out;
                    forward_valid = m1_bus_data_out_valid;
                    forward_mode  = m1_bus_mode;
                end
                INIT_2: begin
                    forward_data  = m2_bus_data_out;
                    forward_valid = m2_bus_data_out_valid;
                    forward_mode  = m2_bus_mode;
                end
                default: ;
            endcase
        end

    end

    // Track last requested direction so slaves see a stable RW qualifier.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            last_bus_rw <= 1'b0;
        end else begin
            case (active_init)
                INIT_1: last_bus_rw <= m1_bus_m_rw;
                INIT_2: last_bus_rw <= m2_bus_m_rw;
                default: ;
            endcase
        end
    end

    always_comb begin
        unique case (active_init)
            INIT_1: current_bus_rw = m1_bus_m_rw;
            INIT_2: current_bus_rw = m2_bus_m_rw;
            default: current_bus_rw = last_bus_rw;
        endcase
    end

    assign s1_rw      = current_bus_rw;
    assign s2_rw      = current_bus_rw;
    assign split_s_rw = current_bus_rw;

    // Remember which master owns the pending split response.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            split_owner <= INIT_NONE;
            split_response_pending <= 1'b0;
        end else begin
            if (split_port_bus_split_ack) begin
                if (active_init != INIT_NONE)
                    split_owner <= active_init;
                else if (grant_m1)
                    split_owner <= INIT_1;
                else if (grant_m2)
                    split_owner <= INIT_2;
                split_response_pending <= 1'b1;
            end

            if (split_port_bus_s_ack)
                split_response_pending <= 1'b0;

            if (!split_response_pending &&
                !s3_select_hold &&
                !split_port_bus_data_out_valid &&
                !split_port_bus_s_ack) begin
                split_owner <= INIT_NONE;
            end
        end
    end

    assign split_route_active = (split_owner != INIT_NONE) &&
                                 (s3_select_hold || split_port_bus_data_out_valid || split_port_bus_s_ack);

    // Determine which slave currently owns the return path.
        always_comb begin
            // Fall back to the currently active master when the owner register has not
            // latched yet, so first-cycle responses are not dropped.
            s1_owner_eff = s1_owner;
            if ((s1_owner_eff == INIT_NONE) && (active_init != INIT_NONE) &&
                (s1_select_hold || s1_valid))
                s1_owner_eff = active_init;

            s2_owner_eff = s2_owner;
            if ((s2_owner_eff == INIT_NONE) && (active_init != INIT_NONE) &&
                (s2_select_hold || s2_valid))
                s2_owner_eff = active_init;

            s3_owner_eff = s3_owner;
            if ((s3_owner_eff == INIT_NONE) && (active_init != INIT_NONE) &&
                (s3_select_hold || s3_valid))
                s3_owner_eff = active_init;
        end

    always_comb begin
        if (split_route_active)
            response_sel = 2'b10;
        else if (s3_select_hold)
            response_sel = 2'b10;
        else if (s2_select_hold)
            response_sel = 2'b01;
        else if (s1_select_hold)
            response_sel = 2'b00;
        else
            response_sel = 2'b00;
    end

    always_comb begin
        if (split_route_active) begin
            response_owner = split_owner;
        end else begin
            unique case (response_sel)
                    2'b10: response_owner = s3_owner_eff;
                    2'b01: response_owner = s2_owner_eff;
                    default: response_owner = s1_owner_eff;
            endcase
        end
    end

    // Backward path selection based on latched decoder outputs.
    always_comb begin
        response_data  = 1'b0;
        response_valid = 1'b0;
        response_ack   = 1'b0;

        unique case (response_sel)
            2'b10: begin
                response_data  = split_port_bus_data_out;
                response_valid = split_port_bus_data_out_valid;
                response_ack   = split_port_bus_s_ack;
            end
            2'b01: begin
                response_data  = s2_bus_data_out;
                response_valid = s2_bus_data_out_valid;
                response_ack   = s2_bus_s_ack;
            end
            default: begin
                response_data  = s1_bus_data_out;
                response_valid = s1_bus_data_out_valid;
                response_ack   = s1_bus_s_ack;
            end
        endcase
    end

    // Drive master-side return signals.
    always_comb begin
        m1_bus_data_in        = 1'b0;
        m1_bus_data_in_valid  = 1'b0;
        m1_s_ack_int     = 1'b0;
        m1_s_split_int   = 1'b0;

        m2_bus_data_in        = 1'b0;
        m2_bus_data_in_valid  = 1'b0;
        m2_s_ack_int     = 1'b0;
        m2_s_split_int   = 1'b0;

        case (response_owner)
            INIT_1: begin
                m1_bus_data_in       = response_data;
                m1_bus_data_in_valid = response_valid;
                m1_s_ack_int    = response_ack;
            end
            INIT_2: begin
                m2_bus_data_in       = response_data;
                m2_bus_data_in_valid = response_valid;
                m2_s_ack_int    = response_ack;
            end
            default: ;
        endcase

        if (split_port_bus_split_ack) begin
            case (active_init)
                INIT_1: m1_s_split_int = 1'b1;
                INIT_2: m2_s_split_int = 1'b1;
                default: begin
                    if (split_owner == INIT_1)
                        m1_s_split_int = 1'b1;
                    else if (split_owner == INIT_2)
                        m2_s_split_int = 1'b1;
                end
            endcase
        end
    end

    // Grant routing back to masters.
    assign m1_arbiter_grant = grant_m1 | (grant_split && split_owner == INIT_1);
    assign m2_arbiter_grant = grant_m2 | (grant_split && split_owner == INIT_2);

endmodule
