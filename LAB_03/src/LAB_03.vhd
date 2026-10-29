library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LAB_03 is
    generic (
        g_DEBOUNCE_LIMIT : integer := 500000  -- 10 ms tai 50 MHz
    );
    port (
        i_Clk      : in  std_logic;
        i_Switch_1 : in  std_logic;
        o_LED_1    : out std_logic
    );
end LAB_03;

architecture Behavioral of LAB_03 is
    signal r_Count    : integer range 0 to g_DEBOUNCE_LIMIT := 0;
    signal r_State    : std_logic := '1';  -- nut da loc (nha = '1', nhan = '0')
    signal r_Switch_1 : std_logic := '1';  -- trang thai nut o chu ky truoc
    signal r_LED      : std_logic := '0';
begin

    -- Chong rung
    p_Debounce : process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if i_Switch_1 /= r_State then
                if r_Count = g_DEBOUNCE_LIMIT then
                    r_State <= i_Switch_1;
                    r_Count <= 0;
                else
                    r_Count <= r_Count + 1;
                end if;
            else
                r_Count <= 0;
            end if;
        end if;
    end process;

    -- Phat hien nha nut va dao trang thai LED
    p_Toggle : process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            r_Switch_1 <= r_State;
            if r_State = '1' and r_Switch_1 = '0' then
                r_LED <= not r_LED;
            end if;
        end if;
    end process;

    o_LED_1 <= r_LED;

end Behavioral;