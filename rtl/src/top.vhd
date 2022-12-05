library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library soc;

entity top is
    port (
        pin_arst_n_i : in std_logic;
        pin_clk_i : in std_logic;
        pin_btn_i : in std_logic_vector(0 downto 0);
        pin_sw_i : in std_logic_vector(3 downto 0);
        pin_led_o : out std_logic_vector(7 downto 0);
        pin_verin_pwm_o : out std_logic;
        pin_verin_sens_o : out std_logic;
        pin_verin_sck_o : out std_logic;
        pin_verin_sdi_i : in std_logic;
        pin_verin_cs_n_o : out std_logic
    );
end entity top;

architecture rtl of top is
    signal arst_n, clk : std_logic;
    signal pwm_internal : std_logic;
begin
    arst_n <= pin_arst_n_i;
    clk <= pin_clk_i;

    u_soc : entity soc.soc
		port map (
			clk_clk => clk,
			reset_reset_n => arst_n,
			btn_export => pin_btn_i(0),
			sw_export => pin_sw_i,
			led_export => pin_led_o,
            pwm0_export => pwm_internal,
            anemo_export => pwm_internal,
            giro_export => pwm_internal,
            verin_cs_n_o => pin_verin_cs_n_o,
            verin_pwm_o => pin_verin_pwm_o,
            verin_sck_o => pin_verin_sck_o,
            verin_sdi_i => pin_verin_sdi_i,
            verin_sens_o => pin_verin_sens_o
		);
    
end architecture rtl;