library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_girouette is
end entity tb_girouette;

architecture rtl of tb_girouette is
    constant C_CLK_FREQ : integer := 50_000_000;
    constant C_CLK_PER : time := 20 ns;
    constant C_TOFF : time := 1 ms;
    signal clk, arst : std_logic := '0';
    signal start, continu : std_logic;
    signal giro : std_logic := '0';
    signal data_valid : std_logic;
begin
    
    arst <= '1', '0' after 63 ns;
    clk <= not clk after C_CLK_PER / 2;

    u_girouette : entity work.girouette
        generic map (
            G_FREQ_IN => C_CLK_FREQ
        )
        port map (
            arst_i => arst,
            clk_i => clk,
            giro_i => giro,
            continu_i => continu,
            start_stop_i => start,
            data_o => open,
            valid_o => data_valid
        );

    process
    begin
        start <= '0'; continu <= '0';
        wait for 5*C_CLK_PER;
        start <= '1';
        wait for C_CLK_PER;
        start <= '0';
        wait until data_valid = '1';
        continu <= '1';
        wait until falling_edge(giro);
        wait until falling_edge(giro);
        wait for 5*C_CLK_PER;
        continu <= '0';
        wait until falling_edge(giro);
        start <= '1';
        wait until data_valid = '1';
        wait;
    end process;

    process
    begin
        giro <= '0';
        wait for C_TOFF;
        giro <= '1';
        wait for 10 ms;
        giro <= '0';
        wait for C_TOFF;
        giro <= '1';
        wait for 19 ms;
        giro <= '0';
        wait for C_TOFF;
        giro <= '1';
        wait for 28 ms;
        giro <= '0';
        wait for C_TOFF;
        giro <= '1';
        wait for 36.9 ms;
    end process;

    
end architecture rtl;