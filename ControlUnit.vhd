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
			  Packet : inout data_packet;						-- The output packet
			  PackType : inout packet_type;
			 
			  PackIsReady : inout STD_LOGIC;
			  Validation : out STD_LOGIC;
			  clk : in STD_LOGIC;				
			  RST : in STD_LOGIC									-- Resets everything
			);
end ControlUnit;

architecture Behavioral of ControlUnit is
	
	signal Step : integer := 0;
	
begin

	process (clk)			
	begin
		if rising_edge(clk) then
			if RST = '1' then
				Step <= 0;
				PackIsReady <= '0';
				PackType <= zero;
				
			else
				case step is
					when 0 =>
						PackIsReady <= '0';
						Packet <= (others => (others => '0'));
						Packet(0) <= InByte;
						
						---
						case InByte is 																-- Categorizing the packet
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
						---
						Step <= Step + 1;
						
					when 1 =>
						Packet(1) <= InByte;
						if PackType = Rea_d then
							Step <= 5;
						else
							Step <= Step + 1;
						end if;
					
					when 2 => 
						Packet(2) <= InByte;
						if PackType = Writ_e then
							Step <= 5;
						else
							Step <= Step + 1;
						end if;

					when 3 => 
						Packet(3) <= InByte;
						if ((PackType = Operand_Alu or PackType = Immediate_Alu) or 
								PackType = Indirect_Addressing) then
							Step <= 5;
						else
							Step <= Step + 1;
						end if;
						
					when 4 => 
						Packet(4) <= InByte;
						Step <= Step + 1;
						
					when 5 => 
						Packet(5) <= InByte;
						Step <= Step + 1;
						
					when 6 =>
						Packet(6) <= InByte;
						if (PackType = Writ_e or PackType = Rea_d) then
							Switch <= '0';
						else
							Switch <= '1';
						end if;
						Step <= Step + 1;
						
					when others =>
						Step <= 0;
						Validation <= Validate(Packet);
						PackIsReady <= '1';
						
				end case;
			end if;
		end if;
	end process;
	
	
end Behavioral;

