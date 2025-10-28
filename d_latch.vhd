LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY d_latch IS
  PORT(
    i_d, i_enable    : IN STD_LOGIC;
    o_q              : OUT STD_LOGIC);
END d_latch;

ARCHITECTURE rtl OF d_latch IS
  SIGNAL int_dBar, int_d : STD_LOGIC;
  SIGNAl int_q, int_qBar    : STD_LOGIC;
BEGIN
  -- Concurrent Signals
  int_dBar <= i_d nand i_enable;
  int_d <= (not i_d) nand i_enable;
  int_q <= int_dBar nand int_qBar;
  int_qBar <= int_d nand int_q;
  
  -- Output Drivers
  o_q <= int_q;
END rtl;
