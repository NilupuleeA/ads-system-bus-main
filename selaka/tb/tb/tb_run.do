# Remove old work library if it exists
if {[file exists "work"]} {
    vdel -all
}
vlib work

# Compile the modules
vlog  ../rtl/mux2.v
vlog  ../rtl/mux3.v
vlog  ../rtl/slave_memory.v
vlog  ../rtl/arbiter.v
vlog  ../rtl/addr_dec.v
vlog  ../rtl/serial_bus.v
vlog  ../rtl/slave_interface.v
vlog  ../rtl/slave.v
vlog  ../rtl/master_interface.v
vlog  ../rtl/serial_bus.v
vlog  ../rtl/top.v

# Compile the Testbench
vlog tb.v

vsim -voptargs="+acc=npr" tb -wlf core_sim.wlf


# Log all signals recursively
#log -r /*




#add wave -position end sim:/tb/dut/master1_inst/mwdata  
#add wave -position end sim:/tb/dut/master1_inst/maddr   
#add wave -position end sim:/tb/dut/master1_inst/mwvalid 
#add wave -position end sim:/tb/dut/master1_inst/mrdata  
#add wave -position end sim:/tb/dut/master1_inst/mrvalid 
#add wave -position end sim:/tb/dut/master1_inst/mready  
#add wave -position end sim:/tb/dut/master1_inst/wen     
#
#
#
#
#add wave -position end sim:/tb/dut/master2_inst/mwdata  
#add wave -position end sim:/tb/dut/master2_inst/maddr   
#add wave -position end sim:/tb/dut/master2_inst/mwvalid 
#add wave -position end sim:/tb/dut/master2_inst/mrdata  
#add wave -position end sim:/tb/dut/master2_inst/mrvalid 
#add wave -position end sim:/tb/dut/master2_inst/mready  
#add wave -position end sim:/tb/dut/master2_inst/wen     
#
#
#
#
#add wave -position end sim:/tb/dut/slave1/u_if/mem_addr
#add wave -position end sim:/tb/dut/slave1/u_if/mem_wen 
#add wave -position end sim:/tb/dut/slave1/u_if/mem_ren
#add wave -position end sim:/tb/dut/slave1/u_if/mem_rdata 
#add wave -position end sim:/tb/dut/slave1/u_if/mem_rvalid
#add wave -position end sim:/tb/dut/slave1/u_if/mem_wdata
#add wave -position end sim:/tb/dut/slave1/u_if/mem_wvalid
#
#
#
#add wave -position end sim:/tb/dut/slave2/u_if/mem_addr
#add wave -position end sim:/tb/dut/slave2/u_if/mem_wen 
#add wave -position end sim:/tb/dut/slave2/u_if/mem_ren
#add wave -position end sim:/tb/dut/slave2/u_if/mem_rdata 
#add wave -position end sim:/tb/dut/slave2/u_if/mem_rvalid
#add wave -position end sim:/tb/dut/slave2/u_if/mem_wdata
#add wave -position end sim:/tb/dut/slave2/u_if/mem_wvalid
#
#
#
#add wave -position end sim:/tb/dut/slave3/u_if/mem_addr
#add wave -position end sim:/tb/dut/slave3/u_if/mem_wen 
#add wave -position end sim:/tb/dut/slave3/u_if/mem_ren
#add wave -position end sim:/tb/dut/slave3/u_if/mem_rdata 
#add wave -position end sim:/tb/dut/slave3/u_if/mem_rvalid
#add wave -position end sim:/tb/dut/slave3/u_if/mem_wdata
#add wave -position end sim:/tb/dut/slave3/u_if/mem_wvalid
#
#add wave -position end sim:/tb/dut/slave3/u_if/state
#





add wave -position end sim:/tb/*
add wave -position end sim:/tb/dut/*
add wave -position end sim:/tb/dut/master2_inst/*
add wave -position end sim:/tb/dut/slave1/*
add wave -position end sim:/tb/dut/slave1/u_if/*

add wave -position end sim:/tb/dut/bus_inst/arbiter_inst/*
add wave -position end sim:/tb/dut/bus_inst/addr_decoder/*




#add wave -position end sim:/tb/dut/bus_inst/arbiter_inst/*
#add wave -position end sim:/tb/dut/bus_inst/addr_decoder/*


#add wave -position end sim:/tb/dut/bus_inst/s_wvalid
#add wave -position end sim:/tb/dut/bus_inst/s3_wvalid
#add wave -position end sim:/tb/dut/s3_wvalid

#add wave -position end sim:/tb/dut/bus_inst/*
#add wave -position end sim:/tb/dut/bus_inst/s1_rdata
#add wave -position end sim:/tb/dut/bus_inst/s1_mode
#add wave -position end sim:/tb/dut/bus_inst/s1_wvalid
#add wave -position end sim:/tb/dut/bus_inst/s1_rvalid
#add wave -position end sim:/tb/dut/bus_inst/s1_ready
#add wave -position end sim:/tb/dut/bus_inst/mctrl_mux/*
#add wave -position end sim:/tb/dut/slave_mem_inst/*
#
#add wave -position end sim:/tb/dut/bus_inst/addr_decoder/*


run 800ns
