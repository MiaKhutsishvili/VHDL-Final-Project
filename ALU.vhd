----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

-- Create Date:    14:11:14 08/05/2025 
-- Module Name:    ALU - Behavioral 
-- Project Name: 	 Logical Circuits Final Project
-- Description:    This module is the calculator
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.All;

entity ALU is
    Port ( in_packet : in  Alu_In_Packet; -- instead of address_1 and address_2, we have the exact data from control unit.
			  clk : in STD_LOGIC;
			  
           output : out Ram_In_Packet
			 );
end ALU;

architecture Behavioral of ALU is

	signal operation : Alu_Operation;	
	signal intSum : integer range -650 to 650 := 0;	
	signal bitSum : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
	
begin
	
	process(clk)
		variable eq : integer := 0;
	begin
		if rising_edge(clk) then
			-- Validation will be done at the control unit.
			case in_packet(0)(1 downto 0) is
				when "00" =>
					operation <= Add;
				when "01" => 
					operation <= Sub;
				when "10" => 
					operation <= Orr;
				when "11" =>
					operation <= Andd;
				when others =>
			end case;
			output(0) <= "11110000";
			output(1) <= in_packet(3);
			case operation is
				when Add => 
					eq := to_integer(signed(in_packet(1))) + to_integer(signed(in_packet(2)));
					output(2) <= std_logic_vector(to_signed(eq, 8));
				when Sub =>
					eq := to_integer(signed(in_packet(1))) - to_integer(signed(in_packet(2)));
					output(2) <= std_logic_vector(to_signed(eq, 8));
					when Orr =>
						output(2) <= in_packet(1) or in_packet(2);
					when Andd => 
						output(2) <= in_packet(1) and in_packet(2);	
					when others =>
				end case;
				intSum <= to_integer(signed(in_packet(0))) + to_integer(signed(in_packet(1))) + to_integer(signed(in_packet(2)));
				bitSum <= std_logic_vector(to_signed(intSum, 16));
				output(3) <= bitSum(15 downto 8);
				output(4) <= bitSum(7 downto 0);		
		end if;
	end process;
	
end Behavioral;

