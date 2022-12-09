library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity buzzer is
    generic (
        G_FREQ_IN : integer := 50_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        trig_i : in std_logic;
        command_i : in std_logic;
        done_o : out std_logic;
        buzzer_o : out std_logic
    );
end entity buzzer;

architecture rtl of buzzer is
    type buzzer_st_t is (st_idle, st_double, st_simple);
    signal buzzer_st : buzzer_st_t;
    signal pwm_reset, pwm_q, d_pwm_q, pwm_re, pwm_re_en : std_logic;
begin
    
    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            buzzer_st <= st_idle;
        elsif rising_edge(clk_i) then
            case buzzer_st is
                when st_idle =>
                    if trig_i = '1' then
                        if command_i = '1' then
                            buzzer_st <= st_double;
                        else
                            buzzer_st <= st_simple;
                        end if;
                    end if;
                when st_double =>
                    if pwm_re = '1' and pwm_re_en = '1' then
                        buzzer_st <= st_simple;
                    end if;
                when st_simple =>
                    if pwm_re = '1' and pwm_re_en = '1' then
                        buzzer_st <= st_idle;
                    end if;
                when others =>
            end case;
        end if;
    end process;

    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if buzzer_st = st_idle then
                pwm_re_en <= '0';
            elsif pwm_re = '1' then
                pwm_re_en <= '1';
            end if;
        end if;
    end process;

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            d_pwm_q <= '0';
        elsif rising_edge(clk_i) then
            d_pwm_q <= pwm_q;
        end if;
    end process;

    pwm_re <= '1' when pwm_q = '1' and d_pwm_q = '0' else '0';
    pwm_reset <= '1' when buzzer_st = st_idle else '0';

    u_pwm : entity work.pwm
    generic map (
        G_N => 24
    )
    port map (
        arst_i => arst_i,
        clk_i => clk_i,
        srst_i => pwm_reset,
        duty_i => std_logic_vector(to_unsigned(10000000 / 2, 24)),
        freq_i => std_logic_vector(to_unsigned(10000000, 24)),
        q_o => pwm_q
    );

    buzzer_o <= d_pwm_q when buzzer_st /= st_idle else '0';
    done_o <= '1' when buzzer_st = st_simple and pwm_re = '1' and pwm_re_en = '1' else '0';
    
end architecture rtl;