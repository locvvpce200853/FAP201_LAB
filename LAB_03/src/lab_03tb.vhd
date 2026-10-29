library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LAB_03_tb is
end LAB_03_tb;

architecture sim of LAB_03_tb is
    signal i_Clk      : std_logic := '0';
    signal i_Switch_1 : std_logic := '1';
    signal o_LED_1    : std_logic;
begin

    uut : entity work.LAB_03
        generic map (g_DEBOUNCE_LIMIT => 5)
        port map (
            i_Clk      => i_Clk,
            i_Switch_1 => i_Switch_1,
            o_LED_1    => o_LED_1
        );

    i_Clk <= not i_Clk after 10 ns;  -- 50 MHz

    stimulus : process
    begin
        wait for 200 ns;

        i_Switch_1 <= '0'; wait for 30 ns;
        i_Switch_1 <= '1'; wait for 20 ns;
        i_Switch_1 <= '0'; wait for 1 us;
        i_Switch_1 <= '1'; wait for 1 us;   -- LED bat

        i_Switch_1 <= '0'; wait for 1 us;
        i_Switch_1 <= '1'; wait for 1 us;   -- LED tat

        wait;
    end process;

end sim;