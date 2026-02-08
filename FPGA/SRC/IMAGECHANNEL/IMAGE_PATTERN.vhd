----------------------------------------------------------------------------------
-- Company: UMA. ETSI Telecomunicación
-- Engineer: Manuel Lorente Almán
-- 
-- Create Date: 16.07.2021
-- Design Name: VICON_FPGA
-- Module Name: IMAGE_PATTERN - Behavioral
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

entity IMAGE_PATTERN is
    Port ( 
            XCLK     : in STD_LOGIC;
            RESET    : in STD_LOGIC;
            RAMP     : in STD_LOGIC;
            PCLK     : out STD_LOGIC;
            FVAL     : out STD_LOGIC;
            LVAL     : out STD_LOGIC;
            DOUT     : out STD_LOGIC_VECTOR(7 downto 0)
           );
end IMAGE_PATTERN ;

architecture Behavioral of IMAGE_PATTERN  is
----------------------------------------------------------------------
-- Debug sync pixels
----------------------------------------------------------------------
signal frame_init       : STD_LOGIC_VECTOR(7 downto 0)  := x"0C";
signal frame_end        : STD_LOGIC_VECTOR(7 downto 0)  := x"0D";
signal line_init        : STD_LOGIC_VECTOR(7 downto 0)  := x"03";
signal line_end         : STD_LOGIC_VECTOR(7 downto 0)  := x"04";
----------------------------------------------------------------------
-- Counters and FSM to emulate sensor operation at 25MHz
----------------------------------------------------------------------
constant sofblank       : NATURAL   := 300;             -- 25us (625)
constant eofblank       : NATURAL   := 14;              -- 1.17us (29)
constant hblank         : NATURAL   := 318;             -- 26.5us (663)
constant vblank         : NATURAL   := 20778;           -- 1.73ms (43288)
constant nlines         : NATURAL   := 479;             -- 480 lines per frame
constant npixels        : NATURAL   := 1279;            -- 1280 pixels per line. YUV:4-2-2 send (Cb_i - Y_i - Cr_i - Y_i+1) we only need Y
type STATES is (idle, sof, dval, eof, hblanking, vblanking);
signal state_reg, state_next                        : STATES;
----------------------------------------------------------------------
-- Sensor output signals
----------------------------------------------------------------------
signal fval_reg, fval_next                          : STD_LOGIC;
signal lval_reg, lval_next                          : STD_LOGIC;
signal dout_vramp_reg, dout_vramp_next              : STD_LOGIC_VECTOR(7 downto 0);
signal dout_hramp_reg, dout_hramp_next              : STD_LOGIC_VECTOR(7 downto 0);
----------------------------------------------------------------------
-- Active data internal signals
----------------------------------------------------------------------
signal reset_pixel_reg, reset_pixel_next            : STD_LOGIC;
signal reset_line_reg, reset_line_next              : STD_LOGIC;
signal reset_data_vramp_reg, reset_data_vramp_next  : STD_LOGIC;
signal reset_data_hramp_reg, reset_data_hramp_next  : STD_LOGIC;
signal count_pixel                                  : STD_LOGIC_VECTOR(10 downto 0);
signal count_line                                   : STD_LOGIC_VECTOR(8 downto 0);
----------------------------------------------------------------------
-- Start of Frame Blanking internal signals
----------------------------------------------------------------------
signal reset_sofblank_reg, reset_sofblank_next      : STD_LOGIC;
signal count_sofblank                               : STD_LOGIC_VECTOR(9 downto 0);
----------------------------------------------------------------------
-- End of Frame blanking internal signals
----------------------------------------------------------------------
signal reset_eofblank_reg, reset_eofblank_next      : STD_LOGIC;
signal count_eofblank                               : STD_LOGIC_VECTOR(5 downto 0);
----------------------------------------------------------------------
-- Horizontal blanking internal signals
----------------------------------------------------------------------
signal reset_hblank_reg, reset_hblank_next          : STD_LOGIC;
signal count_hblank                                 : STD_LOGIC_VECTOR(9 downto 0);
----------------------------------------------------------------------
-- Vertical blanking internal signals
----------------------------------------------------------------------
signal reset_vblank_reg, reset_vblank_next          : STD_LOGIC;
signal count_vblank                                 : STD_LOGIC_VECTOR(19 downto 0);

