##**************************************************************
## Module             : chipscope_vio_console.tcl
## Platform           : Windows 7
## Author             : Bibo Yang  (ash_riple@hotmail.com)
## Organization       : www.opencores.org
## Revision           : 2.5
## Date               : 2015/02/24
## Description        : Tcl/Tk GUI for the buscli-jtag
##**************************************************************

############################
## include the XILINX procs
############################
# Get the Cse DLL's and globals
if {[info exists env(XIL_CSE_TCL)]} {
    if {[string length $env(XIL_CSE_TCL)] > 0} {
        puts "Sourcing from XIL_CSE_TCL: $env(XIL_CSE_TCL) ..."
        source $env(XIL_CSE_TCL)/csejtag.tcl
        source $env(XIL_CSE_TCL)/csefpga.tcl
        source $env(XIL_CSE_TCL)/csecore.tcl
        source $env(XIL_CSE_TCL)/csevio.tcl
    } else {
        puts "Sourcing from XILINX: $env(XILINX)/cse/tcl ..."
        source $env(XILINX)/cse/tcl/csejtag.tcl
        source $env(XILINX)/cse/tcl/csefpga.tcl
        source $env(XILINX)/cse/tcl/csecore.tcl
        source $env(XILINX)/cse/tcl/csevio.tcl
    }
} else {
    puts "Sourcing from XILINX: $env(XILINX)/cse/tcl ..."
    source $env(XILINX)/cse/tcl/csejtag.tcl
    source $env(XILINX)/cse/tcl/csefpga.tcl
    source $env(XILINX)/cse/tcl/csecore.tcl
    source $env(XILINX)/cse/tcl/csevio.tcl
}

namespace import ::chipscope::*

###########################
## define cable parameters
###########################
# Create global variables
set ILA_STATUS_WORD_BIT_LEN  512

# Parallel IV Cable
set PARALLEL_CABLE_ARGS [list "port=LPT1" "frequency=2500000"]
# "frequency=5000000 | 2500000 | 1250000 | 625000 | 200000"

# Platform USB Cable
set PLATFORM_USB_CABLE_ARGS [list "port=USB2" "frequency=3000000"]
# frequency="12000000 | 6000000 | 3000000 | 1500000 | 750000"

# Digilent Cable
# Digilent Cables have default arguments, if there is only one cable connected it will automatically connect to it.
set DIGILENT_CABLE_ARGS {}

