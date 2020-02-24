set no_hardware 0

if {$no_hardware==0} {
set command 1
} else {
set command 0
}
global command
source ../../xilinx/chipscope_vio_rdwr.tcl

##############################
## Main to setup GUI
##############################
set command 1
set no_hardware 0

global command
if {$command == 0} {
} else {
  set command 1
  scan_chain
  select_device 1 1
}

### Test begin ######################################
while {$command != 0} {
  #puts -nonewline "buscli_console:\r"
  #flush stdout
  
  gets stdin command_input
  set command $command_input 
  
  if {[string last "rd" $command] != -1} {
    eval $command    
    puts -nonewline "\r"
    puts "# $jtag_data"
    
  } elseif {[string last "wr" $command] != -1} {
    eval $command
    #puts "\rwr [string range $command 3 10] [string range $command 12 19]"
        
#  } elseif {[string last "exe" $command] != -1} { 
#    set input_file_name [string range $command 4 15]
#    puts "\n Command: $command"
#    set output_file_name data.txt
#    puts "\n Output filename: [pwd]/tmp/$output_file_name"
#    set command_fileid [open "tmp/$input_file_name" r] 
#    set outdata_fileid [open "tmp/$output_file_name" a+]
#    puts $outdata_fileid "@[clock format [clock seconds]]"
#    set line_num 1 
#    foreach command_line [split [read $command_fileid] \n] {
#      eval $command_line
#      if {[string last "rd" $command_line] != -1} {
#        puts $outdata_fileid "[format "%-5s %s %4s" $line_num | $jtag_data]"
#      } else {
#        puts $outdata_fileid "[format "%-5s %s" $line_num |]"
#      }
#      set line_num [expr $line_num + 1]
#    }
#    close $command_fileid
#    close $outdata_fileid
  
  } elseif {[string last "state" $command] != -1} {
    state_from_fpga
    puts " Hardware state is: $jtag_data"
    
  } elseif {[string last "reset" $command] != -1} {
    genrst_pulse
  } elseif {[string last "exit" $command] != -1} {
    puts "\n exiting..."
    close_jtag_device
    break

  } elseif {[string last "help" $command] != -1} {
    puts ""
    puts "rd addr"
    puts "wr addr data"
    puts "state"
    puts "reset"
    puts "exit"
    puts "help"
    #  puts "exe filename"
    puts ""

  } else {
    eval $command
  }
    
}

