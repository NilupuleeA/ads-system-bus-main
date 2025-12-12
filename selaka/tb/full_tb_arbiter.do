onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/clk
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/rstn
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/breq1
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/breq2
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/sready1
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/sready2
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/sreadysp
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/ssplit
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/bgrant1
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/bgrant2
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/msel
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/msplit1
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/msplit2
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/split_grant
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/state
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/next_state
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/split_owner
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/sready
add wave -noupdate /tb/dut/bus_inst/arbiter_inst/sready_nsplit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2122994 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 239
configure wave -valuecolwidth 39
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2158354 ps}
