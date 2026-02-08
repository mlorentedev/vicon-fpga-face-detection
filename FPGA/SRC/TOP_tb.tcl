###################################################################################
##  TFM VICON
##  Simulation script
##  Engineer: Manuel Lorente Alman
##  Example: source -notrace {D:/TFM/3-Development/FPGA/SRC/TOP_tb.tcl}
###################################################################################

# Restart simulation
restart

# Input signals
add_wave {CLK}
add_wave {RESET}
add_wave {RXFn}
add_wave {TXEn}
add_wave {MODE}
# Internal signals
add_wave {ICHI/fval_signal}
add_wave {ICHI/lval_signal}
add_wave {ICHI/PATTERN/state_reg}
add_wave {ICHI/PATTERN/dout_vramp_reg}
add_wave {ICHI/PATTERN/dout_hramp_reg}
add_wave {ICHI/PATTERN/count_line}
add_wave {ICHI/PATTERN/count_pixel}
add_wave {ICHI/RECEIVER/state_reg}
add_wave {FT245/IFWRITE/state_reg}
add_wave {FT245/POP}
add_wave {ICHI/RECEIVER/sof_signal}
add_wave {ICHI/RECEIVER/eof_signal}
add_wave {ICHI/fifo_data_in}
add_wave {ICHI/PATTERN/DOUT}
add_wave {ICHI/fifo_data_in}
add_wave {ICHI/FIFO/words}
add_wave {image_channel_data}
# Output signals
add_wave {RESETN}
add_wave {XCLK}
add_wave {WRn}
add_wave {RDn}
add_wave {DATA}

# CLK at 100MHz (10ns) definition
add_force {CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Init signals value
add_force {RESET} -radix hex {1 0ns} {0 10ns}
add_force {RXFn} -radix bin {1 0ns}
add_force {TXEn} -radix bin {1 0ns}
add_force {MODE} -radix bin {00 0ns}
run 50ns

# Request data from PC
add_force {RXFn} -radix bin {0 0ns} {1 10ns}
run 1ms

## Configure vertical ramp pattern
#add_force {MODE} -radix bin {10 0ns}
#add_force {TXEN} -radix bin {0 0ns} {1 10ns} {0 60ns}    -repeat_every 100ns
#run 80ms

# Configure vertical ramp pattern
add_force {MODE} -radix bin {10 0ns}
#add_force {RXFn} -radix bin {0 0ns} {1 10ns} {0 60ns}    -repeat_every 100ns
add_force {TXEN} -radix bin {0 0ns} {1 10ns} {0 60ns}    -repeat_every 100ns
run 40ms

# End of communication
add_force {TXEn} -radix bin {1 0ns}
run 60ns








