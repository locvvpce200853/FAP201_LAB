library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab04_tb is
end entity lab04_tb;

architecture sim of lab04_tb is
    constant CLK_PERIOD : time := 20 ns;
    signal clk : STD_LOGIC := '0';
    signal i_sw_raw : STD_LOGIC := '0';
    signal i_rst : STD_LOGIC := '0';
    signal o_led, o_dbg_stable : STD_LOGIC;
begin
    clk <= not clk after CLK_PERIOD / 2;

    DUT : entity work.lab04
        generic map (STABLE_CYCLES => 5)
        port map (
            clk => clk, i_sw_raw => i_sw_raw, i_rst => i_rst,
            o_led => o_led, o_dbg_stable => o_dbg_stable
        );

    stimulus : process
    begin
        i_rst <= '1'; wait for 4 * CLK_PERIOD;
        i_rst <= '0'; wait for 3 * CLK_PERIOD;
        assert o_led = '0' report "T0 FAILED: LED reset" severity error;
        assert o_dbg_stable = '0' report "T0 FAILED: stable reset" severity error;

        -- Press with bounce.
        i_sw_raw <= '1'; wait for CLK_PERIOD;
        i_sw_raw <= '0'; wait for CLK_PERIOD;
        i_sw_raw <= '1'; wait for CLK_PERIOD;
        i_sw_raw <= '0'; wait for CLK_PERIOD;
        i_sw_raw <= '1'; wait for 12 * CLK_PERIOD;
        assert o_dbg_stable = '1' report "T1 FAILED: press not accepted" severity error;
        assert o_led = '0' report "T1 FAILED: press toggled LED" severity error;

        -- Hold: no extra toggle.
        wait for 20 * CLK_PERIOD;
        assert o_led = '0' report "T2 FAILED: LED changed while pressed" severity error;

        -- Release with bounce.
        i_sw_raw <= '0'; wait for CLK_PERIOD;
        i_sw_raw <= '1'; wait for CLK_PERIOD;
        i_sw_raw <= '0'; wait for CLK_PERIOD;
        i_sw_raw <= '1'; wait for CLK_PERIOD;
        i_sw_raw <= '0'; wait for 16 * CLK_PERIOD;
        assert o_dbg_stable = '0' report "T3 FAILED: release not accepted" severity error;
        assert o_led = '1' report "T3 FAILED: first release must toggle ON" severity error;

        wait for 20 * CLK_PERIOD;
        assert o_led = '1' report "T4 FAILED: extra toggle" severity error;

        -- Second cycle.
        i_sw_raw <= '1'; wait for CLK_PERIOD;
        i_sw_raw <= '0'; wait for CLK_PERIOD;
        i_sw_raw <= '1'; wait for 12 * CLK_PERIOD;
        assert o_led = '1' report "T5 FAILED: press toggled" severity error;
        i_sw_raw <= '0'; wait for CLK_PERIOD;
        i_sw_raw <= '1'; wait for CLK_PERIOD;
        i_sw_raw <= '0'; wait for 16 * CLK_PERIOD;
        assert o_led = '0' report "T5 FAILED: second release must toggle OFF" severity error;

        i_rst <= '1'; wait for 2 * CLK_PERIOD;
        i_rst <= '0'; wait for 2 * CLK_PERIOD;
        assert o_led = '0' report "T6 FAILED: reset" severity error;

        report "LAB04: ALL SELF-CHECKING TESTS PASSED" severity note;
        wait;
    end process;
end architecture sim;