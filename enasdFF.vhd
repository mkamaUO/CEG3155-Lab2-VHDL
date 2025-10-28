LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY enasdFF is -- D flipflop with enable and asynchronous active-high set
	port(
		i_d 		: in STD_LOGIC;
		i_clk 		: in STD_LOGIC;
		i_setBar	: in STD_LOGIC;
		i_en		: in STD_LOGIC;
		o_q		: out STD_LOGIC;
		o_qBar		: out STD_LOGIC);
end enasdFF;

ARCHITECTURE rtl OF enasdFF IS
	SIGNAL o_mux		: STD_LOGIC;
	SIGNAL int_q		: STD_LOGIC;
	SIGNAL int_qBar		: STD_LOGIC;
BEGIN
	dFF : ENTITY work.asdFF
		port map(
			i_d => o_mux, 
			i_clk => i_clk, 
			i_setBar => i_setBar, 
			o_q => int_q, 
			o_qBar => int_qBar);
	
	pre_mux : ENTITY work.mux21
		port map(
			i_A => int_q, 
			i_B => i_d, 
			i_s => i_en,
			o => o_mux);
	-- Output Drivers
	o_q <= int_q;
	o_qBar <= int_qBar;
END rtl;