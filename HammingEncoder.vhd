----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            402230??

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

entity HammingEncoder is
    Port ( clk : in STD_LOGIC;           -- Receiving sequential data
			  In_Start : in STD_LOGIC;      -- Marking In_Data LSB
			  In_Data : in  STD_LOGIC;      -- Input data
           Rst : in  STD_LOGIC;          -- Setting everything to the default
           Out_Data : out  STD_LOGIC;    -- Hamming coded data
           Out_Rdy : out  STD_LOGIC;     -- Is true if the output is calculated
			  Open_In : inout  STD_LOGIC);    -- No calculation is being done
end HammingEncoder;

architecture Behavioral of HammingEncoder is

	signal code : STD_LOGIC_VECTOR (12 downto 0);

begin

	process (clk, Rst, In_Start)
		variable cnt : integer := 0;	-- cnt is 0 at the begining of simulation
	begin
		if rising_edge(clk) then
			if (Rst = '1' or In_Start = '1') then
				Out_Data <= '0';
				Out_Rdy <= '0';
				Open_In <= '1';
				code <= "0000000000000";
				cnt := 0;
			end if;
			if Open_In = '1' then
				case cnt is
					when 0 => 
						code(2) <= In_Data;
					when 1 =>
						code(4) <= In_Data;
					when 2 => 
						code(5) <= In_Data;
					when 3 =>
						code(6) <= In_Data;
					when 4 => 
						code(7) <= In_Data;
					when 5 =>
						code(8) <= In_Data;
					when 6 => 
						code(9) <= In_Data;
					when 7 =>
						code(10) <= In_Data;
						cnt := 0;
						Open_In <= '0';
					when others =>
						-- Impossible!
				end case;
				cnt := cnt + 1;
			elsif Open_In = '0' then  
				-- Assigning parities
				code(0) <= (((code(2) xor code(4)) xor code(6)) xor code(8)) xor code(10);
				code(1) <= (((code(2) xor code(5)) xor code(6)) xor code(9)) xor code(10);
				code(3) <= ((code(4) xor code(5)) xor code(6)) xor code(11);
				code(7) <= ((code(8) xor code(9)) xor code(10)) xor code(11);
				code(12) <= (((((code(0) xor code(1)) xor code(2)) xor code(3)) xor code(4)) xor code(5)) xor
								(((((code(6) xor code(7)) xor code(8)) xor code(9)) xor code(10)) xor code(11));
				-- Outputing
				Out_Rdy <= '1';
				case cnt is
					when 0 => 
						Out_Data <= code(0);
					when 1 =>
						Out_Data <= code(1);
					when 2 => 
						Out_Data <= code(2);
					when 3 =>
						Out_Data <= code(3);
					when 4 => 
						Out_Data <= code(4);
					when 5 =>
						Out_Data <= code(5);
					when 6 => 
						Out_Data <= code(6);
					when 7 =>
						Out_Data <= code(7);
					when 8 => 
						Out_Data <= code(8);
					when 9 =>
						Out_Data <= code(9);
					when 10 => 
						Out_Data <= code(10);
					when 11 =>
						Out_Data <= code(11);
					when 12 => 
						Out_Data <= code(12);
						cnt := 0;
						Open_In <= '1';
						Out_Rdy <= '0';
					when others =>
						-- Impossible!
				end case;
				cnt := cnt + 1;
			end if;
		end if;	
	end process;

end Behavioral;

