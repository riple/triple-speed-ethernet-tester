## Generated SDC file "easygx_top.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

## DATE    "Tue Sep 03 11:21:12 2013"

##
## DEVICE  "EP4CE10U14I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3


#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk_50M} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk_50M}]
create_clock -name {tse_mac_rx_clk} -period 8.000 -waveform { 0.000 4.000 } [get_ports {tse_mac_rx_clk}]
create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]


#**************************************************************
# Create Generated Clock
#**************************************************************

#create_generated_clock -name {ctrl|clk_gen|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {ctrl|clk_gen|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {clk} [get_pins {ctrl|clk_gen|altpll_component|auto_generated|pll1|clk[2]}] 
derive_pll_clocks -create_base_clocks


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
  


#**************************************************************
# Set Input Delay
#**************************************************************

#set_input_delay -clock { tse_mac_rx_clk } -max 3 [get_ports {tse_mac_rgmii_in[*]}]
#set_input_delay -clock { tse_mac_rx_clk } -min 2 [get_ports {tse_mac_rgmii_in[*]}]
#set_input_delay -clock { tse_mac_rx_clk } -max 3 [get_ports {tse_mac_rx_control}]
#set_input_delay -clock { tse_mac_rx_clk } -min 2 [get_ports {tse_mac_rx_control}]


#**************************************************************
# Set Output Delay
#**************************************************************

#set_output_delay -clock { tse_mac_rx_clk } -max 3 [get_ports {tse_mac_rgmii_out[*]}]
#set_output_delay -clock { tse_mac_rx_clk } -min 2 [get_ports {tse_mac_rgmii_out[*]}]
#set_output_delay -clock { tse_mac_rx_clk } -max 3 [get_ports {tse_mac_tx_control}]
#set_output_delay -clock { tse_mac_rx_clk } -min 2 [get_ports {tse_mac_tx_control}]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -exclusive -group [get_clocks {clk_50M}] -group [get_clocks {*clk_gen*}] -group [get_clocks {tse_mac_rx_clk}]


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -from [get_registers {*data_top:*|data_rx:*|rx_parser:*|*}] -to [get_registers {*data_top:*|data_rx:*|rx_parser:*|*}] -setup -end 4
set_multicycle_path -from [get_registers {*data_top:*|data_rx:*|rx_parser:*|*}] -to [get_registers {*data_top:*|data_rx:*|rx_parser:*|*}] -hold  -end 3

set_multicycle_path -from [get_registers {*data_top:*|data_rx:*|rx_loop:*|*}] -to [get_registers {*data_top:*|data_rx:*|rx_loop:*|*}] -setup -end 4
set_multicycle_path -from [get_registers {*data_top:*|data_rx:*|rx_loop:*|*}] -to [get_registers {*data_top:*|data_rx:*|rx_loop:*|*}] -hold  -end 3

set_multicycle_path -from [get_registers {*data_top:*|data_tx:*|tx_gen:*|*}] -to [get_registers {*data_top:*|data_tx:*|tx_gen:*|*}] -setup -end 4
set_multicycle_path -from [get_registers {*data_top:*|data_tx:*|tx_gen:*|*}] -to [get_registers {*data_top:*|data_tx:*|tx_gen:*|*}] -hold  -end 3


#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

