LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY controlpath IS
  port(
  -- Inputs
  i_OperationSelect            : in STD_LOGIC_VECTOR(1 downto 0);
  i_resetBar                   : in STD_LOGIC;
  i_clk                        : in STD_LOGIC; 
  
  -- Status Signals
  status_signA                 : in STD_LOGIC;
  status_signB                 : in STD_LOGIC;
  status_LSB_product           : in STD_LOGIC;
  status_MSB_remainder         : in STD_LOGIC;
  status_sign_change           : in STD_LOGIC;
  status_done_counter          : in STD_LOGIC;          
  
  -- Outputs (Control Signals)
  -- Universal
  o_ldA, o_ldB, o_check_sign   : out STD_LOGIC;
  o_select1, o_select2         : out STD_LOGIC_VECTOR(1 downto 0);
  o_subtract                   : out STD_LOGIC;
  o_inverse_A, o_inverse_B     : out STD_LOGIC;
  
  -- Product Register
  o_initialize_product         : out STD_LOGIC;
  o_ld_sum                     : out STD_LOGIC;
  o_shiftR_product               : out STD_LOGIC;
  
  -- Remainder Register
  o_initialize_remainder       : out STD_LOGIC;
  o_shiftL_remainder           : out STD_LOGIC;
  o_ld_remainder               : out STD_LOGIC;
  reset_LSB_remainder          : out STD_LOGIC;
  o_shiftR_remainder           : out STD_LOGIC;
  o_ld_MSB_remainder           : out STD_LOGIC;
  
  -- Counter Register
  o_start_counter              : out STD_LOGIC;
  o_dec_counter                : out STD_LOGIC;
  
  -- MuxOutSelector
  o_MuxOutSelect               : out STD_LOGIC_VECTOR(1 downto 0)
  );
END controlpath;

ARCHITECTURE rtl OF controlpath is
  SIGNAL int_state_input              : STD_LOGIC_VECTOR(19 downto 1);
  SIGNAL int_state                    : STD_LOGIC_VECTOR(19 downto 0);
  SIGNAL int_state13_delayed          : STD_LOGIC;
  SIGNAL int_state6and7_delayed       : STD_LOGIC;
  SIGNAL int_state_multiplication     : STD_LOGIC;
  SIGNAL int_state_division           : STD_LOGIC;
  SIGNAL int_state_after_signA        : STD_LOGIC;
  SIGNAL int_state_delay_M_input      : STD_LOGIC;
  SIGNAL int_state_delay_M            : STD_LOGIC;
  SIGNAL int_state_after_state12      : STD_LOGIC;
  
BEGIN  
  state_0 : ENTITY work.asdFF
    port map(
      i_d => '0',
      i_clk => i_clk,
      i_setBar => i_resetBar,
      o_q => int_state(0),
      o_qBar => OPEN
    );
    
    
  gen_dFFar : FOR i IN 1 TO 19 GENERATE
  BEGIN
    state_i : ENTITY work.ardFF
    port map(
      i_d => int_state_input(i),
      i_clk => i_clk,
      i_resetBar => i_resetBar,
      o_q => int_state(i),
      o_qBar => OPEN
    );
  END GENERATE gen_dFFar;   
  
  -- DELAY 
  delay_state13_dFF : ENTITY work.ardFF
    port map(
      i_d => int_state(13),
      i_clk => i_clk,
      i_resetBar => i_resetBar,
      o_q => int_state13_delayed);
  
  delay_multiplication : ENTITY work.ardFF
    port map(
      i_d => int_state_delay_M_input,
      i_clk => i_clk,
      i_resetBar => i_resetBar,
      o_q => int_state_delay_M);
      
  -- Concurrent Signals (int_state_input(i))
  
  -- Add or Subtract
  int_state_input(1) <= ((not i_OperationSelect(1)) and (not i_OperationSelect(0)) and int_state(0)) or int_state(1);
  int_state_input(2) <= ((not i_OperationSelect(1)) and i_OperationSelect(0) and int_state(0)) or int_state(2);
  
  -- Multiplication
  int_state_multiplication <= int_state(0) and i_OperationSelect(1) and (not i_OperationSelect(0));
  int_state_input(3) <= int_state_multiplication and status_signB;
  int_state_input(4) <= int_state(3);
  int_state_input(5) <= (int_state_multiplication and (not status_signB)) or (int_state(4));
  int_state_delay_M_input  <= int_state(5) or (int_state(7) and (not status_done_counter));
  int_state_input(6) <= int_state_delay_M and status_LSB_product;
  int_state_input(7) <= (int_state_delay_M and (not status_LSB_product)) or int_state(6);
  int_state_input(8) <= (int_state(7) and status_done_counter) or int_state(8);
  
  -- Division
  int_state_division <= int_state(0) and i_OperationSelect(1) and i_OperationSelect(0);
  int_state_input(9) <= int_state_division and status_signA;
  int_state_after_signA <= (int_state_division and (not status_signA)) or int_state(9);
  int_state_input(10) <= int_state_after_signA and status_signB;
  int_state_input(11) <= (int_state_after_signA and (not status_signB)) or int_state(10);
  int_state_input(12) <= int_state(11);
  int_state_input(13) <= int_state(12) or (int_state(15) and (not status_done_counter));
  int_state_input(14) <= int_state13_delayed and status_MSB_remainder;
  int_state_input(15) <= (int_state13_delayed and (not status_MSB_remainder)) or int_state(14);
  int_state_input(16) <= int_state(15) and status_done_counter;
  int_state_input(17) <= (int_state(16) and (not status_sign_change)) or int_state(17);
  int_state_input(18) <= int_state(16) and status_sign_change;
  int_state_input(19) <= int_state(18) or int_state(19);
  
  -- Output Drivers:
  o_ldA <= int_state(0) or int_state(3) or int_state(9);
  o_ldB <= int_state(0) or int_state(4) or int_state(10);
  o_check_sign <= int_state(0);
  o_select1(0) <= int_state(1) or int_state(2) or int_state(13) or int_state(14);
  o_select1(1) <= int_state(6) or int_state(13) or int_state(14);
  o_select2(0) <= int_state(1) or int_state(2) or int_state(4) or int_state(10) or int_state(13) or int_state(14) or int_state(17) or int_state(19);
  o_select2(1) <= int_state(17) or int_state(18) or int_state(19);
  o_subtract  <= int_state(2) or int_state(3) or int_state(4) or int_state(9) or int_state(10) or int_state(13) or int_state(18) or int_state(19); 
  o_inverse_A <= int_state(3) or int_state(9);
  o_inverse_B <= int_state(4) or int_state(10);
  o_initialize_product <= int_state(5);
  o_ld_sum <= int_state(6);
  o_shiftR_product <= int_state(7);
  
  o_initialize_remainder <= int_state(11);
  o_shiftL_remainder <= int_state(12) or int_state(15);
  o_ld_remainder <= int_state(13) or int_state(14) or int_state(18);
  o_ld_MSB_remainder <= int_state(13);
  o_shiftR_remainder <= int_state(16);
  o_start_counter <= int_state(5) or int_state(11);
  o_dec_counter <= int_state(7) or int_state(15);
  o_MuxOutSelect(0) <= int_state(2) or int_state(17) or int_state(19);
  o_MuxOutSelect(1) <= int_state(8) or int_state(17) or int_state(19);
END rtl;
