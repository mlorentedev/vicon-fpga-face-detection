----------------------------------------------------------------------------------
-- Company: UMA. ETSI Telecomunicación
-- Engineer: Manuel Lorente Almán
-- 
-- Create Date: 11.09.2021
-- Design Name: VICON_FPGA
-- Module Name: IMAGE_CHANNEL - Behavioral
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

entity IMAGE_CHANNEL is
    Generic (
            -- Internal RAM address bus width
            B: NATURAL range 1 to 63 := 16;
            -- DIN y DOUT data bus width
            W: NATURAL range 1 to 16 := 8 );
    Port (
            CLK         : in STD_LOGIC;
            XCLK        : in STD_LOGIC;    
            RESET       : in STD_LOGIC;
            PAT_ENA     : in STD_LOGIC;
            PAT_MODE    : in STD_LOGIC;
            PCLK        : in STD_LOGIC;
            FVAL        : in STD_LOGIC;
            LVAL        : in STD_LOGIC;
            REQUEST     : in STD_LOGIC;
            FIFO_POP    : in STD_LOGIC;
            DIN         : in STD_LOGIC_VECTOR(7 downto 0);
            READ_USB    : out STD_LOGIC;
            WRITE_USB   : out STD_LOGIC;
            DOUT        : out STD_LOGIC_VECTOR(7 downto 0)
    );
end IMAGE_CHANNEL;

architecture Behavioral of IMAGE_CHANNEL is
----------------------------------------------------------------------
-- Image sensor signals
----------------------------------------------------------------------
signal din_signal                   : STD_LOGIC_VECTOR(7 downto 0);
signal fval_signal                  : STD_LOGIC;
signal lval_signal                  : STD_LOGIC;
signal pclk_signal                  : STD_LOGIC;
----------------------------------------------------------------------
-- Image pattern signals
----------------------------------------------------------------------
signal pat_data_signal              : STD_LOGIC_VECTOR(7 downto 0);
signal pat_fval_signal              : STD_LOGIC;
signal pat_lval_signal              : STD_LOGIC;
signal pat_pclk_signal              : STD_LOGIC;
----------------------------------------------------------------------
-- FIFO signals
----------------------------------------------------------------------
signal fifo_data_in                 : STD_LOGIC_VECTOR(7 downto 0);
signal pop_signal, push_signal      : STD_LOGIC;
signal full_signal, empty_signal    : STD_LOGIC; 
----------------------------------------------------------------------
-- Internal signals
----------------------------------------------------------------------
signal dval_signal                  : STD_LOGIC;
signal eof_signal, sof_signal       : STD_LOGIC;

begin
    ----------------------------------------------------------------------
    -- Mux to address inputs: Data from sensor or image pattern
    ----------------------------------------------------------------------
    pclk_signal     <= PCLK when (PAT_ENA = '0') else pat_pclk_signal;
    fval_signal     <= FVAL when (PAT_ENA = '0') else pat_fval_signal;
    lval_signal     <= LVAL when (PAT_ENA = '0') else pat_lval_signal;
    din_signal      <= DIN when (PAT_ENA = '0') else pat_data_signal;

    ----------------------------------------------------------------------
    -- IMAGE PATTERN block to emulate sensor behavior
    ----------------------------------------------------------------------
    PATTERN: entity work.IMAGE_PATTERN
        PORT MAP(
            -- Inputs
            XCLK        => XCLK,
            RESET       => RESET,
            RAMP        => PAT_MODE,
            -- Outputs
            PCLK        => pat_pclk_signal,
            FVAL        => pat_fval_signal,
            LVAL        => pat_lval_signal,
            DOUT        => pat_data_signal
        );

    ----------------------------------------------------------------------
    -- RECEIVER block to order pixel data into FIFO memory
    ----------------------------------------------------------------------
    RECEIVER: entity work.RECEIVER
        PORT MAP( 
            -- Inputs 
            CLK             => CLK,
            RESET           => RESET,
            PCLK            => pclk_signal,
            FVAL            => fval_signal,
            LVAL            => lval_signal,
            FRAME_REQUEST   => REQUEST,
            FIFO_FULL       => full_signal,
            FIFO_EMPTY      => empty_signal,
            DIN             => din_signal,
            -- Outputs
            RD_EN           => READ_USB,
            WR_EN           => WRITE_USB,
            FIFO_PUSH       => push_signal,        
            DOUT            => fifo_data_in
           );

    ----------------------------------------------------------------------       
    -- FIFO to adjust bandwidth
    ----------------------------------------------------------------------
    FIFO: entity work.FIFO 
          GENERIC MAP (
              B => B,
              W => W
          )
          PORT MAP (
              -- Inputs 
              CLK   => CLK,
              RESET => RESET,
              DIN   => fifo_data_in,
              PUSH  => push_signal,          
              POP   => FIFO_POP,
              -- Outputs
              FULL  => full_signal,
              EMPTY => empty_signal,
              DOUT  => DOUT
          );

end Behavioral;
