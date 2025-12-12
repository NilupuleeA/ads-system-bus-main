# Remove old work library if it exists
if {[file exists "work"]} {
    vdel -all
}
vlib work

# Compile the modules
vlog  ../rtl/master_interface.v

# Compile the Testbench
vlog master_interface_tb.v

vsim -voptargs="+acc=npr" master_interface_tb -wlf core_sim.wlf


# Log all signals recursively
#log -r /*

add wave -position end sim:/master_interface_tb/dut/*


run 800ns
