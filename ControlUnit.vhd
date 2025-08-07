----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

-- Create Date:    11:03:26 08/01/2025 
-- Module Name:    ControlUnit - Behavioral 
-- Project Name:   Logical Circuits final projrct
-- Description:    This module will shape the packets
-- Done.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.ALL;

entity ControlUnit is
    Port ( InByte : in byte;									-- 8 bit input data
	 
			  Switch : out STD_LOGIC;							-- 0 is RAM mode / 1 is ALU mode
			  Packet : out data_packet;						-- The output packet
			  PackMode : out packet_type;
			 
			  clk : in STD_LOGIC;				
			  RST : in STD_LOGIC									-- Resets everything
			);
end ControlUnit;

architecture Behavioral of ControlUnit is
	
	signal PackHold : data_packet := (others => (others => '0'));		-- Temperory memory for a packet
	signal PackType : packet_type;

	signal step : integer := 0;
	
begin

	process (clk)
			variable Sum : signed(15 downto 0) := (others => '0');
			variable PackIsReady : STD_LOGIC := '0';
	begin
		if rising_edge(clk) then
			if RST = '1' then
				PackHold <= (others => (others => '0'));
				step <= 0;
			else
				case step is
					when 0 =>
						PackHold(0) <= InByte;
					case PackHold(0) is 																-- Categorizing the packet
							when "00000000" | "00000001" | "00000010" | "00000011" =>
								PackType <= Operand_Alu;
							when "11110000" => 
								PackType <= Writ_e;
							when "00001111" =>
								PackType <= Rea_d;
							when "00111100" | "00111101" | "00111110" | "00111111" =>
								PackType <= Immediate_Alu;
							when "11000000" | "11000001" | "11000010" | "11000011" =>
								PackType <= Array_Alu;
							when "00110000" | "00110001" | "00110010" | "00110011" =>
								PackType <= Indirect_Addressing;
							when others =>
								PackType <= zero;
						end case;	
						PackMode <= PackType;
						
					when 1 =>
						PackHold(1) <= InByte;
						if PackType = Rea_d then
							PackIsReady := '1';
						end if;
					
					when 2 => 
						PackHold(2) <= InByte;
						if PackType = Writ_e then
							PackIsReady := '1';
						end if;

					when 3 => 
						PackHold(3) <= InByte;
						if ((PackType = Operand_Alu or PackType = Immediate_Alu) or 
								PackType = Indirect_Addressing) then
							PackIsReady := '1';
						end if;
						
					when 4 => 
						PackHold(4) <= InByte;
						if PackType = Array_Alu then
							PackIsReady := '1';
						end if;
	
					when others => 
						step <= 0;
						
				end case;
				
				if PackIsReady = '0' then
					step <= step + 1;
				else
					step <= 0;
					PackHold(5) <= CheckSumH(PackHold); 
					PackHold(6) <= CheckSumL(PackHold);
					Packet <= PackHold;
					if (PackType = Writ_e or PackType = Rea_d) then
						Switch <= '0';
					else
						Switch <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
	
	
end Behavioral;

