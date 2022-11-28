library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pwm is
    generic (
        G_N : integer := 16
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        srst_i : in std_logic;
        duty_i : in std_logic_vector(G_N - 1 downto 0);
        freq_i : in std_logic_vector(G_N - 1 downto 0);
        q_o : out std_logic
    );
end entity pwm;

architecture rtl of pwm is
    signal cnt : unsigned(G_N - 1 downto 0);
begin

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            cnt <= (others => '0');
        elsif rising_edge(clk_i) then
            if srst_i = '1' then
                cnt <= (others => '0');
            else
                cnt <= cnt + 1;
                if cnt >= unsigned(freq_i) then
                    cnt <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            q_o <= '0';
        elsif rising_edge(clk_i) then
            if srst_i = '1' then
                q_o <= '0';
            else
                if cnt < unsigned(duty_i) then
                    q_o <= '1';
                else
                    q_o <= '0';
                end if;
            end if;
        end if;
    end process;

end architecture rtl;