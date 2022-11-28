library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_anemometre is
end entity tb_anemometre;

architecture rtl of tb_anemometre is
    constant C_CLK_FREQ : integer := 50_000_000;
    constant C_CLK_PER : time := 20 ns;
    signal arst, clk : std_logic := '0';
    signal start_stop, continu : std_logic;
    signal anemo_sig : std_logic;
    signal data : std_logic_vector(7 downto 0);
    signal valid : std_logic;
begin
    
    u_anemometre : entity work.anemometre
        generic map (
            G_FREQ_IN => C_CLK_FREQ
        )
        port map (
            arst_i => arst,
            clk_i => clk,
            anemo_i => anemo_sig,
            continu_i => continu,
            start_stop_i => start_stop,
            data_o => data,
            valid_o => valid
        );

    arst <= '1', '0' after 63 ns;
    clk <= not clk after C_CLK_PER / 2;

    process
    begin
        start_stop <= '0'; continu <= '0'; anemo_sig <= '0';
        wait for 5*C_CLK_PER;
        start_stop <= '1';
        wait for 5*C_CLK_PER;
        start_stop <= '0';
        for i in 1 to 90 loop
            anemo_sig <= '1';
            wait for 5*C_CLK_PER;
            anemo_sig <= '0';
            wait for 5*C_CLK_PER;
        end loop;
        wait until valid = '1';
        
        continu <= '1';
        wait for 5*C_CLK_PER;
        for i in 1 to 50 loop
            anemo_sig <= '1';
            wait for 5*C_CLK_PER;
            anemo_sig <= '0';
            wait for 5*C_CLK_PER;
        end loop;
        wait until valid = '1';
        for i in 1 to 60 loop
            anemo_sig <= '1';
            wait for 5*C_CLK_PER;
            anemo_sig <= '0';
            wait for 5*C_CLK_PER;
        end loop;
        continu <= '0';
        wait until unsigned(data) = 60;
        start_stop <= '1';
        for i in 1 to 120 loop
            anemo_sig <= '1';
            wait for 5*C_CLK_PER;
            anemo_sig <= '0';
            wait for 5*C_CLK_PER;
        end loop;
        wait until valid = '1';
        wait for 5*C_CLK_PER;
        start_stop <= '0';
        wait;
    end process;
    
end architecture rtl;