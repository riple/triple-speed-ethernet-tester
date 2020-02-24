quit -sim

vlib work
vdel -lib work -all

set ENABLE_Y1564 0
set ENABLE_LOOPBACK 1

vlib work
# compile vendor independent files
vlog -work work ../rtl/top/ether_top.v +initreg+0
vlog -work work ../rtl/ctrl/ctrl_top.v +initreg+0
vlog -work work ../rtl/ctrl/ctrl_clk.v +initreg+0
vlog -work work ../rtl/ctrl/ctrl_cpu.v +initreg+0
vlog -work work ../rtl/ctrl/ctrl_mdio.v +initreg+0
vlog -work work ../rtl/stat/stat_top.v +initreg+0
vlog -work work ../rtl/stat/bit_vec_stat.v +initreg+0
vlog -work work ../rtl/stat/bit_queue.v +initreg+0
vlog -work work ../rtl/stat/bit_counter.v +initreg+0
vlog -work work ../rtl/stat/vec_queue.v +initreg+0
vlog -work work ../rtl/stat/vec_counter.v +initreg+0
vlog -work work ../rtl/data/data_top.v +initreg+0
vlog -work work ../rtl/data/tx/data_tx.v +initreg+0
vlog -work work ../rtl/data/tx/gmii2rgmii.v +initreg+0 +define+ALTERA
vlog -work work ../rtl/data/tx/tx_gearbox.v +initreg+0
vlog -work work ../rtl/data/tx/tx_gen.v +initreg+0
vlog -work work ../rtl/data/tx/tx_payload.v +initreg+0
vlog -work work ../rtl/data/tx/bw_con.v +initreg+0
if {$ENABLE_Y1564==1} {
vlog -work work ../rtl/data/tx/tx_con.v +initreg+0 +define+ALTERA +define+ENABLE_Y1564
vcom -work work ../rtl/data/tx/ir_con/ir_con.vhd
vcom -work work ../rtl/data/tx/ir_con/bwp_fsm.vhd
} else {
vlog -work work ../rtl/data/tx/tx_con.v +initreg+0 +define+ALTERA
vlog -work work ../rtl/data/tx/ir_con/ir_con.v +initreg+0
}
vlog -work work ../rtl/data/rx/data_rx.v +initreg+0
vlog -work work ../rtl/data/rx/rgmii2gmii.v +initreg+0 +define+ALTERA
vlog -work work ../rtl/data/rx/rx_gearbox.v +initreg+0
vlog -work work ../rtl/data/rx/rx_parser.v +initreg+0
vlog -work work ../rtl/data/rx/rx_payload.v +initreg+0
vlog -work work ../rtl/data/rx/rx_loop.v +initreg+0 +define+ALTERA
vlog -work work ../rtl/data/rx/rx_dump.v +initreg+0 +define+ALTERA
vlog -work work ../rtl/data/rx/rx_pause.v +initreg+0

vlog -work work ../rtl/common/inferred_ram_blocks.v +initreg+0
vlog -work work ../rtl/common/prbs_any.v +initreg+0
vlog -work work ../rtl/common/crc32_data32.v +initreg+0
vlog -work work ../rtl/common/synchronizer_pulse.v +initreg+0
vlog -work work ../rtl/common/synchronizer_level.v +initreg+0
vlog -work work ../rtl/common/dpram_dc_32_1024.v +initreg+0
vlog -work work ../rtl/common/dpram_sc_32_1024.v +initreg+0
vlog -work work ../rtl/common/spram_sc_32_1024_jtag.v +initreg+0
vlog -work work ../rtl/common/dpram_dc_18_4096.v +initreg+0
vlog -work work ../rtl/common/fifo_dc_18_512.v +initreg+0
vlog -work work ../rtl/common/dpram_dc_32_512_16_1024.v +initreg+0
vlog -work work ../rtl/common/multiplier_32_32_d4.v +initreg+0

# compile testbench files
vlog -work work -sv top_bench.v +define+ALTERA

# compile bfm files
vlog -work work phy_rgmii_bfm.v
vlog -work work phy_mdio_bfm.v
if {$ENABLE_Y1564==1} {
vlog -work work cpu_bfm.v +define+ENABLE_Y1564
} elseif {$ENABLE_LOOPBACK==1} {
vlog -work work cpu_bfm.v +define+ENABLE_LOOPBACK
} else {
vlog -work work cpu_bfm.v
}

if {$ENABLE_LOOPBACK==1} {
    set interconnect_config 2
} else {
    set interconnect_config 1
}

vsim top_bench \
     -novopt \
     -L altera \
     -t ps \
     -G/top_bench/bfm_rgmii/CLK_CYCLE=8 \
     -G/top_bench/bfm_rgmii/INTERCONNECT_MATRIX=$interconnect_config \
     -G/top_bench/bfm_rgmii/DELAY=1 \
     -G/top_bench/bfm_rgmii/CAPTURE_PKT_NUM=1

global IgnoreWarning
set IgnoreWarning 1 

log -r */*
radix -hexadecimal

if {$ENABLE_Y1564==1} {
    do wave_y1564.do
} elseif {$ENABLE_LOOPBACK==1} {
    do wave_loopback.do
} else {
    do wave.do
}

source gui/stat_report.tcl
quitReport
buildReport

run 5000ns
run -all
