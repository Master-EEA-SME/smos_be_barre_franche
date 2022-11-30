library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity girouette is
    generic (
        G_FREQ_IN : integer := 50_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        giro_i : in std_logic;
        continu_i : in std_logic;
        start_stop_i : in std_logic;
        data_o : out std_logic_vector(8 downto 0);
        valid_o : out std_logic
    );
end entity girouette;

architecture rtl of girouette is
    type giro_st_t is (st_idle, st_sync, st_measure);
    signal giro, giro_re, giro_fe, start_re : std_logic;
    signal d_giro, d_giro_fe : std_logic; -- retardés d'un coup l'horloge
    signal giro_st : giro_st_t;
    signal width_cnt : unsigned(8 downto 0);
    signal pulse_100us, pulse_100us_reset : std_logic;
    signal data_valid : std_logic;
begin

    process (clk_i)
    begin
        if rising_edge(clk_i) then
            giro <= giro_i;
        end if;
    end process;

    u_edge_detector_start_stop : entity work.edge_detector
        generic map (
            G_ASYNC => FALSE
        )
        port map (
            clk_i => clk_i,
            x_i => start_stop_i,
            re_o => start_re,
            fe_o => open
        );

    u_edge_detector_anemo : entity work.edge_detector
        generic map (
            G_ASYNC => FALSE
        )
        port map (
            clk_i => clk_i,
            x_i => giro,
            re_o => giro_re,
            fe_o => giro_fe
        );

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            width_cnt <= (others => '0');
        elsif rising_edge(clk_i) then
            if giro_st = st_measure and d_giro = '1' then
                if pulse_100us = '1' then
                    width_cnt <= width_cnt + 1;
                end if;
            else
                width_cnt <= (others => '0');
            end if;
        end if;
    end process;

    pulse_100us_reset <= 
        '1' when giro_st = st_idle or giro = '0' else
        '0';

    u_pulse_100us : entity work.pulse
        generic map (
            G_FREQ_IN => G_FREQ_IN,
            G_FREQ_OUT => 10000
        )
        port map (
            arst_i => arst_i,
            clk_i => clk_i,
            srst_i => pulse_100us_reset,
            q_o => pulse_100us
        );

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            giro_st <= st_idle;
        elsif rising_edge(clk_i) then
            case giro_st is
                when st_idle =>
                    if start_re = '1' or continu_i = '1' then
                        giro_st <= st_sync;
                    end if;
                when st_sync =>
                    if giro_re = '1' then
                        giro_st <= st_measure;
                    end if;
                when st_measure =>
                    if continu_i = '0' and d_giro_fe = '1' then
                        giro_st <= st_idle;
                    end if;
                when others =>
                    giro_st <= st_idle;
            end case;
        end if;
    end process;
    
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if giro_st = st_measure and d_giro_fe = '1' then
                data_o <= std_logic_vector(width_cnt);
            end if;
        end if;
    end process;

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            data_valid <= '0';
        elsif rising_edge(clk_i) then
            if giro_st = st_measure then
                if d_giro_fe = '1' then
                    data_valid <= '1';
                end if;
            elsif giro_st = st_idle and (start_re = '1' or continu_i = '1') then
                data_valid <= '0';
            end if;
        end if;
    end process;

    process (clk_i)
    begin
        if rising_edge(clk_i) then
            d_giro <= giro;
            d_giro_fe <= giro_fe;
        end if;
    end process;

    valid_o <= data_valid;

end architecture rtl;