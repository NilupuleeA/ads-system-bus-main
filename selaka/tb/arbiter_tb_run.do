# Remove old work library if it exists
if {[file exists "work"]} {
    vdel -all
}
vlib work

# Compile the modules

vlog  ../rtl/arbiter.v

# Compile the Testbench
vlog arbiter_tb.v

vsim -voptargs="+acc=npr" arbiter_tb -wlf core_sim.wlf


# Log all signals recursively
#log -r /*



add wave -position end sim:/arbiter_tb/* 








run 800ns
