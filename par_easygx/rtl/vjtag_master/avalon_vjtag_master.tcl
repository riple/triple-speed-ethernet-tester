
variable jtag_index 
variable jtag_data
#################################
# Subroutines
################################# 

proc data_from_fpga {} {
  global jtag_index
  global jtag_data
  device_lock -timeout 10000
  device_virtual_ir_shift -instance_index $jtag_index -ir_value 1 -no_captured_ir_value
  set read_data [device_virtual_dr_shift -instance_index $jtag_index -length 32 -value_in_hex]
  device_unlock
  set jtag_data $read_data
} 

proc state_from_fpga {} {
  global jtag_index
  global jtag_data
  device_lock -timeout 10000
  device_virtual_ir_shift -instance_index $jtag_index -ir_value 2 -no_captured_ir_value
  set read_data [device_virtual_dr_shift -instance_index $jtag_index -length 36 -value_in_hex]
  device_unlock
  set jtag_data $read_data
}                          

proc data_to_fpga {{write_data 00000000}} {
  global jtag_index
  device_lock -timeout 10000
  device_virtual_ir_shift -instance_index $jtag_index -ir_value 3 -no_captured_ir_value
  device_virtual_dr_shift -instance_index $jtag_index -length 32 -dr_value $write_data -value_in_hex
  device_unlock
} 

proc addr_to_fpga {{write_addr ffffffff}} { 
  global jtag_index
  device_lock -timeout 10000
  device_virtual_ir_shift -instance_index $jtag_index -ir_value 4 -no_captured_ir_value
  device_virtual_dr_shift -instance_index $jtag_index -length 32 -dr_value $write_addr -value_in_hex
  device_unlock
}

proc read_pulse_to_fpga {} {
  global jtag_index
  device_lock -timeout 10000
  device_virtual_ir_shift -instance_index $jtag_index -ir_value 5 -no_captured_ir_value
  device_virtual_dr_shift -instance_index $jtag_index -length 1  -value_in_hex
  device_unlock
}           

proc write_pulse_to_fpga {} {
  global jtag_index
  device_lock -timeout 10000
  device_virtual_ir_shift -instance_index $jtag_index -ir_value 6 -no_captured_ir_value
  device_virtual_dr_shift -instance_index $jtag_index -length 1  -value_in_hex
  device_unlock
}

proc reset_fpga {} {
  global jtag_index
  device_lock -timeout 10000
  device_virtual_ir_shift -instance_index $jtag_index -ir_value 7 -no_captured_ir_value
  device_virtual_dr_shift -instance_index $jtag_index -length 1  -value_in_hex
  device_unlock
}

proc wr {{write_addr ffffffff} {write_data 55555555}} {
  global Blaster_name
  global test_device
  open_device -hardware_name $Blaster_name -device_name $test_device

  global jtag_data
  addr_to_fpga $write_addr
  data_to_fpga $write_data
  # check waitrequest before send out command
  set tmp 2
  while {$tmp == 1 || $tmp == 2 || $tmp == 3} {
    state_from_fpga
    set tmp [string index $jtag_data 8]
  }
  write_pulse_to_fpga
  # check waitrequest before exit
  set tmp 1
  while {$tmp == 1 || $tmp == 2 || $tmp == 3} {
    state_from_fpga
    set tmp [string index $jtag_data 8]
  }

  close_device
}

proc rd {{read_addr 00000000}} {
  global Blaster_name
  global test_device
  open_device -hardware_name $Blaster_name -device_name $test_device

  global jtag_data
  addr_to_fpga $read_addr
  # check waitrequest before send out command
  set tmp 1
  while {$tmp == 1 || $tmp == 2 || $tmp == 3} {
    state_from_fpga
    set tmp [string index $jtag_data 8]
  }
  read_pulse_to_fpga
  # check waitrequest before read
  set tmp 1
  while {$tmp == 1 || $tmp == 2 || $tmp == 3} {
    state_from_fpga
    set tmp [string index $jtag_data 8]
  }
  data_from_fpga

  close_device
}

### Hardware Setup begins ######################################################

# Get hardware names : get download cable name
foreach hardware_name [get_hardware_names] {
  puts "\n $hardware_name"
  if { [string match "*Blaster*" $hardware_name] } {
    set Blaster_name $hardware_name
  }                                                                                         
}
puts "\n Select JTAG chain connected to $Blaster_name.\n";

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

### Test begin ######################################
set command 1
set jtag_index 8
while {$command != 0} {
  puts "\n Type in the command to run:"
  puts ""
  puts "rd addr"
  puts "wr addr data"
  puts "state"
  puts "reset"
  puts "exit"
#  puts "exe filename"
  puts ""
  
  gets stdin command_input
  set command $command_input 
  
  if {[string last "rd" $command] != -1} {
    puts "\n Command: $command"
    puts " input addr is [string range $command 3 10]"
    eval $command    
    puts " captd data is $jtag_data"
    
  } elseif {[string last "wr" $command] != -1} {
    puts "\n Command: $command"
    puts " input addr is [string range $command 3 10]"
    puts " input data is [string range $command 12 19]"
    eval $command
        
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
    puts "\n Command: $command"
    state_from_fpga
    puts " Hardware state is: $jtag_data"
    
  } elseif {[string last "reset" $command] != -1} {
    puts "\n Command: $command"
    reset_fpga
    
  } elseif {[string last "exit" $command] != -1} {
    puts "\n exiting..."
    break

  } else {
    puts "$command is not in the list"
  }
    
}

