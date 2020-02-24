onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {BFM CPU}
add wave -noupdate -format Literal -radix ascii /top_bench/bfm_cpu/command
add wave -noupdate -format Logic /top_bench/bfm_cpu/up_clk
add wave -noupdate -format Logic /top_bench/bfm_cpu/up_cs
add wave -noupdate -format Literal /top_bench/bfm_cpu/up_addr
add wave -noupdate -format Logic /top_bench/bfm_cpu/up_wr
add wave -noupdate -format Logic /top_bench/bfm_cpu/up_rd
add wave -noupdate -format Literal /top_bench/bfm_cpu/up_data_wr
add wave -noupdate -format Literal /top_bench/bfm_cpu/up_data_rd
add wave -noupdate -divider {BFM MDIO}
add wave -noupdate -format Logic /top_bench/bfm_mdio/mdc
add wave -noupdate -format Logic /top_bench/bfm_mdio/mdio
add wave -noupdate -format Logic /top_bench/bfm_mdio/mdio_i
add wave -noupdate -format Logic /top_bench/bfm_mdio/mdio_o
add wave -noupdate -format Logic /top_bench/bfm_mdio/mdio_oe
add wave -noupdate -format Literal /top_bench/bfm_mdio/mdio_state
add wave -noupdate -divider {BFM RGMII}
add wave -noupdate -format Logic /top_bench/bfm_rgmii/phy_giga_mode
add wave -noupdate -format Logic /top_bench/bfm_rgmii/TxClk
add wave -noupdate -format Logic /top_bench/bfm_rgmii/TxEn
add wave -noupdate -format Literal /top_bench/bfm_rgmii/TxData
add wave -noupdate -format Logic /top_bench/bfm_rgmii/RxClk
add wave -noupdate -format Logic /top_bench/bfm_rgmii/RxDv
add wave -noupdate -format Literal /top_bench/bfm_rgmii/RxData
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DUT TX_GEN}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/gen_en
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/frame_leng_cntr
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/st_hold_cntr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_gen_curr_st
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/int_valid
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/int_sop
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/int_eop
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/int_mod
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/int_data
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/payload_valid
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/gen_en
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/payload_data
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/int_l4_sum
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/gen_en
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_gen_curr_st
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/stream_index_latch
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/frame_check_point_p1
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_done_latch
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_type_latch
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/frame_check_point
add wave -noupdate -divider {tx crc}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/crc32_gen/init_i
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/crc32_gen/valid_i
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/crc32_gen/mod_i
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/crc32_gen/data_i
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/crc32_gen/crc_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/payload_gen/payload_pre_d2
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/payload_gen/payload_err_inj
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_type_latch
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_done_latch
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/test_nber
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/frame_check_point
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/nontest_latch
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_nontest_req
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_gen_next_st
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_gen_curr_st
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/payload_pre
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/payload_valid
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/payload_seed
add wave -noupdate -format Literal -radix hexadecimal /top_bench/dut/data/tx/tx_gen_inst/payload_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/info_addr_d1
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/info_data_rd
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/payload_gen/payload_type
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/payload_gen/payload_byte
add wave -noupdate -divider {DUT TX_GEN}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/clk
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/gen_en
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/rate_buffer_rd_rqst
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/rate_buffer_rd_vald
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/rate_buffer_rd_data
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/rate_buffer_rd
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/rate_buffer_empty
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/info_rd
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/info_addr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/info_data_rd
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/stream_index
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/header_leng
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_gen_curr_st
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/st_hold_cntr
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/nontest_latch
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_stat_chk
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_stat_base_addr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_stat_bit
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/line_leng
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/info_leng
add wave -noupdate -format Logic /top_bench/dut/data/tx/gen_en
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/time_stamp
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/sys_time_tx
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/frame_leng
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/header_leng
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/testtag_leng
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/payload_leng
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/ifg_leng
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/payload_tag
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/header_stat
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DUT TX_CON}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/rate_buffer_wr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/rate_buffer_wr_data
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_cout
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_curr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_last
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/rate_buffer_rd_rqst
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/rate_buffer_empty
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/rate_buffer_rd_vald
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/rate_buffer_rd
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/rate_buffer_rd_data
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {TX CON - Y1564}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/fsm_start
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/fsm_rst
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/test_start
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/up_clk
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/up_wr
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/up_rd
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/up_addr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/up_data_wr
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/frame_fifo_wr_in
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/frame_fifo_data_in
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/up_data_rd
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/frame_fifo_wr_out
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/frame_fifo_data_out
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/line_rate_en_in
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/burst_test_mask_in
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/burst_once_mask_in
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_range_in
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/buffer_capacity_in
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/cycle_number_in
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/duty_cycle_factor_in
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/safe_margin_in
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/fsm_rst
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/fsm_rst
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/fstate
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/fstate
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/buffer_hold_level
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/buffer_hold
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/buffer_empty
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/leng_holder
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/idle_frame_enable
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/space_frame_enable
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/burst_frame_enable
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_rd
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Analog-Step -height 74 -max 3850.0 /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(0)
add wave -noupdate -format Analog-Step -height 74 -max 3850.0 /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(1)
add wave -noupdate -format Analog-Step -height 36 -max 15000.0 /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(2)
add wave -noupdate -format Analog-Step -height 36 -max 15000.0 /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(3)
add wave -noupdate -format Analog-Step -height 36 -max 15000.0 /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(4)
add wave -noupdate -format Analog-Step -height 36 -max 15000.0 /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(5)
add wave -noupdate -format Analog-Step -height 36 -max 15000.0 /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(6)
add wave -noupdate -format Analog-Step -height 36 -max 15000.0 /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(7)
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/reset
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/clock
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/test_start
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/buffer_hold(0)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/buffer_full
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/buffer_half
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/buffer_ovfl
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/buffer_empty
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/duty_reached
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/cycle_reached
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/wait_once(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/fstate
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/burst_disable(0)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/cycle_reached(0)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__0/u_bwp_fsm/external_int
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/external_stop(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/wr_en(0)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rd_en(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_d1(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_d2(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/leng_holder
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/leng_holder_d1(0)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/buffer_empty(0)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/buffer_margin(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/safe_margin(0)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/idle_frame_enable(0)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/burst_frame_enable(0)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/space_frame_enable(0)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_rd
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_incr(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_pointer(0)
add wave -noupdate -format Analog-Step -height 76 -max 10028.0 /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_data
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/ovfl_counter(0)
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/cycle_counter(0)
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/cycle_number(0)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/idle_frame_cnt(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/reset
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/clock
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/test_start
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/buffer_hold(1)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/buffer_full
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/buffer_half
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/buffer_ovfl
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/buffer_empty
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/duty_reached
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/cycle_reached
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/wait_once(1)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/bwp_fsm_loop__1/u_bwp_fsm/fstate
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/burst_disable(1)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/external_stop(1)
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/wr_en(1)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rd_en(1)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter(1)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/idle_frame_enable(1)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/burst_frame_enable(1)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/space_frame_enable(1)
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_rd
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/safe_margin(1)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_pointer(1)
add wave -noupdate -format Analog-Step -height 76 -max 10030.0 /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter(1)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_counter_stable(1)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/rate_data
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/ovfl_counter(1)
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/cycle_counter(1)
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/cycle_number(1)
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/idle_frame_cnt(1)
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix binary /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/burst_test_mask
add wave -noupdate -format Literal -radix binary /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/burst_once_mask
add wave -noupdate -format Literal -radix binary /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/cycle_reached
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/clock_a
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/address_a
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/data_a
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/rden_a
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/wren_a
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/q_a
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/clock_b
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/address_b
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/data_b
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/rden_b
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/wren_b
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/emix_mem/q_b
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/up_clk
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/up_addr
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/up_wr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_con_inst/ir_con_inst/up_wr_emix
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {397665608 ps} 0}
configure wave -namecolwidth 463
configure wave -valuecolwidth 134
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {2304048600 ps}
