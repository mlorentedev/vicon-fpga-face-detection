###################################################################################
##  TFM VICON
##  Simulation script
##  Engineer: Manuel Lorente Alman
##  Example: source -notrace {D:/TFM/3-Development/FPGA/SRC/IMAGECHANNEL/IMAGE_PATTERN_tb.tcl}
###################################################################################

# Restart simulation
restart

# Input signals
add_wave {XCLK}
add_wave {PCLK}
add_wave {RESET}
add_wave {RAMP}
# Internal signals
add_wave {count_line}
add_wave {count_pixel}
add_wave {state_reg}
add_wave {dout_vramp_reg}
add_wave {dout_hramp_reg}
# Output signals
add_wave {FVAL}
add_wave {LVAL}
add_wave {DOUT}

# XCLK at 25MHz (40ns) definition
add_force {XCLK} -radix bin {0 0ns} {1 20ns} -repeat_every 40ns

# Add inputs
add_force {RESET} -radix hex {1 0ns} {0 1000ns}
add_force {RAMP} -radix hex {0 0ns}
run 1us

# Emulate vertical ramp (1 frame)
add_force {RAMP} -radix hex {0 0ns}
run 38ms

# Emulate horizontal ramp (1 frame)
add_force {RAMP} -radix hex {1 0ns}
run 38ms




