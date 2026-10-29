library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Lab04_tb is
end entity Lab04_tb;

architecture sim of Lab04_tb is
    constant CLK_PERIOD : time := 20 ns;

    signal clk          : STD_LOGIC := '0';
    signal i_sw_raw     : STD_LOGIC := '0';
    signal i_rst        : STD_LOGIC := '0';
    signal o_led        : STD_LOGIC;
    signal o_dbg_stable : STD_LOGIC;
begin
    -- 50 MHz simulation clock
    clk <= not clk after CLK_PERIOD / 2;

    -- DUT
    -- Small threshold used only to accelerate simulation.
    DUT : entity work.Lab04
        generic map (
            STABLE_CYCLES => 5
        )
        port map (
            clk          => clk,
            i_sw_raw     => i_sw_raw,
            i_rst        => i_rst,
            o_led        => o_led,
            o_dbg_stable => o_dbg_stable
        );

    -- Stimulus + self-check
    -- Teaching convention:
    -- 1 = pressed
    -- 0 = released
    stimulus : process
    begin
        -- T0. Synchronous reset
        i_rst <= '1';
        wait for 4 * CLK_PERIOD;
        i_rst <= '0';
        wait for 3 * CLK_PERIOD;
        
        assert o_led = '0'
            report "T0 FAILED: LED must reset to 0"
            severity error;
        assert o_dbg_stable = '0'
            report "T0 FAILED: stable switch must reset to 0"
            severity error;

        -- T1. PRESS with bounce: several short glitches.
        -- Final state remains 1 long enough to be accepted.
        i_sw_raw <= '1'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '0'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '1'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '0'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '1';
        
        -- Hold long enough for synchronization + debounce.
        wait for 12 * CLK_PERIOD;
        assert o_dbg_stable = '1'
            report "T1 FAILED: press was not accepted after stable interval"
            severity error;
        assert o_led = '0'
            report "T1 FAILED: press must not toggle LED"
            severity error;

        -- T2. Hold pressed for a long time.
        -- No extra toggle should appear.
        wait for 20 * CLK_PERIOD;
        assert o_led = '0'
            report "T2 FAILED: LED changed while switch remained pressed"
            severity error;

        -- T3. RELEASE with bounce.
        -- Final state remains 0 long enough to be accepted.
        i_sw_raw <= '0'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '1'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '0'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '1'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '0';
        
        -- Allow synchronization, debounce, event detection and toggle.
        wait for 16 * CLK_PERIOD;
        assert o_dbg_stable = '0'
            report "T3 FAILED: release was not accepted"
            severity error;
        assert o_led = '1'
            report "T3 FAILED: first debounced release must toggle LED ON"
            severity error;

        -- T4. Stay released: no additional toggle.
        wait for 20 * CLK_PERIOD;
        assert o_led = '1'
            report "T4 FAILED: LED changed without a new debounced release"
            severity error;

        -- T5. Second press/release cycle with bounce.
        i_sw_raw <= '1'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '0'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '1'; wait for 12 * CLK_PERIOD;
        
        assert o_led = '1'
            report "T5 FAILED: press caused an unexpected toggle"
            severity error;
            
        i_sw_raw <= '0'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '1'; wait for 1 * CLK_PERIOD;
        i_sw_raw <= '0'; wait for 16 * CLK_PERIOD;
        
        assert o_led = '0'
            report "T5 FAILED: second release must toggle LED OFF"
            severity error;

        -- T6. Reset again
        i_rst <= '1'; wait for 2 * CLK_PERIOD;
        i_rst <= '0'; wait for 2 * CLK_PERIOD;
        assert o_led = '0'
            report "T6 FAILED: reset did not clear LED state"
            severity error;

        report "LAB04: ALL SELF-CHECKING TESTS PASSED"
            severity note;
        wait;
    end process;
end architecture sim;