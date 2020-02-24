
proc buildHardwareInit {} {

	# setup the VJTAG link
	global no_hardware
	if {$no_hardware==0} {
	### Hardware Setup begins ######################################################
        scan_chain
        select_device 1 1
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
        global link_speed
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
        global loop_back
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
        wr 00000000 40160002 1
        wr 00000000 40151076 1
        wr 00000000 40160000 1
        wr 00000000 40000140 1
        wr 00000000 40008140 1
        wr 0000000C 00000003 1
}
proc set100mbps {} {
        wr 00000000 40160002 1
        wr 00000000 40153036 1
        wr 00000000 40160000 1
        wr 00000000 40002100 1
        wr 00000000 4000a100 1
        wr 0000000C 00000001 1
}
proc set10mbps {} {
        wr 00000000 40160002 1
        wr 00000000 40151036 1
        wr 00000000 40160000 1
        wr 00000000 40000100 1
        wr 00000000 40008100 1
        wr 0000000C 00000001 1
}
proc setan1000mbps {} {
        wr 00000000 40001140 1
        wr 00000000 40009140 1
        wr 0000000C 00000003 1
}
proc setan100mbps {} {
        wr 00000000 40001140 1
        wr 00000000 40009140 1
        wr 0000000C 00000001 1
}
proc setan10mbps {} {
        wr 00000000 40001140 1
        wr 00000000 40009140 1
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

# unset 18_6.3
# unset 0_0.14
proc setnoloopback {} {
        wr 00000000 40160006 1
        wr 00000000 40120000 1
        wr 00000000 40160000 1
        wr 00000000 40001140 1
        wr 00000000 40009140 1
}
# set 0_0.14
# unset 18_6.3
proc setlocalloopback {} {
        wr 00000000 40005140 1
        wr 00000000 4000D140 1
}
proc setremoteloopback {} {
}
# set 18_6.3
# unset 0_0.14
proc set1gbpsstubloopback {} {
        wr 00000000 40160006 1
        wr 00000000 40120008 1
        wr 00000000 40160000 1
        wr 00000000 40001140 1
        wr 00000000 40009140 1       
}


