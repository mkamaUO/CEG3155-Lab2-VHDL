LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY fA_4Bit IS
  port(
      i_A, i_B    : in STD_LOGIC_VECTOR(3 downto 0);
      i_sub       : in STD_LOGIC;
      o_sum       : out STD_LOGIC_VECTOR(3 downto 0);
      o_carry     : out STD_LOGIC;
      o_overflow  : out STD_LOGIC);
END fA_4Bit;

ARCHITECTURE rtl OF fA_4Bit IS
  SIGNAL int_carryOut  : STD_LOGIC_VECTOR(3 downto 0);
  SIGNAL int_B         : STD_LOGIC_VECTOR(3 downto 0);
BEGIN

  -- Concurrent Signals
  int_B <= i_B xor (3 downto 0 => i_sub);
    
  fA_first : ENTITY work.fullAdder(rtl)
    port map(
      i_A => i_A(0),
      i_B => int_B(0),
      i_C => i_sub,
      o_sum => o_sum(0),
      o_C => int_carryOut(0));
      
  gen_Adder : FOR i in 1 to 3 GENERATE
    fA_1Bit : ENTITY work.fullAdder(rtl)
      port map(
        i_A => i_A(i),
        i_B => int_B(i),
        i_C => int_carryOut(i-1),
        o_sum => o_sum(i),
        o_C => int_carryOut(i));
  END GENERATE;

  
  -- Output Driver
  o_carry <= int_carryOut(3);
  o_overflow <= int_carryOut(3) xor int_carryOut(2);
END rtl;