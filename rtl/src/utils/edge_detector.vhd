library IEEE;
use IEEE.std_logic_1164.all;

entity edge_detector is
    generic (
        G_ASYNC : boolean := false
    );
    port (
        clk_i : in std_logic;
        x_i : in std_logic;
        re_o : out std_logic;
        fe_o : out std_logic
    );
end entity edge_detector;

architecture rtl of edge_detector is
    signal x, d_x : std_logic;
begin
    gen_async: if G_ASYNC = TRUE generate
        process (clk_i)
        begin
            if rising_edge(clk_i) then
                x <= x_i;
            end if;
        end process;
    end generate gen_async;
    gen_sync: if G_ASYNC = FALSE generate
        x <= x_i;
    end generate gen_sync;

    process (clk_i)
    begin
        if rising_edge(clk_i) then
            d_x <= x;
        end if;
    end process;
    re_o <= '1' when x = '1' and d_x = '0' else '0';
    fe_o <= '1' when x = '0' and d_x = '1' else '0';
end architecture rtl;