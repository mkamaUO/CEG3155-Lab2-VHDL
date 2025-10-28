LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

entity ardFF is -- D flipflop with asynchronous active-low reset
	port(
		i_d 		: in STD_LOGIC;
		i_clk 		: in STD_LOGIC;
		i_resetBar	: in STD_LOGIC;
		o_q		: out STD_LOGIC;
		o_qBar		: out STD_LOGIC);
end ardFF;

architecture rtl of ardFF is
	-- SIGNALS
	-- Master Latches
	SIGNAL int_d1			: STD_LOGIC;
	SIGNAL int_d1Bar		: STD_LOGIC;
	SIGNAL int_d2			: STD_LOGIC;
	SIGNAL int_d2Bar		: STD_LOGIC;
	
	-- Slave Latches
	SIGNAL int_q		: STD_LOGIC;
	SIGNAL int_qBar	: STD_LOGIC;
BEGIN
	int_d1 <= int_d1Bar nand int_d2Bar;
	int_d1Bar <= not(int_d1 and i_clk and i_resetBar);
	int_d2 <= not(int_d1Bar and i_clk and int_d2Bar);
	int_d2Bar <= not(int_d2 and i_resetBar and i_d);

	int_q <= int_d1Bar nand int_qBar;
	int_qBar <= not(int_q and int_d2 and i_resetBar);

	-- Output drivers
	o_q <= int_q;
	o_qBar <= int_qBar;
end rtl;