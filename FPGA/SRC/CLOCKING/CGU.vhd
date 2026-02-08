----------------------------------------------------------------------------------
-- Company: UMA. ETSI Telecomunicación
-- Engineer: Manuel Lorente Almán
-- 
-- Create Date: 16.07.2021
-- Design Name: VICON_FPGA
-- Module Name: CGU - Behavioral
-- Project Name: VICON
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity CGU is
    Port ( 
            RESET   : in STD_LOGIC;
            CLK     : in STD_LOGIC;     -- 100MHz system clock
            XCLK    : out STD_LOGIC;    -- 25MHz pixel clock CLK/4
            MCLK    : out STD_LOGIC     -- 100MHz master clock CLK
    );
end CGU;

architecture Behavioral of CGU is
----------------------------------------------------------------------
-- Internal signals
----------------------------------------------------------------------
signal count        : STD_LOGIC;
signal xclk_signal  : STD_LOGIC;

begin
    ----------------------------------------------------------------------
    -- Connect output signals
    ----------------------------------------------------------------------
    XCLK <= xclk_signal;
    MCLK <= CLK;
    
    ----------------------------------------------------------------------
    -- xclk_signal changes every 2 cycles to divide by 4 the input signal frequency
    ----------------------------------------------------------------------
    ONEBITCOUNTER: process
    begin
        wait until rising_edge(CLK);
            if RESET = '1' then
                count <= '0';
                xclk_signal <= '0';
            elsif count = '0' then
                count <= not count;
                xclk_signal <= not xclk_signal;
            else
                count <= not count;
            end if;
    end process;

end Behavioral;
