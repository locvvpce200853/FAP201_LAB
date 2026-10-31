library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab05_tb is
end entity lab05_tb;

architecture SIM of lab05_tb is
    constant CLK_PERIOD         : time := 20 ns;
    constant C_SIM_LFSR_WIDTH   : positive := 3;
    signal i_Clk       : std_logic := '0';
    signal i_Rst       : std_logic := '1';
    signal i_Switch_1  : std_logic := '0';
    signal i_Switch_2  : std_logic := '0';
    signal o_LED_1     : std_logic;
    signal o_LED_2     : std_logic;
    signal o_LED_3     : std_logic;
    signal o_LED_4     : std_logic;
begin
    i_Clk <= not i_Clk after CLK_PERIOD / 2;

    DUT: entity work.lab05
        generic map (
            G_LFSR_WIDTH => C_SIM_LFSR_WIDTH
        )
        port map (
            i_Clk      => i_Clk,
            i_Rst      => i_Rst,
            i_Switch_1 => i_Switch_1,
            i_Switch_2 => i_Switch_2,
            o_LED_1    => o_LED_1,
            o_LED_2    => o_LED_2,
            o_LED_3    => o_LED_3,
            o_LED_4    => o_LED_4
        );

    STIMULUS: process
        procedure check_selection (
            constant p_Sw2       : in std_logic;
            constant p_Sw1       : in std_logic;
            constant p_LED_Index : in integer
        ) is
            variable v_Seen_Low  : boolean := false;
            variable v_Seen_High : boolean := false;
        begin
            i_Switch_2 <= p_Sw2;
            i_Switch_1 <= p_Sw1;
            wait for 1 ns;
            for k in 0 to 24 loop
                wait until rising_edge(i_Clk);
                wait for 1 ns;
                case p_LED_Index is
                    when 1 =>
                        assert o_LED_2 = '0' and o_LED_3 = '0' and o_LED_4 = '0'
                        report "FAIL: non-selected LED active for selection 00" severity error;
                        if o_LED_1 = '0' then v_Seen_Low := true; else v_Seen_High := true; end if;
                    when 2 =>
                        assert o_LED_1 = '0' and o_LED_3 = '0' and o_LED_4 = '0'
                        report "FAIL: non-selected LED active for selection 01" severity error;
                        if o_LED_2 = '0' then v_Seen_Low := true; else v_Seen_High := true; end if;
                    when 3 =>
                        assert o_LED_1 = '0' and o_LED_2 = '0' and o_LED_4 = '0'
                        report "FAIL: non-selected LED active for selection 10" severity error;
                        if o_LED_3 = '0' then v_Seen_Low := true; else v_Seen_High := true; end if;
                    when 4 =>
                        assert o_LED_1 = '0' and o_LED_2 = '0' and o_LED_3 = '0'
                        report "FAIL: non-selected LED active for selection 11" severity error;
                        if o_LED_4 = '0' then v_Seen_Low := true; else v_Seen_High := true; end if;
                    when others =>
                        assert false report "TB internal error: invalid LED index" severity failure;
                end case;
            end loop;
            assert v_Seen_Low and v_Seen_High
            report "FAIL: selected LED did not blink (both logic levels not observed)" severity error;
        end procedure;
    begin
        report "TEST 0 Reset";
        i_Rst <= '1';
        wait for 4 * CLK_PERIOD;
        wait until rising_edge(i_Clk);
        wait for 1 ns;
        assert o_LED_1 = '0' and o_LED_2 = '0' and o_LED_3 = '0' and o_LED_4 = '0'
        report "FAIL: LEDs must be OFF during reset" severity error;

        i_Rst <= '0';
        report "TEST 1 SW2 SW1=00 -> LED1";
        check_selection('0', '0', 1);

        report "TEST 2 SW2 SW1=01 -> LED2";
        check_selection('0', '1', 2);

        report "TEST 3 SW2 SW1=10 -> LED3";
        check_selection('1', '0', 3);

        report "TEST 4 SW2 SW1=11 -> LED4";
        check_selection('1', '1', 4);

        report "=========";
        report "LAB05 SELF-CHECKING TESTBENCH: PASS";
        report "=========";
        std.env.stop;
        wait;
    end process;
end architecture SIM;