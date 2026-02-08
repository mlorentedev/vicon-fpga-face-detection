###################################################################################
##  TFM VICON
##  Simulation script
##  Engineer: Manuel Lorente Alman
##  Example: source -notrace {D:/TFM/3-Development/FPGA/SRC/CLOCKING/CGU_tb.tcl}
###################################################################################

# Restart simulation
restart

# Input signals
add_wave {CLK}
add_wave {RESET}
# Output signals signals
add_wave {XCLK}
add_wave {MCLK}

# CLK at 100MHz (10ns) definition
add_force {CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Init signals value
add_force {RESET} -radix hex {1 0ns} {0 10ns}
run 200ns