###########################
## setup the chain
###########################
proc scan_chain {} {
        global PLATFORM_USB_CABLE_ARGS
        global CSEJTAG_TARGET_PLATFORMUSB
        global PARALLEL_CABLE_ARGS
        global CSEJTAG_TARGET_PARALLEL
        global DIGILENT_CABLE_ARGS
        global CSEJTAG_TARGET_DIGILENT
	global CSEJTAG_SCAN_DEFAULT
	global CSEJTAG_LOCKED_ME
        global CSEJTAG_TEST_LOGIC_RESET
        global CSEJTAG_SHIFT_READ
        global CSEJTAG_RUN_TEST_IDLE

	puts "JTAG Chain Scanning report:\n"
	puts "****************************************\n"
        global blaster_cables
	set blaster_cables [list -usb -par -dig]
	set cable_num 0
	foreach blaster_cable $blaster_cables {
		incr cable_num
                if {[string equal "-usb" $blaster_cable]} {
                        set blaster_cable_name "Platform USB Cable"
                } elseif {[string equal "-par" $blaster_cable]} {
                        set blaster_cable_name "Parallel Cable"
                } elseif {[string equal "-dig" $blaster_cable]} {
                        set blaster_cable_name "Digilent Cable"
                }
		puts "@$cable_num: $blaster_cable_name\n"
	}
	puts "\n****************************************\n"

	global device_list
	set device_list ""
	foreach blaster_cable $blaster_cables {
                if {[string equal "-usb" $blaster_cable]} {
                        set blaster_cable_name "Platform USB Cable"
                        set CABLE_NAME $CSEJTAG_TARGET_PLATFORMUSB
                        set CABLE_ARGS $PLATFORM_USB_CABLE_ARGS
                } elseif {[string equal "-par" $blaster_cable]} {
                        set blaster_cable_name "Parallel Cable"
                        set CABLE_NAME $CSEJTAG_TARGET_PARALLEL
                        set CABLE_ARGS $PARALLEL_CABLE_ARGS
                } elseif {[string equal "-dig" $blaster_cable]} {
                        set blaster_cable_name "Digilent Cable"
                        set CABLE_NAME $CSEJTAG_TARGET_DIGILENT
                        set CABLE_ARGS $DIGILENT_CABLE_ARGS
                }
		puts "$blaster_cable_name:\n"
                lappend device_list $blaster_cable_name

                if {[catch {
                # start chipscope session
		set handle [csejtag_session create 0 $blaster_cable]
                # open cable
		csejtag_target open $handle $CABLE_NAME 0 $CABLE_ARGS
                # lock cable
		set cablelock [csejtag_target lock $handle 5000]

                csejtag_tap autodetect_chain $handle $CSEJTAG_SCAN_DEFAULT
                set deviceCount [csejtag_tap get_device_count $handle]
                csejtag_tap navigate $handle $CSEJTAG_TEST_LOGIC_RESET 0 0
                for {set deviceIndex 0} {$deviceIndex < $deviceCount} {incr deviceIndex} {
                        set idcodeBuffer [csejtag_tap get_device_idcode $handle $deviceIndex]
                        set deviceName [csejtag_db get_device_name_for_idcode $handle $idcodeBuffer]
                        set idcode [format "%x" [binaryStringToInt $idcodeBuffer]]
                        puts "@[expr $deviceIndex+1]: $deviceName (0x$idcode)\n"
                        lappend device_list $deviceName
                }

#altera		#lappend device_list $blaster_cable
		#if [catch {get_device_names -hardware_name $blaster_cable} error_msg] {
		#	puts $error_msg
		#	lappend device_list $error_msg
		#} else {
		#	foreach test_device [get_device_names -hardware_name $blaster_cable] {
		#		puts "$test_device\n"
		#	}
		#	lappend device_list [get_device_names -hardware_name $blaster_cable]
		#}

                # unlock cable
		csejtag_target unlock $handle
                # close device
		csejtag_target close $handle
                # end chipscope session
		csejtag_session destroy $handle
                } result]} {
                        lappend device_list $result
                        puts "$result\n"
                }
	}
}

proc open_jtag_device {{blaster_cable "-dig"}} {
        global handle
        global CABLE_NAME
        global CABLE_ARGS
        global CSEJTAG_SCAN_DEFAULT

        if {[info exist handle]} { close_jtag_device }
	set handle [csejtag_session create 0 $blaster_cable]
	csejtag_target open $handle $CABLE_NAME 0 $CABLE_ARGS
	set cablelock [csejtag_target lock $handle 5000]
        csejtag_tap autodetect_chain $handle $CSEJTAG_SCAN_DEFAULT

#altera	#open_device -hardware_name $test_cable -device_name $test_device
	## Retrieve device id code.
	#device_lock -timeout 5
	#device_ir_shift -ir_value 6 -no_captured_ir_value
	#set idcode "0x[device_dr_shift -length 32 -value_in_hex]"
	#device_unlock
	return 0
}

proc close_jtag_device {} {
	global handle
        if {[info exist handle]} {
	        catch {csejtag_target unlock $handle}
	        catch {csejtag_target close $handle}
	        catch {csejtag_session destroy $handle}
                unset handle
        }
}

proc select_device {{cableNum 3} {deviceNum 2}} {
        global device_list
        global blaster_cables
	global handle
        global PLATFORM_USB_CABLE_ARGS
        global CSEJTAG_TARGET_PLATFORMUSB
        global PARALLEL_CABLE_ARGS
        global CSEJTAG_TARGET_PARALLEL
	global DIGILENT_CABLE_ARGS
	global CSEJTAG_TARGET_DIGILENT
        global CABLE_NAME
        global CABLE_ARGS

	puts "\n****************************************\n"
	set test_cable [lindex $device_list [expr 2*$cableNum-2]]
	puts "Selected Cable : $test_cable\n"
	set test_device [lindex $device_list [expr 2*$cableNum-2+($deviceNum)]]
	puts "Selected Device: $test_device\n"
       
	set blaster_cable [lindex $blaster_cables [expr $cableNum-1]]
        if {[string equal "-usb" $blaster_cable]} {
                set blaster_cable_name "Platform USB Cable"
                set CABLE_NAME $CSEJTAG_TARGET_PLATFORMUSB
                set CABLE_ARGS $PLATFORM_USB_CABLE_ARGS
        } elseif {[string equal "-par" $blaster_cable]} {
                set blaster_cable_name "Parallel Cable"
                set CABLE_NAME $CSEJTAG_TARGET_PARALLEL
                set CABLE_ARGS $PARALLEL_CABLE_ARGS
        } elseif {[string equal "-dig" $blaster_cable]} {
                set blaster_cable_name "Digilent Cable"
                set CABLE_NAME $CSEJTAG_TARGET_DIGILENT
                set CABLE_ARGS $DIGILENT_CABLE_ARGS
        }

        open_jtag_device $blaster_cable

        global deviceIndex
        set deviceIndex [expr $deviceNum-1]

	#set test_cable [lindex $device_list [expr 2*$cableNum-2]]
	#puts "Selected Cable : $test_cable\n"
	#set test_device [lindex [lindex $device_list [expr 2*$cableNum-1]] [expr $deviceNum-1]]
	#puts "Selected Device: $test_device\n"
#altera	#set jtagIdCode [open_jtag_device $test_cable $test_device]
	#puts "Device ID code : $jtagIdCode\n"

}

