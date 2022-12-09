library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gestion_commande is
    generic (
        G_FREQ_IN : integer := 50_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        btn_babord_i : in std_logic;
        btn_tribord_i : in std_logic;
        btn_standby_i : in std_logic;
        led_babord_o : out std_logic;
        led_tribord_o : out std_logic;
        led_standby_o : out std_logic;
        buzzer_o : out std_logic;
        code_fonction_o : out std_logic_vector(3 downto 0)
    );
end entity gestion_commande;

architecture rtl of gestion_commande is
    type commande_st_t is (st_idle, st_manual_babord, st_manual_tribord, st_auto, st_auto_increment_1_babord, st_auto_increment_10_babord, st_auto_increment_1_tribord, st_auto_increment_10_tribord, st_auto_set_cap);
    signal command_st, d_command_st : commande_st_t;
    signal btn_babord, btn_babord_re, btn_babord_fe, btn_babord_short_push, btn_babord_long_push : std_logic;
    signal btn_tribord, btn_tribord_re, btn_tribord_fe, btn_tribord_short_push, btn_tribord_long_push : std_logic;
    signal btn_standby, btn_standby_re, btn_standby_fe, btn_standby_short_push, btn_standby_long_push : std_logic;
    signal bip_trig, bip_end_event : std_logic;
    signal buzzer_cmd, buzzer : std_logic;
