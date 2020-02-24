
proc buildHardwareInit {} {

	# setup the VJTAG link
	global no_hardware
	if {$no_hardware==0} {
	### Hardware Setup begins ######################################################

	# Get hardware names : get download cable name
	global Blaster_name
	foreach hardware_name [get_hardware_names] {
	  puts "\n $hardware_name"
	  if { [string match "*Blaster*" $hardware_name] } {
		set Blaster_name $hardware_name
	  }                                                                                         
	}
	puts "\n Select JTAG chain connected to $Blaster_name.\n";

	global test_device
	# List all devices on the chain, and select the first device on the chain.
	puts "\n Devices on the JTAG chain:"
	foreach device_name [get_device_names -hardware_name $Blaster_name] {
		puts " $device_name"
	}
	#puts "\n Type in the device number to select the device on the chain:"
	#gets stdin device_num
	set device_num 1
	  foreach device_name [get_device_names -hardware_name $Blaster_name] {
	  if { [string match "@$device_num*" $device_name] } {
		set test_device $device_name
	  }
	  }
	puts "\n Select device: $test_device.\n";

	# Open device 
	open_device -hardware_name $Blaster_name -device_name $test_device

	# Retrieve device id code.
	device_lock -timeout 10000
	device_ir_shift -ir_value 6 -no_captured_ir_value
	puts " IDCODE: 0x[device_dr_shift -length 32 -value_in_hex]"
	device_unlock

	close_device
	global jtag_index
	set jtag_index 8
	} else {
	}

	# main scripts
	#runScript "gigalite_demo/hardware_init.txt"
	source "gigalite_demo/hardware_init.txt"

	# build Link-Speed Input GUI
	if {[winfo exists .init]} {
		destroy .init
	}
	toplevel .init
	pack propagate .init true
	wm title .init "Hardware Init"
	
	# link-speed 
	frame .init.lspeed
	pack  .init.lspeed

	frame .init.lspeed.left
	pack  .init.lspeed.left
        ttk::combobox .init.lspeed.left.speed -textvariable link_speed
        .init.lspeed.left.speed configure -values [list "Force 1000Mbps" "Force 100Mbps" "Force 10Mbps" "AN 1000Mbps" "AN 100Mbps" "AN 10Mbps"]
        pack .init.lspeed.left.speed
        set link_speed "Force 1000Mbps"
        
        #frame .init.lspeed.right
	#pack  .init.lspeed.right

	#button .init.lspeed.right.config -text {ConfigLinkSpeed} -command {configLinkSpeed}
	#pack .init.lspeed.right.config -side left
        
	#pack .init.lspeed.left .init.lspeed.right -side left
	
	# loopback
	frame .init.loopb
	pack  .init.loopb

	frame .init.loopb.left
	pack  .init.loopb.left
        ttk::combobox .init.loopb.left.loop -textvariable loop_back
        .init.loopb.left.loop configure -values [list "No Loopback" "Local Loopback" "1Gbps Stub Loopback"]
        pack .init.loopb.left.loop
        set loop_back "No Loopback"
        
        #frame .init.loopb.right
	#pack  .init.loopb.right

	#button .init.loopb.right.config -text {ConfigLoopBack} -command {configLoopBack}
	#pack .init.loopb.right.config -side left

	#pack .init.loopb.left .init.loopb.right -side left
	
        # configure all
        button .init.config -text {Config} -command {configAll}
	pack .init.config -side left

        # generate top level
        pack .init.loopb .init.lspeed .init.config -side top
}

# configure all
proc configAll {} {
        configLoopBack
        configLinkSpeed
}

# link speed
proc configLinkSpeed {} {
        puts ""
        global WireSpeed
        global link_speed
        switch $link_speed {
                "Force 1000Mbps" { 
                        set1000mbps
                        set WireSpeed 1000
                }
                "Force 100Mbps"  { 
                        set100mbps
                        set WireSpeed 100
                }
                "Force 10Mbps"   { 
                        set10mbps
                        set WireSpeed 10
                }
                "AN 1000Mbps"    { 
                        setan1000mbps
                        set WireSpeed 1000
                }
                "AN 100Mbps"     { 
                        setan100mbps
                        set WireSpeed 100
                }
                "AN 10Mbps"      { 
                        setan10mbps
                        set WireSpeed 10
                }
        }
}

proc set1000mbps {} {
        wr 00000000 44000140 1
        #wr 00000000 44008140 1
        wr 0000000C 00000003 1
}
proc set100mbps {} {
        wr 00000000 44002100 1
        #wr 00000000 4400a100 1
        wr 0000000C 00000001 1
}
proc set10mbps {} {
        wr 00000000 44000100 1
        #wr 00000000 44008100 1
        wr 0000000C 00000001 1
}
proc setan1000mbps {} {
        wr 00000000 44140ca3 1
        wr 00000000 44001340 1
        #wr 00000000 44009140 1
        wr 0000000C 00000003 1
}
proc setan100mbps {} {
        wr 00000000 44140c93 1
        wr 00000000 44001340 1
        #wr 00000000 44009140 1
        wr 0000000C 00000001 1
}
proc setan10mbps {} {
        wr 00000000 44140c83 1
        wr 00000000 44001340 1
        #wr 00000000 44009140 1
        wr 0000000C 00000001 1
}

# loop back
proc configLoopBack {} {
       
        global loop_back
        switch $loop_back {
                "No Loopback"         { setnoloopback }
                "Local Loopback"      { setlocalloopback }
                "1Gbps Stub Loopback" { set1gbpsstubloopback }
        }
}

proc setnoloopback {} {
        wr 00000000 44120000 1
        wr 00000000 44090300 1
        wr 00000000 44009140 1
        wr 00000000 441d0007 1
        wr 00000000 441e0800 1
        wr 00000000 441d0010 1
        wr 00000000 441e0040 1
        wr 00000000 441d0012 1
        wr 00000000 441e8900 1
}
proc setlocalloopback {} {    
        global link_speed
        switch $link_speed {
                "Force 1000Mbps" { 
                        wr 00000000 44004140 1
                        wr 00000000 44091300 1
                }
                "Force 100Mbps"  { 
                        wr 00000000 44006100 1
                        wr 00000000 44090300 1
                }
                "Force 10Mbps"   { 
                        wr 00000000 44004100 1
                        wr 00000000 44090300 1
                }
                "AN 1000Mbps"    { 
                        wr 00000000 44004140 1
                        wr 00000000 44091300 1
                }
                "AN 100Mbps"     { 
                        wr 00000000 44006100 1
                        wr 00000000 44090300 1
                }
                "AN 10Mbps"      { 
                        wr 00000000 44004100 1
                        wr 00000000 44090300 1
                }
        }
}
proc set1gbpsstubloopback {} {
        wr 00000000 44120000 1
        wr 00000000 44091b00 1
        wr 00000000 44009140 1
        wr 00000000 441d0007 1
        wr 00000000 441e0808 1
        wr 00000000 441d0010 1
        wr 00000000 441e0042 1
        wr 00000000 441d0012 1
        wr 00000000 441e8901 1
}


