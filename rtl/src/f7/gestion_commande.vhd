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
        led_stanby_o : out std_logic;
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
begin
    
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
                    elsif btn_standby_re = '1' then
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
            done_o => bip_end_event,
            buzzer_o => buzzer_o
        );
    
end architecture rtl;