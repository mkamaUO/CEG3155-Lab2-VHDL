LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY top_level IS
  GENERIC(WIDTH : POSITIVE := 4);
  PORT(
    i_clk           : in  STD_LOGIC;
    G_RESET           : in  STD_LOGIC;
    i_OperandA        : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    i_OperandB        : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    i_OperationSelect : in  STD_LOGIC_VECTOR(1 downto 0);

    o_MuxOut          : out STD_LOGIC_VECTOR(2*WIDTH-1 downto 0);
    o_CarryOut        : out STD_LOGIC;
    o_ZeroOut         : out STD_LOGIC;
    o_OverflowOut     : out STD_LOGIC
  );
END top_level;

ARCHITECTURE structural OF top_level IS

  -- Status Signals (from datapath to controlpath)
  SIGNAL status_signA           : STD_LOGIC;
  SIGNAL status_signB           : STD_LOGIC;
  SIGNAL status_LSB_product     : STD_LOGIC;
  SIGNAL status_MSB_remainder   : STD_LOGIC;
  SIGNAL status_sign_change     : STD_LOGIC;
  SIGNAL status_done_counter    : STD_LOGIC;

  -- Control Signals (from controlpath to datapath)
  SIGNAL o_ldA, o_ldB, o_check_sign       : STD_LOGIC;
  SIGNAL o_select1, o_select2             : STD_LOGIC_VECTOR(1 downto 0);
  SIGNAL o_subtract                       : STD_LOGIC;
  SIGNAL o_inverse_A, o_inverse_B         : STD_LOGIC;
  SIGNAL o_initialize_product             : STD_LOGIC;
  SIGNAL o_ld_sum                         : STD_LOGIC;
  SIGNAL o_shiftR_product                 : STD_LOGIC;
  SIGNAL o_initialize_remainder           : STD_LOGIC;
  SIGNAL o_shiftL_remainder               : STD_LOGIC;
  SIGNAL o_ld_remainder                   : STD_LOGIC;
  SIGNAL reset_LSB_remainder              : STD_LOGIC;
  SIGNAL o_shiftR_remainder               : STD_LOGIC;
  SIGNAL o_ld_MSB_remainder               : STD_LOGIC;
  SIGNAL o_start_counter                  : STD_LOGIC;
  SIGNAL o_dec_counter                    : STD_LOGIC;
  SIGNAL o_MuxOutSelect                   : STD_LOGIC_VECTOR(1 downto 0);
  
  -- Extra
  SIGNAL int_set_LSB_remainder                   : STD_LOGIC; -- inverse of the reset_LSB_remainder;

BEGIN

  -- Control Path Instantiation
  control_unit : ENTITY work.controlpath
    PORT MAP (
      i_OperationSelect      => i_OperationSelect,
      i_resetBar             => G_RESET,
      i_clk                  => i_clk ,
      status_signA           => status_signA,
      status_signB           => status_signB,
      status_LSB_product     => status_LSB_product,
      status_MSB_remainder   => status_MSB_remainder,
      status_sign_change     => status_sign_change,
      status_done_counter    => status_done_counter,
      o_ldA                  => o_ldA,
      o_ldB                  => o_ldB,
      o_check_sign           => o_check_sign,
      o_select1              => o_select1,
      o_select2              => o_select2,
      o_subtract             => o_subtract,
      o_inverse_A            => o_inverse_A,
      o_inverse_B            => o_inverse_B,
      o_initialize_product   => o_initialize_product,
      o_ld_sum               => o_ld_sum,
      o_shiftR_product       => o_shiftR_product,
      o_initialize_remainder => o_initialize_remainder,
      o_shiftL_remainder     => o_shiftL_remainder,
      o_ld_remainder         => o_ld_remainder,
      reset_LSB_remainder    => reset_LSB_remainder,
      o_shiftR_remainder     => o_shiftR_remainder,
      o_ld_MSB_remainder     => o_ld_MSB_remainder,
      o_start_counter        => o_start_counter,
      o_dec_counter          => o_dec_counter,
      o_MuxOutSelect         => o_MuxOutSelect
    );

  -- Datapath Instantiation
  datapath_unit : ENTITY work.datapath
    GENERIC MAP(WIDTH => WIDTH)
    PORT MAP (
      i_resetBar              => G_RESET,
      i_clk                   => i_clk ,
      i_select1               => o_select1,
      i_select2               => o_select2,
      i_subtract              => o_subtract,
      i_ldA                   => o_ldA,
      i_ldB                   => o_ldB,
      i_inverseA              => o_inverse_A,
      i_inverseB              => o_inverse_B,
      i_ld_sum_product        => o_ld_sum,
      i_shiftR_product        => o_shiftR_product,
      i_initialize_product    => o_initialize_product,
      i_shiftL_remainder      => o_shiftL_remainder,
      i_shiftR_remainder      => o_shiftR_remainder,
      i_initialize_remainder  => o_initialize_remainder,
      i_ld_remainder          => o_ld_remainder,
      i_start_counter         => o_start_counter,
      i_dec_counter           => o_dec_counter,
      i_check_sign            => o_check_sign,
      i_ld_MSB_remainder      => o_ld_MSB_remainder,
      i_OperandA              => i_OperandA,
      i_OperandB              => i_OperandB,
      i_OperationSelect       => o_MuxOutSelect,
      status_signA            => status_signA,
      status_signB            => status_signB,
      status_LSB_product      => status_LSB_product,
      status_MSB_remainder    => status_MSB_remainder,
      status_sign_change      => status_sign_change,
      status_done_counter     => status_done_counter,
      o_MuxOut                => o_MuxOut,
      o_CarryOut              => o_CarryOut,
      o_ZeroOut               => o_ZeroOut,
      o_OverflowOut           => o_OverflowOut
    );

  -- Concurrent Signal
  int_set_LSB_remainder <= not reset_LSB_remainder;
END structural;
