LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY product_reg IS
  GENERIC(WIDTH : POSITIVE := 8);
  port(
    i_resetBar          : in STD_LOGIC;
    i_clk               : in STD_LOGIC;
    i_shiftR            : in STD_LOGIC;
    i_initialize        : in STD_LOGIC;
    i_multiplier        : in STD_LOGIC_VECTOR(WIDTH/2 - 1 downto 0); -- 4 bits : 3 to 0
    i_ld_sum            : in STD_LOGIC;
    i_sum               : in STD_LOGIC_VECTOR(WIDTH downto WIDTH/2); -- 5 bits : 8 to 4
    status_LSB          : out STD_LOGIC;
    o_q                 : out STD_LOGIC_VECTOR(WIDTH downto 0)
    );
END product_reg;


-- Load left half (addition)
-- Initialize: Load right half (multiplier)
-- Shift right

-- Compartments:
-- Bit 8 (MSB): load i_sum, (The signed shift right will just keep the same sign, so we don't need to do anything)
-- Bit [7..4] (leftHalf): load i_sum, shift right
-- Bit [3..0] (rightHalf): load multiplier (on initialize), shift right


ARCHITECTURE rtl OF product_reg IS
  SIGNAL int_q                 : STD_LOGIC_VECTOR(WIDTH downto 0);
  SIGNAL int_dFF_inputs_left   : STD_LOGIC_VECTOR(WIDTH-1 downto WIDTH/2);
  SIGNAL int_dFF_inputs_right  : STD_LOGIC_VECTOR(WIDTH/2 -1 downto 0);
  SIGNAL int_en_dFF_leftHalf   : STD_LOGIC;
  SIGNAL int_en_dFF_rightHalf  : STD_LOGIC;
  SIGNAL int_clr_leftHalf      : STD_LOGIC;
  
BEGIN
  -- MSB
  dFF_MSB : ENTITY work.enARdFF_2
    port map(i_d => i_sum(WIDTH), i_clock => i_clk, i_resetBar => int_clr_leftHalf, i_enable => i_ld_sum, o_q => int_q(WIDTH), o_qBar => OPEN);
  
  -- Left half
  gen_leftHalf : FOR i IN WIDTH/2 TO WIDTH-1 GENERATE
    mux21_leftHalf : ENTITY work.mux21
      port map(i_A => int_q(i+1), i_B => i_sum(i), i_s => i_ld_sum, o => int_dFF_inputs_left(i));
    dFF_leftHalf  : ENTITY work.enARdFF_2
      port map(i_d => int_dFF_inputs_left(i), i_clock => i_clk, i_resetBar => int_clr_leftHalf, i_enable => int_en_dFF_leftHalf, o_q => int_q(i), o_qBar => OPEN);
  END GENERATE gen_leftHalf;
  
  -- Right half
  gen_rightHalf : FOR i IN 0 TO WIDTH/2 - 1 GENERATE
    mux21_rightHalf : ENTITY work.mux21
      port map(i_A => int_q(i+1), i_B => i_multiplier(i), i_s => i_initialize, o => int_dFF_inputs_right(i));
    dFF_rightHalf : ENTITY work.enARdFF_2
      port map(i_d => int_dFF_inputs_right(i), i_clock => i_clk, i_resetBar => i_resetBar, i_enable => int_en_dFF_rightHalf, o_q => int_q(i), o_qBar => OPEN);
  END GENERATE gen_rightHalf;
  
  -- Concurrent Signals
  int_en_dFF_leftHalf <= i_ld_sum or i_shiftR;
  int_en_dFF_rightHalf <= i_initialize or i_shiftR;
  
  int_clr_leftHalf <= i_resetBar and (not i_initialize);
  
  -- Output Drivers
  status_LSB <= int_q(0);
  o_q <= int_q;
END rtl;
