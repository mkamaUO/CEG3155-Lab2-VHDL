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
  SIGNAL mux_output           : STD_LOGIC_VECTOR(1 DOWNTO 0);
  COMPONENT mux21
    PORT (
      i_A, i_B, i_s : in STD_LOGIC; 
      o : out STD_LOGIC
    );
  END COMPONENT;
BEGIN
  -- Concurrent Signals
  mux1: mux21
		PORT MAP(
      i_A => i_A, 
      i_B => i_B,
      i_s => i_s1, 
      o => mux_output(1)
    );
		
	mux2: mux21
		PORT MAP(
      i_A => i_C, 
      i_B => i_D,
      i_s => i_s1, 
      o => mux_output(0)
    );
		
	mux3: mux21
		PORT MAP(
      i_A => mux_output(1), 
      i_B => mux_output(0),
      i_s => i_s0, 
      o => int_output
    );
  -- Output Driver;
  o <= int_output;
END rtl;
