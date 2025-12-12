# Questa/ModelSim .do file for simulation
# Usage: pass TB name from Makefile via vsim command line

# The Makefile must pass TB name as argument
# e.g. vsim -do tb/generic_tb_sim.do my_tb_name

# Remove old work library if it exists (optional if compiled via Makefile)
#if {[file exists "work"]} {
#    vdel -all
#}
#vlib work

# The first argument passed to this .do file is the testbench name
if { [llength $argv] < 1 } {
    puts "Error: Testbench name must be passed as argument"
    quit -f
}
set TB_NAME [lindex $argv 0]
set WLF_NAME [concat $TB_NAME "_sim.wlf"]

# Log all signals
log -r /*

# Add waves from the testbench
add wave -position end sim:/*

# Run simulation
run 1000ns

# Uncomment to quit automatically at the end
# quit -f
