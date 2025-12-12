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
vlog  ../rtl/test_slave_bridge.v
vlog  ../rtl/test_master_bridge.v

vlog  ../rtl/serial_bus.v
vlog  ../rtl/dual_bus_loop_fpga.v

# Compile the Testbench
vlog loop_tb.v

vsim -voptargs="+acc=npr" loop_tb -wlf core_sim.wlf


# Log all signals recursively
#log -r /*



add wave -position end sim:/loop_tb/dut/* 




run 800ns
