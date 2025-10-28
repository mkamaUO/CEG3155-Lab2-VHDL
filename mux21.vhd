LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY mux21 IS
	port(i_A,i_B,i_s : in STD_LOGIC; o : out STD_LOGIC);
END mux21;

ARCHITECTURE rtl OF mux21 is
	SIGNAL int_out	: STD_LOGIC;
BEGIN
	int_out <= (i_A and (not i_s)) or (i_B and i_s);
	o <= int_out;
END rtl;