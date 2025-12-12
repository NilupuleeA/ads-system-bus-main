# Remove old work library if it exists
if {[file exists "work"]} {
    vdel -all
}
vlib work

# Compile the modules
vlog  ../rtl/uart_rx.v
vlog  ../rtl/uart_tx.v
vlog  ../rtl/uart.v
vlog  ../rtl/fifo.v
vlog  ../rtl/addr_convert.v



vlog  ../rtl/mux2.v
vlog  ../rtl/mux3.v
vlog  ../rtl/slave_memory.v
vlog  ../rtl/arbiter.v
vlog  ../rtl/addr_dec.v
vlog  ../rtl/serial_bus.v
vlog  ../rtl/slave_interface.v
vlog  ../rtl/slave.v
vlog  ../rtl/master_interface.v
vlog  ../rtl/bus_bridge_master.v

vlog  ../rtl/serial_bus.v
vlog  ../rtl/top_bridge.v

# Compile the Testbench
vlog top_bridge_tb.v

vsim -voptargs="+acc=npr" top_bridge_tb -wlf core_sim.wlf


# Log all signals recursively
#log -r /*



add wave -position end sim:/top_bridge_tb/*
add wave -position end sim:/top_bridge_tb/dut/* 
add wave -position end sim:/top_bridge_tb/dut/bb_master1/*



run 800ns
