----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

-- Create Date:    14:04:19 08/07/2025 
-- Module Name:    PackToByte - Behavioral 
-- Project Name:   Logical Circuits Final Project
-- Description:    This Module will break a packet into its bytes
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.ALL;

entity PackToByte is
    Port ( PackIn : in  ram_resp_pack;
           ByteOut : out  byte;
           clk : in  STD_LOGIC);
end PackToByte;

architecture Behavioral of PackToByte is

	signal CellCnt : integer range 0 to 4 := 4;
	signal PacketCash : ram_resp_pack;

begin
	
	PacketCash(0) <= "11001111";
	PacketCash(2) <= "00000000";
	process(clk)
	begin
		if rising_edge(clk) then
			if CellCnt = 4 then
				CellCnt <= 1;
				PacketCash(1) <= PackIn(1);
				PacketCash(3) <= PackIn(3);
				ByteOut <= PacketCash(0);
			else
				ByteOut <= PacketCash(CellCnt);
				CellCnt <= CellCnt + 1;
			end if;
		end if;
	end process;

end Behavioral;

