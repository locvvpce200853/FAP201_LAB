library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lfsr_timer is
    generic (
        G_WIDTH : positive := 25
    );
    port (
        i_Clk       : in  std_logic;
        i_Rst       : in  std_logic;
        o_LFSR_Data : out std_logic_vector(G_WIDTH-1 downto 0);
        o_LFSR_Done : out std_logic
    );
end entity lfsr_timer;

architecture RTL of lfsr_timer is
    constant C_ZERO : std_logic_vector(G_WIDTH-1 downto 0) := (others => '0');
    signal r_LFSR   : std_logic_vector(G_WIDTH-1 downto 0) := (others => '0');
    signal r_Done   : std_logic := '0';
    signal w_XNOR   : std_logic;
begin
    w_XNOR <= r_LFSR(G_WIDTH-1) xnor r_LFSR(G_WIDTH-2);

    process (i_Clk)
        variable v_Next : std_logic_vector(G_WIDTH-1 downto 0);
    begin
        if rising_edge(i_Clk) then
            if i_Rst = '1' then
                r_LFSR <= C_ZERO;
                r_Done <= '0';
            else
                v_Next := r_LFSR(G_WIDTH-2 downto 0) & w_XNOR;
                r_LFSR <= v_Next;
                if v_Next = C_ZERO then
                    r_Done <= '1';
                else
                    r_Done <= '0';
                end if;
            end if;
        end if;
    end process;

    o_LFSR_Data <= r_LFSR;
    o_LFSR_Done <= r_Done;
end architecture RTL;