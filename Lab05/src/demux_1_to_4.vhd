library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demux_1_to_4 is
    port (
        i_Data  : in  std_logic;
        i_Sel0  : in  std_logic;
        i_Sel1  : in  std_logic;
        o_Data0 : out std_logic;
        o_Data1 : out std_logic;
        o_Data2 : out std_logic;
        o_Data3 : out std_logic
    );
end entity demux_1_to_4;

architecture RTL of demux_1_to_4 is
begin
    process (i_Data, i_Sel0, i_Sel1)
        variable v_Sel : std_logic_vector(1 downto 0);
    begin
        -- Mac dinh tat ca kenh = 0 (khong chon)
        o_Data0 <= '0';
        o_Data1 <= '0';
        o_Data2 <= '0';
        o_Data3 <= '0';

        v_Sel := i_Sel1 & i_Sel0;
        case v_Sel is
            when "00"   => o_Data0 <= i_Data;
            when "01"   => o_Data1 <= i_Data;
            when "10"   => o_Data2 <= i_Data;
            when "11"   => o_Data3 <= i_Data;
            when others => null;
        end case;
    end process;
end architecture RTL;