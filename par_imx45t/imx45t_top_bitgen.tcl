source imx45t_top.tcl


set_property flow     {XST 14}             [get_runs synth_1]
set_property strategy {PlanAhead Defaults} [get_runs synth_1]
set_property flow     {ISE 14}             [get_runs impl_1]
set_property strategy {ISE Defaults}       [get_runs impl_1]

config_run -run impl_1 -program map  -option -ignore_keep_hierarchy -value true 
config_run -run impl_1 -program map  -option -register_duplication  -value true 
config_run -run impl_1 -program map  -option -ol                    -value high 
config_run -run impl_1 -program map  -option -pr                    -value b 
config_run -run impl_1 -program map  -option -t                     -value 1 
config_run -run impl_1 -program par  -option -ol                    -value high 
config_run -run impl_1 -program trce -option -e                     -value 30 
config_run -run impl_1 -program trce -option -u                     -value 30 

reset_run synth_1
reset_run impl_1

launch_runs synth_1 -jobs 1
wait_on_run synth_1

launch_runs impl_1 -jobs 1
wait_on_run impl_1

open_run impl_1
report_utilization -file utilization.rpt.txt -append

set_property -name {steps.bitgen.args.More Options} -value {-g Compress} -objects [get_runs impl_1]
launch_runs impl_1 -to_step Bitgen
wait_on_run impl_1