########################
## operate the VIO core
########################

proc config_data {{data 01000000}} {
	global handle
        global deviceIndex
        global CSEVIO_SYNC_INPUT
        global CSEVIO_SYNC_OUTPUT

	set userRegNumber 1
	set coreIndex 0
	set coreRef [list $deviceIndex $userRegNumber $coreIndex]

	
		csevio_init_core $handle $coreRef
		csevio_define_bus $handle $coreRef "dataID" $CSEVIO_SYNC_OUTPUT [list   0  1  2  3  4  5  6  7\
		                                                                        8  9 10 11 12 13 14 15\
										       16 17 18 19 20 21 22 23\
										       24 25 26 27 28 29 30 31]
		set outputTclArray(dataID) $data
		csevio_write_values $handle $coreRef outputTclArray
		csevio_terminate_core $handle $coreRef
	
	return 0
}

proc config_addr {{addr 01000000}} {
	global handle
        global deviceIndex
        global CSEVIO_SYNC_INPUT
        global CSEVIO_SYNC_OUTPUT

	set userRegNumber 1
	set coreIndex 0
	set coreRef [list $deviceIndex $userRegNumber $coreIndex]

	
		csevio_init_core $handle $coreRef
		csevio_define_bus $handle $coreRef "addrID" $CSEVIO_SYNC_OUTPUT [list  32 33 34 35 36 37 38 39\
		                                                                       40 41 42 43 44 45 46 47\
										       48 49 50 51 52 53 54 55\
										       56 57 58 59 60 61 62 63]
		set outputTclArray(addrID) $addr
		csevio_write_values $handle $coreRef outputTclArray
		csevio_terminate_core $handle $coreRef
	
	return 0
}

proc genwr_pulse {} {
	global handle
        global deviceIndex
        global CSEVIO_SYNC_INPUT
        global CSEVIO_SYNC_OUTPUT

	set userRegNumber 1
	set coreIndex 0
	set coreRef [list $deviceIndex $userRegNumber $coreIndex]

	csevio_init_core $handle $coreRef
	csevio_define_signal $handle $coreRef "wrID" $CSEVIO_SYNC_OUTPUT 64
	set outputTclArray(wrID) 1
	csevio_write_values $handle $coreRef outputTclArray
	set outputTclArray(wrID) 0
	csevio_write_values $handle $coreRef outputTclArray
	csevio_terminate_core $handle $coreRef

	return 0
}

proc genrd_pulse {} {
	global handle
        global deviceIndex
        global CSEVIO_SYNC_INPUT
        global CSEVIO_SYNC_OUTPUT

	set userRegNumber 1
	set coreIndex 0
	set coreRef [list $deviceIndex $userRegNumber $coreIndex]

	csevio_init_core $handle $coreRef
	csevio_define_signal $handle $coreRef "rdID" $CSEVIO_SYNC_OUTPUT 65
	set outputTclArray(rdID) 1
	csevio_write_values $handle $coreRef outputTclArray
	set outputTclArray(rdID) 0
	csevio_write_values $handle $coreRef outputTclArray
	csevio_terminate_core $handle $coreRef

	return 0
}

