--
-- File   : ir_con.vhd
-- Date   : 20131204
-- Author : Bibo Yang, ash_riple@hotmail.com
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use IEEE.numeric_std.all;

entity ir_con is
port(
  rst               : in std_logic;
  clk               : in std_logic;
  test_start        : in std_logic;

  -- general cpu interface --
  up_clk            : in  std_logic;
  up_wr             : in  std_logic;
  up_rd             : in  std_logic;
  up_addr           : in  std_logic_vector(31 downto 0);
  up_data_wr        : in  std_logic_vector(31 downto 0);
  up_data_rd        : out std_logic_vector(31 downto 0);

  -- constant rate buffer in
  frame_fifo_wr_in    : in  std_logic;
  frame_fifo_data_in  : in  std_logic_vector(35 downto 0);
  -- variable rate buffer out
  frame_fifo_wr_out   : out std_logic;
  frame_fifo_data_out : out std_logic_vector(35 downto 0)
);
end ir_con;

architecture synth of ir_con is

type ary8_std64 is array (7 downto 0) of std_logic_vector(63 downto 0);
type ary8_std32 is array (7 downto 0) of std_logic_vector(31 downto 0);
type ary8_std30 is array (7 downto 0) of std_logic_vector(29 downto 0);
type ary8_std16 is array (7 downto 0) of std_logic_vector(15 downto 0);
type ary8_std14 is array (7 downto 0) of std_logic_vector(13 downto 0);
type ary8_std04 is array (7 downto 0) of std_logic_vector( 3 downto 0);
type ary8_std03 is array (7 downto 0) of std_logic_vector( 2 downto 0);
type ary8_std02 is array (7 downto 0) of std_logic_vector( 1 downto 0);

signal up_wr_emix      : std_logic;
signal up_addr_emix    : std_logic_vector( 8 downto 0);
signal rd_addr_emix    : std_logic_vector( 9 downto 0);
signal rd_addr_emix_all: std_logic_vector( 9 downto 0);

