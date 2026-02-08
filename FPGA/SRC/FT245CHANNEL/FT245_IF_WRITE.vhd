----------------------------------------------------------------------------------
-- Company: UMA. ETSI Telecomunicación
-- Engineer: Manuel Lorente Almán
-- 
-- Create Date: 16.07.2021
-- Design Name: VICON_FPGA
-- Module Name: FT245_IF_WRITE - Behavioral
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

entity FT245_IF_WRITE is
    Generic(
            NCYCLES: NATURAL range 1 to 8 := 7
    );
    Port ( 
            -- Inputs 
            CLK      : in STD_LOGIC;
            RESET    : in STD_LOGIC;
            ENABLE   : in STD_LOGIC;
            TXEn     : in STD_LOGIC;
            DIN      : in STD_LOGIC_VECTOR (7 downto 0);
            -- Outputs 
            READY    : out STD_LOGIC;
            WRn      : out STD_LOGIC;
            POP      : out STD_LOGIC;
            DOUT     : out STD_LOGIC_VECTOR (7 downto 0)
        );
end FT245_IF_WRITE;
  
architecture Behavioral of FT245_IF_WRITE is
--------------------------------------------------------------------------------------------
--  States definition for FSM
--------------------------------------------------------------------------------------------                                        
type STATES is (off, idle, tx_data);
-------------------------------------------------------------------------------------------
--  Internal signals to handle outputs, synchronize inputs, and control FSM
--------------------------------------------------------------------------------------------                                        
signal state_reg, state_next    : STATES;
signal ready_reg, ready_next    : STD_LOGIC;
signal txen_sync                : STD_LOGIC;
signal aux_sync                	: STD_LOGIC;
signal pop_reg, pop_next        : STD_LOGIC;
signal wrn_reg, wrn_next        : STD_LOGIC;
signal dout_reg, dout_next      : STD_LOGIC_VECTOR(7 downto 0);
signal wait_counter             : STD_LOGIC_VECTOR(NCYCLES-1 downto 0);

begin 
    --------------------------------------------------------------------------------------------
    --  Output logic
    --------------------------------------------------------------------------------------------                                        
    WRn     <= wrn_reg;
    READY   <= ready_reg;
    POP     <= pop_reg;
    DOUT    <= dout_reg;

    --------------------------------------------------------------------------------------------
    --  2FF Input synchronization for asynchronous external signals 
    --------------------------------------------------------------------------------------------                                            
    SYNC: process
    begin
        wait until rising_edge(CLK);
		if RESET = '1' then
			txen_sync       <= '1';
			aux_sync		<= '1';
		else
			txen_sync       <= aux_sync;
			aux_sync		<= TXEn;
		end if;
    end process SYNC;
        
    --------------------------------------------------------------------------------------------
    --  Sequential proccess to register signals
    --------------------------------------------------------------------------------------------                                        
    REG: process(CLK, RESET)
    begin
        if RESET = '1' then
           state_reg            <= off;
           wrn_reg              <= '1';
           pop_reg              <= '0';
           ready_reg            <= '1';
           dout_reg             <= (others => '0');
           wait_counter         <= (others => '0');
        elsif rising_edge(CLK) then
           state_reg            <= state_next;
           wrn_reg              <= wrn_next;
           pop_reg              <= pop_next;
           ready_reg            <= ready_next;
           dout_reg             <= dout_next;
           if wrn_next = '0' then
                wait_counter    <= wait_counter + 1;
           else
                wait_counter    <= (others => '0');          
           end if;
        end if;
    end process REG;
    
    --------------------------------------------------------------------------------------------
    --  Combinational process for internal signals logic
    --------------------------------------------------------------------------------------------                                        
    COMB: process(state_reg, dout_reg, txen_sync, wait_counter, DIN, ENABLE)
    begin
        -- To prevent latches
        state_next <= state_reg;  
        case state_reg is
            when idle => 
                if ENABLE = '0' then
                    wrn_next        <= '1';
                    pop_next        <= '0';
                    ready_next      <= '0';
                    dout_next       <= dout_reg; 
                    state_next      <= off; 
                else                    
                    if txen_sync = '0' then
                        wrn_next        <= '1';
                        pop_next        <= '1';
                        ready_next      <= '0';
                        dout_next       <= DIN;
                        state_next      <= tx_data;
                    else
                        wrn_next        <= '1';
                        pop_next        <= '0';
                        ready_next      <= '0';
                        dout_next       <= dout_reg; 
                        state_next      <= idle;                        
                    end if; 
                end if;
            when tx_data =>  
                if wait_counter = 1 then
                    wrn_next        <= '0';
                    pop_next        <= '0';
                    ready_next      <= '0';
                    dout_next       <= dout_reg;     
                    state_next      <= tx_data;                
                elsif wait_counter = NCYCLES then
                    wrn_next        <= '1';
                    pop_next        <= '0';
                    ready_next      <= '0';
                    dout_next       <= dout_reg; 
                    state_next      <= idle;
                else
                    wrn_next        <= '0';
                    pop_next        <= '0';
                    ready_next      <= '0';
                    dout_next       <= dout_reg;     
                    state_next      <= tx_data;
                end if;  
            when others =>
                wrn_next            <= '1';
                pop_next            <= '0';
                ready_next          <= '1';
                dout_next           <= (others => '0');   
                if ENABLE = '1' then
                    state_next      <= idle; 
                else
                    state_next      <= off; 
                end if;              
        end case; 
    end process COMB;
   
end Behavioral;
