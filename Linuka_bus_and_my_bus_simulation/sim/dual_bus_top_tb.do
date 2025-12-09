transcript on

vlib work
vmap work work

set root "c:/Users/pasir/Desktop/Github/ads-system-bus-main/Linuka_bus_and_my_bus_simulation"

# Symmetric bus design (package first)
set qdefs "+define+QUESTA_SIM"

vlog -sv -work work $qdefs "$root/RTL/serial-bus-design-uart_dual_fpga_symmetric/rtl/bus_bridge_pkg.sv"
vlog -sv -work work $qdefs "$root/RTL/serial-bus-design-uart_dual_fpga_symmetric/rtl/*.sv"
vlog -sv -work work $qdefs "$root/RTL/serial-bus-design-uart_dual_fpga_symmetric/rtl/uart/*.v"

# Demo bus design
vlog -sv -work work $qdefs "$root/RTL_Mavishan/*.v"

# Combined top and testbench
vlog -sv -work work $qdefs "$root/sim/dual_bus_top.sv"
vlog -sv -work work $qdefs "$root/sim/dual_bus_top_tb.sv"

vsim -voptargs=+acc work.dual_bus_top_tb

# Waves grouped for readability
add wave -group {tb_top}   sim:/dual_bus_top_tb/*

# System (symmetric) bus hierarchy
add wave -group {sys_top}      sim:/dual_bus_top_tb/dut/u_system/*
add wave -group {sys_bus}      sim:/dual_bus_top_tb/dut/u_system/system_bus/*
add wave -group {sys_init0}    sim:/dual_bus_top_tb/dut/u_system/u_initiator_local/*
add wave -group {sys_init1}    sim:/dual_bus_top_tb/dut/u_system/u_bridge_initiator/*
add wave -group {sys_tgt0}     sim:/dual_bus_top_tb/dut/u_system/u_target0/*
add wave -group {sys_tgt1}     sim:/dual_bus_top_tb/dut/u_system/u_target1/*
add wave -group {sys_bridge_t} sim:/dual_bus_top_tb/dut/u_system/u_bridge_target/*

# Demo bus hierarchy
add wave -group {demo_top}     sim:/dual_bus_top_tb/dut/u_demo/*
add wave -group {demo_bus}     sim:/dual_bus_top_tb/dut/u_demo/bus/*
add wave -group {demo_mem}     sim:/dual_bus_top_tb/dut/u_demo/memory/*

run 5 us
