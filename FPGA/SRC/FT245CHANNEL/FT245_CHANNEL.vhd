----------------------------------------------------------------------------------
-- Company: UMA. ETSI Telecomunicación
-- Engineer: Manuel Lorente Almán
-- 
-- Create Date: 14.09.2021
-- Design Name: VICON_FPGA
-- Module Name: FT245_CHANNEL - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity FT245_CHANNEL is
    Port (
        CLK         : in STD_LOGIC;
        RESET       : in STD_LOGIC;
        RXFn        : in STD_LOGIC;
        TXEn        : in STD_LOGIC;
        WR_ENA      : in STD_LOGIC;
        RD_ENA      : in STD_LOGIC;
        DIN         : in STD_LOGIC_VECTOR(7 downto 0);
        WRn         : out STD_LOGIC;
        RDn         : out STD_LOGIC;
        POP         : out STD_LOGIC;
        READY       : out STD_LOGIC;
        REQUEST     : out STD_LOGIC;
        SIWUn       : out STD_LOGIC;
        PWRSVn      : out STD_LOGIC;
        DATA        : inout STD_LOGIC_VECTOR(7 downto 0)
    );
end FT245_CHANNEL;

architecture Behavioral of FT245_CHANNEL is
----------------------------------------------------------------------
-- FPGA input data internal signal
----------------------------------------------------------------------
signal dummy_byte                   : STD_LOGIC_VECTOR(7 downto 0);

begin
    
    ----------------------------------------------------------------------
    -- Map fixed outputs
    ----------------------------------------------------------------------
    SIWUn       <= '1';
    PWRSVn      <= '1';

    ----------------------------------------------------------------------    
    -- FPGA --> FT245 --> PC
    ----------------------------------------------------------------------
    IFWRITE: entity work.FT245_IF_WRITE 
          PORT MAP (
              -- Inputs 
              CLK       => CLK,
              RESET     => RESET,
              ENABLE    => WR_ENA,
              TXEN      => TXEn,
              DIN       => DIN,
              -- Outputs 
              READY     => READY,
              WRn       => WRn,
              POP       => POP,
              DOUT      => DATA
          );

    ----------------------------------------------------------------------      
    -- PC --> FT245 --> FPGA 
    ----------------------------------------------------------------------
    IFREAD: entity work.FT245_IF_READ
        PORT MAP (
            -- Inputs 
            CLK         => CLK,
            RESET       => RESET, 
            ENABLE      => RD_ENA,
            RXFn        => RXFn,
            DIN         => DATA,
            -- Outputs
            RDn         => RDn,
            REQUEST     => REQUEST,
            DOUT        => dummy_byte
        );
    
end Behavioral;
