----------------------------------------------------------------------------------
-- Company: UMA. ETSI Telecomunicación
-- Engineer: Manuel Lorente Almán
-- 
-- Create Date: 16.07.2021
-- Design Name: VICON_FPGA
-- Module Name: TOP - Behavioral
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

entity TOP is
    Port (
        CLK     : in STD_LOGIC;
        RESET   : in STD_LOGIC;
        RXFn    : in STD_LOGIC;
        TXEn    : in STD_LOGIC;
        MODE    : in STD_LOGIC_VECTOR (1 downto 0);   
        PCLK    : in STD_LOGIC;
        FVAL    : in STD_LOGIC;
        LVAL    : in STD_LOGIC;
        DCAMERA : in STD_LOGIC_VECTOR(7 downto 0);    
        XCLK    : out STD_LOGIC;
        PWDn    : out STD_LOGIC;
        RESETn  : out STD_LOGIC;
        LED     : out STD_LOGIC_VECTOR (2 downto 0);
        WRn     : out STD_LOGIC;
        RDn     : out STD_LOGIC;
        SIWUn   : out STD_LOGIC;
        PWRSVn  : out STD_LOGIC;        
        DATA    : inout STD_LOGIC_VECTOR(7 downto 0)
    );
end TOP;

architecture Behavioral of TOP is
----------------------------------------------------------------------
-- ICHI signals (B -> FIFO address bus width 16     W-> FIFO data bus width 8)
----------------------------------------------------------------------
constant B                          : NATURAL := 16;
constant W                          : NATURAL := 8;
signal image_channel_data           : STD_LOGIC_VECTOR(7 downto 0);
signal data_output                  : STD_LOGIC_VECTOR(7 downto 0);
----------------------------------------------------------------------
-- CGU signals
----------------------------------------------------------------------
signal mclk_signal                  : STD_LOGIC;
signal xclk_signal                  : STD_LOGIC;
----------------------------------------------------------------------
-- FTDI comm signals
----------------------------------------------------------------------
signal ready_signal                 : STD_LOGIC;
signal request_signal               : STD_LOGIC;
signal wr_en_signal                 : STD_LOGIC;
signal rd_en_signal                 : STD_LOGIC;
signal wrn_signal                   : STD_LOGIC;
signal rdn_signal                   : STD_LOGIC;
signal fifo_pop_signal              : STD_LOGIC;

begin 
    ----------------------------------------------------------------------
    -- Connect output signals
    ----------------------------------------------------------------------
    PWDn            <= RESET;
    RESETn          <= not(RESET);
    RDn             <= rdn_signal;
    WRn             <= wrn_signal;
    XCLK            <= xclk_signal;
    DATA            <= data_output;
    
    ----------------------------------------------------------------------
    -- Test image configuration
    -- SW[0]    - LED[0]    - MODE[0]       0: vertical ramp        1: horizontal ramp    
    -- Mux for IMAGE CHANNEL output
    -- SW[1]    - LED[1]   - MODE[1]        0: Image sensor         1: Test image
    ----------------------------------------------------------------------
    LED(1 downto 0) <= MODE(1 downto 0);
    LED(2)          <= RESET;
    
    ----------------------------------------------------------------------
    -- CGU Generates 100MHz and 25MHz clocking
    ----------------------------------------------------------------------
    CLOCKING: entity work.CGU
        PORT MAP(
            -- Inputs
            CLK     => CLK,
            RESET   => RESET,
            -- Outputs
            MCLK    => mclk_signal,
            XCLK    => xclk_signal
        );

    ----------------------------------------------------------------------
    -- FT245 channel (FIFO Async mode)
    ----------------------------------------------------------------------       
    FT245: entity work.FT245_CHANNEL
            PORT MAP(
                -- Inputs
                CLK         => mclk_signal,
                RESET       => RESET,
                RXFn        => RXFn,
                TXEn        => TXEn,
                WR_ENA      => wr_en_signal,
                RD_ENA      => rd_en_signal,
                DIN         => image_channel_data,
                -- Outputs
                WRn         => wrn_signal,
                RDn         => rdn_signal,
                READY       => ready_signal,
                REQUEST     => request_signal,
                POP         => fifo_pop_signal,
                SIWUn       => SIWUn,
                PWRSVn      => PWRSVn,
                -- Input/output
                DATA        => data_output
            );

    ----------------------------------------------------------------------        
    -- Image channel  
    ----------------------------------------------------------------------  
    ICHI: entity work.IMAGE_CHANNEL
        GENERIC MAP (
            B => B,
            W => W
        )
        PORT MAP (
            -- Inputs
            CLK         => mclk_signal,
            XCLK        => xclk_signal,       
            RESET       => RESET,
            PAT_ENA     => MODE(1),
            PAT_MODE    => MODE(0),
            PCLK        => PCLK,
            FVAL        => FVAL,
            LVAL        => LVAL,
            REQUEST     => request_signal,
            FIFO_POP    => fifo_pop_signal,
            DIN         => DCAMERA,
            -- Outputs
            READ_USB    => rd_en_signal,
            WRITE_USB   => wr_en_signal,
            DOUT        => image_channel_data
        );
    
end Behavioral;
