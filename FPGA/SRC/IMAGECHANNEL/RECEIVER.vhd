----------------------------------------------------------------------------------
-- Company: UMA. ETSI Telecomunicación
-- Engineer: Manuel Lorente Almán
-- 
-- Create Date: 16.07.2021
-- Design Name: VICON_FPGA
-- Module Name: RECEIVER - Behavioral
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

entity RECEIVER is
    Port ( CLK              : in STD_LOGIC;
           RESET            : in STD_LOGIC;
           PCLK             : in STD_LOGIC;
           FVAL             : in STD_LOGIC; 
           LVAL             : in STD_LOGIC; 
           FRAME_REQUEST    : in STD_LOGIC;
           FIFO_FULL        : in STD_LOGIC;
           FIFO_EMPTY       : in STD_LOGIC;
           DIN              : in STD_LOGIC_VECTOR(7 downto 0);
           RD_EN            : out STD_LOGIC;
           WR_EN            : out STD_LOGIC;
           FIFO_PUSH        : out STD_LOGIC;
           DOUT             : out STD_LOGIC_VECTOR(7 downto 0)
           );
end RECEIVER ;

architecture Behavioral of RECEIVER  is
----------------------------------------------------------------------
-- FSM to capture data
----------------------------------------------------------------------
type STATES is (off, idle, data, blanking, flush);
signal state_reg, state_next                    : STATES;
----------------------------------------------------------------------
-- Internal signals
----------------------------------------------------------------------
signal trigger_reg, trigger_next                : STD_LOGIC;
signal wr_en_reg, wr_en_next                    : STD_LOGIC;
signal rd_en_reg, rd_en_next                    : STD_LOGIC;
signal push_reg, push_next                      : STD_LOGIC;
signal dout_reg, dout_next                      : STD_LOGIC_VECTOR(7 downto 0);
----------------------------------------------------------------------
-- Tick signals to detect PCLK edges
----------------------------------------------------------------------
signal tick_rise_pclk                           : STD_LOGIC;
signal tick_fall_pclk                           : STD_LOGIC;  
----------------------------------------------------------------------
-- Signals to generate start of frame, end of frame, and data valid  
----------------------------------------------------------------------    
signal sof_signal                               : STD_LOGIC;
signal eof_signal                               : STD_LOGIC;
signal dval_signal                              : STD_LOGIC;
signal count                                    : STD_LOGIC;

begin
    ----------------------------------------------------------------------
    -- Connect output signals
    ----------------------------------------------------------------------
    FIFO_PUSH   <= push_reg;
    RD_EN       <= rd_en_reg;
    WR_EN       <= wr_en_reg;
    DOUT        <= dout_reg;

    ----------------------------------------------------------------------
    -- DVAL generator: 1 every two input pixel data (YUV422 format)
    ----------------------------------------------------------------------
    DVAL_GENERATOR: process
    begin
        wait until rising_edge(CLK);
        if RESET = '1' or sof_signal = '1' then
            dval_signal <= '0';
            count       <= '0';
        elsif tick_rise_pclk = '1' and trigger_reg = '1' and LVAL = '1' then
            dval_signal <= count;
            count       <= not count;
        else 
            dval_signal <= '0';
        end if;
    end process;

    ----------------------------------------------------------------------    
    -- Detect PCLK rising and falling edge
    ----------------------------------------------------------------------    
    EDGE_PCLK: entity work.EDGE_DETECT
      port map (
       CLK          => CLK,
       LEVEL        => PCLK,
       TICK_RISE    => tick_rise_pclk,
       TICK_FALL    => tick_fall_pclk
      );

    ----------------------------------------------------------------------    
    -- Detect FVAL rising and falling edge to indicate start and end of frame
    ----------------------------------------------------------------------    
    EDGE_FVAL: entity work.EDGE_DETECT
      port map (
       CLK          => CLK,
       LEVEL        => FVAL,
       TICK_RISE    => sof_signal,
       TICK_FALL    => eof_signal
      );
    
    ----------------------------------------------------------------------                                  
    -- Sequential proccess to register signals
    ----------------------------------------------------------------------
    REG: process(CLK, RESET, FIFO_FULL)
    begin
        if RESET = '1' or FIFO_FULL = '1' then
            state_reg           <= off;
            push_reg            <= '0';
            rd_en_reg           <= '0';
            wr_en_reg           <= '0';
			trigger_reg			<= '0';
            dout_reg            <= (others=>'0');        
        elsif rising_edge(CLK) then
            state_reg           <= state_next;
            push_reg            <= push_next;
            rd_en_reg           <= rd_en_next;
            wr_en_reg           <= wr_en_next;
			trigger_reg			<= trigger_next;			
            dout_reg            <= dout_next;            
        end if;
    end process;
    
    ----------------------------------------------------------------------
    -- Combinational logic
    ----------------------------------------------------------------------
    FSM: process (state_reg, FRAME_REQUEST, LVAL, sof_signal, eof_signal, dval_signal, FIFO_FULL, FIFO_EMPTY)
        begin
            case state_reg is
                when idle =>             
                    push_next           <= '0';
                    rd_en_next          <= '1';
                    wr_en_next          <= '0';
					trigger_next		<= '0';
                    dout_next           <= (others => '0');                                                          
                    if sof_signal = '1' then
                        state_next <= blanking;
                    else
                        state_next <= idle;
                    end if;
                when blanking =>           
                    push_next           <= '0';
                    rd_en_next          <= '0';
                    wr_en_next          <= not FIFO_EMPTY;
					trigger_next		<= '1';
                    dout_next           <= (others => '0'); 
                    if eof_signal = '1' then
                        if FIFO_EMPTY = '1' then
                            state_next <= off;
                        else
                            state_next <= flush;
                        end if;
                    elsif LVAL = '0' then
                        state_next <= blanking;
                    else
                        state_next <= data;
                    end if;
                when data =>              
                    push_next           <= dval_signal;
                    rd_en_next          <= '0';
                    wr_en_next          <= not FIFO_EMPTY;
					trigger_next		<= '1';
                    dout_next           <= DIN;  
                    if LVAL = '0' then
                        state_next <= blanking;
                    else
                        state_next <= data;
                    end if; 
                when flush =>              
                    push_next           <= '0';
                    rd_en_next          <= '0';
                    wr_en_next          <= not FIFO_EMPTY;
                    trigger_next        <= '0';
                    dout_next           <= DIN;  
                    if FIFO_EMPTY = '1' then
                        state_next <= off;
                    else
                        state_next <= flush;
                    end if;                     
                when others =>             
                    push_next           <= '0';
                    rd_en_next          <= '1';
                    wr_en_next          <= '0';
					trigger_next		<= '0';
                    dout_next           <= (others => '0');                                                          
                    if FRAME_REQUEST = '1' then
                        state_next <= idle;
                    else
                        state_next <= off;
                    end if;
             end case;
    end process; 
    
end Behavioral;