component dpram_dc_32_512_16_1024 IS
	PORT
	(
		address_a	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		address_b	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		aclr_a		: IN STD_LOGIC ;
		aclr_b		: IN STD_LOGIC ;
		clock_a		: IN STD_LOGIC ;
		clock_b		: IN STD_LOGIC ;
		enable_a	: IN STD_LOGIC ;
		enable_b	: IN STD_LOGIC ;
		data_a		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rden_a		: IN STD_LOGIC  := '1';
		rden_b		: IN STD_LOGIC  := '1';
		wren_a		: IN STD_LOGIC  := '1';
		wren_b		: IN STD_LOGIC  := '1';
		q_a		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END component;

-- bwp control input parameters --
signal line_rate_en_in      : std_logic_vector(7 downto 0);  -- 000H -- line rate or info rate
signal burst_test_mask_in   : std_logic_vector(7 downto 0);  -- 004H -- burst rate or not
signal burst_once_mask_in   : std_logic_vector(7 downto 0);  -- 008H -- fill half or not
signal emix_range_in        : ary8_std04;                    -- 010H -- up to 16 entries for 8 streams each
signal emix_range_in_all    : std_logic_vector(9 downto 0);  
signal buffer_capacity_in   : ary8_std32;  -- 100H ~ 13CH -- up to 4G Bytes
signal cycle_number_in      : ary8_std32;  -- 140H ~ 17CH -- up to 4G Cycles
signal duty_cycle_factor_in : ary8_std32;  -- 180H ~ 1BCH -- up to 16M times and down to 1/256 times
signal safe_margin_in       : ary8_std32;  -- 1C0H ~ 1FCH -- up to 4G Bytes
-- bwp status output parameters --
signal cycle_counter_out    : ary8_std32;  -- 240H ~ 27CH -- up to 4G Cycles

-- to be implemented as input parameters --
signal line_rate_en         : std_logic_vector(7 downto 0);  -- 000H -- line rate or info rate
signal burst_test_mask      : std_logic_vector(7 downto 0);  -- 004H -- burst rate or not
signal burst_once_mask      : std_logic_vector(7 downto 0);  -- 008H -- fill half or not
signal emix_range           : ary8_std04;                    -- 010H -- up to 16 entries for 8 streams each
signal buffer_capacity      : ary8_std30;  -- 100H ~ 13CH -- up to 1G Bytes
signal cycle_number         : ary8_std30;  -- 140H ~ 17CH -- up to 1G Cycles
signal duty_cycle_factor    : ary8_std32;  -- 180H ~ 1BCH -- up to 16M times and dowon to 1/256 times
signal safe_margin          : ary8_std30;  -- 1C0H ~ 1FCH -- up to 1G Bytes
-- end --
-- to be implemented as output parameters --
signal cycle_counter     : ary8_std30;  -- 0240H ~ 027CH -- up to 1G Cycles
-- end --

signal wr_en : std_logic_vector(7 downto 0);
signal rd_en : std_logic_vector(7 downto 0);
signal wr_data : ary8_std14;
signal rd_data : ary8_std14;

signal rate_counter    : ary8_std30;  -- buffer emulator
signal rate_counter_d1 : ary8_std30;
signal rate_counter_d2 : ary8_std30;
signal rate_counter_stable : ary8_std30;
signal ovfl_counter    : ary8_std32;  -- buffer over flow counter
signal emix_pointer    : ary8_std04;  -- emix selector
signal emix_incr       : ary8_std02;  -- emix incr_timer
signal emix_pointer_all: std_logic_vector(9 downto 0);
signal leng_holder     : std_logic_vector(15 downto 0);  -- length holder
signal leng_holder_d1  : ary8_std14;
signal rate_rd      : std_logic;
signal rate_data    : std_logic_vector(31 downto 0);
signal rate_rd_d1   : std_logic;
signal rate_data_d1 : std_logic_vector(31 downto 0);
signal rate_rd_d2   : std_logic;
signal rate_data_d2 : std_logic_vector(31 downto 0);
signal rate_rd_d3   : std_logic;
signal rate_data_d3 : std_logic_vector(31 downto 0);
signal rate_rd_d4   : std_logic;
signal rate_data_d4 : std_logic_vector(31 downto 0);
signal rate_rd_d5   : std_logic;
signal rate_data_d5 : std_logic_vector(31 downto 0);
signal rate_rd_d6   : std_logic;
signal rate_data_d6 : std_logic_vector(31 downto 0);
signal rate_rd_d7   : std_logic;
signal rate_data_d7 : std_logic_vector(31 downto 0);

component bwp_fsm IS
    PORT (
        reset : IN STD_LOGIC := '0';
        clock : IN STD_LOGIC;
        test_start : IN STD_LOGIC := '0';
        buffer_full : IN STD_LOGIC := '0';
        buffer_half : IN STD_LOGIC := '0';
        buffer_ovfl : IN STD_LOGIC := '0';
        buffer_empty : IN STD_LOGIC := '0';
        duty_reached : IN STD_LOGIC := '0';
        cycle_reached : IN STD_LOGIC := '0';
        burst_test : IN STD_LOGIC := '0';
        burst_disabled : IN STD_LOGIC := '0';
        burst_once : IN STD_LOGIC := '0';
        wait_once : IN STD_LOGIC := '0';
        external_int : IN STD_LOGIC := '0';
        state_ti : OUT STD_LOGIC;
        state_ff : OUT STD_LOGIC;
        state_br : OUT STD_LOGIC;
        state_fh : OUT STD_LOGIC;
        state_sr : OUT STD_LOGIC
    );
END component;

signal burst_frame_enable : std_logic_vector(7 downto 0);
signal space_frame_enable : std_logic_vector(7 downto 0);
signal  idle_frame_enable : std_logic_vector(7 downto 0);
signal burst_frame_sent   : std_logic_vector(7 downto 0);
signal space_frame_sent   : std_logic_vector(7 downto 0);
signal  idle_frame_sent   : std_logic_vector(7 downto 0);

signal burst_frame_cnt   : ary8_std32;  -- frame number in a burst traffic
signal space_frame_cnt   : ary8_std32;  -- frame number in a non-burst traffic
signal  idle_frame_cnt   : ary8_std32;  -- frame number when entering idle state as a trace-bullet
signal buffer_hold_level : ary8_std30;  -- buffer level when entering spaced rate state

signal buffer_full   : std_logic_vector(7 downto 0);
signal buffer_half   : std_logic_vector(7 downto 0);
signal buffer_ovfl   : std_logic_vector(7 downto 0);
signal buffer_hold   : std_logic_vector(7 downto 0);
signal buffer_empty  : std_logic_vector(7 downto 0);
signal buffer_margin : std_logic_vector(7 downto 0);
signal duty_reached  : std_logic_vector(7 downto 0);
signal cycle_reached : std_logic_vector(7 downto 0);
signal burst_disable : std_logic_vector(7 downto 0);
signal wait_once     : std_logic_vector(7 downto 0);
signal external_int  : std_logic_vector(7 downto 0);
signal external_stop : std_logic_vector(7 downto 0);
signal external_not_idle : std_logic;

signal state_ti : std_logic_vector(7 downto 0);  -- test idle
signal state_ff : std_logic_vector(7 downto 0);  -- fill full
signal state_fh : std_logic_vector(7 downto 0);  -- fill half
signal state_br : std_logic_vector(7 downto 0);  -- burst rate
signal state_sr : std_logic_vector(7 downto 0);  -- spaced rate

signal state_ti_d1 : std_logic_vector(7 downto 0);
signal state_ff_d1 : std_logic_vector(7 downto 0);
signal state_fh_d1 : std_logic_vector(7 downto 0);
signal state_br_d1 : std_logic_vector(7 downto 0);
signal state_sr_d1 : std_logic_vector(7 downto 0);

component multiplier_32_32_d4 IS
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
END component;

signal duty_cycle_result : ary8_std64;

signal fsm_rst : std_logic;
signal fsm_start : std_logic;
signal test_start_d1 :std_logic;
signal test_start_d2 :std_logic;
signal test_start_d3 :std_logic;
signal test_start_d4 :std_logic;
signal test_start_d5 :std_logic;
signal test_start_d6 :std_logic;

begin
process (rst, clk)
begin
  if (rst='1') then
    test_start_d1 <= '0';
    test_start_d2 <= '0';
    test_start_d3 <= '0';
    test_start_d4 <= '0';
    test_start_d5 <= '0';
    test_start_d6 <= '0';
  elsif (clk'event and clk='1') then
    test_start_d1 <= test_start;
    test_start_d2 <= test_start_d1;
    test_start_d3 <= test_start_d2;
    test_start_d4 <= test_start_d3;
    test_start_d5 <= test_start_d4;
    test_start_d6 <= test_start_d5;
  end if;
end process;

fsm_start <= test_start_d1 and test_start_d5;  -- 4 clock delay after assert and 1 clock delay after deassert
fsm_rst <= rst or (not test_start and test_start_d1);  -- negative edge of test_start

-- get input parameters --

-- line_rate_en
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 0)=X"000" and up_wr='1') then
  line_rate_en_in(7 downto 0) <= up_data_wr(7 downto 0);
end if; end if; end process;
line_rate_en_init : for i in 0 to 7 generate
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  line_rate_en(i) <= line_rate_en_in(i);
end if; end if; end process;
end generate;

-- burst_test
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 0)=X"004" and up_wr='1') then
  burst_test_mask_in(7 downto 0) <= up_data_wr(7 downto 0);
end if; end if; end process;
burst_test_init_01 : for i in 0 to 1 generate
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  burst_test_mask(i) <= burst_test_mask_in(i);
end if; end if; end process;
end generate;
----------------------------------------------------
-- REMOVE THE FOLLOWING LOOP FOR MULTIPLE BURSTING
----------------------------------------------------
burst_test_init : for i in 2 to 7 generate
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  burst_test_mask(i) <= '0'; --burst_test_mask_in(i);
end if; end if; end process;
end generate;

-- burst_once
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 0)=X"008" and up_wr='1') then
  burst_once_mask_in(7 downto 0) <= up_data_wr(7 downto 0);