proc genrst_pulse {} {
	global handle
        global deviceIndex
        global CSEVIO_SYNC_INPUT
        global CSEVIO_SYNC_OUTPUT

	set userRegNumber 1
	set coreIndex 0
	set coreRef [list $deviceIndex $userRegNumber $coreIndex]

	csevio_init_core $handle $coreRef
	csevio_define_signal $handle $coreRef "rstID" $CSEVIO_SYNC_OUTPUT 66
	set outputTclArray(rstID) 1
	csevio_write_values $handle $coreRef outputTclArray
	set outputTclArray(rstID) 0
	csevio_write_values $handle $coreRef outputTclArray
	csevio_terminate_core $handle $coreRef

	return 0
}

proc obtain_state {} {
	global handle
        global deviceIndex
        global CSEVIO_SYNC_INPUT
        global CSEVIO_SYNC_OUTPUT

	set userRegNumber 1
	set coreIndex 0
	set coreRef [list $deviceIndex $userRegNumber $coreIndex]

	csevio_init_core $handle $coreRef
	csevio_define_bus $handle $coreRef "stateID" $CSEVIO_SYNC_INPUT [list 64 65 66 67]
	csevio_read_values $handle $coreRef inputTclArray
	set state $inputTclArray(stateID)
	csevio_terminate_core $handle $coreRef

        return $state
}

proc obtain_clock {} {
	global handle
        global deviceIndex
        global CSEVIO_SYNC_INPUT
        global CSEVIO_SYNC_OUTPUT

	set userRegNumber 1
	set coreIndex 0
	set coreRef [list $deviceIndex $userRegNumber $coreIndex]

	csevio_init_core $handle $coreRef
	csevio_define_bus $handle $coreRef "clockID" $CSEVIO_SYNC_INPUT  [list  32 33 34 35 36 37 38 39\
		                                                                40 41 42 43 44 45 46 47\
									        48 49 50 51 52 53 54 55\
									        56 57 58 59 60 61 62 63]
	csevio_read_values $handle $coreRef inputTclArray
	set clockT $inputTclArray(clockID)
	csevio_terminate_core $handle $coreRef

	return $clockT
}

proc obtain_rdata {} {
	global handle
        global deviceIndex
        global CSEVIO_SYNC_INPUT
        global CSEVIO_SYNC_OUTPUT

	set userRegNumber 1
	set coreIndex 0
	set coreRef [list $deviceIndex $userRegNumber $coreIndex]

	csevio_init_core $handle $coreRef
	csevio_define_bus $handle $coreRef "rdataID" $CSEVIO_SYNC_INPUT [list    0  1  2  3  4  5  6  7\
		                                                                 8  9 10 11 12 13 14 15\
										16 17 18 19 20 21 22 23\
										24 25 26 27 28 29 30 31]
	csevio_read_values $handle $coreRef inputTclArray
	set rdata $inputTclArray(rdataID)
	csevio_terminate_core $handle $coreRef

	return $rdata
}

##########################
## upper level operations
##########################
variable jtag_data

proc wr {{write_addr ffffffff} {write_data 55555555} {print 0}} {
        if {$print==1} {
                puts [list wr $write_addr $write_data]
        }

        global no_hardware
        if {$no_hardware==0} {
        config_addr $write_addr
        config_data $write_data
        genwr_pulse
        } else {
        }

        return 0
}

proc rd {{read_addr 00000000} {print 0}} {
        global jtag_data

        global no_hardware
        if {$no_hardware==0} {
        config_addr $read_addr
        genrd_pulse
        set curr_state [obtain_state]
        while {$curr_state >= 4} {
            set curr_state [obtain_state]   
        }
        set jtag_data [obtain_rdata]
        } else {
        set jtag_data 12345678
        }

        if {$print==1} {
                puts [list rd $read_addr $jtag_data]
        }

        return $jtag_data
}

proc state_from_fpga {} {
        global jtag_data
        set jtag_data [obtain_state]
        append jtag_data [obtain_clock]
}

##############################
## Miscellence functions
##############################
proc binaryStringToInt {binarystring} {
    set len [string length $binarystring]
    set retval 0
    for {set i 0} {$i < $len} {incr i} {
        set retval [expr $retval << 1]
        if {[string index $binarystring $i] == "1"} {
            set retval [expr $retval | 1]
        }
    }
    return $retval
}

proc hex2dec {{hexNum 00}} {
	set tmp 0x
	append tmp $hexNum
	set decNum [format "%u" $tmp]
	return $decNum
}




