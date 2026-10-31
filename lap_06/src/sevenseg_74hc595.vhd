-- OPTIONAL ACG525 scoreboard adapter: 74HC595 chain, 3 wires DS/SH_CP/ST_CP.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sevenseg_74hc595 is
  generic (
    G_SEG_ACTIVE_LOW : boolean := true;
    G_SEL_ACTIVE_HIGH : boolean := true;
    G_DIV_TICKS : positive := 4;
    G_REFRESH_TICKS : positive := 50000
  );
  port (
    clk_i   : in std_logic;
    score_i : in std_logic_vector(3 downto 0); -- 1..7
    status_i: in std_logic_vector(1 downto 0); -- 00 score, 01 F, 10 A
    ds_o    : out std_logic;
    shcp_o  : out std_logic;
    stcp_o  : out std_logic
  );
end entity;

architecture rtl of sevenseg_74hc595 is
  type phase_t is (LOAD, SETUP, SH_HIGH, SH_LOW, LATCH_HIGH, LATCH_LOW, REFRESH);
  signal phase : phase_t := LOAD;
  signal shift_reg : std_logic_vector(15 downto 0) := (others => '1');
  signal bitno : integer range 0 to 15 := 15;
  signal div_count : natural range 0 to G_DIV_TICKS := 0;
  signal refresh_count : natural range 0 to G_REFRESH_TICKS := 0;
  signal ds : std_logic := '0';
  signal shcp : std_logic := '0';
  signal stcp : std_logic := '0';

  function seg_active_low(v : std_logic_vector(3 downto 0);
                          s : std_logic_vector(1 downto 0)) return std_logic_vector is
  begin
    if s = "01" then return "01110001"; -- F
    elsif s = "10" then return "00010001"; -- A
    else
      case v is
        when "0001" => return "10011111"; -- 1
        when "0010" => return "00100101"; -- 2
        when "0011" => return "00001101"; -- 3
        when "0100" => return "10011001"; -- 4
        when "0101" => return "01001001"; -- 5
        when "0110" => return "01000001"; -- 6
        when "0111" => return "00011111"; -- 7
        when others => return "11111111"; -- blank
      end case;
    end if;
  end function;

  -- Hàm đảo ngược bit (từ a-b-c-d-e-f-g-dp thành dp-g-f-e-d-c-b-a)
  function reverse_byte(b : std_logic_vector(7 downto 0)) return std_logic_vector is
    variable r : std_logic_vector(7 downto 0);
  begin
    for i in 0 to 7 loop
      r(7 - i) := b(i);
    end loop;
    return r;
  end function;

begin
  ds_o <= ds; shcp_o <= shcp; stcp_o <= stcp;
  process(clk_i)
    variable seg : std_logic_vector(7 downto 0);
    variable select_digit : std_logic_vector(7 downto 0);
  begin
    if rising_edge(clk_i) then
      if div_count = G_DIV_TICKS - 1 then
        div_count <= 0;
        case phase is
          when LOAD =>
            seg := seg_active_low(score_i, status_i);
            if not G_SEG_ACTIVE_LOW then seg := not seg; end if;
            
            -- ĐẢO NGƯỢC BIT Ở ĐÂY ĐỂ KHẮC PHỤC LỖI MẤT ĐOẠN
            seg := reverse_byte(seg); 

            select_digit := "00000001";
            if not G_SEL_ACTIVE_HIGH then select_digit := not select_digit; end if;
            shift_reg <= seg & select_digit;
            bitno <= 15;
            shcp <= '0'; stcp <= '0'; phase <= SETUP;
          when SETUP =>
            ds <= shift_reg(bitno);
            shcp <= '0'; phase <= SH_HIGH;
          when SH_HIGH =>
            shcp <= '1'; phase <= SH_LOW;
          when SH_LOW =>
            shcp <= '0';
            if bitno = 0 then phase <= LATCH_HIGH;
            else bitno <= bitno - 1; phase <= SETUP; end if;
          when LATCH_HIGH =>
            stcp <= '1'; phase <= LATCH_LOW;
          when LATCH_LOW =>
            stcp <= '0'; refresh_count <= 0; phase <= REFRESH;
          when REFRESH =>
            if refresh_count = G_REFRESH_TICKS - 1 then phase <= LOAD;
            else refresh_count <= refresh_count + 1; end if;
        end case;
      else
        div_count <= div_count + 1;
      end if;
    end if;
  end process;
end architecture;