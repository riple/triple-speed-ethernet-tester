
proc buildTestSessionInProgress {} {

    if {[winfo exists .prog]} {
        destroy .prog
    }
    toplevel .prog
    pack propagate .prog true
    wm title .prog "Test Session In-Progress"
    
    # bandwidth 
    frame .prog.bandw
    pack .prog.bandw
    frame .prog.bandw.left
    pack .prog.bandw.left
    for {set i 0} {$i<9} {incr i} {
      frame .prog.bandw.left.strm$i
      message          .prog.bandw.left.strm$i.txbw -text { 0.00} -aspect 1000 -relief sunken
      message          .prog.bandw.left.strm$i.rxbw -text { 0.00} -aspect 1000 -relief sunken
      label            .prog.bandw.left.strm$i.name -text [list Bandwidth of Stream $i : ]
      label            .prog.bandw.left.strm$i.per1 -text {%   }
      label            .prog.bandw.left.strm$i.per2 -text {%   }
      pack .prog.bandw.left.strm$i.name .prog.bandw.left.strm$i.txbw .prog.bandw.left.strm$i.per1 .prog.bandw.left.strm$i.rxbw .prog.bandw.left.strm$i.per2 -side left
    }
    .prog.bandw.left.strm8.name configure -text [list Bandwidth of Non-Test : ]
    pack .prog.bandw.left.strm0 \
         .prog.bandw.left.strm1 \
	 .prog.bandw.left.strm2 \
	 .prog.bandw.left.strm3 \
         .prog.bandw.left.strm4 \
	 .prog.bandw.left.strm5 \
	 .prog.bandw.left.strm6 \
	 .prog.bandw.left.strm7 \
	 .prog.bandw.left.strm8 -side top
    frame .prog.bandw.right
    pack .prog.bandw.right
    button .prog.bandw.right.update -text {Update} -command {updateBandwidth}
    pack .prog.bandw.right.update -side left
    pack .prog.bandw.left .prog.bandw.right -side left

    # non-test frames
    frame .prog.txnontest
    pack .prog.txnontest
    button .prog.txnontest.send -text {Send CPU Packet} -command {sendNonTest}
    #entry .prog.txnontest.txnum -textvariable tx_nontest_num
    #entry .prog.txnontest.rxnum -textvariable rx_nontest_num
    label .prog.txnontest.blank -text {} -width 43
    pack .prog.txnontest.send .prog.txnontest.blank -side left

    # error frames
    frame .prog.txerror
    pack .prog.txerror
    button .prog.txerror.send -text {Send Error Packet} -command {sendError}
    ttk::combobox .prog.txerror.type -textvariable tx_error_type
    .prog.txerror.type configure -values [list "CRC Error" "BER Error" "LOS Error" "OOS Error" "DUP Error"]
    global tx_error_type
    set tx_error_type "CRC Error"
    ttk::combobox .prog.txerror.strm -textvariable tx_error_strm
    .prog.txerror.strm configure -values [list "Stream 0" "Stream 1" "Stream 2" "Stream 3" "Stream 4" "Stream 5" "Stream 6" "Stream 7"]
    global tx_error_strm
    set tx_error_strm "Stream 0"
    pack .prog.txerror.send .prog.txerror.type .prog.txerror.strm -side left

    # pack them all
    pack .prog.bandw .prog.txnontest .prog.txerror -side top
}

proc calcBandwidth {{linerate2nd 1} {linerate1st 0} {accesstime2nd 1} {accesstime1st 0} {gigaspeed_ratio 1.00}} {
    # bit, bit, ns, ns
    #puts [list $linerate2nd $linerate1st $accesstime2nd $accesstime1st]
    if {$linerate2nd>=$linerate1st} {
        set linerateincr   [expr $linerate2nd   - $linerate1st  ]
    } else {
        set linerateincr   [expr $linerate2nd   + (4294967296*8  - $linerate1st)  ]
    }
    #puts [list $linerateincr]
    if {$accesstime2nd>=$accesstime1st} {
        set accesstimeincr [expr $accesstime2nd - $accesstime1st]
    } else {
        set accesstimeincr [expr $accesstime2nd + (4294967296*10 - $accesstime1st)]
    }
    #puts [list $accesstimeincr]
    set bandwidth [expr ($linerateincr.0/$accesstimeincr.0)/$gigaspeed_ratio]
    return [format "%f" [expr 100*$bandwidth]]
}

