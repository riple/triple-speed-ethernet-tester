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
add wave -noupdate -divider {DUT RX}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rst
add wave -noupdate -format Logic /top_bench/dut/data/rx/rgmii_rxclk
add wave -noupdate -format Logic /top_bench/dut/data/rx/rgmii_rxden
add wave -noupdate -format Literal /top_bench/dut/data/rx/rgmii_rxdin
add wave -noupdate -format Logic /top_bench/dut/data/rx/phy_link_up
add wave -noupdate -format Logic /top_bench/dut/data/rx/phy_giga_mode
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/rx/int_valid
add wave -noupdate -format Logic /top_bench/dut/data/rx/int_sop
add wave -noupdate -format Logic /top_bench/dut/data/rx/int_eop
add wave -noupdate -format Literal /top_bench/dut/data/rx/int_data
add wave -noupdate -format Literal /top_bench/dut/data/rx/int_mod
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_gearbox_inst/gmii_clk
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_gearbox_inst/gmii_ctrl
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_gearbox_inst/gmii_data
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/payload_data
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_gearbox_inst/nibble_h
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_gearbox_inst/gmii_ctrl_conv
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_gearbox_inst/gmii_data_conv
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_gearbox_inst/int_valid_o
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_gearbox_inst/int_sop_o
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_gearbox_inst/int_eop_o
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_gearbox_inst/int_data_o
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_gearbox_inst/int_mod_o
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_gearbox_inst/par_en
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DUT RX PARSER}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/par_en
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/int_valid
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/int_sop
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/int_eop
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_mod
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_cnt
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d1
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d2
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d5
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_l2l3l4_header
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/test_stream_found
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/l4_data_valid
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/l4_data_data
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/l4_data_sum
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/l4_data_sum_check
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/payload_chk/payload_type
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/payload_tag
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/payload_seed
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/payload_pre
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/payload_valid
add wave -noupdate -format Literal -radix hexadecimal /top_bench/dut/data/rx/rx_parser_inst/payload_data
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/payload_chk/payload_err
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/payload_esum
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/frame_check_point
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_cnt
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_l2_header
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/payload_valid
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/payload_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/rst
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/clk
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/par_en
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/int_valid
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/int_sop
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/int_eop
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_mod
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/rx/rx_parser_inst/info_leng_byte
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/int_valid_d1
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/int_valid_d2
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/int_valid_d3
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/int_valid_d4
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d1
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d2
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d3
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d4
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d5
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d6
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d7
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_data_d8
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/test_stream_found
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/test_stream_index
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/rx/rx_parser_inst/test_stream_seqnum
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/test_stream_tstamp
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/test_stream_rstamp
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/rx/rx_parser_inst/int_cnt
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/bypass_mac_cnt
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/bypass_vlan_cnt
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/bypass_llc_cnt
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/bypass_mpls_cnt
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/bypass_ipv4_cnt
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/bypass_ipv6_cnt
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/bypass_udp_cnt
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/bypass_tcp_cnt
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_l2_header
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_l3_header
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_l2l3l4_header
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_mac
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_vlan
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_llc
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_mpls
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_ipv4
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_ipv6
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_udp
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/bypass_tcp
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/found_udp
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/found_tcp
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/mac_da
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/mac_sa
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/mac_type
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/vlan_num
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/mpls_num
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/ipv4_sa
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/ipv4_da
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/ipv6_sa
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/ipv6_da
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/ip_protocol
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/udp_sp
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/udp_dp
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/tcp_sp
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/tcp_dp
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/test_jitr
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/test_stream_tstamp
add wave -noupdate -format Literal {/top_bench/dut/data/rx/rx_parser_inst/test_stream_tstamp_old[0]}
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/test_stream_rstamp
add wave -noupdate -format Literal {/top_bench/dut/data/rx/rx_parser_inst/test_stream_rstamp_old[0]}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/test_jitr_sum
add wave -noupdate -format Logic {/top_bench/dut/data/rx/rx_parser_inst/test_stream_1st_time[0]}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/frame_check_point
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/mac_crc_bad
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/int_crc
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/crc32_par/init_i
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/crc32_par/valid_i
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/crc32_par/mod_i
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/crc32_par/data_i
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/crc32_par/crc_o
add wave -noupdate -divider {DUT RX STAT WRITE}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/rx_stat_chk
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/rx_stat_base_addr
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/rx_stat_bit
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/rx_stat_vec
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/rx_stat_bit
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal {/top_bench/dut/data/rx/rx_parser_inst/test_stream_seqnum_old[3]}
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DUT TX_CON}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_scal_full[1]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_scal[1]}
add wave -noupdate -format Logic {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_cout[1]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_curr[1]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/up_data_tx_con_bw_scal[1]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_incr[1]}
add wave -noupdate -format Logic {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_scal_full[2]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_scal[2]}
add wave -noupdate -format Logic {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_cout[2]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_curr[2]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/up_data_tx_con_bw_scal[2]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_incr[2]}
add wave -noupdate -format Logic {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_scal_full[3]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_scal[3]}
add wave -noupdate -format Logic {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_cout[3]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_curr[3]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/up_data_tx_con_bw_scal[3]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_incr[3]}
add wave -noupdate -format Logic {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_scal_full[4]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_scal[4]}
add wave -noupdate -format Logic {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_cout[4]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_curr[4]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/up_data_tx_con_bw_scal[4]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_incr[4]}
add wave -noupdate -format Logic {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_scal_full[0]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_scal[0]}
add wave -noupdate -format Logic {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_cout[0]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_curr[0]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/up_data_tx_con_bw_scal[0]}
add wave -noupdate -format Literal {/top_bench/dut/data/tx/tx_con_inst/bw_con_inst/rate_cntr_incr[0]}
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
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_strm
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_type
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_pulse
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_level
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_req
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_ack
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/err_inj_latch
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/err_inj_start
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/err_inj_done
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_err_inj_return
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_gen_curr_st
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/stream_index
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/int_eop_d1
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/int_eop_d2
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/int_crc
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_nontest
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_nontest_pulse
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_nontest_level
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_nontest_req
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_nontest_ack
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_nontest_return
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/nontest_start
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/nontest_latch
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/nontest_done
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/info_mem/address_a
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/info_mem/clock_a
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/info_mem/data_a
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/info_mem/enable_a
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/info_mem/wren_a
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/info_mem/q_a
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
add wave -noupdate -divider {DUT TX_GEARBOX}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gearbox_inst/int_cntr
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gearbox_inst/gen_en
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gearbox_inst/int_eop_latch
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gearbox_inst/int_mod_latch
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gearbox_inst/int_cntr_hold_cntr
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gearbox_inst/int_valid_i
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gearbox_inst/int_sop_i
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gearbox_inst/int_eop_i
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gearbox_inst/int_mod_i
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gearbox_inst/int_data_i
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gearbox_inst/int_valid
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gearbox_inst/int_data
add wave -noupdate -format Literal -radix hexadecimal /top_bench/dut/data/tx/tx_gearbox_inst/int_mod
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gearbox_inst/int_sop
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gearbox_inst/int_eop
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gearbox_inst/gmii_clk
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gearbox_inst/gmii_ctrl
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gearbox_inst/gmii_data
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
add wave -noupdate -divider {CPU RX STAT READ}
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {STAT TOP}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/stat/stat_clk
add wave -noupdate -format Logic /top_bench/dut/stat/data_clk
add wave -noupdate -format Logic /top_bench/dut/stat/tx_stat_chk
add wave -noupdate -format Logic /top_bench/dut/stat/tx_stat_chk_cdc
add wave -noupdate -format Literal /top_bench/dut/stat/tx_stat_base_addr
add wave -noupdate -format Literal /top_bench/dut/stat/tx_stat_bit
add wave -noupdate -format Literal /top_bench/dut/stat/tx_stat_vec
add wave -noupdate -format Logic /top_bench/dut/stat/rx_stat_chk
add wave -noupdate -format Logic /top_bench/dut/stat/rx_stat_chk_cdc
add wave -noupdate -format Literal /top_bench/dut/stat/rx_stat_base_addr
add wave -noupdate -format Literal /top_bench/dut/stat/rx_stat_bit
add wave -noupdate -format Literal /top_bench/dut/stat/rx_stat_vec
add wave -noupdate -format Logic /top_bench/dut/stat/clr_in
add wave -noupdate -format Logic /top_bench/dut/stat/clr_in_cdc
add wave -noupdate -format Literal /top_bench/dut/stat/clr_cntr
add wave -noupdate -format Logic /top_bench/dut/stat/clr_done
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/stat/rx_stat_inst/stat_bit_queue/chk_in
add wave -noupdate -format Logic /top_bench/dut/stat/rx_stat_inst/stat_vec_queue/chk_in
add wave -noupdate -format Logic /top_bench/dut/stat/tx_stat_inst/stat_bit_queue/chk_in
add wave -noupdate -format Logic /top_bench/dut/stat/tx_stat_inst/stat_vec_queue/chk_in
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/frame_check_point
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/pack_intv
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/pack_time_rscv
add wave -noupdate -format Literal {/top_bench/dut/data/rx/rx_parser_inst/pack_time_rscv_old[0]}
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/stat/rx_stat_inst/stat_vec_counter/cntr_next_d2
add wave -noupdate -format Literal /top_bench/dut/stat/rx_stat_inst/stat_vec_counter/cntr_wrad_d2
add wave -noupdate -format Logic /top_bench/dut/stat/rx_stat_inst/stat_vec_counter/cntr_wren_d2
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {MDIO CONTROL}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/rst
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/up_clk
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/up_wr
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/up_rd
add wave -noupdate -format Literal /top_bench/dut/ctrl/mdio_ctrl/up_addr
add wave -noupdate -format Literal /top_bench/dut/ctrl/mdio_ctrl/up_data_wr
add wave -noupdate -format Literal /top_bench/dut/ctrl/mdio_ctrl/up_data_rd
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/up_wr_mdio
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/mdio_drct
add wave -noupdate -format Literal /top_bench/dut/ctrl/mdio_ctrl/mdio_ctrl
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/mdio_load
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/ctrl/mdio_ctrl/mdio_data
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/mdio_clk
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/mdio_io
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/ctrl/mdio_ctrl/mdio_cntr
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/mdio_i
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/mdio_o
add wave -noupdate -format Logic /top_bench/dut/ctrl/mdio_ctrl/mdio_oe
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {116748000 ps} 0}
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
WaveRestoreZoom {0 ps} {293919938 ps}
