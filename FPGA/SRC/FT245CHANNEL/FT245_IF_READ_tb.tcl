###################################################################################
##  TFM VICON
##  Simulation script
##  Engineer: Manuel Lorente Alman
##  Example: source -notrace {D:/TFM/3-Development/FPGA/SRC/FT245CHANNEL/FT245_IF_READ_tb.tcl}
###################################################################################

# Restart simulation
restart

# Input signals
add_wave {CLK}
add_wave {RESET}
add_wave {ENABLE}
add_wave {DIN}
add_wave {RXFn}
# Internal signals
add_wave {state_reg}
# Output signals
add_wave {RDn}
add_wave {REQUEST}
add_wave {DOUT}

# CLK at 100MHz (10ns) definition
add_force {CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Init signals value
add_force {DIN} -radix hex {00 0ns}
add_force {RESET} -radix hex {1 0ns} {0 10ns} 
add_force {ENABLE} -radix bin {0 0ns} {1 10ns}
add_force {RXFn} -radix bin {1 0ns}
run 50ns

# Data read timing:    DIN (t3+t3=15+15=30ns)
# RXFn timing:          0   (t11=0)     1 (t1=14)   0 (t2=49)   
add_force {DIN} -radix hex {BB 0ns}
run 1us
add_force {DIN} -radix hex {5A 0ns} {1C 1us}
add_force {RXFn} -radix bin {0 0ns} {1 50ns}
run 2us

# End of communication
add_force {ENABLE} -radix bin {0 0ns}
run 50ns








