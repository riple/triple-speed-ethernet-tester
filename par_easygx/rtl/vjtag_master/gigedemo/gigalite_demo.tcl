
#### pre-GUI setup ####
source gigalite_rdwr.tcl
# set the QuartusII special Tk command
init_tk
set exit_console 0


#### Main GUI Begin ####
# build flow chart style GUI
toplevel .flow
pack propagate .flow true
wm title .flow "Test Flow"

    # set if GUI runs without Hardware
    checkbutton .flow.nohardware -text {Hardware not Attached} -variable no_hardware
    set no_hardware 1
    label .flow.space -text {}

    # build "Hardware Init" button
    button .flow.hardwareinit -text {Hardware Init} -command {HardwareInit}
    label .flow.arrow1 -text {|v} -height 2 -wraplength 1
    # build "Test Session Setup" button
    button .flow.testsessionsetup -text {Test Session Setup} -command {TestSessionSetup}
    label .flow.arrow2 -text {|v} -height 2 -wraplength 1
    # build "Test Session Start" button
    button .flow.testsessionstart -text {Test Session Start} -command {TestSessionStart}
    label .flow.arrow3 -text {|v} -height 2 -wraplength 1
    # build "Test Session In-Progress" button
    button .flow.testsessioninprogress -text {Test Session In-Progress} -command {TestSessionInProgress}
    label .flow.arrow4 -text {|v} -height 2 -wraplength 1
    # build "Test Session Stop" button
    button .flow.testsessionstop -text {Test Session Stop} -command {TestSessionStop}
    label .flow.arrow5 -text {|v} -height 2 -wraplength 1
    # build "Read Statistic Results" button
    button .flow.readstatisticresults -text {Read Statistic Results} -command {ReadStatisticResults}
    # 
    pack .flow.nohardware .flow.space \
         .flow.hardwareinit .flow.arrow1 \
         .flow.testsessionsetup .flow.arrow2 \
         .flow.testsessionstart .flow.arrow3 \
         .flow.testsessioninprogress .flow.arrow4 \
         .flow.testsessionstop .flow.arrow5 \
         .flow.readstatisticresults

# set button initial states
set hardwareinit_done 0
set testsessionsetup_done 0
set testsessionstart_done 0
set testsessioninprogress_done 0
set testsessionstop_done 0
set readstatisticresults_done 0

# disable down flow buttons
proc EvaluateButtonState {} {
    global hardwareinit_done
    global testsessionsetup_done
    global testsessionstart_done
    global testsessioninprogress_done
    global testsessionstop_done

    if {$hardwareinit_done==1} {
        .flow.testsessionsetup config -state normal
	if {$testsessionsetup_done==1} {
            .flow.testsessionstart config -state normal
	    if {$testsessionstart_done==1} {
                .flow.testsessioninprogress config -state normal
                if {$testsessioninprogress_done==1} {
                    .flow.testsessionstop config -state normal
                    if {$testsessionstop_done==1} {
                        .flow.readstatisticresults config -state normal
                    } else {
                        .flow.readstatisticresults config -state disabled
                    }
		} else {
                    .flow.testsessionstop config -state disabled
                    .flow.readstatisticresults config -state disabled
                    set testsessionstop_done 0
		}
            } else {
                .flow.testsessioninprogress config -state disabled
                .flow.testsessionstop config -state disabled
                .flow.readstatisticresults config -state disabled
                set testsessioninprogress_done 0
                set testsessionstop_done 0
            }
	} else {
            .flow.testsessionstart config -state disabled
            .flow.testsessioninprogress config -state disabled
            .flow.testsessionstop config -state disabled
            .flow.readstatisticresults config -state disabled
            set testsessionstart_done 0
            set testsessioninprogress_done 0
            set testsessionstop_done 0
	}
    } else {
        .flow.testsessionsetup config -state disabled
        .flow.testsessionstart config -state disabled
        .flow.testsessioninprogress config -state disabled
        .flow.testsessionstop config -state disabled
        .flow.readstatisticresults config -state disabled
        set testsessionsetup_done 0
        set testsessionstart_done 0
        set testsessioninprogress_done 0
        set testsessionstop_done 0
    }
}
EvaluateButtonState

# define sub-gui entrance
proc HardwareInit {} {
    global hardwareinit_done
    if {$hardwareinit_done==0} {
        set hardwareinit_done 1
        EvaluateButtonState
	# do something
        source gigalite_demo/hardware_init.tcl
	buildHardwareInit
    } else {
        set hardwareinit_done 0
        EvaluateButtonState
	# do nothing
    }
}
proc TestSessionSetup {} {
    global testsessionsetup_done
    if {$testsessionsetup_done==0} {
        set testsessionsetup_done 1
        EvaluateButtonState
	# do something
	source gigalite_demo/testsession_setup.tcl
	buildTestSessionSetup
    } else {
        set testsessionsetup_done 0
        EvaluateButtonState
	# do nothing
    }
}
proc TestSessionStart {} {
    global testsessionstart_done
    if {$testsessionstart_done==0} {
        set testsessionstart_done 1
	EvaluateButtonState
	# do something
	source gigalite_demo/testsession_start.tcl
	buildTestSessionStart
    } else {
        set testsessionstart_done 0
	EvaluateButtonState
	# do nothing 
    }
}
proc TestSessionInProgress {} {
    global testsessioninprogress_done
    if {$testsessioninprogress_done==0} {
        set testsessioninprogress_done 1
        EvaluateButtonState
	# do something
	source gigalite_demo/testsession_inprogress.tcl
	buildTestSessionInProgress
    } else {
        set testsessioninprogress_done 0
        EvaluateButtonState
	# do nothing
    }
}
proc TestSessionStop {} {
    global testsessionstop_done
    if {$testsessionstop_done==0} {
        set testsessionstop_done 1
        EvaluateButtonState
	# do something
	source gigalite_demo/testsession_stop.tcl
	buildTestSessionStop
    } else {
        set testsessionstop_done 0
        EvaluateButtonState
	# do nothing
    }
}
proc ReadStatisticResults {} {
    global readstatisticresults_done
    if {$readstatisticresults_done==0} {
        set readstatisticresults_done 1
        EvaluateButtonState
	# do something
        source gigalite_demo/stat_report.tcl
        buildReadStatisticResults
    } else {
        set readstatisticresults_done 0
        EvaluateButtonState
	# do nothing
    }
}

# utilities
proc runScript {{scriptfile 0}} {
    set fileid [open $scriptfile r]
    foreach command_line [split [read $fileid] \n] {
        eval $command_line
    }
}




# make the program wait for exit signal
vwait exit_console

