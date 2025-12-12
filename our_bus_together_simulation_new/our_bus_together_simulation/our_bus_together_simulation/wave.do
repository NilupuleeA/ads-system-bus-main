onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Top /demo_top_bb_dual_tb/clk
add wave -noupdate -expand -group Top /demo_top_bb_dual_tb/rstn
add wave -noupdate -expand -group Top /demo_top_bb_dual_tb/start_a
add wave -noupdate -expand -group Top /demo_top_bb_dual_tb/start_b
add wave -noupdate -expand -group Top /demo_top_bb_dual_tb/mode_a
add wave -noupdate -expand -group Top /demo_top_bb_dual_tb/mode_b
add wave -noupdate -expand -group Top /demo_top_bb_dual_tb/ready_a
add wave -noupdate -expand -group Top /demo_top_bb_dual_tb/ready_b
add wave -noupdate -expand -group Top /demo_top_bb_dual_tb/LED_a
add wave -noupdate -expand -group Top /demo_top_bb_dual_tb/LED_b
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/clk
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/rstn
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/start
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/ready
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/mode
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/m_u_rx
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/s_u_rx
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/m_u_tx
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/s_u_tx
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/d1_addr
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/d1_wdata
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/d1_rdata
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/d1_valid
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/m1_ready
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/m1_rw_mode
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/s_ready
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/demo_data
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/memaddr
add wave -noupdate -group {demo_top_bb A} /demo_top_bb_dual_tb/dut/demo_a/memwen
add wave -noupdate -group {demo_top_bb A internal} /demo_top_bb_dual_tb/dut/demo_a/d1_start
add wave -noupdate -group {demo_top_bb A internal} /demo_top_bb_dual_tb/dut/demo_a/edge_start
add wave -noupdate -group {demo_top_bb A internal} /demo_top_bb_dual_tb/dut/demo_a/start_prev
add wave -noupdate -group {demo_top_bb A internal} /demo_top_bb_dual_tb/dut/demo_a/state
add wave -noupdate -group {demo_top_bb A internal} /demo_top_bb_dual_tb/dut/demo_a/next_state
add wave -noupdate -group {demo_top_bb A internal} /demo_top_bb_dual_tb/dut/demo_a/counter
add wave -noupdate -group {demo_top_bb A internal} /demo_top_bb_dual_tb/dut/demo_a/idx
add wave -noupdate -group {demo_top_bb A internal} /demo_top_bb_dual_tb/dut/demo_a/LED_wire
add wave -noupdate -group {demo_top_bb A internal} /demo_top_bb_dual_tb/dut/demo_a/d1_wdata_demo
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/clk
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/rstn
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/start
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/ready
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/mode
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/m_u_rx
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/s_u_rx
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/m_u_tx
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/s_u_tx
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/d1_addr
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/d1_wdata
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/d1_rdata
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/d1_valid
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/m1_ready
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/m1_rw_mode
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/s_ready
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/demo_data
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/memaddr
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/memwen
add wave -noupdate -expand -group {demo_top_bb B} /demo_top_bb_dual_tb/dut/demo_b/state
add wave -noupdate -group {demo_top_bb B internal} /demo_top_bb_dual_tb/dut/demo_b/d1_start
add wave -noupdate -group {demo_top_bb B internal} /demo_top_bb_dual_tb/dut/demo_b/edge_start
add wave -noupdate -group {demo_top_bb B internal} /demo_top_bb_dual_tb/dut/demo_b/start_prev
add wave -noupdate -group {demo_top_bb B internal} /demo_top_bb_dual_tb/dut/demo_b/state
add wave -noupdate -group {demo_top_bb B internal} /demo_top_bb_dual_tb/dut/demo_b/next_state
add wave -noupdate -group {demo_top_bb B internal} /demo_top_bb_dual_tb/dut/demo_b/counter
add wave -noupdate -group {demo_top_bb B internal} /demo_top_bb_dual_tb/dut/demo_b/idx
add wave -noupdate -group {demo_top_bb B internal} /demo_top_bb_dual_tb/dut/demo_b/LED_wire
add wave -noupdate -group {demo_top_bb B internal} /demo_top_bb_dual_tb/dut/demo_b/d1_wdata_demo
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/clk
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/rstn
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/dwdata
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/drdata
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/daddr
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/dvalid
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/dready
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/dmode
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/mrdata
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/mwdata
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/mmode
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/mvalid
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/svalid
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/mbreq
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/mbgrant
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/msplit
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/ack
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/wdata
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/rdata
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/addr
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/mode
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/counter
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/timeout
add wave -noupdate -expand -group {BusA master1} /demo_top_bb_dual_tb/dut/demo_a/bus/master1/state
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/clk
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/rstn
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/mrdata
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/mwdata
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/mmode
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/mvalid
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/svalid
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/mbreq
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/mbgrant
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/msplit
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/ack
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/u_tx
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/u_rx
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/LEDs
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/dwdata
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/drdata
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/daddr
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/dvalid
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/dready
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/dmode
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/fifo_enq
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/fifo_deq
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/fifo_din
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/fifo_dout
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/fifo_empty
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/u_din
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/u_en
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/u_tx_busy
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/u_rx_ready
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/u_dout
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/bb_addr
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/expect_rdata
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/prev_u_ready
add wave -noupdate -group {BusA master_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_master/prev_m_ready
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/clk
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/rstn
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/swdata
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/smode
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/mvalid
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/split_grant
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/srdata
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/svalid
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/sready
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/ssplit
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/u_tx
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/u_rx
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/spready
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/smemrdata
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/smemwen
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/smemren
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/smemaddr
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/smemwdata
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/rvalid
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/u_din
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/u_en
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/u_tx_busy
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/u_rx_ready
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/u_dout
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/state
add wave -noupdate -expand -group {BusA slave_bridge} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/next_state
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/clk
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/rstn
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/swdata
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/srdata
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/smode
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/mvalid
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/svalid
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/sready
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/demo_data
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/LED
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/smemrdata
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/smemwen
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/smemren
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/smemaddr
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/smemwdata
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/LED_wire
add wave -noupdate -group {BusA slave1} /demo_top_bb_dual_tb/dut/demo_a/bus/slave1/rvalid
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/clk
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/rstn
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/swdata
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/srdata
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/smode
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/mvalid
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/svalid
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/sready
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/demo_data
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/LED
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/smemrdata
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/smemwen
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/smemren
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/smemaddr
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/smemwdata
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/LED_wire
add wave -noupdate -group {BusA slave2} /demo_top_bb_dual_tb/dut/demo_a/bus/slave2/rvalid
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/data_input
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/data_en
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/clk
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/rstn
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/tx
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/tx_busy
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/rx
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/ready
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/data_output
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/Rxclk_en
add wave -noupdate -group {BusA slave_bridge.uart} /demo_top_bb_dual_tb/dut/demo_a/bus/bb_slave/uart_module/Txclk_en
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/clk
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/rstn
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/dwdata
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/drdata
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/daddr
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/dvalid
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/dready
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/dmode
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/mrdata
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/mwdata
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/mmode
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/mvalid
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/svalid
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/mbreq
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/mbgrant
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/msplit
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/ack
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/wdata
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/rdata
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/addr
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/mode
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/counter
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/timeout
add wave -noupdate -group {BusB master1} /demo_top_bb_dual_tb/dut/demo_b/bus/master1/state
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/clk
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/rstn
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/mrdata
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/mwdata
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/mmode
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/mvalid
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/svalid
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/mbreq
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/mbgrant
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/msplit
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/ack
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/u_tx
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/u_rx
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/LEDs
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/dwdata
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/drdata
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/daddr
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/dvalid
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/dready
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/dmode
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/fifo_enq
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/fifo_deq
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/fifo_din
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/fifo_dout
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/fifo_empty
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/u_din
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/u_en
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/u_tx_busy
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/u_rx_ready
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/u_dout
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/bb_addr
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/expect_rdata
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/prev_u_ready
add wave -noupdate -expand -group {BusB master_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/prev_m_ready
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/clk
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/rstn
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/swdata
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/smode
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/mvalid
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/split_grant
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/srdata
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/svalid
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/sready
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/ssplit
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/u_tx
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/u_rx
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/spready
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/smemrdata
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/smemwen
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/smemren
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/smemaddr
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/smemwdata
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/rvalid
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/u_din
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/u_en
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/u_tx_busy
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/u_rx_ready
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/u_dout
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/state
add wave -noupdate -group {BusB slave_bridge} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_slave/next_state
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/clk
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/rstn
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/swdata
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/srdata
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/smode
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/mvalid
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/svalid
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/sready
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/demo_data
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/LED
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/smemrdata
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/smemwen
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/smemren
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/smemaddr
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/smemwdata
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/LED_wire
add wave -noupdate -group {BusB slave1} /demo_top_bb_dual_tb/dut/demo_b/bus/slave1/rvalid
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/rstn
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/swdata
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/srdata
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/smode
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/mvalid
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/svalid
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/sready
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/demo_data
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/LED
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/smemrdata
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/smemwen
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/smemren
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/smemaddr
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/smemwdata
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/LED_wire
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/rvalid
add wave -noupdate -expand -group {BusB slave2} /demo_top_bb_dual_tb/dut/demo_b/bus/slave2/clk
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/data_input
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/data_en
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/clk
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/rstn
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/tx
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/tx_busy
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/rx
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/ready
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/data_output
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/Rxclk_en
add wave -noupdate -group {BusB master_bridge.uart} /demo_top_bb_dual_tb/dut/demo_b/bus/bb_master/uart_module/Txclk_en
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/clk
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/rstn
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/mwdata
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/mvalid
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/ssplit
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/split_grant
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/sready1
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/sready2
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/sready3
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/mvalid1
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/mvalid2
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/mvalid3
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/ssel
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/ack
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/slave_addr
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/slave_en
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/mvalid_out
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/slave_addr_valid
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/sready
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/counter
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/split_slave_addr
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/state
add wave -noupdate -group {BusA addr_decoder} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/decoder/next_state
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/clk
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/rstn
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/mwdata
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/mvalid
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/ssplit
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/split_grant
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/sready1
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/sready2
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/sready3
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/mvalid1
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/mvalid2
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/mvalid3
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/ssel
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/ack
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/slave_addr
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/slave_en
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/mvalid_out
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/slave_addr_valid
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/sready
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/counter
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/split_slave_addr
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/state
add wave -noupdate -group {BusB addr_decoder} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/decoder/next_state
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/clk
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/rstn
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/breq1
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/breq2
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/sready1
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/sready2
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/sreadysp
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/ssplit
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/bgrant1
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/bgrant2
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/msel
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/msplit1
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/msplit2
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/split_grant
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/sready
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/sready_nsplit
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/split_owner
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/state
add wave -noupdate -group {BusA arbiter} /demo_top_bb_dual_tb/dut/demo_a/bus/bus/bus_arbiter/next_state
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/clk
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/rstn
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/breq1
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/breq2
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/sready1
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/sready2
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/sreadysp
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/ssplit
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/bgrant1
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/bgrant2
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/msel
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/msplit1
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/msplit2
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/split_grant
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/sready
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/sready_nsplit
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/split_owner
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/state
add wave -noupdate -group {BusB arbiter} /demo_top_bb_dual_tb/dut/demo_b/bus/bus/bus_arbiter/next_state
add wave -noupdate -expand -group {UART Links} /demo_top_bb_dual_tb/dut/a_m_u_tx
add wave -noupdate -expand -group {UART Links} /demo_top_bb_dual_tb/dut/a_s_u_tx
add wave -noupdate -expand -group {UART Links} /demo_top_bb_dual_tb/dut/a_m_u_rx
add wave -noupdate -expand -group {UART Links} /demo_top_bb_dual_tb/dut/a_s_u_rx
add wave -noupdate -expand -group {UART Links} /demo_top_bb_dual_tb/dut/b_m_u_tx
add wave -noupdate -expand -group {UART Links} /demo_top_bb_dual_tb/dut/b_s_u_tx
add wave -noupdate -expand -group {UART Links} /demo_top_bb_dual_tb/dut/b_m_u_rx
add wave -noupdate -expand -group {UART Links} /demo_top_bb_dual_tb/dut/b_s_u_rx
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14594788179 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 250
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
WaveRestoreZoom {14594485427 ps} {14597988695 ps}
