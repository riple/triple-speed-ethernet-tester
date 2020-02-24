quit -sim

vlib altera
vdel -lib altera -all

vlib altera
# compile vendor dependent files
vlog -work altera altera_mf.v
vlog -work altera 220model.v

do resim_win.do
