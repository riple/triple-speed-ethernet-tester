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
add wave -noupdate -format Logic /top_bench/bfm_rgmii/phy_link_up
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
add wave -noupdate -divider {output Packet}
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/out_data
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/out_valid
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/out_sop
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_parser_inst/out_eop
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/out_mod
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_parser_inst/out_info
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
add wave -noupdate -format Literal {/top_bench/dut/data/rx/rx_parser_inst/test_stream_seqnum_old[3]}
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DUT RX_PAUSE}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_pause_inst/rst
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_pause_inst/in_clk
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_pause_inst/par_en
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_pause_inst/hereis_mac
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_pause_inst/hereis_mac_d1
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_pause_inst/hereis_mac_d2
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_pause_inst/hereis_mac_cntr
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_pause_inst/in_data
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_pause_inst/pause_rx
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_pause_inst/pause_time
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_pause_inst/rx_pause_en
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_pause_inst/pause_on
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/tx_pause_en
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/pause_on
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_con_inst/pause_on_level
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DUT RX_LOOP}
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/loop_l1
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/loop_l2
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/loop_l3
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/loop_l4
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/rst
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/in_clk
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/in_par_en
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/in_data
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/in_valid
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/in_sop
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/in_eop
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/in_mod
add wave -noupdate -format Literal -radix binary /top_bench/dut/data/rx/rx_loop_inst/in_info
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/in_stat
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/in_snum
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/in_par_en_d8
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/in_par_en_d12
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/par_en
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/hereis_mac
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/hereis_mac_cntr
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/hereis_ip4
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/hereis_ip4_cntr
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/hereis_ip6
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/hereis_ip6_cntr
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/hereis_tcp
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/hereis_tcp_cntr
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/hereis_udp
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/hereis_udp_cntr
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrad_incr
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrad_hold
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrad_load
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrad
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/fsm_dbwr_curr_st
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrad_h
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrad_l
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrda_h
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrda_l
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/dbuf_wren_h
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/dbuf_wren_l
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/dbuf_lpl4_rewrite
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrad_h_temp
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrad_l_temp
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrda_h_temp
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrda_l_temp
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/dbuf_rden_h
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/dbuf_rden_l
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_rdad_h
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_rdad_l
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_rdda_h
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/dbuf_rdda_l
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix decimal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrad
add wave -noupdate -format Literal -radix decimal /top_bench/dut/data/rx/rx_loop_inst/info_data_base
add wave -noupdate -format Literal -radix decimal /top_bench/dut/data/rx/rx_loop_inst/dbuf_wrad_interval
add wave -noupdate -format Literal -radix decimal /top_bench/dut/data/rx/rx_loop_inst/info_data_leng
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/info_data_snum
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/info_data_base
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/info_data_base
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/info_data_leng
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/info_data_snum
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/info_fifo_wrda
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/info_fifo_wren
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/info_fifo_empty
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/lpbk_info_rqst
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/lpbk_info_vald
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/lpbk_info_data
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/info_fifo_full_h
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_loop_inst/info_fifo_full_l
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_loop_inst/rx_loop_en
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {RX DUMP}
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/dbuf_wrad_hold
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/dbuf_wrad_incr
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/dbuf_wrad_load
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_dump_inst/dbuf_wrad_base
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_dump_inst/dbuf_wrad
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/dbuf_wrad_full
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/dump_it
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/info_fifo_wren
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_dump_inst/info_fifo_wrda
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/up_clk
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_dump_inst/up_addr
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/up_cs_dump_buff
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/up_cs_dump_info
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/up_rd
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_dump_inst/up_data_rd
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_dump_inst/up_data_rd_dump_buff
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_dump_inst/up_data_rd_dump_info
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_dump_inst/up_data_rx_ctrl
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/up_wr
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_dump_inst/up_data_wr
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/info_fifo_rden
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/dump_info_rqst
add wave -noupdate -format Logic /top_bench/dut/data/rx/rx_dump_inst/dump_info_vald
add wave -noupdate -format Literal /top_bench/dut/data/rx/rx_dump_inst/dump_info_data
add wave -noupdate -divider <NULL>
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
add wave -noupdate -divider {tx crc}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/crc32_gen/init_i
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/crc32_gen/valid_i
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/crc32_gen/mod_i
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/crc32_gen/data_i
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/crc32_gen/crc_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {DUT TX_GEN}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/clk
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/gen_en
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/info_rd
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/info_addr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_gen_curr_st
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/st_hold_cntr
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/lpbk_info_rqst
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/lpbk_info_vald
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/lpbk_info_vald_latch
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/lpbk_info_vald_int
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/lpbk_info_data
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/lpbk_buff_rden
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/lpbk_buff_rdad
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/lpbk_buff_rdda
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/header_leng
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_gen_curr_st
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/st_hold_cntr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/ifg_leng
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/ifg_leng_latch
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/tx_stat_chk
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_stat_base_addr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_stat_bit
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/line_leng
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/info_leng
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/time_stamp
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/sys_time_tx
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/frame_leng
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/header_leng
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/testtag_leng
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/payload_leng
add wave -noupdate -format Literal -radix unsigned /top_bench/dut/data/tx/tx_gen_inst/ifg_leng
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/payload_tag
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/header_stat
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/gen_en
add wave -noupdate -format Logic /top_bench/dut/data/tx/tx_gen_inst/frame_check_point
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_stat_base_addr
add wave -noupdate -format Literal /top_bench/dut/data/tx/tx_gen_inst/tx_stat_bit
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
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
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
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
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {377552811 ps} 0} {{Cursor 4} {112588000 ps} 0}
configure wave -namecolwidth 352
configure wave -valuecolwidth 213
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
WaveRestoreZoom {28547584 ps} {35256816 ps}
