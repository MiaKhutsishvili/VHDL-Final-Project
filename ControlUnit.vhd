----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

-- Create Date:    11:03:26 08/01/2025 
-- Module Name:    ControlUnit - Behavioral 
-- Project Name:   Logical Circuit final projrct
-- Description:    This module will shape the packets
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.ALL;

entity ControlUnit is
    Port ( 	in_data : in  STD_LOGIC_VECTOR(7 downto 0);		-- 8 bit input data
			  -- in_start : in STD_LOGIC;									
	   	clk : in STD_LOGIC;				
			  
		RST : inout STD_LOGIC;					-- Resets everything
		out_rdy : inout STD_LOGIC;				-- Is 1 when the whole packet is ready 
		packet_type : inout pack_type;				-- Determines the type packet

		out_data : out data_packet				-- Whole packet output
	);
end ControlUnit;

architecture Behavioral of ControlUnit is
	
	signal packet : data_packet;					-- Temperory memory for a packet
	signal waitOneClk : STD_LOGIC;					-- Used to make a 1 clk hold for the out_rdy
	signal step : integer := 0;					-- To save which part of packet is the input
	
begin

	process (clk)
	begin
		if rising_edge(clk) then
--			if in_start = '1' then
--				for i in 0 to 6 loop
--					for j in 0 to 7 loop
--						packet(i)(j) <= '0';
--					end loop;
--				end loop;
--				step <= 0;
--				waitOneClk <= '0';
--			end if;
			if RST = '1' then
				for i in 0 to 6 loop
					for j in 0 to 7 loop
						packet(i)(j) <= '0';
					end loop;
				end loop;
				step <= 0;
				waitOneClk <= '0';
			end if;
			
			if waitOneClk = '1' then 
				out_rdy <= '0';
				waitOneClk <= '0';
			end if;
			
			if out_rdy = '1' then
				waitOneClk <= '1';
			end if; 
			
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
					packet(2) <= in_data;
				when 3 => 
					packet(3) <= in_data;
					if (packet_type = Rea_d or packet_type = Read_Response) then
						packet(4) <= "00000000";
						packet(5) <= "00000000";
						packet(6) <= "00000000";
						out_rdy <= '1';
						out_data <= packet;
						RST <= '1';
					end if;
					
				when 4 => 
					packet(4) <= in_data;
					if packet_type = Writ_e then
						packet(5) <= "00000000";
						packet(6) <= "00000000";
						out_rdy <= '1';
						out_data <= packet;
						RST <= '1';
					end if;
					
				when 5 => 
					packet(5) <= in_data;
					if ((packet_type = Operand_Alu or packet_type = Immediate_Alu) or packet_type = Indirect_Addressing) then
						packet(6) <= "00000000";
						out_rdy <= '1';
						out_data <= packet;
						RST <= '1';
					end if;
				
				when 6 => 
					packet(6) <= in_data;
					if packet_type = Array_Alu then
						out_rdy <= '1';
						out_data <= packet;
						RST <= '1';
					end if;
					
				when others =>
					-- Oopsi;
			end case;
			step <= step + 1;
		end if;
	end process;
	
	
end Behavioral;

