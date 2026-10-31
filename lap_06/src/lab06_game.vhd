-- FAP201 Lab06 - reusable game core, synthesizable VHDL-2008
-- Inputs start and press_onehot are single-clock events.
-- Logical keys/LEDs are active-high INSIDE the core.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab06_game is
  generic (
    G_OFF_TICKS  : positive := 15000000; -- 0.3 s at 50 MHz
    G_SHOW_TICKS : positive := 20000000  -- 0.4 s at 50 MHz
  );
  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;  -- synchronous, active-high
    start_i     : in  std_logic;  -- one clock pulse, also replay
    press_i     : in  std_logic_vector(2 downto 0); -- one-hot pulses
    leds_o      : out std_logic_vector(2 downto 0);
    score_o     : out std_logic_vector(3 downto 0); -- current round 1..7
    status_o    : out std_logic_vector(1 downto 0); -- 00 playing, 01 lose, 10 win
    state_o     : out std_logic_vector(2 downto 0); -- 0 idle; 1 off; 2 show; 3 input; 4 win; 5 lose
    show_idx_o  : out std_logic_vector(2 downto 0);
    input_idx_o : out std_logic_vector(2 downto 0)
  );
end entity;

architecture rtl of lab06_game is
  type state_t is (IDLE, PATTERN_OFF, PATTERN_SHOW, WAIT_PLAYER, WIN, LOSE);
  type pattern_t is array (0 to 6) of integer range 0 to 2;
  signal pattern : pattern_t := (0, 1, 2, 0, 1, 2, 0);
  signal state   : state_t := IDLE;
  signal count   : natural := 0;
  signal round_len : integer range 1 to 7 := 1;
  signal show_idx  : integer range 0 to 6 := 0;
  signal input_idx : integer range 0 to 6 := 0;
  signal seed : unsigned(7 downto 0) := x"5A";
  signal game_id : integer range 0 to 2 := 0;

  function lfsr_step(v : unsigned(7 downto 0)) return unsigned is
    variable n : unsigned(7 downto 0);
  begin
    -- x^8 + x^6 + x^5 + x^4 + 1; deterministic, non-cryptographic
    n := v(6 downto 0) & (v(7) xor v(5) xor v(4) xor v(3));
    if n = to_unsigned(0, 8) then n := x"5A"; end if;
    return n;
  end function;

  function onehot_symbol(x : integer) return std_logic_vector is
  begin
    case x is
      when 0 => return "001";
      when 1 => return "010";
      when others => return "100";
    end case;
  end function;
begin
  leds_o <= onehot_symbol(pattern(show_idx)) when state = PATTERN_SHOW else "000";
  score_o <= std_logic_vector(to_unsigned(round_len, 4));
  status_o <= "10" when state = WIN else "01" when state = LOSE else "00";
  state_o <= "000" when state = IDLE else
             "001" when state = PATTERN_OFF else
             "010" when state = PATTERN_SHOW else
             "011" when state = WAIT_PLAYER else
             "100" when state = WIN else "101";
  show_idx_o <= std_logic_vector(to_unsigned(show_idx, 3));
  input_idx_o <= std_logic_vector(to_unsigned(input_idx, 3));

  process(clk_i)
    variable next_seed : unsigned(7 downto 0);
    variable sym : integer range 0 to 2;
    variable valid_onehot : boolean;
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        state <= IDLE;
        count <= 0;
        round_len <= 1;
        show_idx <= 0;
        input_idx <= 0;
        seed <= x"5A";
        game_id <= 0;
      else
        case state is
          when IDLE | WIN | LOSE =>
            if start_i = '1' then
              if state /= IDLE then
                if game_id = 2 then game_id <= 0; else game_id <= game_id + 1; end if;
              end if;
              next_seed := lfsr_step(seed);
              for i in 0 to 6 loop
                next_seed := lfsr_step(next_seed);
                if i = 0 then
                  if state = IDLE then sym := game_id;
                  elsif game_id = 2 then sym := 0;
                  else sym := game_id + 1;
                  end if;
                else
                  case next_seed(1 downto 0) is
                    when "00" => sym := 0;
                    when "01" => sym := 1;
                    when others => sym := 2;
                  end case;
                end if;
                pattern(i) <= sym;
              end loop;
              seed <= next_seed;
              round_len <= 1;
              show_idx <= 0;
              input_idx <= 0;
              count <= 0;
              state <= PATTERN_OFF;
            end if;
          when PATTERN_OFF =>
            if count = G_OFF_TICKS - 1 then
              count <= 0;
              state <= PATTERN_SHOW;
            else
              count <= count + 1;
            end if;
          when PATTERN_SHOW =>
            if count = G_SHOW_TICKS - 1 then
              count <= 0;
              if show_idx = round_len - 1 then
                show_idx <= 0;
                input_idx <= 0;
                state <= WAIT_PLAYER;
              else
                show_idx <= show_idx + 1;
                state <= PATTERN_OFF;
              end if;
            else
              count <= count + 1;
            end if;
          when WAIT_PLAYER =>
            valid_onehot := (press_i = "001") or (press_i = "010") or (press_i = "100");
            if press_i /= "000" then
              if valid_onehot and (press_i = onehot_symbol(pattern(input_idx))) then
                if input_idx = round_len - 1 then
                  if round_len = 7 then
                    state <= WIN;
                  else
                    round_len <= round_len + 1;
                    input_idx <= 0;
                    show_idx <= 0;
                    count <= 0;
                    state <= PATTERN_OFF;
                  end if;
                else
                  input_idx <= input_idx + 1;
                end if;
              else
                state <= LOSE;
              end if;
            end if;
        end case;
      end if;
    end if;
  end process;
end architecture;