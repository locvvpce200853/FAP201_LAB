library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
entity lab06_game_tb is end;
architecture test of lab06_game_tb is
  constant T : time := 20 ns;
  signal clk : std_logic := '0';
  signal rst, start : std_logic := '0';
  signal press : std_logic_vector(2 downto 0) := "000";
  signal leds : std_logic_vector(2 downto 0);
  signal score : std_logic_vector(3 downto 0);
  signal status : std_logic_vector(1 downto 0);
  signal state, showidx, inputidx : std_logic_vector(2 downto 0);
  type seq_t is array(0 to 6) of std_logic_vector(2 downto 0);
begin
  clk <= not clk after T/2;
  dut: entity work.lab06_game(rtl)
    generic map(G_OFF_TICKS => 3, G_SHOW_TICKS => 4)
    port map(clk_i => clk, rst_i => rst, start_i => start, press_i => press,
      leds_o => leds, score_o => score, status_o => status, state_o => state,
      show_idx_o => showidx, input_idx_o => inputidx);

  test: process
    variable seq : seq_t;
    variable original_prefix : seq_t;
    variable first_game_first : std_logic_vector(2 downto 0) := "000";
    variable captured, cycles : integer;
    variable last_led : std_logic_vector(2 downto 0);
    procedure tick is
    begin
      wait until rising_edge(clk);
      wait for 1 ns;
    end procedure;
    procedure begin_game is
    begin
      start <= '1'; tick;
      start <= '0'; tick;
    end procedure;
    procedure send_press(constant choice : in std_logic_vector(2 downto 0)) is
    begin
      press <= choice; tick;
      press <= "000"; tick;
    end procedure;
    procedure watch_round(
      constant required_count : in integer;
      variable seen : out seq_t
    ) is
      variable got : integer := 0;
      variable spent : integer := 0;
      variable prev : std_logic_vector(2 downto 0) := "000";
    begin
      while state /= "011" loop
        assert spent < 300 report "TIMEOUT: game did not enter WAIT_PLAYER" severity failure;
        if leds /= "000" and prev = "000" then
          assert got < required_count report "EXTRA symbol displayed" severity failure;
          assert leds = "001" or leds = "010" or leds = "100"
            report "LED display is not one-hot" severity failure;
          seen(got) := leds;
          got := got + 1;
        end if;
        prev := leds;
        tick;
        spent := spent + 1;
      end loop;
      assert got = required_count report "Wrong number of pattern blinks" severity failure;
      assert to_integer(unsigned(score)) = required_count
        report "Score/round length mismatch" severity failure;
      assert leds = "000" report "LED must be off in input phase" severity failure;
    end procedure;
  begin
    rst <= '1'; tick; tick; rst <= '0'; tick;
    assert state = "000" report "RESET failed" severity failure;
    begin_game;

    for r in 1 to 7 loop
      watch_round(r, seq);
      if r = 1 then first_game_first := seq(0); end if;
      if r > 1 then
        for k in 0 to r - 2 loop
          assert seq(k) = original_prefix(k)
            report "Pattern prefix changed between rounds" severity failure;
        end loop;
      end if;
      for k in 0 to r - 1 loop original_prefix(k) := seq(k); end loop;
      report "PASS: showing round " & integer'image(r) severity note;
      for i in 0 to r-1 loop
        send_press(seq(i));
      end loop;
      if r < 7 then
        assert state = "001" report "Did not advance to next round" severity failure;
      end if;
    end loop;
    assert state = "100" and status = "10"
      report "WIN condition failed after seven correct rounds" severity failure;
    report "PASS: seven-round victory and A status" severity note;

    begin_game;
    watch_round(1, seq);
    assert seq(0) /= first_game_first
      report "Replay did not change the pattern" severity failure;
    report "PASS: replay produced a different pattern" severity note;
    if seq(0) = "001" then send_press("010");
    else send_press("001"); end if;
    assert state = "101" and status = "01"
      report "LOSE status was not reached after wrong key" severity failure;
    report "PASS: wrong key triggers F status" severity note;

    begin_game;
    watch_round(1, seq);
    send_press("011");
    assert state = "101" report "Multiple simultaneous keys not rejected" severity failure;
    report "PASS: multi-key input rejected" severity note;
    report "LAB06_GAME_TB: ALL CHECKS PASS" severity note;
    stop;
    wait;
  end process;
end architecture;