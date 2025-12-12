onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /arbiter_tb/clk
add wave -noupdate /arbiter_tb/rstn
add wave -noupdate /arbiter_tb/breq1
add wave -noupdate /arbiter_tb/breq2
add wave -noupdate /arbiter_tb/bgrant1
add wave -noupdate /arbiter_tb/bgrant2
add wave -noupdate /arbiter_tb/msel
add wave -noupdate /arbiter_tb/sready1
add wave -noupdate /arbiter_tb/sready2
add wave -noupdate /arbiter_tb/sreadysp
add wave -noupdate /arbiter_tb/ssplit
add wave -noupdate /arbiter_tb/msplit1
add wave -noupdate /arbiter_tb/msplit2
add wave -noupdate /arbiter_tb/split_grant
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {47872 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {341250 ps}
