library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity avalon_verin is
    generic (
        G_FREQ_IN : integer := 50_000_000;
        G_FREQ_ADC : integer := 1_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        address_i : in std_logic_vector(2 downto 0);
        write_i : in std_logic;
        write_data_i : in std_logic_vector(31 downto 0);
        read_data_o : out std_logic_vector(31 downto 0);
        pwm_o : out std_logic;
        sens_o : out std_logic;
        sck_o : out std_logic;
        sdi_i : in std_logic;
        cs_n_o : out std_logic
    );
end entity avalon_verin;

architecture rtl of avalon_verin is
    signal duty, freq : std_logic_vector(15 downto 0);
    signal butee_g, butee_d, angle_barre : std_logic_vector(11 downto 0);
    signal reset, pwm_en, sens, fin_course_g, fin_course_d : std_logic;
begin
    
    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            reset <= '1';
            sens <= '0';
            butee_g <= (others => '0');
            butee_d <= (others => '0');
            pwm_en <= '0';
        elsif rising_edge(clk_i) then
            if write_i = '1' then
                case to_integer(unsigned(address_i)) is
                    when 16#00# =>
                        freq <= write_data_i(15 downto 0);
                    when 16#01# =>
                        duty <= write_data_i(15 downto 0);
                    when 16#02# =>
                        butee_g <= write_data_i(11 downto 0);
                    when 16#03# =>
                        butee_d <= write_data_i(11 downto 0);
                    when 16#04# =>
                        reset <= not write_data_i(0);
                        pwm_en <= write_data_i(1);
                        sens <= write_data_i(2);
                    when others =>
                end case;
            end if;
        end if;
    end process;

    read_data_o <= 
        (16 to 31 => '0') & freq when unsigned(address_i) = 16#00# else
        (16 to 31 => '0') & duty when unsigned(address_i) = 16#01# else
        (12 to 31 => '0') & butee_g when unsigned(address_i) = 16#02# else
        (12 to 31 => '0') & butee_d when unsigned(address_i) = 16#03# else
        (5 to 31 => '0') & (fin_course_g & fin_course_d & sens & pwm_en & not reset) when unsigned(address_i) = 16#04# else
        (12 to 31 => '0') & angle_barre when unsigned(address_i) = 16#05# else
        (others => '-');

    block_verin_inst : block
        component verin
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
        end component;
          
    begin
        u_verin : component verin
            generic map (
                G_FREQ_IN => G_FREQ_IN,
                G_FREQ_ADC => G_FREQ_ADC
            )
            port map (
                arst_i => reset,
                clk_i => clk_i,
                pwm_en_i => pwm_en,
                duty_i => duty,
                freq_i => freq,
                butee_g_i => butee_g,
                butee_d_i => butee_d,
                angle_barre_o => angle_barre,
                sens_i => sens,
                pwm_o => pwm_o,
                sens_o => sens_o,
                sck_o => sck_o,
                sdi_i => sdi_i,
                cs_n_o => cs_n_o
            );
    end block;

end architecture rtl;