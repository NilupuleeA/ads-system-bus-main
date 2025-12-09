# Clean simulation script for combined_top
# Usage: vsim -do run_combined.do

# Clean up existing libraries
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

echo "========================================="
echo "Compiling all design files..."
echo "========================================="

# Compile Altera behavioral model
vlog RTL_Mavishan/altsyncram.v

# Compile RTL_Linuka files
vlog -sv RTL_Linuka/bus_bridge_pkg.sv
vlog -sv RTL_Linuka/addr_decoder.sv
vlog -sv RTL_Linuka/arbiter.sv
vlog -sv RTL_Linuka/init_port.sv
vlog -sv RTL_Linuka/target_port.sv
vlog -sv RTL_Linuka/split_target_port.sv
vlog RTL_Linuka/uart/buadrate.v
vlog RTL_Linuka/uart/receiver.v
vlog RTL_Linuka/uart/transmitter.v
vlog RTL_Linuka/uart/uart.v
vlog -sv RTL_Linuka/bus_bridge_initiator_if.sv
vlog -sv RTL_Linuka/bus_bridge_target_if.sv
vlog -sv RTL_Linuka/bus_bridge.sv
vlog -sv RTL_Linuka/bus_bridge_initiator_uart_wrapper.sv
vlog -sv RTL_Linuka/bus_bridge_target_uart_wrapper.sv
vlog -sv RTL_Linuka/initiator.sv
vlog -sv RTL_Linuka/target.sv
vlog -sv RTL_Linuka/split_target.sv
vlog -sv RTL_Linuka/bus.sv
vlog -sv RTL_Linuka/system_top_with_bus_bridge_a.sv

# Compile RTL_Mavishan files
vlog RTL_Mavishan/addr_convert.v
vlog RTL_Mavishan/addr_decoder_mav.v
vlog RTL_Mavishan/arbiter_mav.v
vlog RTL_Mavishan/dec3.v
vlog RTL_Mavishan/mux2.v
vlog RTL_Mavishan/mux3.v
vlog RTL_Mavishan/master_port.v
vlog RTL_Mavishan/slave_port.v
vlog RTL_Mavishan/fifo.v
vlog -sv RTL_Mavishan/baudrate.sv
vlog RTL_Mavishan/uart_rx.v
vlog RTL_Mavishan/uart_tx.v
vlog RTL_Mavishan/uart_mav.v
vlog RTL_Mavishan/uart_rx_other.v
vlog RTL_Mavishan/uart_tx_other.v
vlog RTL_Mavishan/uart_other.v
vlog RTL_Mavishan/bus_bridge_master.v
vlog RTL_Mavishan/bus_bridge_slave.v
vlog RTL_Mavishan/slave_bram.v
vlog RTL_Mavishan/slave_bram_2k.v
vlog RTL_Mavishan/slave_memory_bram.v
vlog RTL_Mavishan/slave_with_bram.v
vlog RTL_Mavishan/master_bram.v
vlog RTL_Mavishan/bus_m2_s3.v
vlog RTL_Mavishan/top_with_bb_v1.v
vlog RTL_Mavishan/demo_top_bb.v

# Compile combined top and testbench
vlog -sv combined_top.sv
vlog -sv combined_top_tb.sv

echo "========================================="
echo "Compilation complete!"
echo "========================================="

# Load simulation
vsim -voptargs=+acc work.combined_top_tb

# Add waveforms
add wave -divider "==== Clock and Reset ===="
add wave -hex /combined_top_tb/clk
add wave -hex /combined_top_tb/btn_reset

add wave -divider "==== Control Signals ===="
add wave -hex /combined_top_tb/btn_trigger
add wave -hex /combined_top_tb/start
add wave -hex /combined_top_tb/mode
add wave -hex /combined_top_tb/ready

add wave -divider "==== UART Cross-Connection ===="
add wave -hex /combined_top_tb/u_dut/uart_a_to_b
add wave -hex /combined_top_tb/u_dut/uart_b_to_a

add wave -divider "==== Bus A - Initiator 1 ===="
add wave -hex /combined_top_tb/u_dut/u_system_a/init1_req
add wave -hex /combined_top_tb/u_dut/u_system_a/init1_grant
add wave -hex /combined_top_tb/u_dut/u_system_a/init1_addr_out
add wave -hex /combined_top_tb/u_dut/u_system_a/init1_data_out
add wave -hex /combined_top_tb/u_dut/u_system_a/init1_rw
add wave -hex /combined_top_tb/u_dut/u_system_a/init1_ack

add wave -divider "==== Bus B - Demo Top ===="
add wave -hex /combined_top_tb/u_dut/u_demo_bb/state
add wave -hex /combined_top_tb/u_dut/u_demo_bb/d1_valid
add wave -hex /combined_top_tb/u_dut/u_demo_bb/m1_ready
add wave -hex /combined_top_tb/u_dut/u_demo_bb/d1_addr
add wave -hex /combined_top_tb/u_dut/u_demo_bb/d1_wdata
add wave -hex /combined_top_tb/u_dut/u_demo_bb/d1_rdata

# System A UART signals (top ports and internal bridge)
add wave -divider "==== System A UART ===="
add wave -hex /combined_top_tb/u_dut/u_system_a/uart_tx
add wave -hex /combined_top_tb/u_dut/u_system_a/uart_rx
add wave -hex /combined_top_tb/u_dut/u_system_a/u_bridge_target/uart_tx
add wave -hex /combined_top_tb/u_dut/u_system_a/u_bridge_target/uart_rx

# Master bridge (demo_top) FIFO and UART internals
add wave -divider "==== Master Bridge (bb_master) Internals ===="
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/bb_master/fifo_dout
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/bb_master/fifo_empty
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/bb_master/u_dout
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/bb_master/u_tx
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/bb_master/u_rx
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/bb_master/u_tx_busy
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/bb_master/u_rx_ready
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/bb_master/daddr
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/bb_master/dwdata
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/bb_master/dvalid

# Slave 1 interface and internals
add wave -divider "==== Slave1 (slave_with_bram) ===="
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/swdata
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/srdata
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/smode
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/mvalid
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/svalid
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sready
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/demo_data
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/LED
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/state
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/smemwen
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/smemren
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/smemaddr
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/smemwdata
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/smemrdata
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/demo_data
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/addr
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/wdata
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/mode
add wave -hex /combined_top_tb/u_dut/u_demo_bb/bus/slave1/sp/counter

echo "========================================="
echo "Starting simulation..."
echo "Use 'run -all' to run complete test"
echo "or 'run 100us' to run for specific time"
echo "========================================="

# Uncomment the next line to run automatically
# run -all
