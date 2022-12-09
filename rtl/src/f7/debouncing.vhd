library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity debouncing is
    generic (
        G_FREQ_IN : integer := 50_000_000
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        btn_i : in std_logic;
        btn_o : out std_logic
    );
end entity debouncing;

architecture rtl of debouncing is
    type debouncing_st_t is (st_idle, st_deboucing, st_debounced);
    signal debouncing_st : debouncing_st_t;
    signal pulse_reset, pulse_q : std_logic;
    signal btn : std_logic;
begin
    
    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            debouncing_st <= st_idle;
        elsif rising_edge(clk_i) then
            case debouncing_st is
                when st_idle =>
                    if btn_i = '1' then
                        debouncing_st <= st_deboucing;
                    end if;
                when st_deboucing =>
                    if pulse_q = '1' then
                        debouncing_st <= st_debounced;
                    elsif btn_i = '0' then
                        debouncing_st <= st_idle;
                    end if;
                when st_debounced =>
                    if btn_i = '0' then
                        debouncing_st <= st_idle;
                    end if;
                when others =>
            end case;
        end if;
    end process;

    pulse_reset <= '0' when debouncing_st = st_deboucing else '1';

    u_pulse : entity work.pulse
        generic map (
            G_FREQ_IN => G_FREQ_IN,
            G_FREQ_OUT => 1000
        )
        port map (
            arst_i => arst_i,
            clk_i => clk_i,
            srst_i => pulse_reset,
            q_o => pulse_q
        );

    btn_o <= '1' when debouncing_st = st_debounced else '0';

end architecture rtl;