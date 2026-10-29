library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Lab02 is
    port (
        i_sw1 : in  STD_LOGIC;  -- Mặc định là 1 (Chưa bấm)
        i_sw2 : in  STD_LOGIC;  -- Mặc định là 1 (Chưa bấm)
        o_led : out STD_LOGIC   -- Mức 1 là TẮT, mức 0 là SÁNG
    );
end entity Lab02;

architecture rtl of Lab02 is
begin
    -- Logic OR áp dụng cho phần cứng Active-Low:
    -- Ban đầu (Chưa bấm): 1 or 1 = 1 (Đèn TẮT)
    -- Bấm 1 nút        : 0 or 1 = 1 (Đèn TẮT)
    -- Bấm cả 2 nút     : 0 or 0 = 0 (Đèn SÁNG)
    
    o_led <= i_sw1 and i_sw2;

end architecture rtl;