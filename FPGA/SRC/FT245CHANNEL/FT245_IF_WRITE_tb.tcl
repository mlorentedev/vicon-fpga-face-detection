###################################################################################
##  TFM VICON
##  Simulation script
##  Engineer: Manuel Lorente Alman
##  Example: source -notrace {D:/TFM/3-Development/FPGA/SRC/FT245CHANNEL/FT245_IF_WRITE_tb.tcl}
###################################################################################

# Restart simulation
restart

# Input signals
add_wave {CLK}
add_wave {RESET}
add_wave {ENABLE}
add_wave {DIN}
add_wave {TXEn}
# Internal signals
add_wave {state_reg}
# Output signals
add_wave {WRn}
add_wave {READY}
add_wave {POP}
add_wave {DOUT}

# CLK at 100MHz (10ns) definition
add_force {CLK} -radix bin {0 0ns} {1 5ns} -repeat_every 10ns

# Init signals value
add_force {DIN} -radix hex  {00 0ns}
add_force {RESET} -radix hex {1 0ns} {0 10ns} 
add_force {ENABLE} -radix bin {0 0ns} {1 10ns}
add_force {TXEn} -radix bin {1 0ns}
run 50ns

# Send data at max speed
# Data write timing:    DIN (t11=0)     0 (t8+t9=5+5=10)
# WREN timing:          0   (t8=5)      1   (t10=30)    0        
# TXEN timing:          0   (t11=0)     1   (t6=14)     0 (t7=49) 
add_force {DIN} -radix hex  {BB 0ns}
run 100ns
add_force {DIN} -radix hex  {5A 0ns} {1C 50ns} {53 100ns} {34 150ns} {CA 200ns} {1B 250ns}
add_force {TXEN} -radix bin {0 0ns} {1 40ns}            -repeat_every 50ns
run 300ns

# Send data at system speed
# Data write timing:    DIN (t11=0)     0 (t8+t9=5+5=10)
# WREN timing:          0   (t8=5)      1   (t10=30)    0        
# TXEN timing:          0   (t11=0)     1   (t6=14)     0 (t7=49) 
add_force {DIN} -radix hex  {5A 0ns} {1C 100ns} {53 200ns} {34 300ns} {CA 400ns} {1B 500ns}
add_force {TXEN} -radix bin {0 0ns} {1 10ns}            -repeat_every 100ns
run 600ns

# End of communication
add_force {ENABLE} -radix bin {0 0ns}
run 50ns








