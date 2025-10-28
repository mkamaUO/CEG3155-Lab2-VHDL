LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY mux41 IS
  PORT(
    i_A, i_B, i_C, i_D        : in STD_LOGIC;
    i_s0, i_s1                : in STD_LOGIC;
    o                         : out STD_LOGIC
  );
END mux41;

ARCHITECTURE rtl OF mux41 IS
  SIGNAL int_output           : STD_LOGIC;
BEGIN
  -- Concurrent Signals
  int_output <= ((not i_s0) and (not i_s1) and i_A) or (i_s0 and (not i_s1) and i_B) or ((not i_s0) and i_s1 and i_C) or (i_s0 and i_s1 and i_D);
  -- Output Driver;
  o <= int_output;
END rtl;