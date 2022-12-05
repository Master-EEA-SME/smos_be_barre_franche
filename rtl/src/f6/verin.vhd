library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity verin is
    generic (
        G_FREQ_IN : integer := 50_000_000;
        G_FREQ_ADC : integer := 1_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        pwm_en_i : in std_logic;
        duty_i : in std_logic_vector(15 downto 0);
        freq_i : in std_logic_vector(15 downto 0);
        butee_g_i : in std_logic_vector(11 downto 0);
        butee_d_i : in std_logic_vector(11 downto 0);
        angle_barre_o : out std_logic_vector(11 downto 0);
        fin_course_g_o : out std_logic;
        fin_course_d_o : out std_logic;
        sens_i : in std_logic;
        pwm_o : out std_logic;
        sens_o : out std_logic;
        sck_o : out std_logic;
        sdi_i : in std_logic;
        cs_n_o : out std_logic
    );
end entity verin;

architecture rtl of verin is
    signal pwm_reset : std_logic;
    signal angle_barre : std_logic_vector(11 downto 0);
begin
    
    u_pwm_verin : entity work.pwm
        generic map (
            G_N => duty_i'length
        )
        port map (
            arst_i => arst_i,
            clk_i => clk_i,
            srst_i => pwm_reset,
            duty_i => duty_i,
            freq_i => freq_i,
            q_o => pwm_o
        );

    block_gestion_butees : block
        signal fin_course_g, fin_course_d : std_logic;
    begin
        fin_course_g <= '1' when unsigned(angle_barre) <= unsigned(butee_g_i) else '0';
        fin_course_d <= '1' when unsigned(angle_barre) >= unsigned(butee_d_i) else '0';
        pwm_reset <= 
            '1' when fin_course_g = '1' and sens_i = '0' else -- vers la gauche
            '1' when fin_course_d = '1' and sens_i = '1' else -- vers la droite
            not pwm_en_i;
        sens_o <= sens_i;
        fin_course_g_o <= fin_course_g;
        fin_course_d_o <= fin_course_d;
    end block;

    block_gestion_adc : block
        signal pulse100ms, start_conv, conv_done : std_logic;
        signal m_angle_barre : std_logic_vector(11 downto 0);
    begin
        u_pulse_100ms : entity work.pulse
            generic map (
                G_FREQ_IN => G_FREQ_IN,
                G_FREQ_OUT => 10
            )
            port map (
                arst_i => arst_i,
                clk_i => clk_i,
                srst_i => '0',
                q_o => pulse100ms
            );
        process (clk_i, arst_i)
        begin
            if arst_i = '1' then
                start_conv <= '1';
            elsif rising_edge(clk_i) then
                start_conv <= pulse100ms;
            end if;
        end process;
        u_adc : entity work.adc
            generic map (
                G_FREQ_IN => G_FREQ_IN,
                G_FREQ_SCK => G_FREQ_ADC
            )
            port map (
                arst_i => arst_i,
                clk_i => clk_i,
                start_i => start_conv,
                data_o => m_angle_barre,
                done_o => conv_done,
                sck_o => sck_o,
                sdi_i => sdi_i,
                cs_n_o => cs_n_o
            );
        process (clk_i)
        begin
            if rising_edge(clk_i) then
                if conv_done = '1' then
                    angle_barre <= m_angle_barre;
                end if;
            end if;
        end process;
    end block;
    
    angle_barre_o <= angle_barre;

end architecture rtl;