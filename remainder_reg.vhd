LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY remainder_reg IS
  GENERIC(WIDTH : POSITIVE := 8);
  port(
    i_resetBar            : in STD_LOGIC;
    i_clk                 : in STD_LOGIC;
    i_shiftL              : in STD_LOGIC;
    i_LSB                 : in STD_LOGIC;
    i_shiftR              : in STD_LOGIC;
    i_initialize          : in STD_LOGIC;
    i_dividend            : in STD_LOGIC_VECTOR(WIDTH/2 - 1 downto 0);
    i_ld_remainder        : in STD_LOGIC;
    i_remainder           : in STD_LOGIC_VECTOR(WIDTH downto WIDTH/2); -- 5 bits (bit 8 to bit 4)
    o_q                   : out STD_LOGIC_VECTOR(WIDTH downto 0) --9 bits (bit 8 to bit 0)
    );
END remainder_reg;


-- Load left half (subtraction)
-- Initialize: Load right half (dividend)
-- Load LSB
-- Shift left
-- Shift right (only left half)

-- Compartments:
-- Bit 7 (MSB): load, shift left, ld 0 (shift right)
-- Bit [6..4] (leftHalf): load, shift left, shift right
-- Bit [3..1] (rightHalf): load dividend, shift left
-- Bit 0 (LSB): load (on initialize), load LSB

ARCHITECTURE rtl OF remainder_reg IS
  SIGNAL int_q                : STD_LOGIC_VECTOR(WIDTH downto 0);
  SIGNAL int_shiftedLeft      : STD_LOGIC_VECTOR(WIDTH downto WIDTH/2);
  SIGNAL int_en_dFF_leftHalf  : STD_LOGIC;
  SIGNAL int_en_dFF_rightHalf : STD_LOGIC;
  SIGNAL int_en_dFF_LSB       : STD_LOGIC;
  SIGNAL int_dFF_inputs       : STD_LOGIC_VECTOR(WIDTH downto 0);
  SIGNAL int_clr_leftHalf     : STD_LOGIC;
BEGIN
  -- MSB
  mux21_MSB_First : ENTITY work.mux21(rtl)
    port map(i_A => int_q(WIDTH-1), i_B => '0', i_s => i_shiftR, o => int_shiftedLeft(WIDTH)); -- Shift left or right
  mux21_MSB_Second : ENTITY work.mux21(rtl)
    port map(i_A => int_shiftedLeft(WIDTH), i_B => i_remainder(WIDTH), i_s => i_ld_remainder, o => int_dFF_inputs(WIDTH)); -- loaded or shifted
  dFF_MSB : ENTITY work.enARdFF_2
    port map(i_d => int_dFF_inputs(WIDTH), i_clock => i_clk, i_resetBar => int_clr_leftHalf, i_enable => int_en_dFF_leftHalf, o_q => int_q(WIDTH), o_qBar => OPEN);
      
  -- Left Half
  gen_leftHalf : FOR i IN WIDTH/2 TO WIDTH-1 GENERATE
  BEGIN
    mux21_leftHalf_First : ENTITY work.mux21(rtl)
      port map(i_A => int_q(i-1), i_B => int_q(i+1), i_s => i_shiftR, o => int_shiftedLeft(i)); -- Shift left or right
    mux21_leftHalf_Second : ENTITY work.mux21(rtl)
      port map(i_A => int_shiftedLeft(i), i_B => i_remainder(i), i_s => i_ld_remainder, o => int_dFF_inputs(i)); --loaded or shifted
    dFF_leftHalf : ENTITY work.enARdFF_2
      port map(i_d => int_dFF_inputs(i), i_clock => i_clk, i_resetBar => int_clr_leftHalf, i_enable => int_en_dFF_leftHalf, o_q => int_q(i), o_qBar => OPEN);
  END GENERATE gen_leftHalf;
  
  
  -- Right Half
  gen_rightHalf : FOR i IN 1 TO WIDTH/2 - 1 GENERATE
  BEGIN
    mux21_rightHalf : ENTITY work.mux21(rtl)
      port map(i_A => int_q(i-1), i_B => i_dividend(i), i_s => i_initialize, o => int_dFF_inputs(i)); -- Shift left or load (initialize)
    dFF_rightHalf : ENTITY work.enARdFF_2
      port map(i_d => int_dFF_inputs(i), i_clock => i_clk, i_resetBar => i_resetBar, i_enable => int_en_dFF_rightHalf, o_q => int_q(i), o_qBar => OPEN);
  END GENERATE gen_rightHalf;
  
  -- LSB
  mux21_LSB : ENTITY work.mux21(rtl)
    port map(i_A => i_LSB, i_B => i_dividend(0), i_s => i_initialize, o => int_dFF_inputs(0)); -- Shift left or load (initialize or ld LSB)
  dFF_LSB : ENTITY work.enARdFF_2
    port map(i_d => int_dFF_inputs(0), i_clock => i_clk, i_resetBar => i_resetBar, i_enable => int_en_dFF_LSB, o_q => int_q(0), o_qBar => OPEN);
      

  -- Concurrent Signals
  int_en_dFF_leftHalf <= i_shiftL or i_shiftR or i_ld_remainder;
  int_en_dFF_rightHalf <= i_shiftL or i_initialize;
  int_en_dFF_LSB <= i_initialize or i_shiftL;
  
  int_clr_leftHalf <= i_resetBar and (not i_initialize);
  
  -- Output Drivers:
  o_q <= int_q;
END rtl;