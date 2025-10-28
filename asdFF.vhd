LIBRARY ieee; -- D flipflop with just an asynchronous active-high set
use ieee.STD_LOGIC_1164.all;

entity asdFF is 
	port(
		i_d		: in STD_LOGIC;
		i_clk		: in STD_LOGIC;
		i_setBar		: in STD_LOGIC;
		o_q		: out STD_LOGIC;
		o_qBar		: out STD_LOGIC);
end asdFF;
architecture rtl of asdFF is
	--SIGNALS
	SIGNAL int_d1		: STD_LOGIC;
	SIGNAL int_d1Bar	: STD_LOGIC;
	SIGNAL int_d2		: STD_LOGIC;
	SIGNAL int_d2Bar	: STD_LOGIC;

	SIGNAL int_q		: STD_LOGIC;
	SIGNAL int_qBar		: STD_LOGIC;
BEGIN
	int_d1 <= not(i_setBar and int_d2Bar and int_d1Bar);
	int_d1Bar <= int_d1 nand i_clk;
	int_d2 <= not(int_d1Bar and i_clk and int_d2Bar);
	int_d2Bar <= int_d2 nand i_d;

	int_q <= not(i_setBar and int_d1Bar and int_qBar);
	int_qBar <= int_q nand int_d2;

	--Output drivers
	o_q <= int_q;
	o_qBar <= int_qBar;
end rtl;	