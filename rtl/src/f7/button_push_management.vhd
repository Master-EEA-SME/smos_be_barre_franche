library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.utils.all;

entity button_push_management is
    generic (
        G_FREQ_IN : integer := 50_000_000;
        G_LONG_PUSH_TIME : integer := 1000 -- in ms
    );
    port (
        arst_i : in std_logic;
        clk_i : in std_logic;
        btn_i : in std_logic;
        short_push_o : out std_logic;
        long_push_o : out std_logic
    );
end entity button_push_management;

architecture rtl of button_push_management is
    type button_st_t is (st_release, st_push, st_wait_release);
    signal button_st : button_st_t;
    signal pulse_reset, pulse_q : std_logic;
begin
    
    process (clk_i, arst_i)
    begin
        if arst_i = '1' then
            button_st <= st_release;
        elsif rising_edge(clk_i) then
            case button_st is
                when st_release =>
                    if btn_i = '1' then
                        button_st <= st_push;
                    end if;
                when st_push =>
                    if btn_i = '1' and pulse_q = '1' then
                        button_st <= st_wait_release;
                    elsif btn_i = '0' then
                        button_st <= st_release;
                    end if;
                when st_wait_release =>
                    if btn_i = '0' then
                        button_st <= st_release;
                    end if;
                when others =>
            end case;
        end if;
    end process;

    
    block_pulse : block
        signal cnt : unsigned(bit_width((G_FREQ_IN * G_LONG_PUSH_TIME / 1000) - 1) - 1 downto 0);
    begin
        pulse_reset <= '1' when button_st /= st_push else '0';
        process (clk_i, arst_i)
        begin
            if arst_i = '1' then
                cnt <= (others => '0');
            elsif rising_edge(clk_i) then
                if pulse_reset = '1' then
                    cnt <= (others => '0');
                else
                    cnt <= cnt + 1;
                end if;
            end if;
        end process;
        pulse_q <= '1' when cnt >= ((G_FREQ_IN * G_LONG_PUSH_TIME / 1000) - 1) else '0';
    end block;

    short_push_o <= 
        '1' when button_st = st_push and btn_i = '0' else 
        '0';
            
    long_push_o <= 
        '1' when button_st = st_push and btn_i = '1' and pulse_q = '1' else 
        '0';
end architecture rtl;