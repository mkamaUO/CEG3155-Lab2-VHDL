LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY fullAdder IS
	port(
		i_A :	in STD_LOGIC;
		i_B : 	in STD_LOGIC;
		i_C :	in STD_LOGIC;
		o_sum :	out STD_LOGIC;
		o_C : 	out STD_LOGIC);
END fullAdder;

ARCHITECTURE rtl OF fullAdder IS
BEGIN
	o_sum 	<= i_A xor i_B xor i_C;
	o_C 	<= (i_A and i_C) or (i_B and i_C) or (i_A and i_B);
END rtl;  
