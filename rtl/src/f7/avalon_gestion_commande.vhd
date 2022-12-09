library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity avalon_gestion_commande is
    generic (
        G_FREQ_IN : integer := 50_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        address_i : in std_logic_vector(0 downto 0);
        write_i : in std_logic;
        write_data_i : in std_logic_vector(31 downto 0);
        read_data_o : out std_logic_vector(31 downto 0);
        btn_babord_i : in std_logic;
        btn_tribord_i : in std_logic;
        btn_standby_i : in std_logic;
        led_babord_o : out std_logic;
        led_tribord_o : out std_logic;
        led_standby_o : out std_logic;
        buzzer_o : out std_logic
    );
end entity avalon_gestion_commande;

architecture rtl of avalon_gestion_commande is
    signal reset : std_logic;
    signal code_fonction : std_logic_vector(3 downto 0);
begin
    
    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            reset <= '1';
        elsif rising_edge(clk_i) then
            if write_i = '1' then
                case to_integer(unsigned(address_i)) is
                    when 16#00# =>
                        reset <= not write_data_i(0);
                    when others =>
                end case;
            end if;
        end if;
    end process;

    read_data_o <= 
        (1 to 31 => '0') & not reset when unsigned(address_i) = 16#00# else
        (4 to 31 => '0') & code_fonction when unsigned(address_i) = 16#01# else
        (others => '-');

    block_gestion_commande_inst : block
        component gestion_commande
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
          end component;
    begin
        u_gestion_commande : component gestion_commande
            generic map (
                G_FREQ_IN => G_FREQ_IN
            )
            port map (
                arst_i => arst_i,
                clk_i => clk_i,
                btn_babord_i => btn_babord_i,
                btn_tribord_i => btn_tribord_i,
                btn_standby_i => btn_standby_i,
                led_babord_o => led_babord_o,
                led_tribord_o => led_tribord_o,
                led_standby_o => led_standby_o,
                buzzer_o => buzzer_o,
                code_fonction_o => code_fonction
            );
    end block;

end architecture rtl;