begin
    block_debouncing : block
        signal btn_babord_sync, btn_tribord_sync, btn_standby_sync : std_logic;
    begin
        process (clk_i)
        begin
            if rising_edge(clk_i) then
                btn_babord_sync <= btn_babord_i;
                btn_tribord_sync <= btn_tribord_i;
                btn_standby_sync <= btn_standby_i;
            end if;
        end process;
        u_babord_debouncing : entity work.debouncing
            generic map (
                G_FREQ_IN => G_FREQ_IN
            )
            port map (
                arst_i => arst_i,
                clk_i => clk_i,
                btn_i => btn_babord_sync,
                btn_o => btn_babord
            );
        u_tribord_debouncing : entity work.debouncing
            generic map (
                G_FREQ_IN => G_FREQ_IN
            )
            port map (
                arst_i => arst_i,
                clk_i => clk_i,
                btn_i => btn_tribord_sync,
                btn_o => btn_tribord
            );
        u_standby_debouncing : entity work.debouncing
            generic map (
                G_FREQ_IN => G_FREQ_IN
            )
            port map (
                arst_i => arst_i,
                clk_i => clk_i,
                btn_i => btn_standby_sync,
                btn_o => btn_standby
            );
    end block;
    block_btn_edge_detection : block
        signal d_btn_babord, d_btn_tribord, d_btn_standby : std_logic;
    begin
        process (clk_i)
        begin
            if rising_edge(clk_i) then
                d_btn_babord <= btn_babord;
                d_btn_tribord <= btn_tribord;
                d_btn_standby <= btn_standby;
            end if;
        end process;
        btn_babord_re <= '1' when btn_babord = '1' and d_btn_babord = '0' else '0';
        btn_babord_fe <= '1' when btn_babord = '0' and d_btn_babord = '1' else '0';
        btn_tribord_re <= '1' when btn_tribord = '1' and d_btn_tribord = '0' else '0';
        btn_tribord_fe <= '1' when btn_tribord = '0' and d_btn_tribord = '1' else '0';
        btn_standby_re <= '1' when btn_standby = '1' and d_btn_standby = '0' else '0';
        btn_standby_fe <= '1' when btn_standby = '0' and d_btn_standby = '1' else '0';
    end block;

    u_button_push_management_standby : entity work.button_push_management
        generic map (
            G_FREQ_IN => G_FREQ_IN,
            G_LONG_PUSH_TIME => 2000
        )
        port map (
            arst_i => arst_i,
            clk_i => clk_i,
            btn_i => btn_standby,
            short_push_o => btn_standby_short_push,
            long_push_o => btn_standby_long_push
        );
    u_button_push_management_babord : entity work.button_push_management
        generic map (
            G_FREQ_IN => G_FREQ_IN,
            G_LONG_PUSH_TIME => 2000
        )
        port map (
            arst_i => arst_i,
            clk_i => clk_i,
            btn_i => btn_babord,
            short_push_o => btn_babord_short_push,
            long_push_o => btn_babord_long_push
        );
    u_button_push_management_tribord : entity work.button_push_management
        generic map (
            G_FREQ_IN => G_FREQ_IN,
            G_LONG_PUSH_TIME => 2000
        )
        port map (
            arst_i => arst_i,
            clk_i => clk_i,
            btn_i => btn_tribord,
            short_push_o => btn_tribord_short_push,
            long_push_o => btn_tribord_long_push
        );

    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            command_st <= st_idle;
        elsif rising_edge(clk_i) then
            case command_st is
                when st_idle =>
                    if btn_babord_re = '1' then
                        command_st <= st_manual_babord;
                    elsif btn_tribord_re = '1' then
                        command_st <= st_manual_tribord;
                    elsif btn_standby_fe = '1' then
                        command_st <= st_auto;
                    end if;
                when st_manual_babord =>
                    if btn_babord_fe = '1' then
                        command_st <= st_idle;
                    end if;
                when st_manual_tribord =>
                    if btn_tribord_fe = '1' then
                        command_st <= st_idle;
                    end if;
                when st_auto =>
                    if btn_babord_short_push = '1' then
                        command_st <= st_auto_increment_1_babord;
                    elsif btn_babord_long_push = '1' then
                        command_st <= st_auto_increment_10_babord;
                    elsif btn_tribord_short_push = '1' then
                        command_st <= st_auto_increment_1_tribord;
                    elsif btn_tribord_long_push = '1' then
                        command_st <= st_auto_increment_10_tribord;
                    elsif btn_standby_short_push = '1' then
                        command_st <= st_idle;
                    elsif btn_standby_long_push = '1' then
                        command_st <= st_auto_set_cap;
                    end if;
                when st_auto_increment_1_babord | st_auto_increment_10_babord | st_auto_increment_1_tribord | st_auto_increment_10_tribord | st_auto_set_cap =>
                    if bip_end_event = '1' then
                        command_st <= st_auto;
                    end if;
                when others =>
            end case;
        end if;
    end process;

    process (clk_i)
    begin
        if rising_edge(clk_i) then
            d_command_st <= command_st;
        end if;
    end process;

    bip_trig <= 
        '1' when command_st /= st_idle and d_command_st = st_idle else -- exit of st_idle
        '1' when command_st /= st_auto and d_command_st = st_auto else -- exit of st_auto
        '0';

    u_buzzer : entity work.buzzer
        generic map (
            G_FREQ_IN => G_FREQ_IN
        )
        port map (
            arst_i => arst_i,
            clk_i => clk_i,
            trig_i => bip_trig,
            command_i => buzzer_cmd,
            done_o => bip_end_event,
            buzzer_o => buzzer
        );
    
    buzzer_o <= buzzer;

    buzzer_cmd <= '1' when command_st = st_auto_increment_10_babord or command_st = st_auto_increment_10_tribord else '0';

    code_fonction_o <= 
        "0000" when command_st = st_idle else --: pas d'action, le pilote est en veille
        "0001" when command_st = st_manual_babord else --: mode manuel action vérin babord
        "0010" when command_st = st_manual_tribord else --: mode manuel action vérin tribord
        "0011" when command_st = st_auto or command_st = st_auto_set_cap else --: mode pilote automatique/cap
        "0100" when command_st = st_auto_increment_1_tribord else --: incrément de 1° consigne de cap
        "0101" when command_st = st_auto_increment_10_tribord else --: incrément de 10° consigne de cap
        "0111" when command_st = st_auto_increment_1_babord else --: décrément de 1° consigne de cap
        "0110" when command_st = st_auto_increment_10_babord else --: décrément de 10° consigne de cap
        "1111";

    block_led_standby : block
        signal pwm_reset, pwm_q : std_logic;
    begin
        u_pwm_led : entity work.pwm
            generic map (
                G_N => 25
            )
            port map (
                arst_i => arst_i,
                clk_i => clk_i,
                srst_i => pwm_reset,
                duty_i => std_logic_vector(to_unsigned(25_000_000 / 2, 25)),
                freq_i => std_logic_vector(to_unsigned(25_000_000, 25)), -- 2 Hz
                q_o => pwm_q
            );
        pwm_reset <= '0' when command_st = st_idle or command_st = st_manual_babord or command_st = st_manual_tribord else '1';
        led_standby_o <= 
            pwm_q when command_st = st_idle or command_st = st_manual_babord or command_st = st_manual_tribord else
            '1';
    end block;
    block_led_tribord : block
        signal pwm_reset, pwm_q : std_logic;
    begin
        u_pwm_led : entity work.pwm
            generic map (
                G_N => 19
            )
            port map (
                arst_i => arst_i,
                clk_i => clk_i,
                srst_i => pwm_reset,
                duty_i => std_logic_vector(to_unsigned(500_000 / 2, 19)),
                freq_i => std_logic_vector(to_unsigned(500_000, 19)), -- 100 Hz
                q_o => pwm_q
            );
        pwm_reset <= '0' when command_st = st_idle or command_st = st_manual_babord or command_st = st_manual_tribord else '1';
        led_tribord_o <= 
            pwm_q when command_st = st_idle or command_st = st_manual_babord or command_st = st_manual_tribord else
            buzzer when command_st = st_auto_increment_1_tribord or command_st = st_auto_increment_10_tribord else
            '0';
    end block;
    block_led_babord : block
        signal pwm_reset, pwm_q : std_logic;
    begin
        u_pwm_led : entity work.pwm
            generic map (
                G_N => 19
            )
            port map (
                arst_i => arst_i,
                clk_i => clk_i,
                srst_i => pwm_reset,
                duty_i => std_logic_vector(to_unsigned(500_000 / 2, 19)),
                freq_i => std_logic_vector(to_unsigned(500_000, 19)), -- 100 Hz
                q_o => pwm_q
            );
        pwm_reset <= '0' when command_st = st_idle or command_st = st_manual_babord or command_st = st_manual_tribord else '1';
        led_babord_o <= 
            pwm_q when command_st = st_idle or command_st = st_manual_babord or command_st = st_manual_tribord else
            buzzer when command_st = st_auto_increment_1_babord or command_st = st_auto_increment_10_babord else
            '0';
    end block;

end architecture rtl;