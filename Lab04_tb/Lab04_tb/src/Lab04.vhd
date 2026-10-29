library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lab04 is
    generic (
        -- Example: 20 ms * 50 MHz = 1,000,000 cycles.
        STABLE_CYCLES : positive := 1_000_000
    );
    port (
        clk          : in  STD_LOGIC;
        i_sw_raw     : in  STD_LOGIC;
        i_rst        : in  STD_LOGIC;
        o_led        : out STD_LOGIC;
        o_dbg_stable : out STD_LOGIC
    );
end entity lab04;

architecture rtl of lab04 is
    function clog2(n : positive) return natural is
        variable value : natural := n - 1;
        variable bits  : natural := 0;
    begin
        while value > 0 loop
            value := value / 2;
            bits  := bits + 1;
        end loop;
        if bits = 0 then return 1; else return bits; end if;
    end function;

    constant COUNTER_BITS : natural := clog2(STABLE_CYCLES);
    constant TERMINAL_COUNT : UNSIGNED(COUNTER_BITS-1 downto 0) :=
        to_unsigned(STABLE_CYCLES - 1, COUNTER_BITS);

    signal sw_sync1, sw_sync2 : STD_LOGIC;
    signal sw_stable : STD_LOGIC;
    signal stable_count : UNSIGNED(COUNTER_BITS-1 downto 0);
    signal evt_cur, evt_prev, release_event : STD_LOGIC;
    signal led_state : STD_LOGIC;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if i_rst = '1' then
                sw_sync1 <= '0'; sw_sync2 <= '0'; sw_stable <= '0';
                stable_count <= (others => '0');
            else
                sw_sync1 <= i_sw_raw;
                sw_sync2 <= sw_sync1;
                if sw_sync2 = sw_stable then
                    stable_count <= (others => '0');
                elsif stable_count = TERMINAL_COUNT then
                    sw_stable <= sw_sync2;
                    stable_count <= (others => '0');
                else
                    stable_count <= stable_count + 1;
                end if;
            end if;
        end if;
    end process;

    release_event <= evt_prev and (not evt_cur);

    process(clk)
    begin
        if rising_edge(clk) then
            if i_rst = '1' then
                evt_cur <= '0'; evt_prev <= '0'; led_state <= '0';
            else
                evt_prev <= evt_cur;
                evt_cur  <= sw_stable;
                if release_event = '1' then
                    led_state <= not led_state;
                end if;
            end if;
        end if;
    end process;

    o_led <= led_state;
    o_dbg_stable <= sw_stable;
end architecture rtl;