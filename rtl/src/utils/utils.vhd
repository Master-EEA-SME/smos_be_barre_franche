library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

package utils is
    
    function bit_width (value : in integer) return integer;

end package utils;

package body utils is
    
    function bit_width(value : in integer) return integer is
        variable ret : integer;
    begin
        if value = 0 then
            ret := -1;
        elsif value = 1 then
            ret := 1;
        else
            ret := integer(ceil(log2(real(value))));
        end if;
        return ret;
    end function;
    
end package body utils;