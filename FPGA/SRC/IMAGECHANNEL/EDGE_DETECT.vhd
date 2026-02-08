----------------------------------------------------------------------------------
-- Company: UMA. ETSI Telecomunicación
-- Engineer: Manuel Lorente Almán
-- 
-- Create Date: 16.07.2021
-- Design Name: VICON_FPGA
-- Module Name: EDGE_DETECT - Behavioral
-- Project Name: VICON
-- Target Devices: BASYS 3
-- Target Devices: BASYS 3
-- Tool Versions: Vivado v2018.1 (64-bit)
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EDGE_DETECT is
    Port (
            CLK         : in  STD_LOGIC;
            LEVEL       : in  STD_LOGIC;
            TICK_RISE   : out STD_LOGIC;
            TICK_FALL   : out STD_LOGIC
         );
end EDGE_DETECT;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

architecture Behavioral of EDGE_DETECT is
----------------------------------------------------------------------
-- FSM to capture data
----------------------------------------------------------------------
type STATES is (zero, one);
signal state_reg, state_next            : STATES;
----------------------------------------------------------------------
-- Status logic internal signals
----------------------------------------------------------------------
signal tick_rise_signal                 : STD_LOGIC;
signal tick_fall_signal                 : STD_LOGIC;

begin
    ----------------------------------------------------------------------
    -- Connect output signals
    ----------------------------------------------------------------------
    TICK_RISE   <= tick_rise_signal;
    TICK_FALL   <= tick_fall_signal;
    
    ----------------------------------------------------------------------
    -- Sequential proccess to register signals
    ----------------------------------------------------------------------
    REG: process
    begin          
        wait until rising_edge(CLK);
        state_reg  <= state_next;
    end process;
    
    ----------------------------------------------------------------------
    -- Combinational logic
    ----------------------------------------------------------------------    
    FSM: process (state_reg, LEVEL)
        begin
            case state_reg is
                when one =>
                    if LEVEL = '0' and state_reg = one then
                        state_next          <= zero;
                        tick_rise_signal    <= '0';
                        tick_fall_signal    <= '1';
                    else 
                        tick_rise_signal    <= '0';
                        tick_fall_signal    <= '0';
                        state_next          <= one;
                    end if;
                when others =>
                    if LEVEL = '1' and state_reg = zero then
                        state_next          <= one;
                        tick_rise_signal    <= '1';
                        tick_fall_signal    <= '0';
                    else
                        tick_rise_signal    <= '0';
                        tick_fall_signal    <= '0';
                        state_next          <= zero;
                    end if;
             end case;
    end process; 

end Behavioral;


