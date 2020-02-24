create_project -force imx45t_top . -part xc6slx45tfgg484-3

add_files -norecurse imx45t_top.ucf
add_files -norecurse define.v
set_property is_global_include true [get_files  define.v]

add_files -norecurse rtl/imx45t_top.v
add_files -norecurse rtl/cpu_bfm_usbspi.v
add_files -norecurse rtl/usbspi_master/usbspi_master.v
add_files -norecurse rtl/usbspi_master/spi_phy.v
add_files -norecurse rtl/usbspi_master/spi_fsm.v
add_files -norecurse rtl/cpu_bfm_vjtag.v
add_files -norecurse rtl/buscli-jtag/rtl/buscli_jtag.v
add_files -norecurse rtl/buscli-jtag/rtl/xilinx/chipscope_vio_adda_stat.v
add_files -norecurse rtl/buscli-jtag/rtl/xilinx/coregen/chipscope_icon.v
add_files -norecurse rtl/buscli-jtag/rtl/xilinx/coregen/chipscope_icon.ngc
add_files -norecurse rtl/buscli-jtag/rtl/xilinx/coregen/chipscope_vio.v
add_files -norecurse rtl/buscli-jtag/rtl/xilinx/coregen/chipscope_vio.ngc
add_files -norecurse rtl/dcfifo/fifo_dc_18_512.v
add_files -norecurse rtl/dcfifo/fifo_dc_18_512.ngc
add_files -norecurse rtl/dcram/dpram_dc_18_4096.v
add_files -norecurse rtl/dcram/dpram_dc_18_4096.ngc
add_files -norecurse rtl/ctrl_clk.v
add_files -norecurse rtl/ctrl_clk/clk_wiz_v3_6.v
add_files -norecurse ../rtl/top/ether_top.v
add_files -norecurse ../rtl/ctrl/ctrl_top.v
add_files -norecurse ../rtl/ctrl/ctrl_cpu.v
add_files -norecurse ../rtl/ctrl/ctrl_mdio.v
add_files -norecurse ../rtl/stat/stat_top.v
add_files -norecurse ../rtl/stat/bit_vec_stat.v
add_files -norecurse ../rtl/stat/bit_queue.v
add_files -norecurse ../rtl/stat/bit_counter.v
add_files -norecurse ../rtl/stat/vec_queue.v
add_files -norecurse ../rtl/stat/vec_counter.v
add_files -norecurse ../rtl/data/data_top.v
add_files -norecurse ../rtl/data/tx/data_tx.v
add_files -norecurse ../rtl/data/tx/gmii2rgmii.v
add_files -norecurse ../rtl/data/tx/tx_gearbox.v
add_files -norecurse ../rtl/data/tx/tx_gen.v
add_files -norecurse ../rtl/data/tx/tx_payload.v
add_files -norecurse ../rtl/data/tx/tx_con.v
add_files -norecurse ../rtl/data/tx/bw_con.v
add_files -norecurse ../rtl/data/tx/ir_con/ir_con.v
add_files -norecurse ../rtl/data/rx/data_rx.v
add_files -norecurse ../rtl/data/rx/rx_parser.v
add_files -norecurse ../rtl/data/rx/rx_loop.v
add_files -norecurse ../rtl/data/rx/rx_dump.v
add_files -norecurse ../rtl/data/rx/rx_pause.v
add_files -norecurse ../rtl/data/rx/rgmii2gmii.v
add_files -norecurse ../rtl/data/rx/rx_gearbox.v
add_files -norecurse ../rtl/data/rx/rx_payload.v
add_files -norecurse ../rtl/common/crc32_data32.v
add_files -norecurse ../rtl/common/prbs_any.v
add_files -norecurse ../rtl/common/synchronizer_pulse.v
add_files -norecurse ../rtl/common/synchronizer_level.v
add_files -norecurse ../rtl/common/dpram_dc_32_1024.v
add_files -norecurse ../rtl/common/dpram_sc_32_1024.v
add_files -norecurse ../rtl/common/inferred_ram_blocks.v


set_property used_in_simulation false [get_files ./rtl/imx45t_top.v]
set_property used_in_simulation false [get_files ./rtl/usbspi_master/spi_fsm.v]
set_property used_in_simulation false [get_files ./rtl/usbspi_master/spi_phy.v]
set_property used_in_simulation false [get_files ./rtl/usbspi_master/usbspi_master.v]
set_property used_in_simulation false [get_files ./rtl/cpu_bfm_usbspi.v]

add_files -fileset sim_1 -norecurse {../sim/top_bench.v ../sim/cpu_bfm.v ../sim/cpu_bfm.txt ../sim/cpu_bfm_loopback.txt ../sim/cpu_bfm_y1564.txt ../sim/phy_mdio_bfm.v ../sim/phy_rgmii_bfm.v ../sim/phy_rgmii_rx_source.pcap}


#reset_run synth_1
#reset_run impl_1

#launch_runs synth_1 -jobs 1
#wait_on_run synth_1

#launch_runs impl_1 -jobs 1
#wait_on_run impl_1

#launch_runs impl_1 -to_step Bitgen
#wait_on_run impl_1

