----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

-- Create Date:    11:03:26 08/01/2025 
-- Module Name:    ControlUnit - Behavioral 
-- Project Name:   Logical Circuits final projrct
-- Description:    This module will shape the packets
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.ALL;

entity ControlUnit is
    Port ( in_data : in Byte;								-- 8 bit input data
			  packet_type : inout pack_type;				-- Determines the type packet

			  out_data : out data_packet;					-- Whole packet output

			  clk : in STD_LOGIC;				
			  RST : in STD_LOGIC								-- Resets everything
			);
end ControlUnit;

architecture Behavioral of ControlUnit is
	
	signal packet : data_packet := (others => (others => '0'));		-- Temperory memory for a packet
	signal step : integer := 0;												-- To save which part of packet is the input
	signal intSum : integer range -650 to 650 := 0;						-- From -2^7 * 5 to (2^7 - 1) * 5
	signal bitSum : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
	
begin

	process (clk)
	begin
		if rising_edge(clk) then
			if RST = '1' then
				packet <= (others => (others => '0'));
				step <= 0;
			else
				case step is
					when 0 =>
						packet(0) <= in_data;
					case packet(0) is 																-- Categorizing the packet
							when "00000000" | "00000001" | "00000010" | "00000011" =>
								packet_type <= Operand_Alu;
							when "11110000" => 
								packet_type <= Writ_e;
							when "00001111" =>
								packet_type <= Rea_d;
							when "00111100" | "00111101" | "00111110" | "00111111" =>
								packet_type <= Immediate_Alu;
							when "11000000" | "11000001" | "11000010" | "11000011" =>
								packet_type <= Array_Alu;
							when "00110000" | "00110001" | "00110010" | "00110011" =>
								packet_type <= Indirect_Addressing;
							when "11001111" =>
								packet_type <= Read_Response;
							when others =>
								packet_type <= zero;
						end case;	
						
					when 1 =>
						packet(1) <= in_data;
					
					when 2 => 
						if packet_type = Rea_d then
							packet(2) <= "00000000";
							step <= 3;
						else
							packet(2) <= in_data;
						end if;

					when 3 => 
						if (packet_type = Rea_d or packet_type = Writ_e) then
							packet(3) <= "00000000";
							step <= 4;
						else
							packet(3) <= in_data;
						end if;
						
					when 4 => 
						if packet_type = Array_Alu then
							packet(4) <= in_data;
						else
							packet(4) <= "00000000";
						end if;
						step <= 5;
					
					when 5 => 
						intSum <= to_integer(signed(packet(0))) + to_integer(signed(packet(1))) +
									 to_integer(signed(packet(2))) + to_integer(signed(packet(3))) +
									 to_integer(signed(packet(4)));
						bitSum <= std_logic_vector(to_signed(intSum, 16));
						packet(5) <= bitSum(15 downto 8);
						step <= 6;
					
					when 6 =>
						packet(6) <= bitSum(7 downto 0);
						step <= 7;
						
					when others =>
						out_data <= packet;
						step <= -1;
				end case;
				step <= step + 1;
				
			end if;
		end if;
	end process;
	
	
end Behavioral;

