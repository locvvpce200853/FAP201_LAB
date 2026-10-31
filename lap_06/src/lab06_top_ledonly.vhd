-- Board test path: ACG525 50MHz / 3 keys / 3 LEDs.
-- The 7-segment adapter is integrated separately after schematic validation.
-- Pin numbers and polarity MUST be verified with course GPIO table before programming.
library ieee;
use ieee.std_logic_1164.all;
entity lab06_top_ledonly is
  generic (
    G_KEYS_ACTIVE_LOW : boolean := true;
    G_LEDS_ACTIVE_LOW : boolean := false;
    G_STABLE_CYCLES  : positive := 1000000;
    G_OFF_TICKS      : positive := 15000000;
    G_SHOW_TICKS     : positive := 20000000
  );
  port (
    clk_50m_i : in std_logic;
    key_raw_i : in std_logic_vector(2 downto 0);
    led_pin_o : out std_logic_vector(2 downto 0)
  );
end entity;
architecture rtl of lab06_top_ledonly is
  signal pressed : std_logic_vector(2 downto 0);
  signal pulse, stable : std_logic_vector(2 downto 0);
  signal leds : std_logic_vector(2 downto 0);
  signal score : std_logic_vector(3 downto 0);
  signal status : std_logic_vector(1 downto 0);
  signal state_dbg, show_dbg, input_dbg : std_logic_vector(2 downto 0);
  signal powerup_start : std_logic := '1';
  signal start_pulse : std_logic;
begin
  pressed <= not key_raw_i when G_KEYS_ACTIVE_LOW else key_raw_i;
  led_pin_o <= not leds when G_LEDS_ACTIVE_LOW else leds;
  gen_key: for i in 0 to 2 generate
    u_filter: entity work.key_conditioner(rtl)
      generic map(G_STABLE_CYCLES => G_STABLE_CYCLES)
      port map(clk_i => clk_50m_i, rst_i => '0',
               raw_pressed_i => pressed(i),
               press_pulse_o => pulse(i), stable_pressed_o => stable(i));
  end generate;
  -- First game starts automatically after FPGA configuration (requires supported init).
  -- During WIN/LOSE, press KEY0 to start a new game; same 3 physical keys reused.
  process(clk_50m_i)
  begin
    if rising_edge(clk_50m_i) then powerup_start <= '0'; end if;
  end process;
  start_pulse <= powerup_start or (pulse(0) and (status(0) or status(1)));
  u_game: entity work.lab06_game(rtl)
    generic map(G_OFF_TICKS => G_OFF_TICKS, G_SHOW_TICKS => G_SHOW_TICKS)
    port map(clk_i => clk_50m_i, rst_i => '0', start_i => start_pulse,
      press_i => pulse, leds_o => leds, score_o => score,
      status_o => status, state_o => state_dbg,
      show_idx_o => show_dbg, input_idx_o => input_dbg);
end architecture;