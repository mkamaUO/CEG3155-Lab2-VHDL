LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY datapath IS
  GENERIC(WIDTH : POSITIVE := 4);
  PORT(
    i_resetBar                  : in STD_LOGIC;
    i_clk                       : in STD_LOGIC;
    
    ----------------------- Control Signals ----------------------------
    
    -- Adder/Subtractor
    i_select1                   : in STD_LOGIC_VECTOR(1 downto 0);
    i_select2                   : in STD_LOGIC_VECTOR(1 downto 0);
    i_subtract                  : in STD_LOGIC;
    
    -- Register A & B
    i_ldA, i_ldB                : in STD_LOGIC;
    i_inverseA, i_inverseB      : in STD_LOGIC;
    
    -- Product Register
    i_ld_sum_product            : in STD_LOGIC;
    i_shiftR_product            : in STD_LOGIC;
    i_initialize_product        : in STD_LOGIC;
    
    -- Remainder Register
    i_shiftL_remainder          : in STD_LOGIC;
    i_shiftR_remainder          : in STD_LOGIC;
    i_initialize_remainder      : in STD_LOGIC;
    i_ld_remainder              : in STD_LOGIC;
    
    -- Counter Register
    i_start_counter             : in STD_LOGIC;
    i_dec_counter               : in STD_LOGIC;
    
    -- Check Sign
    i_check_sign                : in STD_LOGIC;
    i_ld_MSB_remainder          : in STD_LOGIC;
    --------------------------- Inputs ----------------------------------
    i_OperandA                  : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    i_OperandB                  : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    i_OperationSelect           : in STD_LOGIC_VECTOR(1 downto 0);
    
    --------------------------- Status ----------------------------------
    status_signA                 : out STD_LOGIC;
    status_signB                 : out STD_LOGIC;
    status_LSB_product           : out STD_LOGIC;
    status_MSB_remainder         : out STD_LOGIC;
    status_sign_change           : out STD_LOGIC;
    status_done_counter          : out STD_LOGIC; 
    -------------------------- Outputs ----------------------------------
    o_MuxOut                    : out STD_LOGIC_VECTOR(2*WIDTH-1 downto 0);
    o_CarryOut                  : out STD_LOGIC;
    o_ZeroOut                   : out STD_LOGIC;
    o_OverflowOut               : out STD_LOGIC
  );
END datapath;

ARCHITECTURE rtl OF datapath IS
  SIGNAL int_A, int_B             : STD_LOGIC_VECTOR(WIDTH downto 0);
  SIGNAL int_dFF_A_input          : STD_LOGIC_VECTOR(WIDTH downto 0);
  SIGNAL int_dFF_B_input          : STD_LOGIC_VECTOR(WIDTH downto 0);
  
  SIGNAL int_fA_Op1, int_fA_Op2   : STD_LOGIC_VECTOR(WIDTH downto 0);
  SIGNAL int_fA_output            : STD_LOGIC_VECTOR(WIDTH downto 0);
  
  SIGNAL int_product              : STD_LOGIC_VECTOR(2*WIDTH downto 0);
  SIGNAL int_remainder            : STD_LOGIC_VECTOR(2*WIDTH downto 0);
  SIGNAL int_remainder_5bitright  : STD_LOGIC_VECTOR(WIDTH downto 0);
  SIGNAL int_MSB_remainder        : STD_LOGIC;
  SIGNAL int_LSB_remainder        : STD_LOGIC;
  SIGNAL int_sign_change          : STD_LOGIC;
  SIGNAL int_MuxOut               : STD_LOGIC_VECTOR(2*WIDTH-1 downto 0);
