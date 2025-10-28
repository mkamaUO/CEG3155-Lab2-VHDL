LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY counter_2Bit IS
  PORT(
    i_clk             : in STD_LOGIC;
    i_resetBar        : in STD_LOGIC;
    i_start_counter   : in STD_LOGIC;
    i_dec_counter     : in STD_LOGIC;
    o_done            : out STD_LOGIC);
    
END counter_2Bit;

ARCHITECTURE rtl of counter_2Bit IS
  SIGNAL int_iA, int_iB, int_oA, int_oB       : STD_LOGIC;
  SIGNAL int_start_counter                    : STD_LOGIC;
BEGIN
  
  dFF_1  : ENTITY work.enasdFF
    port map(
      i_d => int_iA,
      i_clk => i_clk,
      i_setBar => i_resetBar,
      i_en => i_dec_counter,
      o_q => int_oA,
      o_qBar => OPEN);
      
    dFF_0  : ENTITY work.enasdFF
    port map(
      i_d => int_iB,
      i_clk => i_clk,
      i_setBar => i_resetBar,
      i_en => i_dec_counter,
      o_q => int_oB,
      o_qBar => OPEN);
      
    -- Concurrent Signals
    int_iA <= int_oA and int_oB;
    int_iB <= not int_oB;
    int_start_counter <= i_resetBar and (not i_start_counter);
    -- Output Drivers
    o_done <=  (not int_oA) and (not int_oB); 
END rtl;
      