begin

    ----------------------------------------------------------------------
    -- Connect output signals
    ----------------------------------------------------------------------
    PCLK <= XCLK;
    LVAL <= lval_reg;
    FVAL <= fval_reg;
    DOUT <= dout_hramp_reg when RAMP = '1' else dout_vramp_reg; 

    ----------------------------------------------------------------------
    -- Horizontal ramp pattern
    ----------------------------------------------------------------------
    HORIZONTAL_RAMP: process(XCLK, RESET, reset_data_hramp_reg, state_reg)
    begin
        if RESET = '1' or reset_data_hramp_reg = '1' then
            dout_hramp_next <= (others=>'0');
        elsif rising_edge(XCLK) and state_reg = dval then      
            if count_pixel = 0 and count_line = 0 then
                dout_hramp_next <= frame_init;
            elsif count_pixel = 0 then
                dout_hramp_next <= line_init;
            elsif count_pixel = npixels-1 and count_line = nlines-1 then
                dout_hramp_next <= frame_end;
            elsif count_pixel = npixels-1 then
                dout_hramp_next <= line_end;
            else          
                if count_pixel > 1023 then
                    dout_hramp_next <= x"FF";
                elsif count_pixel > 767 then
                    dout_hramp_next <= x"CC";
                elsif count_pixel > 511 then
                    dout_hramp_next <= x"99";
                elsif count_pixel > 255 then
                    dout_hramp_next <= x"66";
                else
                    dout_hramp_next <= x"33";
                end if;
            end if; 
        end if; 
    end process;

    ----------------------------------------------------------------------
    -- Vertical ramp pattern
    ----------------------------------------------------------------------
    VERTICAL_RAMP: process(XCLK, RESET, reset_data_vramp_reg, state_reg)
    begin
        if RESET = '1' or reset_data_vramp_reg = '1' then
            dout_vramp_next <= (others=>'0');
        elsif rising_edge(XCLK) and state_reg = dval then
            if count_pixel = 0 and count_line = 0 then
                dout_vramp_next <= frame_init;
            elsif count_pixel = 0 then
                dout_vramp_next <= line_init;
            elsif count_pixel = npixels-1 and count_line = nlines-1 then
                dout_vramp_next <= frame_end;
            elsif count_pixel = npixels-1 then
                dout_vramp_next <= line_end;
            else
                if count_line > 383 then
                    dout_vramp_next <= x"FF";
                elsif count_line > 287 then
                    dout_vramp_next <= x"CC";
                elsif count_line > 191 then
                    dout_vramp_next <= x"99";
                elsif count_line > 95 then
                    dout_vramp_next <= x"66";
                else
                    dout_vramp_next <= x"33";
                end if; 
            end if;
        end if;  
    end process;
        
    ----------------------------------------------------------------------
    -- Pixels counter
    ----------------------------------------------------------------------
    PIXEL_COUNT: process(XCLK, RESET, reset_pixel_reg, lval_reg)
    begin
        if RESET = '1' or reset_pixel_reg = '1' then
            count_pixel <= (others=>'0');
        elsif falling_edge(XCLK) and lval_reg = '1' then
            count_pixel <= count_pixel + 1;
        end if;  
    end process;
    
    ----------------------------------------------------------------------
    -- Lines counter
    ----------------------------------------------------------------------
    LINE_COUNT: process(XCLK, RESET, reset_line_reg, count_pixel)
    begin
        if RESET = '1' or reset_line_reg = '1' then
            count_line <= (others=>'0');
        elsif falling_edge(XCLK) and count_pixel = npixels - 1 then
            count_line <= count_line + 1;
        end if;
    end process;

    ----------------------------------------------------------------------
    -- Horizontal blanking counter
    ----------------------------------------------------------------------
    HBLANK_COUNT: process(XCLK, RESET, reset_hblank_reg, state_reg, lval_reg)
    begin
        if RESET = '1' or reset_hblank_reg = '1' then
            count_hblank <= (others=>'0');
        elsif falling_edge(XCLK) and lval_reg = '0' and state_reg = hblanking then
            count_hblank <= count_hblank + 1;
        end if;
    end process;
    
    ----------------------------------------------------------------------
    -- Start Of Frame blanking counter
    ----------------------------------------------------------------------        
    SOFBLANK_COUNT: process(XCLK, RESET, reset_sofblank_reg, state_reg, lval_reg)
    begin
        if RESET = '1' or reset_sofblank_reg = '1' then
            count_sofblank <= (others=>'0');
        elsif falling_edge(XCLK) and lval_reg = '0' and state_reg = sof then
            count_sofblank <= count_sofblank + 1;
        end if;
    end process;

    ----------------------------------------------------------------------
    -- End Of Frame blanking counter
    ----------------------------------------------------------------------           
    EOFBLANK_COUNT: process(XCLK, RESET, reset_eofblank_reg, state_reg, lval_reg)
    begin
        if RESET = '1' or reset_eofblank_reg = '1' then
            count_eofblank <= (others=>'0');
        elsif falling_edge(XCLK) and lval_reg = '0' and state_reg = eof then
            count_eofblank <= count_eofblank + 1;
        end if;
    end process;

    ----------------------------------------------------------------------
    -- Blanking between frames counter
    ----------------------------------------------------------------------   
    VBLANK_COUNT: process(XCLK, RESET, reset_vblank_reg, state_reg, fval_reg)
    begin
        if RESET = '1' or reset_vblank_reg = '1' then
            count_vblank <= (others=>'0');
        elsif falling_edge(XCLK) and fval_reg = '0' and state_reg = vblanking then
            count_vblank <= count_vblank + 1;
        end if;   
    end process;
   
   ----------------------------------------------------------------------                    
    -- Sequential process to register signals
    ----------------------------------------------------------------------
    REG: process(XCLK, RESET)
    begin
        if RESET = '1' then
            state_reg               <= idle;
            lval_reg                <= '0';
            fval_reg                <= '0';
            reset_hblank_reg        <= '1';
            reset_sofblank_reg      <= '1';
            reset_eofblank_reg      <= '1';
            reset_pixel_reg         <= '1';
            reset_line_reg          <= '1';
            reset_data_vramp_reg    <= '1';
            reset_data_hramp_reg    <= '1';
            reset_vblank_reg        <= '1';
            dout_vramp_reg          <= (others=>'0');
            dout_hramp_reg          <= (others=>'0');
        elsif falling_edge(XCLK) then
            state_reg               <= state_next;
            lval_reg                <= lval_next;
            fval_reg                <= fval_next;
            reset_hblank_reg        <= reset_hblank_next;
            reset_sofblank_reg      <= reset_sofblank_next;
            reset_eofblank_reg      <= reset_eofblank_next;
            reset_pixel_reg         <= reset_pixel_next;
            reset_line_reg          <= reset_line_next;
            reset_data_vramp_reg    <= reset_data_vramp_next;
            reset_data_hramp_reg    <= reset_data_hramp_next;
            reset_vblank_reg        <= reset_vblank_next;
            dout_vramp_reg          <= dout_vramp_next;
            dout_hramp_reg          <= dout_hramp_next;
        end if;
    end process;
    
    ----------------------------------------------------------------------
    -- Output signals logic
    ----------------------------------------------------------------------
    FSM: process (state_reg, count_sofblank, count_line, count_pixel, count_hblank, count_eofblank, count_vblank)
        begin
            case state_reg is
                -- Start Of Frame
                when sof =>
                    if count_sofblank = sofblank-1 then
                        state_next              <= dval;
                        reset_data_vramp_next   <= '0';
                        reset_data_hramp_next   <= '0';
                    else  
                        state_next <= sof;
                        reset_data_vramp_next   <= '1';
                        reset_data_hramp_next   <= '1';
                    end if;
                    lval_next               <= '0';
                    fval_next               <= '1';
                    reset_hblank_next       <= '1';
                    reset_sofblank_next     <= '0';
                    reset_eofblank_next     <= '1';
                    reset_pixel_next        <= '1';
                    reset_line_next         <= '1';
                    reset_vblank_next       <= '1';
                -- Data valid output
                when dval =>
                    lval_next               <= '1';
                    fval_next               <= '1';
                    reset_hblank_next       <= '1';
                    reset_sofblank_next     <= '1';
                    reset_eofblank_next     <= '1';
                    reset_pixel_next        <= '0';
                    reset_line_next         <= '0';
                    reset_data_vramp_next   <= '0';                    
                    reset_data_hramp_next   <= '0';
                    reset_vblank_next       <= '1';                        
                    -- Check if end of VGA frame (640x2)x480 or end of line.
                    if count_pixel = npixels-1 and count_line = nlines-1 then
                        state_next <= eof;
                    elsif count_pixel = npixels-1 then
                        state_next <= hblanking;
                    else
                        state_next <= dval;
                    end if;
                -- Horizontal Blanking
                when hblanking =>
                    lval_next               <= '0';
                    fval_next               <= '1';
                    reset_hblank_next       <= '0';
                    reset_sofblank_next     <= '1';
                    reset_eofblank_next     <= '1';
                    reset_pixel_next        <= '1';
                    reset_line_next         <= '0';                 
                    reset_vblank_next       <= '1';
                    if count_hblank = hblank-1 then
                        state_next              <= dval;
                        reset_data_vramp_next   <= '0';
                        reset_data_hramp_next   <= '0';
                    else
                        state_next              <= hblanking;
                        reset_data_vramp_next   <= '1';
                        reset_data_hramp_next   <= '1';                           
                    end if;
                -- End Of Frame
                when eof =>
                    lval_next               <= '0';
                    fval_next               <= '1';
                    reset_hblank_next       <= '1';
                    reset_sofblank_next     <= '1';
                    reset_eofblank_next     <= '0';
                    reset_pixel_next        <= '1';
                    reset_line_next         <= '1';
                    reset_data_vramp_next   <= '1';
                    reset_data_hramp_next   <= '1';
                    reset_vblank_next       <= '1';
                    if count_eofblank = eofblank-1 then
                        state_next <= vblanking;
                    else
                        state_next <= eof;
                    end if;
                -- Vertical Blanking
                when vblanking =>
                    lval_next               <= '0';
                    fval_next               <= '0';
                    reset_hblank_next       <= '1';
                    reset_sofblank_next     <= '1';
                    reset_eofblank_next     <= '1';
                    reset_pixel_next        <= '1';
                    reset_line_next         <= '1';
                    reset_data_vramp_next   <= '1';
                    reset_data_hramp_next   <= '1';
                    reset_vblank_next       <= '0';
                    if count_vblank = vblank-1 then
                        state_next <= sof;
                    else 
                        state_next <= vblanking;
                    end if;
               -- IDLE state
                when others =>
                    lval_next               <= '0';
                    fval_next               <= '0';
                    reset_hblank_next       <= '1';
                    reset_sofblank_next     <= '1';
                    reset_eofblank_next     <= '1';
                    reset_pixel_next        <= '1';
                    reset_line_next         <= '1';
                    reset_data_vramp_next   <= '1';
                    reset_data_hramp_next   <= '1';                    
                    reset_vblank_next       <= '1';
                    state_next              <= sof;
             end case;
    end process; 
    
end Behavioral;
