-- FPGA input synchronization and debounce. Single-cycle pulse on PRESS.
library ieee;
use ieee.std_logic_1164.all;
entity key_conditioner is
  generic(G_STABLE_CYCLES : positive := 1000000);
  port(clk_i : in std_logic; rst_i : in std_logic;
       raw_pressed_i : in std_logic; press_pulse_o : out std_logic;
       stable_pressed_o : out std_logic);
end entity;
architecture rtl of key_conditioner is
  signal meta : std_logic := '0';
  signal sync : std_logic := '0';
  signal stable : std_logic := '0';
  signal counter : natural range 0 to G_STABLE_CYCLES := 0;
  signal pulse : std_logic := '0';
begin
  stable_pressed_o <= stable;
  press_pulse_o <= pulse;
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        meta <= '0'; sync <= '0'; stable <= '0';
        counter <= 0; pulse <= '0';
      else
        meta <= raw_pressed_i;
        sync <= meta;
        pulse <= '0';
        if sync = stable then
          counter <= 0;
        elsif counter = G_STABLE_CYCLES - 1 then
          counter <= 0;
          stable <= sync;
          if sync = '1' then pulse <= '1'; end if;
        else
          counter <= counter + 1;
        end if;
      end if;
    end if;
  end process;
end architecture;