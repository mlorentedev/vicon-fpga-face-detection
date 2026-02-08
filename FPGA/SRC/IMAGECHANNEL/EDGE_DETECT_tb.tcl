###################################################################################
##  TFM VICON
##  Simulation script
##  Engineer: Manuel Lorente Alman
##  Example: source -notrace {D:/TFM/3-Development/FPGA/SRC/IMAGECHANNEL/EDGE_DETECT_tb.tcl}
###################################################################################

# Restart simulation
restart
# Rename signals
add_wave {CLK}
add_wave {LEVEL}
add_wave {TICK_RISE}
add_wave {TICK_FALL}
add_wave {state_reg}


# CLK at 100MHz (10ns) definition
add_force {CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# PUSH and POP at the same time with FIFO empty
add_force {LEVEL} -radix bin {0 0ns} {1 50ns} {0 150ns} {1 200ns} {0 250ns}
run 300ns






