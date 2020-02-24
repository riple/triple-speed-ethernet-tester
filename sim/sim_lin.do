quit -sim

vlib altera
vdel -lib altera -all
vlib work
vdel -lib work -all

vlib altera
# compile vendor dependent files
vlog -work altera altera_mf.v

vlib work
# compile vendor independent files
vlog -work work ../rtl/data/rx/rx_top.v +initreg+0
vlog -work work ../rtl/data/rx/rgmii2gmii.v +initreg+0
vlog -work work ../rtl/data/rx/rx_parser.v +initreg+0

# compile testbench files
vlog -work work -sv top_bench.v

# compile bfm files
vlog -work work phy_rgmii.v

vsim top_bench \
     -novopt \
     -L altera \
     -t ps \
     -G/top_bench/bfm_rgmii/CLK_CYCLE=8 \
     -G/top_bench/bfm_rgmii/INTERCONNETC_MATRIX=2 \
     -G/top_bench/bfm_rgmii/DELAY_PortA=1 \
     -G/top_bench/bfm_rgmii/CAPTURE_PKT_NUM=4

global IgnoreWarning
set IgnoreWarning 1 

log -r */*
radix -hexadecimal
do wave.do

run 50000ns