BEGIN
  -- Adder/Subtractor operand1
  gen_mux41_operand1 : FOR i IN 0 TO WIDTH GENERATE  
    mux41_operand1 : ENTITY work.mux41
      port map(
        i_A => '0',
        i_B => int_A(i),
        i_C => int_product(WIDTH + i),
        i_D => int_remainder(WIDTH + i),
        i_s0 => i_select1(0),
        i_s1 => i_select1(1),
        o => int_fA_Op1(i)
      );
  END GENERATE gen_mux41_operand1;
    
  -- Adder/Subtractor operand2
  gen_mux41_operand2 : FOR i IN 0 TO WIDTH GENERATE
    mux41_operand2 : ENTITY work.mux41
      port map(
        i_A => int_A(i),
        i_B => int_B(i),
        i_C => int_remainder(WIDTH+i),
        i_D => int_remainder_5bitright(i), -- we can't just take the last 4 bits in 5 bit full adder
        i_s0 => i_select2(0),
        i_s1 => i_select2(1),
        o => int_fA_Op2(i)
    );
  END GENERATE gen_mux41_operand2;
  
    
  -- Adder/Subtractor
  adder_subtractor : ENTITY work.fA_4Bit
    port map(
      i_A => int_fA_Op1(3 downto 0),
      i_B => int_fA_Op2(3 downto 0),
      i_sub => i_subtract,
      o_sum => int_fA_output(3 downto 0),
      o_carry => o_CarryOut,
      o_overflow => o_OverflowOut
    );
      
  -- Register A and Register B
  
  --------------- Register A --------------
  -- Load from operandA or load from full Adder (after 2 complimenting)
  -- Not MSB bits
  gen_regA : FOR i IN 0 TO WIDTH-1 GENERATE
    mux21_A : ENTITY work.mux21
      port map(
        i_A => i_OperandA(i),
        i_B => int_fA_output(i),
        i_s => i_inverseA,
        o => int_dFF_A_input(i)
      );
      
    dFF_A : ENTITY work.enARdFF_2
      port map(
        i_d => int_dFF_A_input(i),
        i_clock => i_clk,
        i_resetBar => i_resetBar,
        i_enable => i_ldA,
        o_q => int_A(i),
        o_qBar => OPEN
      );
  END GENERATE gen_regA;
  
  -- MSB
  mux21_A_MSB : ENTITY work.mux21
    port map(
      i_A => i_OperandA(WIDTH-1), --extend the sign
      i_B => int_fA_output(WIDTH), -- load the sign from fA
      i_s => i_inverseA,
      o => int_dFF_A_input(WIDTH)
    );
    
  dFF_A_MSB : ENTITY work.enARdFF_2
    port map(
      i_d => int_dFF_A_input(WIDTH),
      i_clock => i_clk,
      i_resetBar => i_resetBar,
      i_enable => i_ldA,
      o_q => int_A(WIDTH),
      o_qBar => OPEN);
      
  --------------- Register B --------------
  -- Load from operandA or load from full Adder (after 2 complimenting)
  
  -- not MSB bits
  gen_regB : FOR i IN 0 TO WIDTH-1 GENERATE
    mux21_B : ENTITY work.mux21
      port map(
        i_A => i_OperandB(i),
        i_B => int_fA_output(i),
        i_s => i_inverseB,
        o => int_dFF_B_input(i)
      );
    dFF_B : ENTITY work.enARdFF_2
      port map(
        i_d => int_dFF_B_input(i),
        i_clock => i_clk,
        i_resetBar => i_resetBar,
        i_enable => i_ldB,
        o_q => int_B(i),
        o_qBar => OPEN
      );
  END GENERATE gen_regB;
  
  -- MSB (Extend the sign)
  mux21_B_MSB : ENTITY work.mux21
    port map(
      i_A => i_OperandB(WIDTH-1), --extend the sign
      i_B => int_fA_output(WIDTH), -- load the sign from fA
      i_s => i_inverseB,
      o => int_dFF_B_input(WIDTH)
    );
  dFF_B_MSB : ENTITY work.enARdFF_2
    port map(
      i_d => int_dFF_B_input(WIDTH),
      i_clock => i_clk,
      i_resetBar => i_resetBar,
      i_enable => i_ldB,
      o_q => int_B(WIDTH),
      o_qBar => OPEN);
      
      
  -- Product Register
  product_reg : ENTITY work.product_reg
    port map(
      i_resetBar => i_resetBar,
      i_clk => i_clk,
      i_shiftR => i_shiftR_product,
      i_initialize => i_initialize_product,
      i_multiplier => int_B(WIDTH-1 downto 0), -- 4 bits
      i_ld_sum => i_ld_sum_product,
      i_sum => int_fA_output,
      status_LSB => status_LSB_product,
      o_q => int_product
    );
  
  -- Remainder Register
  remainder_reg : ENTITY work.remainder_reg
    port map(
      i_resetBar => i_resetBar,
      i_clk => i_clk,
      i_shiftL => i_shiftL_remainder,
      i_LSB => int_LSB_remainder,
      i_shiftR => i_shiftR_remainder,
      i_initialize => i_initialize_remainder,
      i_dividend => int_A(WIDTH-1 downto 0), -- 4 bits
      i_ld_remainder => i_ld_remainder,
      i_remainder => int_fA_output,
      o_q => int_remainder
    );
  
  -- Multiplexer Out
  gen_mux41_Output_rightHalf : FOR i IN 0 TO WIDTH - 1 GENERATE  
    mux41_Output : ENTITY work.mux41
      port map(
        i_A => int_fA_output(i),
        i_B => int_fA_output(i),
        i_C => int_product(i),
        i_D => int_fA_output(i), -- Needs to go through fA to check negative or positive
        i_s0 => i_OperationSelect(0),
        i_s1 => i_OperationSelect(1),
        o => int_MuxOut(i)
      );
  END GENERATE gen_mux41_Output_rightHalf;
   
   gen_mux41_Output_leftHalf : FOR i IN WIDTH TO 2*WIDTH-1 GENERATE  
    mux41_Output : ENTITY work.mux41
      port map(
        i_A => int_fA_output(WIDTH-1), -- Extend the sign
        i_B => int_fA_output(WIDTH-1), -- Extend the sign
        i_C => int_product(i),
        i_D => int_remainder(i),
        i_s0 => i_OperationSelect(0),
        i_s1 => i_OperationSelect(1),
        o => int_MuxOut(i)
      );
  END GENERATE gen_mux41_Output_leftHalf;

  counter_2Bit : ENTITY work.counter_2Bit
    port map(
      i_clk => i_clk,
      i_resetBar => i_resetBar,
      i_start_counter => i_start_counter,
      i_dec_counter => i_dec_counter,
      o_done => status_done_counter
    );
  
  -- Sign Change
  sign_change_latch : ENTITY work.d_latch
    port map(
      i_d => int_sign_change,
      i_enable => i_check_sign,
      o_q => status_sign_change);
    
  -- MSB_Remainder (Should start at 1)
  remainder_MSB_dFF : ENTITY work.enasdFF
    port map(
      i_d => int_fA_output(WIDTH),
      i_clk => i_clk,
      i_setBar => i_resetBar,
      i_en => i_ld_MSB_remainder,
      o_q => int_MSB_remainder,
      o_qBar => OPEN);
      
  -- Concurrent Signals
  int_remainder_5bitright <= int_remainder(WIDTH-1) & int_remainder(WIDTH-1 downto 0);
  int_LSB_remainder <= not int_MSB_remainder;
  
  int_sign_change <= i_operandA(WIDTH-1) xor i_operandB(WIDTH-1);
  
  status_signA <= i_operandA(WIDTH-1);
  status_signB <= i_operandB(WIDTH-1);
  
  status_MSB_remainder <= int_MSB_remainder;
  
  -- Output Drivers
  o_MuxOut <= int_MuxOut;
  o_ZeroOut <= not(int_MuxOut(7) or int_MuxOut(6) or int_MuxOut(5) or int_MuxOut(4) or int_MuxOut(3) or int_MuxOut(2) or int_MuxOut(1) or int_MuxOut(0));
END rtl;
