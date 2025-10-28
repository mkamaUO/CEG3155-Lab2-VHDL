LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY counter_4 IS
  port(
    i_clk                 : in STD_LOGIC;
    i_resetBar            : in STD_LOGIC;
    i_start_counter       : in STD_LOGIC;
    i_dec_counter         : in STD_LOGIC;
    o_done                : out STD_LOGIC);
END counter_4;

ARCHITECTURE rtl OF counter_4 IS
  SIGNAL int_oA, int_oB, int_oC       : STD_LOGIC;  -- Outputs of the DFF
  SIGNAL int_iA, int_iB, int_iC       : STD_LOGIC;  -- Inputs of the DFF
  SIGNAL int_start_counter            : STD_LOGIC;
  
BEGIN
  dff_A : ENTITY work.enasdFF
    port map(
      i_d => int_iA,
      i_clk => i_clk,
      i_setBar => int_start_counter,
      i_en => i_dec_counter,
      o_q => int_oA,
      o_qBar => OPEN);


  dff_B : ENTITY work.enARdFF_2
    port map(
      i_d => int_iB,
      i_clock => i_clk,
      i_resetBar => int_start_counter,
      i_enable => i_dec_counter,
      o_q => int_oB,
      o_qBar => OPEN);

  dff_C : ENTITY work.enARdFF_2
    port map(
      i_d => int_iC,
      i_clock => i_clk,
      i_resetBar => int_start_counter,
      i_enable => i_dec_counter,
      o_q => int_oC,
      o_qBar => OPEN);
      
  -- Concurrent Signals
  int_iA <= '0';
  int_iB <= int_oA or (int_oB and int_oC);
  int_iC <= not int_oC;
      
  int_start_counter <= i_resetBar and (not i_start_counter);
  -- Output driver
  o_done <= not(int_oA or int_oB or int_oC);
  
      
END rtl;