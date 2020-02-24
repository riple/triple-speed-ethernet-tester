


proc createReport {} {
    # build top frame
    frame .report.top
    pack .report.top
    # build notebook
    set nb [NoteBook .report.top.nb -side bottom]
    pack $nb -fill both -expand 1
    # build each tab
    set i 0
    foreach tabName [stream_define_dout] {
        $nb insert $i tab$i -text $tabName
        set i [expr $i+1]
    }
    $nb raise tab0
    # build report content for each tab
    global rowNum
    set rowNum 8
    listReport $rowNum

    # build bottom frame
    frame .report.bottom
    pack .report.bottom
    # build TX-CPU button
    frame .report.bottom.f0 -relief ridge -borderwidth 5
    pack .report.bottom.f0
    button .report.bottom.f0.txcpu -text {TX CPU} -command {txCPU}
    pack .report.bottom.f0.txcpu
    # build Start/Stop button
    frame .report.bottom.f1 -relief ridge -borderwidth 5
    pack .report.bottom.f1
    button .report.bottom.f1.start -text {TX Start} -command {triggerTx}
    pack .report.bottom.f1.start
    global txState
    set txState 0
    # build Clear button
    frame .report.bottom.f2 -relief ridge -borderwidth 5
    pack .report.bottom.f2
    button .report.bottom.f2.clear -text {Reset} -command {resetReport}
    pack .report.bottom.f2.clear
    # build Update button
    frame .report.bottom.f3 -relief ridge -borderwidth 5
    pack .report.bottom.f3
    button .report.bottom.f3.update -text {Update} -command {updateReport $rowNum}
    pack .report.bottom.f3.update
    # build page button
    frame .report.bottom.f4 -relief ridge -borderwidth 5
    pack .report.bottom.f4
    button .report.bottom.f4.pgup -text {PgUp} -command {PgUp}
    pack .report.bottom.f4.pgup
    # build page button
    frame .report.bottom.f5 -relief ridge -borderwidth 5
    pack .report.bottom.f5
    button .report.bottom.f5.pgdn -text {PgDn} -command {PgDn}
    pack .report.bottom.f5.pgdn
    # build Quit button
    frame .report.bottom.f6 -relief ridge -borderwidth 5
    pack .report.bottom.f6
    button .report.bottom.f6.quit -text {Quit} -command {quitReport}
    pack .report.bottom.f6.quit
    # align bottom buttons
    pack .report.bottom.f0 .report.bottom.f1 .report.bottom.f2 .report.bottom.f3 .report.bottom.f4 .report.bottom.f5 .report.bottom.f6 -side left

    # build whole
    pack .report.top .report.bottom -side top
}

proc hex2dec {{hexNum 00}} {
    set tmp 0x
    append tmp $hexNum
    set decNum [format "%u" $tmp]
    return $decNum
}

proc getResult {{node} {index 0} {radix hex}} {
    set base_addr [hex2dec $node]
    set bias_addr $index
    set stat_addr [format "%08x" [expr $base_addr+$bias_addr*4]]
    return [rd $stat_addr]
    #return [examine -$radix $node\[$index\]]
}

proc listReport {{rowNum 16}} {
    # get report parameter
    set target_define_dout [target_define_dout]
    set message_define_dout [message_define_dout]
    global currTargNum
    set currTargNum 0
    global totalTargNum
    set totalTargNum [llength $target_define_dout]
    set reportTrgt [lindex $target_define_dout $currTargNum]
    set reportNumb [llength $message_define_dout]
    # get report target parameter
    set reportNode [lindex $reportTrgt 0]
    set reportDesc [lindex $reportTrgt 1]
    set reportBase [lindex $reportTrgt 2]
    set reportCycl [lindex $reportTrgt 3]

    for {set i 0} {$i<[llength [stream_define_dout]]} {incr i} {
        set tab [.report.top.nb getframe tab$i]
        # build column frame
        for {set j 0} {$j <[expr ($reportNumb-$reportNumb%$rowNum)/$rowNum+1]} {incr j} {
            frame $tab.f$j -relief groove -borderwidth 5
            pack $tab.f$j  -side left -anchor n
        }
        # build content for each entry
        set k 0
        foreach tmp [lrange $message_define_dout 0 end] {
            # get report value for each entry
            set msgRadx [lindex $tmp 0]
            set msgIndx [expr ([lindex $tmp 1]-$reportBase)/1+$i*$reportCycl]
            set msgDesc [lindex $tmp [expr $currTargNum+2]]
            if {$msgDesc=="_______"} {
                set msgValu 00000000
            } else {
                set msgValu [getResult $reportNode $msgIndx $msgRadx] 
            }
            # display report value for each entry
            set colIndex [expr ($k-$k%$rowNum)/$rowNum]
            set rowIndex [expr $k%$rowNum]
            frame $tab.f$colIndex.$rowIndex
            pack $tab.f$colIndex.$rowIndex -fill x -expand true
            label $tab.f$colIndex.$rowIndex.l$k -text [list $msgDesc : ]
            message $tab.f$colIndex.$rowIndex.m$k -text [list $msgValu] -aspect 1000 -relief sunken
            pack $tab.f$colIndex.$rowIndex.m$k $tab.f$colIndex.$rowIndex.l$k -side right
            set k [expr $k+1] 
        }
    }

    wm title .report "Report: $reportDesc"
}

