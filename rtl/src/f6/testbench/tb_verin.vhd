library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_verin is
end entity tb_verin;

architecture rtl of tb_verin is
    constant CLK_FREQ : integer := 50_000_000;
    constant CLK_ADC : integer := 1_000_000;
    constant CLK_PER : time := 20 ns;
    signal arst, clk : std_logic := '0';
    signal sens, pwm_en : std_logic;
    signal adc_data, butee_g, butee_d : unsigned(11 downto 0);
    signal sck, sdi, cs_n : std_logic;
begin
    
    u_verin : entity work.verin
        generic map (
            G_FREQ_IN => CLK_FREQ,
            G_FREQ_ADC => CLK_ADC
        )
        port map (
            arst_i => arst,
            clk_i => clk,
            pwm_en_i => pwm_en,
            duty_i => std_logic_vector(to_unsigned(500, 16)),
            freq_i => std_logic_vector(to_unsigned(1000, 16)),
            butee_g_i => std_logic_vector(butee_g),
            butee_d_i => std_logic_vector(butee_d),
            fin_course_g_o => open,
            fin_course_d_o => open,
            angle_barre_o => open,
            sens_i => sens,
            pwm_o => open,
            sens_o => open,
            sck_o => sck,
            sdi_i => sdi,
            cs_n_o => cs_n
        );


    arst <= '1', '0' after 63 ns;
    clk <= not clk after CLK_PER / 2;

    process
    begin
        butee_g <= to_unsigned(1000, 12); butee_d <= to_unsigned(4000, 12); sens <= '0'; pwm_en <= '1';
        adc_data <= to_unsigned(2000, 12);
        wait for 5*CLK_PER;
        wait until rising_edge(cs_n);
        adc_data <= to_unsigned(500, 12);
        wait until rising_edge(cs_n);
        adc_data <= to_unsigned(3000, 12);
        wait for 10 ms;
        sens <= '1';
        wait until rising_edge(cs_n);
        adc_data <= to_unsigned(3000, 12);
        wait until rising_edge(cs_n);
        adc_data <= to_unsigned(4050, 12);
        wait until rising_edge(cs_n);
        wait for 10 ms;
        pwm_en <= '0';
        wait;
    end process;

    block_sim_adc_data : block
        signal adc_shift : std_logic_vector(14 downto 0);
    begin
        process (sck, cs_n)
        begin
            if falling_edge(cs_n) then
                adc_shift <= "000" & std_logic_vector(adc_data);
            elsif falling_edge(sck) then
                adc_shift <= adc_shift(adc_shift'left - 1 downto 0) & '0';
            end if;
        end process;
        sdi <= adc_shift(adc_shift'left) when cs_n = '0' else 'Z';
    end block;
    
end architecture rtl;