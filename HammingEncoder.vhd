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
			  TestBenchCheck : out hamming;
			  TestBenchInputDisplay : out byte;
			  OutRdy : inout STD_LOGIC := '0';
			  
           RST : in  STD_LOGIC;          		-- Setting everything to the default
           clk : in STD_LOGIC		        		-- Receiving sequential data
			 );    
end HammingEncoder;

architecture Behavioral of HammingEncoder is

	signal InCode : byte := (others => '0');
	signal Encoded : STD_LOGIC_VECTOR(0 to 12) := (others => '0');
	signal InCnt : integer := 0;
	signal OutCnt : integer := 0;

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
				if InCnt < 8 then											-- 8 * Clk -> Input
					InCode <= BitIn & InCode(7 downto 1);
					InCnt <= InCnt + 1;
				elsif InCnt = 8 then										-- 1 * Clk -> Calculation
					TestBenchInputDisplay <= InCode;
					Encoded(2) <= InCode(7);
					Encoded(4) <= InCode(6);
					Encoded(5) <= InCode(5);
					Encoded(6) <= InCode(4);
					Encoded(8) <= InCode(3);
					Encoded(9) <= InCode(2);
					Encoded(10) <= InCode(1);
					Encoded(11) <= InCode(0);
					-- Assigning parities
					Encoded(0) <= (((InCode(7) xor InCode(6)) xor InCode(4)) xor InCode(3)) xor InCode(1);	
					Encoded(1) <= (((InCode(7) xor InCode(5)) xor InCode(4)) xor InCode(2)) xor InCode(1);	
					Encoded(3) <= ((InCode(6) xor InCode(5)) xor InCode(4)) xor InCode(0);	
					Encoded(7) <= ((InCode(3) xor InCode(2)) xor InCode(1)) xor InCode(0);
					Encoded(12) <= ((((InCode(7) xor InCode(6)) xor InCode(5)) xor InCode(3)) xor InCode(2)) xor InCode(0);	
					InCnt <= InCnt + 1;
				else 															-- 14 * Clk -> Output
					TestBenchCheck <= Encoded;
					OutRdy <= '1';
					if OutCnt < 13 then
						BitOut <= Encoded(OutCnt);
						OutCnt <= OutCnt + 1;
					else
						InCnt <= 0;
						OutCnt <= 0;
						OutRdy <= '0';
					end if;
				end if;
			end if;
		end if;	
	end process;

end Behavioral;

