----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030				  40223019

-- Create Date:    03:27:20 08/03/2025 
-- Module Name:    RAM - Behavioral 
-- Project Name: 	 Logiccal Circuits Final Project
-- Description: 	 Just a Ram containing 256 cells, 32 rows 8 colomns
-- DONE!
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.ALL;

entity RAM is
    Port ( 	CtrlReq : in  data_packet;						-- Input data packet
				AluReq : in  data_packet;
				ReadResp : out Ram_Resp_Pack;					-- Output of read mode
				InChoose : in STD_LOGIC;
				Error : out STD_LOGIC;						-- Address Out of Band / CheckSum Fail
				RST : in  STD_LOGIC;
				clk : in  STD_LOGIC
			 );
end RAM;

architecture Behavioral of RAM is
	
	signal Memory : ram_matrix := (others => (others => '0')); --(others => '0')));	-- initial value is zerop
	
begin
	
	process(clk)
		variable InPack : data_packet;
		variable Mode : packet_type;								
		variable RowAddress : integer range 0 to 31;
--		variable ColAddress : integer range 0 to 7;
		variable WriteData : byte;
		variable bitSum : byte := (others => '0');
		variable CheckSum : STD_LOGIC;
		
	begin
		if rising_edge(clk) then
			if RST = '1' then
				Memory <= (others => (others => '0')); 
			else
				if InChoose = '1' then
					InPack := AluReq;
				else 
					InPack := CtrlReq;
				end if;
				Error <= '0';
				if InPack(0) = "00001111" then
					Mode := Rea_d;
				elsif InPack(0) = "11110000" then
					Mode := Writ_e;
				else
					Mode := zero;
					Error <= '1';
				end if;
				
				RowAddress := to_integer(unsigned(InPack(1))); --(7 downto 3)));
--				ColAddress := to_integer(unsigned(InPack(1)(2 downto 0)));
				WriteData := InPack(2);
				CheckSum := Validate(InPack);
				if (to_integer(unsigned(InPack(1))) < 32 and CheckSum = '1') then
					case Mode is				
						when Writ_e =>
							-- Write Operation
							Memory(RowAddress) <= WriteData;
						when Rea_d =>
							-- Read Operation
							ReadResp(0) <= "11001111";
							ReadResp(1) <= Memory(RowAddress);
							bitSum := std_logic_vector(to_signed(-49, 8) + signed(Memory(RowAddress))); 
							-- Since Row Address is always > 0, => bitSum will always use only 8 bits. max bitSum = 206
							ReadResp(2) <= "00000000";
							ReadResp(3) <= bitSum;
						when others =>
							Error <= '1';
					end case;
				else
					Error <= '1';
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;

