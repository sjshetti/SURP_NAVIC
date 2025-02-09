
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Complex4Multiply IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        btfIn2_re                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        btfIn2_im                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        din2Dly_vld                       :   IN    std_logic;
        twdl_re                           :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
        twdl_im                           :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
        syncReset                         :   IN    std_logic;
        dinXTwdl_re                       :   OUT   std_logic_vector(64 DOWNTO 0);  -- sfix65_En46
        dinXTwdl_im                       :   OUT   std_logic_vector(64 DOWNTO 0);  -- sfix65_En46
        dinXTwdl_vld                      :   OUT   std_logic
        );
END Complex4Multiply;


ARCHITECTURE rtl OF Complex4Multiply IS

  -- Signals
  SIGNAL btfIn2_re_signed                 : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL din_re_reg                       : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL btfIn2_im_signed                 : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL din_im_reg                       : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL twdl_re_signed                   : signed(31 DOWNTO 0);  -- sfix32_En30
  SIGNAL twdl_re_reg                      : signed(31 DOWNTO 0);  -- sfix32_En30
  SIGNAL twdl_im_signed                   : signed(31 DOWNTO 0);  -- sfix32_En30
  SIGNAL twdl_im_reg                      : signed(31 DOWNTO 0);  -- sfix32_En30
  SIGNAL Complex4Multiply_din1_re_pipe1   : signed(31 DOWNTO 0) := to_signed(0, 32);  -- sfix32
  SIGNAL Complex4Multiply_din1_im_pipe1   : signed(31 DOWNTO 0) := to_signed(0, 32);  -- sfix32
  SIGNAL Complex4Multiply_mult1_re_pipe1  : signed(63 DOWNTO 0) := to_signed(0, 64);  -- sfix64
  SIGNAL Complex4Multiply_mult2_re_pipe1  : signed(63 DOWNTO 0) := to_signed(0, 64);  -- sfix64
  SIGNAL Complex4Multiply_mult1_im_pipe1  : signed(63 DOWNTO 0) := to_signed(0, 64);  -- sfix64
  SIGNAL Complex4Multiply_mult2_im_pipe1  : signed(63 DOWNTO 0) := to_signed(0, 64);  -- sfix64
  SIGNAL Complex4Multiply_twiddle_re_pipe1 : signed(31 DOWNTO 0) := to_signed(0, 32);  -- sfix32
  SIGNAL Complex4Multiply_twiddle_im_pipe1 : signed(31 DOWNTO 0) := to_signed(0, 32);  -- sfix32
  SIGNAL prod1_re                         : signed(63 DOWNTO 0) := to_signed(0, 64);  -- sfix64_En46
  SIGNAL prod1_im                         : signed(63 DOWNTO 0) := to_signed(0, 64);  -- sfix64_En46
  SIGNAL prod2_re                         : signed(63 DOWNTO 0) := to_signed(0, 64);  -- sfix64_En46
  SIGNAL prod2_im                         : signed(63 DOWNTO 0) := to_signed(0, 64);  -- sfix64_En46
  SIGNAL din_vld_dly1                     : std_logic;
  SIGNAL din_vld_dly2                     : std_logic;
  SIGNAL din_vld_dly3                     : std_logic;
  SIGNAL prod_vld                         : std_logic;
  SIGNAL Complex4Add_multRes_re_reg       : signed(64 DOWNTO 0);  -- sfix65
  SIGNAL Complex4Add_multRes_im_reg       : signed(64 DOWNTO 0);  -- sfix65
  SIGNAL Complex4Add_prod_vld_reg1        : std_logic;
  SIGNAL Complex4Add_prod1_re_reg         : signed(63 DOWNTO 0);  -- sfix64
  SIGNAL Complex4Add_prod1_im_reg         : signed(63 DOWNTO 0);  -- sfix64
  SIGNAL Complex4Add_prod2_re_reg         : signed(63 DOWNTO 0);  -- sfix64
  SIGNAL Complex4Add_prod2_im_reg         : signed(63 DOWNTO 0);  -- sfix64
  SIGNAL Complex4Add_multRes_re_reg_next  : signed(64 DOWNTO 0);  -- sfix65_En46
  SIGNAL Complex4Add_multRes_im_reg_next  : signed(64 DOWNTO 0);  -- sfix65_En46
  SIGNAL Complex4Add_sub_cast             : signed(64 DOWNTO 0);  -- sfix65_En46
  SIGNAL Complex4Add_sub_cast_1           : signed(64 DOWNTO 0);  -- sfix65_En46
  SIGNAL Complex4Add_add_cast             : signed(64 DOWNTO 0);  -- sfix65_En46
  SIGNAL Complex4Add_add_cast_1           : signed(64 DOWNTO 0);  -- sfix65_En46
  SIGNAL mulResFP_re                      : signed(64 DOWNTO 0);  -- sfix65_En46
  SIGNAL mulResFP_im                      : signed(64 DOWNTO 0);  -- sfix65_En46

