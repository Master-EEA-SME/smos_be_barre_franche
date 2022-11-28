library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity avalon_pwm is
    generic (
        G_PWM_RESOLUTION : integer range 1 to 32 := 16
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        address_i : in std_logic_vector(1 downto 0);
        write_i : in std_logic;
        write_data_i : in std_logic_vector(31 downto 0);
        read_data_o : out std_logic_vector(31 downto 0);
        q_o : out std_logic
    );
end entity avalon_pwm;

architecture rtl of avalon_pwm is
    component pwm
        generic (
            G_N : integer := 16
        );
        port (
            arst_i : in std_logic;
            clk_i : in std_logic;
            srst_i : in std_logic;
            duty_i : in std_logic_vector(G_N - 1 downto 0);
            freq_i : in std_logic_vector(G_N - 1 downto 0);
            q_o : out std_logic
        );
      end component;
      
    signal srst : std_logic;
    signal duty, freq : std_logic_vector(G_PWM_RESOLUTION - 1 downto 0);
begin
    
    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            srst <= '1';
            duty <= (others => '0');
            freq <= (others => '1');
        elsif rising_edge(clk_i) then
            if write_i = '1' then
                case to_integer(unsigned(address_i)) is
                    when 16#00# =>
                        srst <= write_data_i(0);
                    when 16#02# =>
                        duty <= write_data_i(G_PWM_RESOLUTION - 1 downto 0);
                    when 16#03# =>
                        freq <= write_data_i(G_PWM_RESOLUTION - 1 downto 0);
                    when others =>
                end case;
            end if;
        end if;
    end process;

    read_data_o <= 
        (1 to 31 => '0') & srst when unsigned(address_i) = 16#00# else
        (G_PWM_RESOLUTION to 31 => '0') & duty when unsigned(address_i) = 16#02# else
        (G_PWM_RESOLUTION to 31 => '0') & freq when unsigned(address_i) = 16#03# else
        (others => '-');

    u_pwm : component pwm
        generic map (
            G_N => G_PWM_RESOLUTION
        )
        port map (
            arst_i => arst_i,
            clk_i => clk_i,
            srst_i => srst,
            duty_i => duty,
            freq_i => freq,
            q_o => q_o
        );
        
end architecture rtl;