-- ======================================================================
-- Testbench for Lab02 VHDL
-- ======================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Lab02tb is
-- Testbench không có port
end entity Lab02tb;

architecture behavior of Lab02tb is
    -- Khai báo Component của DUT (Device Under Test)
    component Lab02 is
        port (
            i_sw1 : in  STD_LOGIC;
            i_sw2 : in  STD_LOGIC;
            o_led : out STD_LOGIC
        );
    end component;

    -- Khai báo Signals để nối vào DUT
    signal i_sw1 : STD_LOGIC := '0';
    signal i_sw2 : STD_LOGIC := '0';
    signal o_led : STD_LOGIC;

begin
    -- Instantiate DUT (Kết nối tín hiệu)
    uut: Lab02 port map (
        i_sw1 => i_sw1,
        i_sw2 => i_sw2,
        o_led => o_led
    );

    -- Quá trình tạo kích thích (Stimulus Process) để test bảng chân trị
    stim_proc: process
    begin
        -- Test Case 1: 00
        i_sw1 <= '0'; i_sw2 <= '0';
        wait for 10 ns;
        
        -- Test Case 2: 01
        i_sw1 <= '0'; i_sw2 <= '1';
        wait for 10 ns;

        -- Test Case 3: 10
        i_sw1 <= '1'; i_sw2 <= '0';
        wait for 10 ns;

        -- Test Case 4: 11
        i_sw1 <= '1'; i_sw2 <= '1';
        wait for 10 ns;

        -- Kết thúc mô phỏng
        wait;
    end process;

end architecture behavior;