proc updateBandwidth {} {
    global WireSpeed
    puts ""
    for {set i 0} {$i<9} {incr i} {
      # read line-rate 1st time
      set txlr1st$i [rd 08010[set i]88 1]
      # read stat access time
      set txat1st$i [rd 00000010 1]
      # read line-rate 1st time
      set rxlr1st$i [rd 08030[set i]88 1]
      # read stat access time
      set rxat1st$i [rd 00000010 1]
    }
    after 1000
    puts ""
    for {set i 0} {$i<9} {incr i} {
      # read line-rate 2nd time
      set txlr2nd$i [rd 08010[set i]88 1]
      # read stat access time
      set txat2nd$i [rd 00000010 1]
      # read line-rate 2nd time
      set rxlr2nd$i [rd 08030[set i]88 1]
      # read stat access time
      set rxat2nd$i [rd 00000010 1]
    }
    for {set i 0} {$i<9} {incr i} {
      # calculate bandwith
      set txbw [calcBandwidth [expr [hex2dec [set txlr2nd$i]]*8] [expr [hex2dec [set txlr1st$i]]*8] [expr [hex2dec [set txat2nd$i]]*10] [expr [hex2dec [set txat1st$i]]*10] [expr $WireSpeed/1000.0]]
      set rxbw [calcBandwidth [expr [hex2dec [set rxlr2nd$i]]*8] [expr [hex2dec [set rxlr1st$i]]*8] [expr [hex2dec [set rxat2nd$i]]*10] [expr [hex2dec [set rxat1st$i]]*10] [expr $WireSpeed/1000.0]]
      # update gui
      .prog.bandw.left.strm$i.txbw configure -text [list $txbw]
      .prog.bandw.left.strm$i.rxbw configure -text [list $rxbw]
    }
}

proc sendNonTest {} {
    # read before write
    set txCtrl [rd 04000010]
    # set command
    set txCtrl [format "%08x" [expr [hex2dec $txCtrl]+4]]
    wr 04000010 $txCtrl 1
    # poll finish state
    set txState 00000000
    set i 0
    while {[string index $txState 7]!=[string index $txCtrl 7]} {
        set txState [rd 04000014]
        # timeout
	incr i
	after 2
	if {$i>1000} {
	    break
	}
    }
    # reset command
    wr 04000010 [format "%08x" [expr [hex2dec $txCtrl]-4]] 1
}

proc sendError {} {
    # read before write
    set txCtrl [rd 04000010]
    # choose stream
    global tx_error_strm
    switch $tx_error_strm {
        "Stream 0" { set tx_error_strm_val [expr 0*4096]}
        "Stream 1" { set tx_error_strm_val [expr 1*4096]}
        "Stream 2" { set tx_error_strm_val [expr 2*4096]}
        "Stream 3" { set tx_error_strm_val [expr 3*4096]}
        "Stream 4" { set tx_error_strm_val [expr 4*4096]}
        "Stream 5" { set tx_error_strm_val [expr 5*4096]}
        "Stream 6" { set tx_error_strm_val [expr 6*4096]}
        "Stream 7" { set tx_error_strm_val [expr 7*4096]}
    }
    # choose type
    global tx_error_type
    switch $tx_error_type {
        "CRC Error" { set tx_error_type_val [expr 0*256]}
        "BER Error" { set tx_error_type_val [expr 1*256]}
        "LOS Error" { set tx_error_type_val [expr 4*256]}
        "OOS Error" { set tx_error_type_val [expr 5*256]}
        "DUP Error" { set tx_error_type_val [expr 6*256]}
    }
    # set error injection bits
    set tx_error_inj [expr $tx_error_strm_val+$tx_error_type_val+65536]
    # set command 
    set txCtrl [format "%08x" [expr [hex2dec $txCtrl]+$tx_error_inj]]
    wr 04000010 $txCtrl 1
    # poll finish state
    set txState 00000000
    set i 0
    while {$txState!=$txCtrl} {
        set txState [rd 04000014]
        # timeout
	incr i
	after 2
	if {$i>1000} {
	    break
	}
    }
    # reset command
    wr 04000010 [format "%08x" [expr [hex2dec $txCtrl]-$tx_error_inj]] 1
}

