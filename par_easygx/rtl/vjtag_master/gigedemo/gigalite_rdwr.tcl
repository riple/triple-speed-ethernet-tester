

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

proc wr {{write_addr ffffffff} {write_data 55555555} {print 0}} {
  if {$print==1} {
    puts [list wr $write_addr $write_data]
  }

  global no_hardware
  if {$no_hardware==0} {
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
  } else {
  }
}

proc rd {{read_addr 00000000} {print 0}} {
  global no_hardware
  if {$no_hardware==0} {
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
  if {$print==1} {
    puts [list rd $read_addr $jtag_data]
  }
  return $jtag_data
  } else {
  return 123456
  }
}

proc hex2dec {{hexNum 00}} {
	set tmp 0x
	append tmp $hexNum
	set decNum [format "%u" $tmp]
	return $decNum
}

