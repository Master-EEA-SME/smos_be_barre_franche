library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adc is
    generic (
        G_FREQ_IN : integer := 50_000_000;
        G_FREQ_SCK : integer := 1_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        start_i : in std_logic;
        data_o : out std_logic_vector(11 downto 0);
        done_o : out std_logic;
        sck_o : out std_logic;
        sdi_i : in std_logic;
        cs_n_o : out std_logic
    );
end entity adc;

architecture rtl of adc is
    type adc_st_t is (st_idle, st_transfer);
    signal adc_st : adc_st_t;
    signal sck, sck_re, sck_fe : std_logic;
    signal sdi, cs_n : std_logic;
    signal data_cnt : unsigned(3 downto 0);
    signal data_latch : std_logic_vector(14 downto 0);
begin
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            sdi <= sdi_i;
        end if;
    end process;
    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            adc_st <= st_idle;
        elsif rising_edge(clk_i) then
            case adc_st is
                when st_idle =>
                    if start_i = '1' then
                        adc_st <= st_transfer;
                    end if;
                when st_transfer =>
                    if data_cnt >= 14 and sck_fe = '1' then
                        adc_st <= st_idle;
                    end if;
                when others =>
            end case;
        end if;
    end process;

    block_sck_generation : block
        signal pulse_reset, pulse_q : std_logic;
    begin
        u_pulse : entity work.pulse
            generic map (
                G_FREQ_IN => G_FREQ_IN,
                G_FREQ_OUT => G_FREQ_SCK
            )
            port map (
                arst_i => arst_i,
                clk_i => clk_i,
                srst_i => pulse_reset,
                q_o => pulse_q
            );
    
        pulse_reset <= '1' when adc_st = st_idle else '0';
    
        process (clk_i, arst_i)
        begin
            if arst_i = '1' then
               sck <= '0'; 
            elsif rising_edge(clk_i) then
                if pulse_q = '1' then
                    sck <= not sck;
                end if;
            end if;
        end process;
        sck_re <= '1' when pulse_q = '1' and sck = '0' else '0';
        sck_fe <= '1' when pulse_q = '1' and sck = '1' else '0';
    end block;

    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if adc_st = st_transfer then
                if sck_re = '1' then
                    data_latch <= data_latch(data_latch'left - 1 downto 0) & sdi;
                end if;
                if sck_fe = '1' then
                    data_cnt <= data_cnt + 1;
                end if;
            else
                data_cnt <= (others => '0');
            end if;
        end if;
    end process;

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            done_o <= '0';
            cs_n_o <= '1';
        elsif rising_edge(clk_i) then
            if adc_st = st_transfer and data_cnt >= 14 and sck_fe = '1' then
                done_o <= '1';
            else
                done_o <= '0';
            end if;
            cs_n_o <= cs_n;
        end if;
    end process;
    cs_n <= '0' when adc_st = st_transfer else '1';
    sck_o <= sck;
    data_o <= data_latch(11 downto 0);
end architecture rtl;