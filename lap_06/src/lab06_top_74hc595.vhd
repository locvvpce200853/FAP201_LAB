-- OPTIONAL seven-segment board top. Validate ACG525 74HC595 wiring FIRST.
library ieee;
use ieee.std_logic_1164.all;
entity lab06_top_74hc595 is
  generic (
    G_KEYS_ACTIVE_LOW  : boolean := true;
    G_LEDS_ACTIVE_LOW  : boolean := false;
    G_STABLE_CYCLES   : positive := 1000000;
    G_OFF_TICKS       : positive := 15000000;
    G_SHOW_TICKS      : positive := 20000000;
    G_SEG_ACTIVE_LOW  : boolean := true;
    G_SEL_ACTIVE_HIGH : boolean := true
  );
  port (
    clk_50m_i : in std_logic;
    key_raw_i : in std_logic_vector(2 downto 0);
    led_pin_o : out std_logic_vector(2 downto 0);
    seg_ds_o  : out std_logic;
    seg_shcp_o: out std_logic;
    seg_stcp_o: out std_logic
  );
end entity;
architecture rtl of lab06_top_74hc595 is
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
  gen_keys: for i in 0 to 2 generate
    u_key: entity work.key_conditioner(rtl)
      generic map(G_STABLE_CYCLES => G_STABLE_CYCLES)
      port map(clk_i => clk_50m_i, rst_i => '0',
        raw_pressed_i => pressed(i), press_pulse_o => pulse(i), stable_pressed_o => stable(i));
  end generate;
  process(clk_50m_i)
  begin
    if rising_edge(clk_50m_i) then powerup_start <= '0'; end if;
  end process;
  start_pulse <= powerup_start or (pulse(0) and (status(0) or status(1)));
  u_game: entity work.lab06_game(rtl)
    generic map(G_OFF_TICKS => G_OFF_TICKS, G_SHOW_TICKS => G_SHOW_TICKS)
    port map(clk_i => clk_50m_i, rst_i => '0', start_i => start_pulse,
      press_i => pulse, leds_o => leds, score_o => score,
      status_o => status, state_o => state_dbg, show_idx_o => show_dbg, input_idx_o => input_dbg);
  u_display: entity work.sevenseg_74hc595(rtl)
    generic map(G_SEG_ACTIVE_LOW => G_SEG_ACTIVE_LOW,
                G_SEL_ACTIVE_HIGH => G_SEL_ACTIVE_HIGH)
    port map(clk_i => clk_50m_i, score_i => score, status_i => status,
             ds_o => seg_ds_o, shcp_o => seg_shcp_o, stcp_o => seg_stcp_o);
end architecture;