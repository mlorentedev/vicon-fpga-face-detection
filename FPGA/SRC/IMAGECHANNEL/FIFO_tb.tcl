###################################################################################
##  TFM VICON
##  Simulation script
##  Engineer: Manuel Lorente Alman
##  Example: source -notrace {D:/TFM/3-Development/FPGA/SRC/IMAGECHANNEL/FIFO_tb.tcl}
###################################################################################

# Restart simulation
restart

# Input signals
add_wave {CLK}
add_wave {RESET}
add_wave {DIN}
add_wave {PUSH}
add_wave {POP}
# Internal signals
add_wave {ram}
add_wave {words}
#Output signals
add_wave {DOUT}
add_wave {FULL}
add_wave {EMPTY}

# CLK at 100MHz (10ns) definition
add_force {CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# RESET
add_force {RESET} -radix hex {1 0ns} {0 10ns}
add_force {PUSH} -radix bin {0 0ns}
add_force {POP} -radix bin {0 0ns}
run 20ns

# PUSH with FIFO - Entry one dta
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
add_force {DIN} -radix hex {00 0ns}
run 10ns

# PUSH and POP at the same time with data in FIFO
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
add_force {POP} -radix bin {1 0ns} {0 10ns}
run 10ns

# PUSH with data - readout priority. 0x03 will be lost
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
add_force {DIN} -radix hex {01 0ns}
run 10ns
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
add_force {DIN} -radix hex {02 0ns}
run 10ns
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
add_force {DIN} -radix hex {03 0ns}
run 10ns
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
add_force {DIN} -radix hex {04 0ns}
run 10ns
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
add_force {DIN} -radix hex {05 0ns}
run 10ns
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
add_force {DIN} -radix hex {06 0ns}
run 10ns
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
add_force {DIN} -radix hex {07 0ns}
run 10ns

# PUSH and POP with FIFO full
add_force {POP} -radix bin {1 0ns} {0 10ns}
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
run 10ns

# POP with FIFO full
add_force {POP} -radix bin {1 0ns} {0 20ns}
run 20ns
# FIFO is empty
add_force {POP} -radix bin {1 0ns} {0 20ns}
run 50ns

# PUSH and POP at the same time with FIFO empty
add_force {PUSH} -radix bin {1 0ns} {0 10ns}
add_force {POP} -radix bin {1 0ns} {0 10ns}
run 50ns






