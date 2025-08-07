----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

-- Create Date:    13:54:01 08/07/2025 
-- Module Name:    ByteToBit - Behavioral 
-- Project Name:   Logical Circuits Final Project
-- Description:    This Module will break a byte to its bits
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.ALL;

entity ByteToBit is
    Port ( ByteIn : in  byte;
           BitOut : out  STD_LOGIC;
			  
			  clk : in  STD_LOGIC);
end ByteToBit;

architecture Behavioral of ByteToBit is

	signal BitCnt : integer range 0 to 8 := 8;
	signal ByteCash : byte;
	
begin

	process(clk)
	begin
		if rising_edge(clk) then
			if BitCnt = 8 then
				BitCnt <= 1;
				ByteCash <= ByteIn;
				BitOut <= ByteCash(0);
			else
				BitOut <= ByteCash(BitCnt);
				BitCnt <= BitCnt + 1;
			end if;
		end if;
	end process;

end Behavioral;

