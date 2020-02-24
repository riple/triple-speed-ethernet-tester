


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
    # build Update button
    frame .report.bottom.f1 -relief ridge -borderwidth 5
    pack .report.bottom.f1
    button .report.bottom.f1.update -text {Update} -command {updateReport $rowNum}
    pack .report.bottom.f1.update
    # build blank
    frame .report.bottom.f2 
    pack .report.bottom.f2
    # build page button
    frame .report.bottom.f3 -relief ridge -borderwidth 5
    pack .report.bottom.f3
    button .report.bottom.f3.pgup -text {PgUp} -command {PgUp}
    pack .report.bottom.f3.pgup
    # build page button
    frame .report.bottom.f4 -relief ridge -borderwidth 5
    pack .report.bottom.f4
    button .report.bottom.f4.pgdn -text {PgDn} -command {PgDn}
    pack .report.bottom.f4.pgdn
    # build blank
    frame .report.bottom.f5
    pack .report.bottom.f5
    # build Quit button
    frame .report.bottom.f6 -relief ridge -borderwidth 5
    pack .report.bottom.f6
    button .report.bottom.f6.quit -text {Quit} -command {quitReport}
    pack .report.bottom.f6.quit
    # align bottom buttons
    pack .report.bottom.f1 .report.bottom.f2 .report.bottom.f3 .report.bottom.f4 .report.bottom.f5 .report.bottom.f6 -side left

    # build whole
    pack .report.top .report.bottom -side top
}


proc getResult {{node} {index 0} {radix hex}} {
    return [examine -$radix $node\[$index\]]
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
            set msgValu [getResult $reportNode $msgIndx $msgRadx]
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

    global Now
    wm title .report "Report @$Now : $reportDesc"
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
            set msgValu [getResult $reportNode $msgIndx $msgRadx]
            # update report value for each entry
            set colIndex [expr ($k-$k%$rowNum)/$rowNum]
            set rowIndex [expr $k%$rowNum]
            $tab.f$colIndex.$rowIndex.l$k config -text [list $msgDesc : ]
            $tab.f$colIndex.$rowIndex.m$k config -text [list $msgValu]
    
            set k [expr $k+1] 
        }
    }

    global Now
    wm title .report "Report @$Now : $reportDesc"
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
}

proc buildReport {} {
    package require BWidget
    source gui/stat_report_para.tcl

    toplevel .report
    pack propagate .report true

    createReport
}
