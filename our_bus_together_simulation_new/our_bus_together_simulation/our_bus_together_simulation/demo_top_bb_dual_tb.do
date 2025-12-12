# ModelSim do file for demo_top_bb_dual_tb
# Compile everything in RTL_Mavishan and run the dual demo testbench.

# 1. Create and map the work library
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# 2. Compile RTL and testbench
# Changed +define+QUESTA_SIM to +define+MODEL_SIM
# Preserved exact file compilation order
vlog -sv +define+MODEL_SIM RTL_Mavishan/uart_tx_32.v RTL_Mavishan/uart_rx_other_16.v RTL_Mavishan/uart_other_32_16.v \
	RTL_Mavishan/*.v RTL_Mavishan/*.sv demo_top_bb_dual.v demo_top_bb_dual_tb.sv

# 3. Load Simulation
# -voptargs=+acc is CRITICAL for ModelSim to see the internal signals (bus internals, etc.)
vsim -voptargs=+acc work.demo_top_bb_dual_tb

# 4. Configure Waveforms
# Top-level clocks/resets
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/clk
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/rstn
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/start_a
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/start_b
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/mode_a
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/mode_b
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/ready_a
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/ready_b
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/LED_a
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/LED_b
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/LED_demo_a
add wave -noupdate -group "Top" sim:/demo_top_bb_dual_tb/LED_demo_b

# demo_top_bb interface-level visibility
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/clk
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/rstn
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/start
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/ready
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/mode
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/m_u_rx
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/s_u_rx
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/m_u_tx
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/s_u_tx
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/d1_addr
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/d1_wdata
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/d1_rdata
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/d1_valid
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/m1_ready
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/m1_rw_mode
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/s_ready
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/demo_data
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/memaddr
add wave -noupdate -group "demo_top_bb A" sim:/demo_top_bb_dual_tb/dut/demo_a/memwen
add wave -noupdate -group "demo_top_bb A internal" sim:/demo_top_bb_dual_tb/dut/demo_a/d1_start
add wave -noupdate -group "demo_top_bb A internal" sim:/demo_top_bb_dual_tb/dut/demo_a/edge_start
add wave -noupdate -group "demo_top_bb A internal" sim:/demo_top_bb_dual_tb/dut/demo_a/start_prev
add wave -noupdate -group "demo_top_bb A internal" sim:/demo_top_bb_dual_tb/dut/demo_a/state
add wave -noupdate -group "demo_top_bb A internal" sim:/demo_top_bb_dual_tb/dut/demo_a/next_state
add wave -noupdate -group "demo_top_bb A internal" sim:/demo_top_bb_dual_tb/dut/demo_a/counter
add wave -noupdate -group "demo_top_bb A internal" sim:/demo_top_bb_dual_tb/dut/demo_a/idx
add wave -noupdate -group "demo_top_bb A internal" sim:/demo_top_bb_dual_tb/dut/demo_a/LED_wire
add wave -noupdate -group "demo_top_bb A internal" sim:/demo_top_bb_dual_tb/dut/demo_a/d1_wdata_demo

add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/clk
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/rstn
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/start
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/ready
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/mode
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/m_u_rx
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/s_u_rx
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/m_u_tx
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/s_u_tx
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/d1_addr
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/d1_wdata
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/d1_rdata
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/d1_valid
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/m1_ready
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/m1_rw_mode
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/s_ready
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/demo_data
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/memaddr
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/memwen
add wave -noupdate -group "demo_top_bb B" sim:/demo_top_bb_dual_tb/dut/demo_b/state
add wave -noupdate -group "demo_top_bb B internal" sim:/demo_top_bb_dual_tb/dut/demo_b/d1_start
add wave -noupdate -group "demo_top_bb B internal" sim:/demo_top_bb_dual_tb/dut/demo_b/edge_start
add wave -noupdate -group "demo_top_bb B internal" sim:/demo_top_bb_dual_tb/dut/demo_b/start_prev
add wave -noupdate -group "demo_top_bb B internal" sim:/demo_top_bb_dual_tb/dut/demo_b/state
add wave -noupdate -group "demo_top_bb B internal" sim:/demo_top_bb_dual_tb/dut/demo_b/next_state
add wave -noupdate -group "demo_top_bb B internal" sim:/demo_top_bb_dual_tb/dut/demo_b/counter
add wave -noupdate -group "demo_top_bb B internal" sim:/demo_top_bb_dual_tb/dut/demo_b/idx
add wave -noupdate -group "demo_top_bb B internal" sim:/demo_top_bb_dual_tb/dut/demo_b/LED_wire
add wave -noupdate -group "demo_top_bb B internal" sim:/demo_top_bb_dual_tb/dut/demo_b/d1_wdata_demo

# Bus A internals
add wave -noupdate -group "BusA master1" sim:/demo_top_bb_dual_tb/dut/demo_a/bus/master1/*
add wave -noupdate -group "BusA master_bridge" sim:/demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/*
add wave -noupdate -group "BusA slave_bridge" sim:/demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/*
add wave -noupdate -group "BusA slave1" sim:/demo_top_bb_dual_tb/dut/demo_a/bus/slave1/*
add wave -noupdate -group "BusA slave2" sim:/demo_top_bb_dual_tb/dut/demo_a/bus/slave2/*
add wave -noupdate -group "BusA slave_bridge.uart" sim:/demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/*

# Bus B internals
add wave -noupdate -group "BusB master1" sim:/demo_top_bb_dual_tb/dut/demo_b/bus/master1/*
add wave -noupdate -group "BusB master_bridge" sim:/demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/*
add wave -noupdate -group "BusB slave_bridge" sim:/demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/*
add wave -noupdate -group "BusB slave1" sim:/demo_top_bb_dual_tb/dut/demo_b/bus/slave1/*
add wave -noupdate -group "BusB slave2" sim:/demo_top_bb_dual_tb/dut/demo_b/bus/slave2/*
add wave -noupdate -group "BusB master_bridge.uart" sim:/demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/*

# Address decoder visibility
add wave -noupdate -group "BusA addr_decoder" sim:/demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/*
add wave -noupdate -group "BusB addr_decoder" sim:/demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/*
add wave -noupdate -group "BusA arbiter" sim:/demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/*
add wave -noupdate -group "BusB arbiter" sim:/demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/*

# UART cross-links
add wave -noupdate -group "UART Links" sim:/demo_top_bb_dual_tb/dut/a_m_u_tx
add wave -noupdate -group "UART Links" sim:/demo_top_bb_dual_tb/dut/a_s_u_tx
add wave -noupdate -group "UART Links" sim:/demo_top_bb_dual_tb/dut/a_m_u_rx
add wave -noupdate -group "UART Links" sim:/demo_top_bb_dual_tb/dut/a_s_u_rx
add wave -noupdate -group "UART Links" sim:/demo_top_bb_dual_tb/dut/b_m_u_tx
add wave -noupdate -group "UART Links" sim:/demo_top_bb_dual_tb/dut/b_s_u_tx
add wave -noupdate -group "UART Links" sim:/demo_top_bb_dual_tb/dut/b_m_u_rx
add wave -noupdate -group "UART Links" sim:/demo_top_bb_dual_tb/dut/b_s_u_rx

# 5. Run simulation
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
run 8ms