BEGIN
  btfIn2_re_signed <= signed(btfIn2_re);

  intdelay_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      din_re_reg <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          din_re_reg <= to_signed(0, 32);
        ELSE 
          din_re_reg <= btfIn2_re_signed;
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_process;


  btfIn2_im_signed <= signed(btfIn2_im);

  intdelay_1_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      din_im_reg <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          din_im_reg <= to_signed(0, 32);
        ELSE 
          din_im_reg <= btfIn2_im_signed;
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_1_process;


  twdl_re_signed <= signed(twdl_re);

  intdelay_2_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      twdl_re_reg <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          twdl_re_reg <= to_signed(0, 32);
        ELSE 
          twdl_re_reg <= twdl_re_signed;
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_2_process;


  twdl_im_signed <= signed(twdl_im);

  intdelay_3_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      twdl_im_reg <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          twdl_im_reg <= to_signed(0, 32);
        ELSE 
          twdl_im_reg <= twdl_im_signed;
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_3_process;


  -- Complex4Multiply
  Complex4Multiply_1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        prod1_re <= Complex4Multiply_mult1_re_pipe1;
        prod2_re <= Complex4Multiply_mult2_re_pipe1;
        prod1_im <= Complex4Multiply_mult1_im_pipe1;
        prod2_im <= Complex4Multiply_mult2_im_pipe1;
        Complex4Multiply_mult1_re_pipe1 <= Complex4Multiply_din1_re_pipe1 * Complex4Multiply_twiddle_re_pipe1;
        Complex4Multiply_mult2_re_pipe1 <= Complex4Multiply_din1_im_pipe1 * Complex4Multiply_twiddle_im_pipe1;
        Complex4Multiply_mult1_im_pipe1 <= Complex4Multiply_din1_re_pipe1 * Complex4Multiply_twiddle_im_pipe1;
        Complex4Multiply_mult2_im_pipe1 <= Complex4Multiply_din1_im_pipe1 * Complex4Multiply_twiddle_re_pipe1;
        Complex4Multiply_twiddle_re_pipe1 <= twdl_re_reg;
        Complex4Multiply_twiddle_im_pipe1 <= twdl_im_reg;
        Complex4Multiply_din1_re_pipe1 <= din_re_reg;
        Complex4Multiply_din1_im_pipe1 <= din_im_reg;
      END IF;
    END IF;
  END PROCESS Complex4Multiply_1_process;


  intdelay_4_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      din_vld_dly1 <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          din_vld_dly1 <= '0';
        ELSE 
          din_vld_dly1 <= din2Dly_vld;
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_4_process;


  intdelay_5_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      din_vld_dly2 <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          din_vld_dly2 <= '0';
        ELSE 
          din_vld_dly2 <= din_vld_dly1;
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_5_process;


  intdelay_6_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      din_vld_dly3 <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          din_vld_dly3 <= '0';
        ELSE 
          din_vld_dly3 <= din_vld_dly2;
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_6_process;


  intdelay_7_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      prod_vld <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          prod_vld <= '0';
        ELSE 
          prod_vld <= din_vld_dly3;
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_7_process;


  -- Complex4Add
  Complex4Add_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Complex4Add_multRes_re_reg <= to_signed(0, 65);
      Complex4Add_multRes_im_reg <= to_signed(0, 65);
      Complex4Add_prod1_re_reg <= to_signed(0, 64);
      Complex4Add_prod1_im_reg <= to_signed(0, 64);
      Complex4Add_prod2_re_reg <= to_signed(0, 64);
      Complex4Add_prod2_im_reg <= to_signed(0, 64);
      Complex4Add_prod_vld_reg1 <= '0';
      dinXTwdl_vld <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          Complex4Add_multRes_re_reg <= to_signed(0, 65);
          Complex4Add_multRes_im_reg <= to_signed(0, 65);
          Complex4Add_prod1_re_reg <= to_signed(0, 64);
          Complex4Add_prod1_im_reg <= to_signed(0, 64);
          Complex4Add_prod2_re_reg <= to_signed(0, 64);
          Complex4Add_prod2_im_reg <= to_signed(0, 64);
          Complex4Add_prod_vld_reg1 <= '0';
          dinXTwdl_vld <= '0';
        ELSE 
          Complex4Add_multRes_re_reg <= Complex4Add_multRes_re_reg_next;
          Complex4Add_multRes_im_reg <= Complex4Add_multRes_im_reg_next;
          Complex4Add_prod1_re_reg <= prod1_re;
          Complex4Add_prod1_im_reg <= prod1_im;
          Complex4Add_prod2_re_reg <= prod2_re;
          Complex4Add_prod2_im_reg <= prod2_im;
          dinXTwdl_vld <= Complex4Add_prod_vld_reg1;
          Complex4Add_prod_vld_reg1 <= prod_vld;
        END IF;
      END IF;
    END IF;
  END PROCESS Complex4Add_process;

  Complex4Add_sub_cast <= resize(Complex4Add_prod1_re_reg, 65);
  Complex4Add_sub_cast_1 <= resize(Complex4Add_prod2_re_reg, 65);
  Complex4Add_multRes_re_reg_next <= Complex4Add_sub_cast - Complex4Add_sub_cast_1;
  Complex4Add_add_cast <= resize(Complex4Add_prod1_im_reg, 65);
  Complex4Add_add_cast_1 <= resize(Complex4Add_prod2_im_reg, 65);
  Complex4Add_multRes_im_reg_next <= Complex4Add_add_cast + Complex4Add_add_cast_1;
  mulResFP_re <= Complex4Add_multRes_re_reg;
  mulResFP_im <= Complex4Add_multRes_im_reg;

  dinXTwdl_re <= std_logic_vector(mulResFP_re);

  dinXTwdl_im <= std_logic_vector(mulResFP_im);

END rtl;

