----------------------------------------------------------------------------------
-- Company: UMA. ETSI Telecomunicación
-- Engineer: Manuel Lorente Almán
-- 
-- Create Date: 16.07.2021
-- Design Name: VICON_FPGA
-- Module Name: FT245_IF_READ - Behavioral
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

entity FT245_IF_READ is
    Generic(
			NCYCLES: NATURAL range 1 to 7 := 6
    );
    Port (
            -- Inputs 
            CLK      : in STD_LOGIC;
            RESET    : in STD_LOGIC;
            ENABLE   : in STD_LOGIC;
            RXFn     : in STD_LOGIC;
            DIN      : in STD_LOGIC_VECTOR (7 downto 0);
            -- Outputs
            RDn      : out STD_LOGIC;
            REQUEST  : out STD_LOGIC;
            DOUT     : out STD_LOGIC_VECTOR (7 downto 0));
end FT245_IF_READ;

architecture Behavioral of FT245_IF_READ is
--------------------------------------------------------------------------------------------
--  States definition for FSM
--------------------------------------------------------------------------------------------                                        
type STATUS is (off, idle, rx_data); 
-------------------------------------------------------------------------------------------
--  Internal signals to handle outputs, synchronize inputs, and control FSM
--------------------------------------------------------------------------------------------                                        
signal state_reg, state_next        : STATUS;
signal rxfn_sync                    : STD_LOGIC;
signal aux_sync                    : STD_LOGIC;
signal rdn_reg, rdn_next            : STD_LOGIC;
signal request_reg, request_next    : STD_LOGIC;
signal dout_reg, dout_next          : STD_LOGIC_VECTOR(7 downto 0);
signal wait_counter                 : STD_LOGIC_VECTOR(NCYCLES-1 downto 0);
begin 
    --------------------------------------------------------------------------------------------
    --  Output logic
    --------------------------------------------------------------------------------------------                                        
    RDn     <= rdn_reg;
    REQUEST <= request_reg;
    DOUT    <= dout_reg;

    --------------------------------------------------------------------------------------------
    --  2FF Input synchronization for asynchronous external signals 
    --------------------------------------------------------------------------------------------                                            
    SYNC: process
    begin
        wait until rising_edge(CLK);
		if RESET = '1' then
			rxfn_sync       <= '1';
			aux_sync		<= '1';
		else
			rxfn_sync       <= aux_sync;
			aux_sync		<= RXFn;
		end if;
    end process SYNC;
          
    --------------------------------------------------------------------------------------------
    --  Sequential proccess to register signals
    --------------------------------------------------------------------------------------------                                        
    REG: process(CLK, RESET)
    begin
        if RESET = '1' then
           state_reg            <= off;
           rdn_reg              <= '1';
           request_reg          <= '0';
           dout_reg             <= (others => '0');
           wait_counter    	    <= (others => '0');
        elsif rising_edge(CLK) then
           state_reg            <= state_next;
           rdn_reg              <= rdn_next;
           request_reg          <= request_next;
           dout_reg             <= dout_next;
           if rdn_next = '0' then
                wait_counter    <= wait_counter + 1;
           else
                wait_counter    <= (others => '0');          
           end if;
        end if;
    end process REG;
    
    --------------------------------------------------------------------------------------------
    --  Combinational process for internal signals logic
    --------------------------------------------------------------------------------------------                                        
    COMB: process(state_reg, rxfn_sync, wait_counter, ENABLE, DIN)
    begin
        -- To prevent latches
        state_next <= state_reg;
        case state_reg is
            when idle =>               
                if rxfn_sync = '0' then
                    dout_next       <= (others => '0');               
                    rdn_next        <= '0';
                    request_next    <= '0';
                    state_next      <= rx_data;
                else
                    dout_next       <= (others => '0');
                    rdn_next        <= '1';
                    request_next    <= '0';
                    state_next      <= idle;
                end if; 
            when rx_data =>
                if wait_counter = 1 then
                    dout_next       <= DIN;
                    rdn_next        <= '0';
                    request_next    <= '1';
                    state_next      <= rx_data;
                elsif wait_counter = NCYCLES then
                    dout_next       <= (others => '0');
                    rdn_next        <= '1';
                    request_next    <= '0';
                    state_next      <= idle;
                else
                    dout_next       <= (others => '0');
                    rdn_next        <= '0';
                    request_next    <= '0';
                    state_next      <= rx_data;
                end if;  
            when others =>
                dout_next           <= (others => '0');            
                rdn_next            <= '1';
                request_next        <= '0';
                if ENABLE = '1' then
                    state_next      <= idle;
                else
                    state_next      <= off;                
                end if;
        end case;
    end process COMB;
    
end Behavioral;
