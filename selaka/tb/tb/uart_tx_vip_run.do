# Remove old work library if it exists
if {[file exists "work"]} {
    vdel -all
}
vlib work


# Compile the Testbench
vlog -sv uart_tx_vip.sv

vsim -voptargs="+acc=npr" uart_tx_vip -wlf core_sim.wlf


# Log all signals recursively
#log -r /*



add wave -position end sim:/uart_tx_vip/*




run 800ns
