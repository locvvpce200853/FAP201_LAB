library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab05 is
    generic (
        G_LFSR_WIDTH : positive := 25
    );
    port (
        i_Clk      : in  std_logic;
        i_Rst      : in  std_logic;
        i_Switch_1 : in  std_logic;
        i_Switch_2 : in  std_logic;
        o_LED_1    : out std_logic;
        o_LED_2    : out std_logic;
        o_LED_3    : out std_logic;
        o_LED_4    : out std_logic
    );
end entity lab05;

architecture RTL of lab05 is
    component lfsr_timer is
        generic ( G_WIDTH : positive := 25 );
        port (
            i_Clk       : in  std_logic;
            i_Rst       : in  std_logic;
            o_LFSR_Data : out std_logic_vector(G_WIDTH-1 downto 0);
            o_LFSR_Done : out std_logic
        );
    end component;

    component demux_1_to_4 is
        port (
            i_Data  : in  std_logic;
            i_Sel0  : in  std_logic;
            i_Sel1  : in  std_logic;
            o_Data0 : out std_logic;
            o_Data1 : out std_logic;
            o_Data2 : out std_logic;
            o_Data3 : out std_logic
        );
    end component;

    signal w_LFSR_Done   : std_logic;
    signal w_LFSR_Data   : std_logic_vector(G_LFSR_WIDTH-1 downto 0);
    signal r_LFSR_Toggle : std_logic := '0';

    signal w_Rst_Norm      : std_logic;
    signal w_Switch_1_Norm : std_logic;
    signal w_Switch_2_Norm : std_logic;
    signal w_Data0, w_Data1, w_Data2, w_Data3 : std_logic;

begin
    -- Nút Reset: Board ACG525 dùng Active-Low (nhấn = 0) -> Đảo lại
    w_Rst_Norm      <= not i_Rst;

    -- Nút Switch: Board ACG525 dùng Active-Low (nhấn = 0) -> PHẢI ĐẢO LẠI
    w_Switch_1_Norm <= not i_Switch_1;
    w_Switch_2_Norm <= not i_Switch_2;

    LFSR_INST : lfsr_timer
        generic map ( G_WIDTH => G_LFSR_WIDTH )
        port map (
            i_Clk       => i_Clk,
            i_Rst       => w_Rst_Norm,
            o_LFSR_Data => w_LFSR_Data,
            o_LFSR_Done => w_LFSR_Done
        );

    process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            if w_Rst_Norm = '1' then
                r_LFSR_Toggle <= '0';
            elsif w_LFSR_Done = '1' then
                r_LFSR_Toggle <= not r_LFSR_Toggle;
            end if;
        end if;
    end process;

    DEMUX_INST : demux_1_to_4
        port map (
            i_Data  => r_LFSR_Toggle,
            i_Sel0  => w_Switch_1_Norm,
            i_Sel1  => w_Switch_2_Norm,
            o_Data0 => w_Data0,
            o_Data1 => w_Data1,
            o_Data2 => w_Data2,
            o_Data3 => w_Data3
        );

    -- LED trên board là Active-High (mức 1 = sáng) -> BỎ CHỮ 'NOT'
    -- Kênh không chọn (0) -> LED tắt. Kênh được chọn -> LED nháy theo toggle.
    o_LED_1 <= w_Data0;
    o_LED_2 <= w_Data1;
    o_LED_3 <= w_Data2;
    o_LED_4 <= w_Data3;

end architecture RTL;