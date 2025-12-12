# Start simulation (compiled testbench snapshot)
vsim addr_dec_tb -voptargs=+acc -wlf addr_dec_sim.wlf

# Log all signals in the design
log -r /*

# Add waves from testbench
add wave -position end sim:/addr_dec_tb/*

# Run simulation for a specified time
run 800ns

# Quit after simulation
#quit -f
