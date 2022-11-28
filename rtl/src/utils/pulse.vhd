library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.utils.all;

entity pulse is
    generic (
        G_FREQ_IN : integer := 50_000_000;
        G_FREQ_OUT : integer := 1_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        srst_i : in std_logic;
        q_o : out std_logic
    );
end entity pulse;

architecture rtl of pulse is
    constant C_COMPARE_VALUE : integer := G_FREQ_IN / G_FREQ_OUT;
    signal cnt : unsigned(bit_width(G_FREQ_IN / G_FREQ_OUT) - 1 downto 0);
begin
    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            cnt <= (others => '0');
        elsif rising_edge(clk_i) then
            if srst_i = '1' then
                cnt <= (others => '0');
            else
                if cnt >= C_COMPARE_VALUE - 1 then
                    cnt <= (others => '0');
                else
                    cnt <= cnt + 1;
                end if;
            end if;
        end if;
    end process;

    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if cnt >= C_COMPARE_VALUE - 1 then
                q_o <= '1';
            else
                q_o <= '0';
            end if;
        end if;
    end process;

end architecture rtl;