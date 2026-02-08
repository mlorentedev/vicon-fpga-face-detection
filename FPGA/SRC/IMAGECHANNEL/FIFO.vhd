----------------------------------------------------------------------------------
-- Company: UMA. ETSI Telecomunicación
-- Engineer: Manuel Lorente Almán
-- 
-- Create Date: 16.07.2021
-- Design Name: VICON_FPGA
-- Module Name: FIFO - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FIFO is
    Generic (
            -- Internal RAM address bus width
            B: NATURAL range 1 to 63 := 16;
            -- DIN y DOUT data bus width
            W: NATURAL range 1 to 16 := 8 );
    Port ( 
            CLK      : in STD_LOGIC;
            RESET    : in STD_LOGIC;
            PUSH     : in STD_LOGIC;
            POP      : in STD_LOGIC;
            DIN      : in STD_LOGIC_VECTOR (W-1 downto 0);           
            FULL     : out STD_LOGIC;
            EMPTY    : out STD_LOGIC;
            DOUT     : out STD_LOGIC_VECTOR (W-1 downto 0)
          );
end FIFO;

architecture Behavioral of FIFO is
----------------------------------------------------------------------
-- RAM memory component internal signals
----------------------------------------------------------------------
type memory is array((2**B)-1 downto 0) of STD_LOGIC_VECTOR(W-1 DOWNTO 0);  -- RAM memory data type
signal ram          :   memory;	                                            -- RAM memory instance
signal rptr         :   INTEGER range 0 to (2**B)-1 := 0;  	                -- RAM read address pointer
signal wptr         :   INTEGER range 0 to (2**B)-1 := 0;  	                -- RAM write address pointer
signal wr_en        :   STD_LOGIC;                                          -- RAM memory write enable
signal rd_en        :   STD_LOGIC;                                          -- RAM memory read enable
----------------------------------------------------------------------    
-- Control logic internal signals
----------------------------------------------------------------------
signal fifo_full    :   STD_LOGIC;                                          -- FIFO full flag
signal fifo_empty   :   STD_LOGIC;                                          -- FIFO empty flag
----------------------------------------------------------------------
-- Status logic internal signals
----------------------------------------------------------------------
signal words        :   INTEGER range 0 to (2**B) := 0;                     -- Number of housed words
 
begin
    ----------------------------------------------------------------------
    -- Connect output signals
    ----------------------------------------------------------------------
    FULL <= fifo_full;
    EMPTY <= fifo_empty;   

    ----------------------------------------------------------------------
    -- RAM memory block
    ----------------------------------------------------------------------
	LUTRAM:process
    begin
        wait until rising_edge(CLK);
        -- Write port at 1xTclk
        if (wr_en = '1') then ram(wptr) <= DIN; end if; 
        -- Read port at 1xTclk
        DOUT <= ram(rptr);
    end process;
    
    ----------------------------------------------------------------------
    -- Read/write enable control
    ----------------------------------------------------------------------    
    wr_en <= PUSH and not fifo_full;  
    rd_en <= POP and not fifo_empty;

    ----------------------------------------------------------------------
    -- Control logic block
    ----------------------------------------------------------------------      
    CONTROL:process
    begin
        wait until rising_edge(CLK);
        -- Synchronous reset
        if (RESET = '1') then
            rptr <= 0;
            wptr <= 0;
        else
            -- Write/read pointers update 
            if rd_en ='1' then rptr <= rptr + 1; end if;
            if wr_en ='1' then wptr <= wptr + 1; end if;           
            -- Close circular buffer
            if rptr = (2**B)-1 then rptr <= 0; end if;
            if wptr = (2**B)-1 then wptr <= 0; end if;
         end if;       
    end process;

    ---------------------------------------------------------------------- 
     -- FIFO status update pending on number of stored words
    ----------------------------------------------------------------------     
    fifo_empty 	<= '1' when (words = 0) else '0';  
    fifo_full 	<= '1' when (words = (2**B)) else '0';
            
    ----------------------------------------------------------------------
    -- Logic state block
    ----------------------------------------------------------------------
    STATUS:process
    begin
        wait until rising_edge(CLK);
        -- Synchronous reset
        if (RESET = '1') then
            words <= 0;
        else
            -- UP/DOWN counter
            if (wr_en = '1') and (rd_en = '0') then
                words <= words + 1;
            elsif (rd_en = '1') and (wr_en = '0') then
                words <= words - 1;        
            else
                words <= words;
            end if;
        end if;
    end process;
    
end Behavioral;
