###################################################################################
##  TFM VICON
##  Simulation script
##  Engineer: Manuel Lorente Alman
##  Example: source -notrace {D:/TFM/3-Development/FPGA/SRC/IMAGECHANNEL/IMAGE_CHANNEL_tb.tcl}
###################################################################################

# Restart simulation
restart

# Input signals
add_wave {CLK}
add_wave {XCLK}
add_wave {RESET}
add_wave {PAT_ENA}
add_wave {REQUEST}
# Internal signals
add_wave {PATTERN/state_reg}
add_wave {RECEIVER/LVAL}
add_wave {RECEIVER/sof_signal}
add_wave {RECEIVER/eof_signal}
add_wave {RECEIVER/DIN}
add_wave {FIFO/PUSH}
add_wave {FIFO/words}
add_wave {FIFO/POP}
# Output signals
add_wave {WRITE_USB}
add_wave {DOUT}

# CLK at 100MHz (10ns) definition
add_force {CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns
add_force {XCLK} -radix bin {0 0ns} {1 20ns} -repeat_every 40ns

# Init signals value
add_force {RESET} -radix hex {1 0ns} {0 10ns}
add_force {PAT_ENA} -radix bin {0 0ns}
add_force {REQUEST} -radix bin {0 0ns}
add_force {FIFO_POP} -radix bin {0 0ns}
run 50ns

# Enable pattern mode and write data to PC
add_force {PAT_ENA} -radix bin {1 0ns}
run 1ms
add_force {REQUEST} -radix bin {0 0ns} {1 10ns} {0 20ns}
run 5ms
add_force {FIFO_POP} -radix bin {0 0ns} {1 10ns} {0 60ns} -repeat_every 100ns
run 150ms
add_force {REQUEST} -radix bin {0 0ns} {1 10ns} {0 20ns} -repeat_every 1ms
add_force {FIFO_POP} -radix bin {0 0ns} {1 10ns} {0 60ns} -repeat_every 100ns
run 150ms

