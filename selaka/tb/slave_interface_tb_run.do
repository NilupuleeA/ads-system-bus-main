# Remove old work library if it exists
if {[file exists "work"]} {
    vdel -all
}
vlib work

# Compile the modules
vlog  ../rtl/slave_interface.v

# Compile the Testbench
vlog slave_interface_tb.v

vsim -voptargs="+acc=npr" slave_interface_tb -wlf core_sim.wlf


# Log all signals recursively
#log -r /*

add wave -position end sim:/slave_interface_tb/dut/*


run 800ns
