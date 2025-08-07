----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

-- Create Date:    14:17:47 07/25/2025  
-- Module Name:    HammingEncoder - Behavioral 
-- Project Name:   Final Project
-- Description:    This module will receive an 8 bit serial data and will encode it using hamming method.
--
-- Dependencies:   Odd mode = 0
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.All;

entity HammingEncoder is
    Port ( BitIn : in  STD_LOGIC;      -- Input data
	        BitOut : out  STD_LOGIC;    -- Hamming coded data
			 
           RST : in  STD_LOGIC;          		-- Setting everything to the default
           clk : in STD_LOGIC		        		-- Receiving sequential data
			 );    
end HammingEncoder;

architecture Behavioral of HammingEncoder is

	signal InCode : byte := (others => '0');
	signal Encoded : STD_LOGIC_VECTOR(12 downto 0) := (others => '0');
	signal InCnt : integer := 0;
	signal OutCnt : integer := 0;
	signal OutRdy : STD_LOGIC;

begin

	process (clk)
	begin
		if rising_edge(clk) then
			if (RST = '1') then 
				InCode <= (others => '0');
				Encoded <= (others => '0');
				InCnt <= 0;
				OutCnt <= 0;
				OutRdy <= '0';
			else
				if InCnt < 8 then
					OutRdy <= '0';
					InCode <= BitIn & InCode(7 downto 1);
					InCnt <= InCnt + 1;
				else
					InCnt <= 0;
					Encoded(2) <= InCode(0);
					Encoded(4) <= InCode(1);
					Encoded(5) <= InCode(2);
					Encoded(6) <= InCode(3);
					Encoded(8) <= InCode(4);
					Encoded(9) <= InCode(5);
					Encoded(10) <= InCode(6);
					Encoded(12) <= InCode(7);
					-- Assigning parities
					Encoded(0) <= (((Encoded(2) xor Encoded(4)) xor Encoded(6)) xor Encoded(8)) xor Encoded(10);
					Encoded(1) <= (((Encoded(2) xor Encoded(5)) xor Encoded(6)) xor Encoded(9)) xor Encoded(10);
					Encoded(3) <= ((Encoded(4) xor Encoded(5)) xor Encoded(6)) xor Encoded(11);
					Encoded(7) <= ((Encoded(8) xor Encoded(9)) xor Encoded(10)) xor Encoded(11);
					Encoded(12) <= (((((Encoded(0) xor Encoded(1)) xor Encoded(2)) xor Encoded(3)) xor Encoded(4)) xor Encoded(5)) xor
									(((((Encoded(6) xor Encoded(7)) xor Encoded(8)) xor Encoded(9)) xor Encoded(10)) xor Encoded(11));
					OutRdy <= '1';
				end if;
				if OutRdy = '1' then
					if OutCnt < 13 then
						BitOut <= Encoded(OutCnt);
						OutCnt <= OutCnt + 1;
					else
						OutCnt <= 0;
					end if;
				end if;
			end if;
		end if;	
	end process;

end Behavioral;