end if; end if; end process;
burst_once_init_01 : for i in 0 to 1 generate
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  burst_once_mask(i) <= burst_once_mask_in(i);
end if; end if; end process;
end generate;
----------------------------------------------------
-- REMOVE THE FOLLOWING LOOP FOR MULTIPLE BURSTING
----------------------------------------------------
burst_once_init : for i in 2 to 7 generate
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  burst_once_mask(i) <= '0'; --burst_once_mask_in(i);
end if; end if; end process;
end generate;

-- emix_range
emix_range_init : for i in 0 to 7 generate
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 0)=X"010" and up_wr='1') then
  emix_range_in(i) <= up_data_wr(i*4+3 downto i*4+0);
end if; end if; end process;
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  emix_range(i) <= emix_range_in(i);
end if; end if; end process;
end generate;
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 0)=X"010" and up_wr='1') then
  emix_range_in_all <= up_data_wr(9 downto 0);
end if; end if; end process;

-- buffer_capacity
buffer_capacity_init_01 : for i in 0 to 1 generate
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 6)="000100" and i=CONV_INTEGER(up_addr(4 downto 2)) and up_wr='1') then
  buffer_capacity_in(i) <= up_data_wr(31 downto 0);
end if; end if; end process;
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  buffer_capacity(i) <= buffer_capacity_in(i)(29 downto 0);
end if; end if; end process;
end generate;
----------------------------------------------------
-- REMOVE THE FOLLOWING LOOP FOR MULTIPLE BURSTING
----------------------------------------------------
buffer_capacity_init : for i in 2 to 7 generate
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 6)="000100" and i=CONV_INTEGER(up_addr(4 downto 2)) and up_wr='1') then
  buffer_capacity_in(i) <= up_data_wr(31 downto 0);
end if; end if; end process;
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  buffer_capacity(i) <= (others=>'0'); --buffer_capacity_in(i)(29 downto 0);
end if; end if; end process;
end generate;

-- cycle_number
cycle_number_init_01 : for i in 0 to 1 generate
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 6)="000101" and i=CONV_INTEGER(up_addr(4 downto 2)) and up_wr='1') then
  cycle_number_in(i) <= up_data_wr(31 downto 0);
end if; end if; end process;
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  cycle_number(i) <= cycle_number_in(i)(29 downto 0);
end if; end if; end process;
end generate;
----------------------------------------------------
-- REMOVE THE FOLLOWING LOOP FOR MULTIPLE BURSTING
----------------------------------------------------
cycle_number_init : for i in 2 to 7 generate
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 6)="000101" and i=CONV_INTEGER(up_addr(4 downto 2)) and up_wr='1') then
  cycle_number_in(i) <= up_data_wr(31 downto 0);
end if; end if; end process;
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  cycle_number(i) <= (others=>'0'); --cycle_number_in(i)(29 downto 0);
end if; end if; end process;
end generate;

-- duty_cycle
duty_cycle_init_01 : for i in 0 to 1 generate
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 6)="000110" and i=CONV_INTEGER(up_addr(4 downto 2)) and up_wr='1') then
  duty_cycle_factor_in(i) <= up_data_wr(31 downto 0);
end if; end if; end process;
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  duty_cycle_factor(i) <= duty_cycle_factor_in(i)(31 downto 0);
end if; end if; end process;
end generate;
----------------------------------------------------
-- REMOVE THE FOLLOWING LOOP FOR MULTIPLE BURSTING
----------------------------------------------------
duty_cycle_init : for i in 2 to 7 generate
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 6)="000110" and i=CONV_INTEGER(up_addr(4 downto 2)) and up_wr='1') then
  duty_cycle_factor_in(i) <= up_data_wr(31 downto 0);
end if; end if; end process;
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  duty_cycle_factor(i) <= (others=>'0'); --duty_cycle_factor_in(i)(31 downto 0);
end if; end if; end process;
end generate;

-- safe_margin
safe_margin_init_01 : for i in 0 to 1 generate
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 6)="000111" and i=CONV_INTEGER(up_addr(4 downto 2)) and up_wr='1') then
  safe_margin_in(i) <= up_data_wr(31 downto 0);
