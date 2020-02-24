
proc buildTestSessionSetup {} {
    #runScript "gigalite_demo/testsession_setup.txt"
    source "gigalite_demo/testsession_setup.txt"
    
    # build Bandwidth Input GUI
    if {[winfo exists .setup]} {
        destroy .setup
    }
    toplevel .setup
    pack propagate .setup true
    wm title .setup "Test Session Setup"
    
    # bandwidth 
    frame .setup.bandw
    pack .setup.bandw
    frame .setup.bandw.left
    pack .setup.bandw.left
    for {set i 0} {$i<8} {incr i} {
      frame .setup.bandw.left.strm$i
      label            .setup.bandw.left.strm$i.name -text [list Bandwidth of Stream $i : ]
      entry            .setup.bandw.left.strm$i.txbw -textvar txbw$i -relief sunken -width 8
      label            .setup.bandw.left.strm$i.per1 -text {%   }
      entry            .setup.bandw.left.strm$i.leng -textvar leng$i -relief sunken -width 8
      label            .setup.bandw.left.strm$i.byte -text {Byte}
      pack .setup.bandw.left.strm$i.name .setup.bandw.left.strm$i.txbw .setup.bandw.left.strm$i.per1 .setup.bandw.left.strm$i.leng .setup.bandw.left.strm$i.byte -side left
      global txbw$i
      global leng$i
      set txbw$i 12.5
      set leng$i 1518
    }
    pack .setup.bandw.left.strm0 \
         .setup.bandw.left.strm1 \
	 .setup.bandw.left.strm2 \
	 .setup.bandw.left.strm3 \
         .setup.bandw.left.strm4 \
	 .setup.bandw.left.strm5 \
	 .setup.bandw.left.strm6 \
	 .setup.bandw.left.strm7 -side top
    frame .setup.bandw.right
    pack .setup.bandw.right
    button .setup.bandw.right.config -text {Config} -command {configBandwidth}
    pack .setup.bandw.right.config -side left
    pack .setup.bandw.left .setup.bandw.right -side left
}

proc configBandwidth {} {
    puts {}
    global WireSpeed
    for {set i 0} {$i<8} {incr i} {
        global txbw$i
        global leng$i
        set txbwi [set txbw$i]
        set txbwi [expr $txbwi*1.0/100]
        set lengi [set leng$i]
        # calculate old
        set bwReg [expr 65536.0*($WireSpeed.0*$txbwi)/(($lengi.0+8)*8+96)/50]
        #set bwReg [lindex [split $bwReg "."] 0]
        # calculate new
        set scaleFactor [expr 30000.0/$bwReg]
        set scaleFactor [lindex [split $scaleFactor "."] 0]
        set bwReg [expr $scaleFactor*65536.0*($WireSpeed.0*$txbwi)/(($lengi.0+8)*8+96)/50]
        set bwReg       [lindex [split $bwReg       "."] 0]
        set scaleFactor [lindex [split $scaleFactor "."] 0]

        wr [format "%08x" [expr [hex2dec 04000020] + $i*4]] [format "%08x" [expr $bwReg*65536+[set leng$i]]] 1
        wr [format "%08x" [expr [hex2dec 04000040] + $i*4]] [format "%08x" [expr $scaleFactor]] 1
    }
}


