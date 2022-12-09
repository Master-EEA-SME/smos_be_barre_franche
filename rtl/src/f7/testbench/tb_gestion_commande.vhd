library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_gestion_commande is
end entity tb_gestion_commande;

architecture rtl of tb_gestion_commande is
    constant CLK_FREQ : integer := 50_000_000;
    constant CLK_PER : time := 20 ns;
    signal clk, arst : std_logic := '0';
    signal btn_babord, btn_tribord, btn_standby : std_logic;
begin
    
    arst <= '1', '0' after 63 ns;
    clk <= not clk after CLK_PER / 2;

    process
        procedure push_button (signal button : inout std_logic; long : boolean) is
        begin
            button <= '1';
            if long = true then
                wait for 1.1 ms;
            else
                wait for 5*CLK_PER;
            end if;
            button <= '0';
            wait for 5*CLK_PER;
        end procedure;
    begin
        btn_babord <= '0'; btn_tribord <= '0'; btn_standby <= '0';
        wait for 5*CLK_PER;
        push_button(btn_babord, false);
        push_button(btn_tribord, false);
        push_button(btn_standby, false);
        push_button(btn_babord, false);
        push_button(btn_tribord, false);
        push_button(btn_babord, true);
        push_button(btn_tribord, true);
        push_button(btn_standby, true);
        push_button(btn_standby, false);
        wait;
    end process;

    u_gestion_commande : entity work.gestion_commande
        generic map (
            G_FREQ_IN => CLK_FREQ
        )
        port map (
            arst_i => arst,
            clk_i => clk,
            btn_babord_i => btn_babord,
            btn_tribord_i => btn_tribord,
            btn_standby_i => btn_standby,
            led_babord_o => open,
            led_tribord_o => open,
            led_standby_o => open,
            buzzer_o => open,
            code_fonction_o => open
        );

    
end architecture rtl;