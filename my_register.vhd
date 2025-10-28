LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY my_register IS
    PORT(
        i_d             : in STD_LOGIC_VECTOR(3 downto 0);
        i_clk           : in STD_LOGIC;
        i_resetBar      : in STD_LOGIC;
        i_en            : in STD_LOGIC;
        o_q             : out STD_LOGIC_VECTOR(3 downto 0);
        o_qBar          : out STD_LOGIC_VECTOR(3 downto 0));
END my_register;

ARCHITECTURE rtl OF my_register IS
BEGIN
  gen_dFF : FOR i IN 0 TO 3 GENERATE
  BEGIN
    dFF_inst : ENTITY work.enARdFF_2
      port map(
        i_d => i_d(i),
        i_clock => i_clk,
        i_resetBar => i_resetBar,
        i_enable => i_en,
        o_q => o_q(i),
        o_qBar => o_qBar(i));
  END GENERATE gen_dFF;
END rtl;   