library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity avalon_anemometre is
    generic (
        G_FREQ_IN : integer := 50_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        anemo_i : in std_logic;
        address_i : in std_logic_vector(0 downto 0);
        write_data_i : in std_logic_vector(31 downto 0);
        write_i : in std_logic;
        read_data_o : out std_logic_vector(31 downto 0)
    );
end entity avalon_anemometre;

architecture rtl of avalon_anemometre is
    signal reset, start_stop, continu, data_valid : std_logic;
    signal data_anemo : std_logic_vector(7 downto 0);
begin
    
    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            reset <= '1';
            start_stop <= '0';
            continu <= '0';
        elsif rising_edge(clk_i) then
            if write_i = '1' and unsigned(address_i) = 16#00# then
                reset <= not write_data_i(0);
                start_stop <= write_data_i(1);
                continu <= write_data_i(2);
            end if;
        end if;
    end process;

    block_anemo_inst : block
        component anemometre
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
          end component;          
    begin
        u_anemometre : component anemometre
            generic map (
                G_FREQ_IN => G_FREQ_IN
            )
            port map (
                arst_i => reset,
                clk_i => clk_i,
                anemo_i => anemo_i,
                continu_i => continu,
                start_stop_i => start_stop,
                data_o => data_anemo,
                valid_o => data_valid
            );
    end block;

    read_data_o <= 
        (3 to 31 => '0') & continu & start_stop & (not reset) when unsigned(address_i) = 16#00# else
        (9 to 31 => '0') & data_valid & data_anemo;
    
end architecture rtl;