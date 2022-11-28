library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity anemometre is
    generic (
        G_FREQ_IN : integer := 50_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        anemo_i : in std_logic;
        continu_i : in std_logic;
        start_stop_i : in std_logic;
        data_o : out std_logic_vector(7 downto 0);
        valid_o : out std_logic
    );
end entity anemometre;

architecture rtl of anemometre is
    type anemo_st_t is (st_idle, st_measure);
    signal anemo_re, start_re : std_logic;
    signal anemo_st : anemo_st_t;
    signal freq_cnt : unsigned(7 downto 0);
    signal pulse_1s, pulse_reset : std_logic;
begin
    u_edge_detector_start_stop : entity work.edge_detector
        generic map (
            G_ASYNC => TRUE
        )
        port map (
            clk_i => clk_i,
            x_i => start_stop_i,
            re_o => start_re,
            fe_o => open
        );
    u_edge_detector_anemo : entity work.edge_detector
        generic map (
            G_ASYNC => TRUE
        )
        port map (
            clk_i => clk_i,
            x_i => anemo_i,
            re_o => anemo_re,
            fe_o => open
        );

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            freq_cnt <= (others => '0');
        elsif rising_edge(clk_i) then
            if pulse_1s = '1' then
                freq_cnt <= (others => '0');
            elsif anemo_re = '1' then
                freq_cnt <= freq_cnt + 1;
            end if;
        end if;
    end process;

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            anemo_st <= st_idle;
        elsif rising_edge(clk_i) then
            case anemo_st is
                when st_idle =>
                    if start_re = '1' or continu_i = '1' then
                        anemo_st <= st_measure;
                    end if;
                when st_measure =>
                    if continu_i = '0' and pulse_1s = '1' then
                        anemo_st <= st_idle;
                    end if;
                when others =>
                    anemo_st <= st_idle;
            end case;
        end if;
    end process;

    pulse_reset <= 
        '1' when anemo_st = st_idle else
        '1' when pulse_1s = '1' else
        '0';

    u_pulse_1s : entity work.pulse
        generic map (
            G_FREQ_IN => G_FREQ_IN,
            G_FREQ_OUT => 1
        )
        port map (
            arst_i => arst_i,
            clk_i => clk_i,
            srst_i => pulse_reset,
            q_o => pulse_1s
        );
    
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if pulse_1s = '1' then
                data_o <= std_logic_vector(freq_cnt);
            end if;
        end if;
    end process;

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            valid_o <= '0';
        elsif rising_edge(clk_i) then
            if anemo_st = st_measure then
                if pulse_1s = '1' then
                    valid_o <= '1';
                end if;
            elsif anemo_st = st_idle and (start_re = '1' or continu_i = '1') then
                valid_o <= '0';
            end if;
        end if;
    end process;

end architecture rtl;