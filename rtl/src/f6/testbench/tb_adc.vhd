library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_adc is
end entity tb_adc;

architecture rtl of tb_adc is
    constant CLK_FREQ : integer := 50_000_000;
    constant CLK_ADC : integer := 1_000_000;
    constant CLK_PER : time := 20 ns;
    signal arst, clk : std_logic := '0';
    signal start, done : std_logic;
    signal sck, sdi, cs_n : std_logic;
begin
    
    u_adc : entity work.adc
        generic map (
            G_FREQ_IN => CLK_FREQ,
            G_FREQ_SCK => CLK_ADC
        )
        port map (
            arst_i => arst,
            clk_i => clk,
            start_i => start,
            data_o => open,
            done_o => done,
            sck_o => sck,
            sdi_i => sdi,
            cs_n_o => cs_n
        );

    arst <= '1', '0' after 63 ns;
    clk <= not clk after CLK_PER / 2;

    process
    begin
        start <= '0';
        wait for 5*CLK_PER;
        start <= '1';
        wait for CLK_PER;
        start <= '0';
        wait until done = '1';
        start <= '1';
        wait for CLK_PER;
        start <= '0';
        wait until done = '1';
        wait;
    end process;

    block_sim_adc_data : block
        signal adc_data : std_logic_vector(14 downto 0) := "000" & x"555";
        signal adc_shift : std_logic_vector(14 downto 0);
    begin
        process (cs_n)
        begin
            if falling_edge(cs_n) then
                adc_data <= "000" & not adc_data(11 downto 0);
            end if;
        end process;
        process (sck, cs_n)
        begin
            if cs_n = '1' then
                adc_shift <= adc_data;
            elsif falling_edge(sck) then
                adc_shift <= adc_shift(adc_shift'left - 1 downto 0) & '0';
            end if;
        end process;
        sdi <= adc_shift(adc_shift'left) when cs_n = '0' else 'Z';
    end block;
    
end architecture rtl;