end if; end if; end process;
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  safe_margin(i) <= safe_margin_in(i)(29 downto 0);
end if; end if; end process;
end generate;
----------------------------------------------------
-- REMOVE THE FOLLOWING LOOP FOR MULTIPLE BURSTING
----------------------------------------------------
safe_margin_init : for i in 2 to 7 generate
process (up_clk) begin if (up_clk'event and up_clk='1') then if (up_addr(11 downto 6)="000111" and i=CONV_INTEGER(up_addr(4 downto 2)) and up_wr='1') then
  safe_margin_in(i) <= up_data_wr(31 downto 0);
end if; end if; end process;
process (clk) begin if (clk'event and clk='1') then if (test_start='1' and test_start_d1='0') then
  safe_margin(i) <= (others=>'0'); --safe_margin_in(i)(29 downto 0);
end if; end if; end process;
end generate;
-- end input parameters --

-- set output --
up_data_rd <= (others=>'0');
-- cycle_cnt
cycle_cnt_output : for i in 0 to 7 generate
process (fsm_rst, clk) 
begin
  if (fsm_rst='1') then
    cycle_counter_out(i) <= (others=>'0');
  elsif (clk'event and clk='1') then
    if (state_ff(i)='0' and state_ff_d1(i)='1') then
      cycle_counter_out(i) <= "00"&cycle_counter(i);
    end if;
  end if; end process;
end generate;
-- end output --


length_selector : for i in 0 to 7 generate
process (fsm_rst, clk)
begin
  if (fsm_rst='1') then
      leng_holder_d1(i) <= (others=>'0');
  elsif (clk'event and clk='1') then
    --if (rate_rd_d1 = '1' and i=CONV_INTEGER(rate_data_d1(2 downto 0))) then
      leng_holder_d1(i) <= leng_holder(13 downto 0);
    --end if;
  end if;
end process;
end generate;

-- write to rate counter
wr_loop : for i in 0 to 7 generate
--process (frame_fifo_wr_in, frame_fifo_data_in(3 downto 0), frame_fifo_data_in(29 downto 16)) begin
process (clk) begin if (clk'event and clk='1') then
  if (i=CONV_INTEGER(frame_fifo_data_in(2 downto 0))) then
    wr_en(i) <= frame_fifo_wr_in;
    wr_data(i) <= frame_fifo_data_in(29 downto 16);
  else
    wr_en(i) <= '0';
    wr_data(i) <= wr_data(i);
  end if;
end if; end process;
--end process;
end generate;

-- read from rate counter
rd_loop : for i in 0 to 7 generate
--process (rate_rd_d1, rate_data_d1(3 downto 0), rate_data_d1(29 downto 16)) begin
process (clk) begin if (clk'event and clk='1') then
  if (i=CONV_INTEGER(rate_data_d1(2 downto 0))) then
    rd_en(i) <= rate_rd_d1;
    rd_data(i) <= rate_data_d1(29 downto 16);
  else
    rd_en(i) <= '0';
    rd_data(i) <= rd_data(i);
  end if;
end if; end process;
--end process;
end generate;

buffer_level : for i in 0 to 1 generate
-- use seperate lower and upper bits counter updating to cut down long paths to improve timing
process (fsm_rst, clk)
begin
  if (fsm_rst='1') then
            rate_counter(i)    <= (others=>'0');
  elsif (clk'event and clk='1') then
    -- update lower bits with complex logic
    if    (wr_en(i)='1' and rd_en(i)='1') then
        -- write and read  -- read >= write, so will not cause overflow
          if (line_rate_en(i)='1') then
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + wr_data(i) - rd_data(i) + 20 - 20;
          else
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + wr_data(i) - rd_data(i);
          end if;
    elsif (wr_en(i)='1' and rd_en(i)='0') then
        -- write only
      if   ((rate_counter(i)(29 downto 0) < buffer_capacity(i) and buffer_capacity(i) > 0) or
            (                                                      buffer_capacity(i) = 0)   ) then
          -- not overflow yet
          if (line_rate_en(i)='1') then
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + wr_data(i) - 0          + 20 -  0;
          else
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + wr_data(i) - 0                   ;
          end if;
      end if;
    elsif (wr_en(i)='0' and rd_en(i)='1') then
        -- read only  -- no consequtive read, so no underflow will happen
          if (line_rate_en(i)='1') then
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + 0          - rd_data(i) +  0 - 20;
          else
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + 0          - rd_data(i);
          end if;
    elsif (rate_counter_stable(i)>buffer_capacity(i) and buffer_capacity(i) > 0) then
            rate_counter(i)(15 downto 0 ) <= buffer_capacity(i)(15 downto 0 );
    else
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + 0          - 0                   ; --
    end if;
    -- update upper bits with simple logic, glitches will be generated due to 1 clk delay of response to lower bits
    if    (rate_counter(i)(15 downto 14)="00" and rate_counter_d1(i)(15 downto 14)="11") then
            -- carry-in from lower bits
            rate_counter(i)(29 downto 16) <= rate_counter(i)(29 downto 16) + 1          - 0                   ; --
    elsif (rate_counter(i)(15 downto 14)="11" and rate_counter_d1(i)(15 downto 14)="00") then
            -- borrow-in from lower bits
            rate_counter(i)(29 downto 16) <= rate_counter(i)(29 downto 16) + 0          - 1                   ; --	    
    elsif (rate_counter_stable(i)>buffer_capacity(i) and buffer_capacity(i) > 0) then
            rate_counter(i)(29 downto 16) <= buffer_capacity(i)(29 downto 16);
    else
            rate_counter(i)(29 downto 16) <= rate_counter(i)(29 downto 16) + 0          - 0                   ; --
    end if;
  end if;
end process;
-- use a low-pass filter to filter out the counter glitches when borrow-in or carry-in occurs
process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
      rate_counter_stable(i) <= (others=>'0');
      rate_counter_d1(i)     <= (others=>'0');
      rate_counter_d2(i)     <= (others=>'0');
  elsif (clk'event and clk='1') then
    if (rate_counter_d1(i) = rate_counter_d2(i)) then
      rate_counter_stable(i) <= rate_counter_d2(i);
    else
      rate_counter_stable(i) <= rate_counter_stable(i);
    end if;
      rate_counter_d1(i)     <= rate_counter(i);
      rate_counter_d2(i)     <= rate_counter_d1(i);
  end if;
end process;
end generate;

----------------------------------------------------
-- REMOVE THE FOLLOWING LOOP FOR MULTIPLE BURSTING
----------------------------------------------------
buffer_level_2_15 : for i in 2 to 7 generate
-- use seperate lower and upper bits counter updating to cut down long paths to improve timing
rate_counter(i)(29 downto 16) <= (others=>'0');
process (fsm_rst, clk)
begin
  if (fsm_rst='1') then
            rate_counter(i)(15 downto 0 ) <= (others=>'0');
  elsif (clk'event and clk='1') then
    -- update lower bits with complex logic
    if    (wr_en(i)='1' and rd_en(i)='1') then
        -- write and read  -- read >= write, so will not cause overflow
          if (line_rate_en(i)='1') then
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + wr_data(i) - rd_data(i) + 20 - 20;
          else
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + wr_data(i) - rd_data(i);
          end if;
    elsif (wr_en(i)='1' and rd_en(i)='0') then
        -- write only
      if   ((rate_counter(i)(15 downto 0) < buffer_capacity(i) and buffer_capacity(i) > 0) or
            (                                                      buffer_capacity(i) = 0)   ) then
          -- not overflow yet
          if (line_rate_en(i)='1') then
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + wr_data(i) - 0          + 20 -  0;
          else
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + wr_data(i) - 0                   ;
          end if;
      end if;
    elsif (wr_en(i)='0' and rd_en(i)='1') then
        -- read only  -- no consequtive read, so no underflow will happen
          if (line_rate_en(i)='1') then
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + 0          - rd_data(i) +  0 - 20;
          else
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + 0          - rd_data(i);
          end if;
    elsif (rate_counter(i)>buffer_capacity(i) and buffer_capacity(i) > 0) then
            rate_counter(i)(15 downto 0 ) <= buffer_capacity(i)(15 downto 0 );
    else
            rate_counter(i)(15 downto 0 ) <= rate_counter(i)(15 downto 0 ) + 0          - 0                   ; --
    end if;
--    -- update upper bits with simple logic, glitches will be generated due to 1 clk delay of response to lower bits
--    if    (rate_counter(i)(15 downto 14)="00" and rate_counter_d1(i)(15 downto 14)="11") then
--            -- carry-in from lower bits
--            rate_counter(i)(29 downto 16) <= rate_counter(i)(29 downto 16) + 1        - 0                   ; --
--    elsif (rate_counter(i)(15 downto 14)="11" and rate_counter_d1(i)(15 downto 14)="00") then
--            -- borrow-in from lower bits
--            rate_counter(i)(29 downto 16) <= rate_counter(i)(29 downto 16) + 0        - 1                   ; --	    
--    elsif (rate_counter(i)>buffer_capacity(i)) then
--            rate_counter(i)(29 downto 16) <= buffer_capacity(i)(29 downto 16);
--    else
--            rate_counter(i)(29 downto 16) <= rate_counter(i)(29 downto 16) + 0        - 0                   ; --
--    end if;
  end if;
end process;
-- use a low-pass filter to filter out the counter glitches when borrow-in or carry-in occurs
process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
      rate_counter_stable(i) <= (others=>'0');
      rate_counter_d1(i)     <= (others=>'0');
      rate_counter_d2(i)     <= (others=>'0');
  elsif (clk'event and clk='1') then
    if (rate_counter_d1(i) = rate_counter_d2(i)) then
      rate_counter_stable(i) <= rate_counter_d2(i);
    else
      rate_counter_stable(i) <= rate_counter_stable(i);
    end if;
      rate_counter_d1(i)     <= rate_counter(i);
      rate_counter_d2(i)     <= rate_counter_d1(i);
  end if;
end process;
end generate;

-- bwp_fsm loop --
bwp_fsm_loop: for i in 0 to 1 generate

process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    buffer_full(i)   <= '0';
    buffer_half(i)   <= '0';
    buffer_ovfl(i)   <= '0';
    buffer_hold(i)   <= '0';
    buffer_empty(i)  <= '1';
    --buffer_margin(i) <= '1';
    duty_reached(i)  <= '0';
    cycle_reached(i) <= '0';
  elsif (clk'event and clk='1') then
    if (rate_counter_stable(i) >= buffer_capacity(i)(29 downto 0)                                  ) then 
      buffer_full(i)   <= '1'; else buffer_full(i)   <= '0'; end if;

    if (rate_counter_stable(i) >= buffer_capacity(i)(29 downto 1)                                  ) then 
      buffer_half(i)   <= '1'; else buffer_half(i)   <= '0'; end if; -- 1/2

    if (ovfl_counter(i) >= buffer_capacity(i)(29 downto 6) + buffer_capacity(i)(29 downto 8)       ) then 
      buffer_ovfl(i)   <= '1'; else buffer_ovfl(i)   <= '0'; end if; -- 1/64 + 1/256 = 1.9%

    if (rate_counter_stable(i) >= buffer_hold_level(i)                                             ) then 
      buffer_hold(i)   <= '1'; else buffer_hold(i)   <= '0'; end if;

    if (line_rate_en(i)='1') then
    if (rate_counter_stable(i) < safe_margin(i) + leng_holder_d1(i) + 20 or leng_holder_d1(i) = 0  ) then
      buffer_empty(i)  <= '1'; else buffer_empty(i)  <= '0'; end if;
    else
    if (rate_counter_stable(i) < safe_margin(i) + leng_holder_d1(i)      or leng_holder_d1(i) = 0  ) then
      buffer_empty(i)  <= '1'; else buffer_empty(i)  <= '0'; end if;
    end if;

    --if (line_rate_en(i)='1') then
    --if (rate_counter_stable(i) < safe_margin(i) + 32 + 20                                          ) then
    --  buffer_margin(i) <= '1'; else buffer_margin(i)  <= '0'; end if;
    --else
    --if (rate_counter_stable(i) < safe_margin(i) + 32                                               ) then
    --  buffer_margin(i) <= '1'; else buffer_margin(i)  <= '0'; end if;
    --end if;

    if (state_sr_d1(i)='1' and space_frame_cnt(i)&X"00" >= duty_cycle_result(i)(47 downto 0)       ) then 
      duty_reached(i)  <= '1'; else duty_reached(i)  <= '0'; end if;

    if (cycle_counter(i) >= cycle_number(i)                                                        ) then 
      cycle_reached(i) <= '1'; else cycle_reached(i) <= '0'; end if;
  end if;
end process;

process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    cycle_counter(i) <= (others=>'0');
  elsif (clk'event and clk='1') then
    if (burst_once_mask(i)='1') then
      if (state_br(i)='0' and state_br_d1(i)='1') then  -- leaving br state
        cycle_counter(i) <= cycle_counter(i) + 1;
      end if;
    else
      if (state_fh(i)='0' and state_fh_d1(i)='1') then  -- leaving fh state
        cycle_counter(i) <= cycle_counter(i) + 1;
      end if;
    end if;
  end if;
end process;

process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    burst_frame_enable(i) <= '0';
    space_frame_enable(i) <= '0';
     idle_frame_enable(i) <= '0';
  elsif (clk'event and clk='1') then
    if (state_br_d1(i)='1' and buffer_empty(i)='0') then
      burst_frame_enable(i) <= '1';
    else
      burst_frame_enable(i) <= '0';
    end if;
    if (state_sr_d1(i)='1' and buffer_empty(i)='0' and buffer_hold(i)='1' and (duty_cycle_factor(i)/=0 or burst_test_mask(i)='0')) then
      space_frame_enable(i) <= '1';
    else
      space_frame_enable(i) <= '0';
    end if;
    if (state_ti(i)='1' and buffer_full(i)='1' and test_start_d6='1' and test_start_d1='1' and external_not_idle='1') then
       idle_frame_enable(i) <= '1';
    else
       idle_frame_enable(i) <= '0';
    end if;
  end if;
end process;

process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    burst_frame_sent(i) <= '0';
    space_frame_sent(i) <= '0';
     idle_frame_sent(i) <= '0';
  elsif (clk'event and clk='1') then
    if (state_br_d1(i)='1' and rate_rd_d1='1' and i=CONV_INTEGER(rate_data_d1(3 downto 0))) then
      burst_frame_sent(i) <= '1';
    else
      burst_frame_sent(i) <= '0';
    end if;
    if (state_sr_d1(i)='1' and rate_rd_d1='1' and i=CONV_INTEGER(rate_data_d1(3 downto 0))) then
      space_frame_sent(i) <= '1';
    else
      space_frame_sent(i) <= '0';
    end if;
    if (state_ti_d1(i)='1' and rate_rd_d1='1' and i=CONV_INTEGER(rate_data_d1(3 downto 0))) then
       idle_frame_sent(i) <= '1';
    else
       idle_frame_sent(i) <= '0';
    end if;
  end if;
end process;

process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    burst_frame_cnt(i) <= (others=>'0');
    space_frame_cnt(i) <= (others=>'0');
     idle_frame_cnt(i) <= (others=>'0');
  elsif (clk'event and clk='1') then
    if (state_ff_d1(i)='1') then
      burst_frame_cnt(i) <= (others=>'0');
    elsif (burst_frame_sent(i)='1') then
      burst_frame_cnt(i) <= burst_frame_cnt(i) + 1;
    end if;
    if (state_fh_d1(i)='1') then
      space_frame_cnt(i) <= (others=>'0');
    elsif (space_frame_sent(i)='1') then
      space_frame_cnt(i) <= space_frame_cnt(i) + 1;
    end if;
    if (state_ff_d1(i)='1') then
       idle_frame_cnt(i) <= (others=>'0');
    elsif (idle_frame_sent(i)='1' and external_stop(i)='1') then
       idle_frame_cnt(i) <=  idle_frame_cnt(i) + 1;
    end if;
  end if;
end process;

process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    ovfl_counter(i) <= (others=>'0');
  elsif (clk'event and clk='1') then
    if (buffer_full(i)='0') then
      ovfl_counter(i) <= (others=>'0');
    elsif (frame_fifo_wr_in='1' and i=CONV_INTEGER(frame_fifo_data_in(2 downto 0))) then
      ovfl_counter(i) <= ovfl_counter(i) + frame_fifo_data_in(29 downto 16);
    end if;
  end if;
end process;

calculate_duty_cycle : multiplier_32_32_d4
port map
  (
  aclr => '0', --fsm_rst,
  clock => clk,
  dataa	=> burst_frame_cnt(i),
  datab	=> duty_cycle_factor(i),
  result => duty_cycle_result(i)
  );

process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    buffer_hold_level(i) <= (others=>'0');
  elsif (clk'event and clk='1') then
    --if (buffer_hold_level(i) >= buffer_capacity(i)-leng_holder(i)) then
    --  buffer_hold_level(i) <= buffer_capacity(i)-leng_holder(i);
    if (state_sr(i)='1' and state_sr_d1(i)='0') then
      buffer_hold_level(i) <= rate_counter_stable(i);
    --elsif (state_sr(i)='1' and rate_rd='1' and i=CONV_INTEGER(rate_data(3 downto 0))) then
    --  buffer_hold_level(i) <= rate_counter_stable(i);
    end if;
  end if;
end process;

u_bwp_fsm : bwp_fsm
    port map
    (
        reset => fsm_rst,
        clock => clk,
        test_start => fsm_start, --test_start_d5,
        buffer_full => buffer_full(i),
        buffer_half => buffer_half(i),
        buffer_ovfl => buffer_ovfl(i),
        buffer_empty => buffer_empty(i), --buffer_margin(i),
        duty_reached => duty_reached(i),
        cycle_reached => cycle_reached(i),
        burst_test => burst_test_mask(i),
        burst_disabled => burst_disable(i),
        burst_once => burst_once_mask(i),
        wait_once => wait_once(i),
        external_int => external_int(i),
        state_ti => state_ti(i),
        state_ff => state_ff(i),
        state_br => state_br(i),
        state_fh => state_fh(i),
        state_sr => state_sr(i)
    );

end generate;
-- end --


----------------------------------------------------
-- REMOVE THE FOLLOWING LOOP FOR MULTIPLE BURSTING
----------------------------------------------------
none_bursting_stream_loop: for i in 2 to 7 generate

state_br(i) <= '0';
idle_frame_enable(i)  <= '0';
burst_frame_enable(i) <= '0';
buffer_hold(i) <= '0';
buffer_hold_level(i) <= (others=>'0');

process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    buffer_empty(i)  <= '1';
  elsif (clk'event and clk='1') then
    if (line_rate_en(i)='1') then
    if (rate_counter_stable(i)(15 downto 0) < leng_holder_d1(i) + 20 or leng_holder_d1(i) = 0) then
      buffer_empty(i)  <= '1'; else buffer_empty(i)  <= '0'; end if;
    else
    if (rate_counter_stable(i)(15 downto 0) < leng_holder_d1(i)      or leng_holder_d1(i) = 0) then
      buffer_empty(i)  <= '1'; else buffer_empty(i)  <= '0'; end if;
    end if;
  end if;
end process;

--buffer_margin(i) <= '1';

process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    space_frame_enable(i) <= '0';
  elsif (clk'event and clk='1') then
    if (test_start_d6='1' and buffer_empty(i)='0') then
      space_frame_enable(i) <= '1';
    else
      space_frame_enable(i) <= '0';
    end if;
  end if;
end process;
end generate;

-- all streams must start from the same point --
-- burst once stream must be fulfilled first --
process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    wait_once <= "00000000";
  elsif (clk'event and clk='1') then
    if ((state_ff_d1(00)='1' and buffer_ovfl(00)='0' and cycle_counter(00)=0) or 
        (state_ff_d1(01)='1' and buffer_ovfl(01)='0' and cycle_counter(01)=0)) then
      wait_once <= "11111111";
    elsif ((state_ff_d1(00)='1' or state_br_d1(00)='1') and burst_once_mask(00)='1' and cycle_reached(00)='0') then
      wait_once <= "11111110";
--    elsif ((state_ff_d1(01)='1' or state_br_d1(01)='1') and burst_once_mask(01)='1') then
--      wait_once <= "11111100";
--    elsif ((state_ff_d1(02)='1' or state_br_d1(02)='1') and burst_once_mask(02)='1') then
--      wait_once <= "11111000";
--    elsif ((state_ff_d1(03)='1' or state_br_d1(03)='1') and burst_once_mask(03)='1') then
--      wait_once <= "11110000";
--    elsif ((state_ff_d1(04)='1' or state_br_d1(04)='1') and burst_once_mask(04)='1') then
--      wait_once <= "11100000";
--    elsif ((state_ff_d1(05)='1' or state_br_d1(05)='1') and burst_once_mask(05)='1') then
--      wait_once <= "11000000";
--    elsif ((state_ff_d1(06)='1' or state_br_d1(06)='1') and burst_once_mask(06)='1') then
--      wait_once <= "10000000";
--    elsif ((state_ff_d1(07)='1' or state_br_d1(07)='1') and burst_once_mask(07)='1') then
--      wait_once <= "00000000";
    else
      wait_once <= "00000000";
    end if;
  end if;
end process;
-- end --

-- burst priority when multiple state machines enter the burst_rate state, --
-- state machine must be designed to prevent a higher priority state machine from preempting a running one--
process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
      burst_disable <= "00000000";
  elsif (clk'event and clk='1') then
       if (state_br(00)='1') then
      burst_disable <= "11111110";
    elsif (state_br(01)='1') then
      burst_disable <= "11111101";
    elsif (state_br(02)='1') then
      burst_disable <= "11111011";
    elsif (state_br(03)='1') then
      burst_disable <= "11110111";
    elsif (state_br(04)='1') then
      burst_disable <= "11101111";
    elsif (state_br(05)='1') then
      burst_disable <= "11011111";
    elsif (state_br(06)='1') then
      burst_disable <= "10111111";
    elsif (state_br(07)='1') then
      burst_disable <= "01111111";
    else
      burst_disable <= "00000000";
    end if;
  end if;
end process;
-- end --

-- interrupt burst_once state machines when bursting ones finished -- CM=0
-- assuming only stream 1 is set to burst once, and stream 2 is cycling
process (fsm_rst, clk)
begin
  if (fsm_rst='1') then
    external_int <= (others=>'0');
  elsif (clk'event and clk='1') then
    --if (cycle_reached=burst_test_mask) then
    --  external_int <= burst_once_mask;
    --if (cycle_reached(1 downto 1)=burst_test_mask(1 downto 1) and state_ti_d1(1 downto 1)=burst_test_mask(1 downto 1)) then
    --  external_int <= "0000000000000001";
    if (cycle_reached(1 downto 1)="1" and state_ti_d1(1 downto 1)="1") then
      external_int <= "00000001";
    else
      external_int <= "00000000";
    end if;
  end if;
end process;
-- end --

-- stop all idle state machines when all enters idle state -- CM=1
-- assuming only stream 1 is set to burst once, and stream 2 is cycling
process (fsm_rst, clk)
begin
  if (fsm_rst='1') then
    external_stop <= (others=>'0');
  elsif (clk'event and clk='1') then
    --if (state_ti_d1=burst_test_mask) then
    --  external_stop <= burst_test_mask;
    if (state_ti_d1(1 downto 0)=burst_test_mask(1 downto 0)) then
      external_stop <= "00000011";  --burst_test_mask(1 downto 0)
    else
      external_stop <= "00000000";
    end if;
  end if;
end process;
-- end --

-- not all stream in idle state
-- assuming only stream 1 and stream 2 is cycling
process (fsm_rst, clk)
begin
  if (fsm_rst='1') then
    external_not_idle <= '0';
  elsif (clk'event and clk='1') then
    if ((burst_test_mask(0)='1' and idle_frame_cnt(0)=0) or (burst_test_mask(1)='1' and idle_frame_cnt(1)=0)) then
      external_not_idle <= '1';
    else
      external_not_idle <= '0';
    end if;
  end if;
end process;
-- end --

-- pipeline registers to improve timing
process (clk)
begin
  if (clk'event and clk='1') then
    rate_rd_d1      <= rate_rd;
    rate_rd_d2      <= rate_rd_d1;
    rate_rd_d3      <= rate_rd_d2;
    rate_rd_d4      <= rate_rd_d3;
    rate_rd_d5      <= rate_rd_d4;
    rate_rd_d6      <= rate_rd_d5;
    rate_rd_d7      <= rate_rd_d6;
    rate_data_d1    <= rate_data;
    rate_data_d2    <= rate_data_d1;
    rate_data_d3    <= rate_data_d2;
    rate_data_d4    <= rate_data_d3;
    rate_data_d5    <= rate_data_d4;
    rate_data_d6    <= rate_data_d5;
    rate_data_d7    <= rate_data_d6;

    state_ti_d1     <= state_ti;
    state_ff_d1     <= state_ff;
    state_br_d1     <= state_br;
    state_fh_d1     <= state_fh;
    state_sr_d1     <= state_sr;
  end if;
end process;

-- scheduler --
process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    rate_rd      <= '0';
    rate_data    <= (others=>'0');
  elsif (clk'event and clk='1') then
    --if (rate_rd='1' or rate_rd_d1='1' or frame_fifo_wr_stop='1') then
    if (rate_rd='1' or rate_rd_d1='1' or rate_rd_d2='1' or rate_rd_d3='1' or rate_rd_d4='1' or rate_rd_d5='1' or rate_rd_d6='1' or rate_rd_d7='1') then  -- rate control
      rate_rd <= '0';

--    elsif (burst_once_mask /= "0000000000000000") then
--      -- spaced rate traffic should take precedence
      -- idle state frame
      elsif (idle_frame_enable(00)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(00) & CONV_STD_LOGIC_VECTOR(0,16);
      elsif (idle_frame_enable(01)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(01) & CONV_STD_LOGIC_VECTOR(1,16);
      elsif (idle_frame_enable(02)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(02) & CONV_STD_LOGIC_VECTOR(2,16);
      elsif (idle_frame_enable(03)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(03) & CONV_STD_LOGIC_VECTOR(3,16);
      elsif (idle_frame_enable(04)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(04) & CONV_STD_LOGIC_VECTOR(4,16);
      elsif (idle_frame_enable(05)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(05) & CONV_STD_LOGIC_VECTOR(5,16);
      elsif (idle_frame_enable(06)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(06) & CONV_STD_LOGIC_VECTOR(6,16);
      elsif (idle_frame_enable(07)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(07) & CONV_STD_LOGIC_VECTOR(7,16);
      -- spaced rate frame
      elsif (space_frame_enable(00)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(00) & CONV_STD_LOGIC_VECTOR(0,16);
      elsif (space_frame_enable(01)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(01) & CONV_STD_LOGIC_VECTOR(1,16);
      elsif (space_frame_enable(02)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(02) & CONV_STD_LOGIC_VECTOR(2,16);
      elsif (space_frame_enable(03)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(03) & CONV_STD_LOGIC_VECTOR(3,16);
      elsif (space_frame_enable(04)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(04) & CONV_STD_LOGIC_VECTOR(4,16);
      elsif (space_frame_enable(05)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(05) & CONV_STD_LOGIC_VECTOR(5,16);
      elsif (space_frame_enable(06)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(06) & CONV_STD_LOGIC_VECTOR(6,16);
      elsif (space_frame_enable(07)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(07) & CONV_STD_LOGIC_VECTOR(7,16);
      -- burst rate frame
      elsif (burst_frame_enable(00)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(00) & CONV_STD_LOGIC_VECTOR(0,16);
      elsif (burst_frame_enable(01)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(01) & CONV_STD_LOGIC_VECTOR(1,16);
      elsif (burst_frame_enable(02)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(02) & CONV_STD_LOGIC_VECTOR(2,16);
      elsif (burst_frame_enable(03)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(03) & CONV_STD_LOGIC_VECTOR(3,16);
      elsif (burst_frame_enable(04)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(04) & CONV_STD_LOGIC_VECTOR(4,16);
      elsif (burst_frame_enable(05)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(05) & CONV_STD_LOGIC_VECTOR(5,16);
      elsif (burst_frame_enable(06)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(06) & CONV_STD_LOGIC_VECTOR(6,16);
      elsif (burst_frame_enable(07)='1') then
          rate_rd          <= '1';
          rate_data        <= "00"&leng_holder_d1(07) & CONV_STD_LOGIC_VECTOR(7,16);

    end if;
  end if;
end process;
-- end --

-- emix_pointer --
emix_pointer_loop: for i in 0 to 7 generate
process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    emix_pointer(i) <= (others=>'0');
    emix_incr(i)    <= (others=>'0');
  elsif (clk'event and clk='1') then
    if    (rate_rd = '1' and i=CONV_INTEGER(rate_data(2 downto 0)) and emix_pointer(i) >= emix_range(i)) then
      emix_pointer(i) <= (others=>'0');        -- cycle back when range reached
    elsif (rate_rd = '1' and i=CONV_INTEGER(rate_data(2 downto 0))) then
      emix_pointer(i) <= emix_pointer(i) + 1;  -- advance forward when current one is used
    --elsif (emix_incr(i)="11" and state_br_d1(i)='1' and buffer_empty(i)='1' and buffer_margin(i)='0' and burst_frame_enable(i)='0' and 
    --       emix_pointer(i) >= emix_range(i)) then
    --  emix_pointer(i) <= (others=>'0');        -- cycle back when range reached
    --elsif (emix_incr(i)="11" and state_br_d1(i)='1' and buffer_empty(i)='1' and buffer_margin(i)='0' and burst_frame_enable(i)='0') then
    --  emix_pointer(i) <= emix_pointer(i) + 1;  -- advance forward searching for shorter frame length
    end if;

    --if ((rate_rd = '1' and i=CONV_INTEGER(rate_data(3 downto 0))) or (emix_range(i)="0000")) then
    --  emix_incr(i)    <= (others=>'0');
    --elsif (                      state_br_d1(i)='1' and buffer_empty(i)='1' and buffer_margin(i)='0' and burst_frame_enable(i)='0') then
    --  emix_incr(i)    <= emix_incr(i) + 1;
    --end if;
  end if;
end process;
end generate;
process (fsm_rst,clk)
begin
  if (fsm_rst='1') then
    emix_pointer_all <= (others=>'0');
  elsif (clk'event and clk='1') then
    if    (rate_rd = '1' and (emix_pointer_all >= emix_range_in_all)) then
      emix_pointer_all <= (others=>'0');        -- cycle back when range reached
    elsif (rate_rd = '1') then
      emix_pointer_all <= emix_pointer_all + 1;  -- advance forward when current one is used
    end if;
  end if;
end process;
-- end --

-- cpu write in emix values --
process (up_addr(11 downto 2), up_wr) begin
  up_wr_emix                 <= up_addr(11) and up_wr;  -- higher 2048B for EMIX lengths
  up_addr_emix ( 8 downto 0) <= up_addr(10 downto 2);   -- 256B = 128x 16b-entry, only 32x 16b-entry used
end process;

-- rate read out emix values --
process (rate_data(2 downto 0), emix_pointer) begin
    rd_addr_emix ( 9 downto 0) <= rate_data(2 downto 0) & "000" & emix_pointer(CONV_INTEGER(rate_data(2 downto 0)));
end process;
process (emix_pointer_all) begin
    rd_addr_emix_all ( 9 downto 0) <= emix_pointer_all;
end process;

EMIX_mem : dpram_dc_32_512_16_1024
port map(
  aclr_a        => rst,
  clock_a	=> up_clk,
  enable_a      => '1',
  address_a	=> up_addr_emix,
  data_a	=> up_data_wr,
  rden_a	=> '0',	
  wren_a	=> up_wr_emix,
  q_a		=> open,   

  aclr_b        => rst,
  clock_b	=> clk,
  enable_b      => '1',
  address_b	=> rd_addr_emix_all,
  data_b	=> (others=>'0'),
  rden_b	=> '1',	
  wren_b	=> '0',
  q_b		=> leng_holder
);
-- end --

-- module output stage --
frame_fifo_wr_out   <= rate_rd_d1;
frame_fifo_data_out <= X"0" & rate_data_d1;
-- end --
end synth;