proc updateReport {{rowNum 16}} {
    global currTargNum
    # get report parameter
    set target_define_dout [target_define_dout]
    set message_define_dout [message_define_dout]
    set reportTrgt [lindex $target_define_dout $currTargNum]
    # get report target
    set reportNode [lindex $reportTrgt 0]
    set reportDesc [lindex $reportTrgt 1]
    set reportBase [lindex $reportTrgt 2]
    set reportCycl [lindex $reportTrgt 3]

    for {set i 0} {$i<[llength [stream_define_dout]]} {incr i} {
        set tab [.report.top.nb getframe tab$i]
        
        set k 0
        foreach tmp [lrange $message_define_dout 0 end] {
            # get report value for each entry
            set msgRadx [lindex $tmp 0]
            set msgIndx [expr ([lindex $tmp 1]-$reportBase)/1+$i*$reportCycl]
            set msgDesc [lindex $tmp [expr $currTargNum+2]]
            if {$msgDesc=="_______"} {
                set msgValu 00000000
            } else {
                set msgValu [getResult $reportNode $msgIndx $msgRadx] 
            }
            # update report value for each entry
            set colIndex [expr ($k-$k%$rowNum)/$rowNum]
            set rowIndex [expr $k%$rowNum]
            $tab.f$colIndex.$rowIndex.l$k config -text [list $msgDesc : ]
            $tab.f$colIndex.$rowIndex.m$k config -text [list $msgValu]
    
            set k [expr $k+1] 
        }
    }

    wm title .report "Report: $reportDesc"
}

proc resetReport {} {
    wr 00000004 00000310
    set clrState 00000000
    while {$clrState==00000000} {
        set clrState [rd 00000008]
    }
    wr 00000004 00000300
}

proc txCPU {} {
    set cpuCtrl [rd 04000010]
    set cpuCtrl [format "%08x" [expr [hex2dec $cpuCtrl]+4]]
    wr 04000010 $cpuCtrl
    set cpuState 00000000
    while {[string index $cpuState 7]!=[string index $cpuCtrl 7]} {
        set cpuState [rd 04000014]
    }
    wr 04000010 [format "%08x" [expr [hex2dec $cpuCtrl]-4]]
}

proc triggerTx {} {
    global txState
    if {$txState==0} {
        set cpuCtrl [rd 04000010]
        set cpuCtrlLeng [string range $cpuCtrl 0 5]
        wr 04000010 [append cpuCtrlLeng 03]
        .report.bottom.f1.start config -text {TX Stop}
        set txState 1
    } else {    
        set cpuCtrl [rd 04000010]
        set cpuCtrlLeng [string range $cpuCtrl 0 5]
        wr 04000010 [append cpuCtrlLeng 02]
        .report.bottom.f1.start config -text {TX Start}
        set txState 0
    }
}

proc PgUp {} {
    global currTargNum
    global totalTargNum
    if {$currTargNum>0} {
        set currTargNum [expr $currTargNum-1]
    } else {
        set currTargNum [expr $totalTargNum-1]
    }
    global rowNum
    updateReport $rowNum
}

proc PgDn {} {
    global currTargNum
    global totalTargNum
    if {$currTargNum<[expr $totalTargNum-1]} {
        set currTargNum [expr $currTargNum+1]
    } else {
        set currTargNum 0
    }
    global rowNum
    updateReport $rowNum
}

proc quitReport {} {
    destroy .report

    global exit_console
    destroy .console
    set exit_console 1
}

proc buildReport {} {
    package require BWidget
    source stat_report_para.tcl

    toplevel .report
    pack propagate .report true

    createReport
}
