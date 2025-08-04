----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030		40223019

-- Create Date:    	03:27:20 08/03/2025 
-- Module Name:    	RAM - Behavioral 
-- Project Name: 	Logiccal Circuits Final Project
-- Description: 	Just a Ram containing 256 cells, 32 rows 8 colomns
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.ALL;

entity RAM is
    Port ( 	packet : in  Ram_In_Pack;				-- Input data packets
		mode : in pack_type;					-- Read or write
		RST : in  STD_LOGIC;
		clk : in  STD_LOGIC;
			  
		valid : inout STD_LOGIC;				-- If the Checksums match
				
		Ram_Response : out Ram_Resp_Pack			-- Output of read mode
			 );
end RAM;

architecture Behavioral of RAM is
	
	signal Memory : Ram_Matrix;
	signal intSum : integer range -650 to 650 := 0;	
	signal bitSum : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
	signal CheckSumH : STD_LOGIC_VECTOR(7 downto 0);
	signal CheckSumL : STD_LOGIC_VECTOR(7 downto 0);

begin

	process(clk)
		variable address_row : integer range 0 to 31;
		--variable address_col : integer range 0 to 7;
	begin
		if rising_edge(clk) then
			if RST = '1' then
				for i in 0 to 31 loop
					--for j in 0 to 7 loop
					Memory(i) <= "00000000";
					--end loop;
				end loop;
			else
				intSum <= 0;
				bitSum <= "0000000000000000";
				Valid <= '0';
				case mode is
					when Writ_e =>
						-- Validation:
						intSum <= to_integer(signed(packet(0))) + to_integer(signed(packet(1))) + to_integer(signed(packet(2)));
						bitSum <= std_logic_vector(to_signed(intSum, 16));
						CheckSumH <= bitSum(15 downto 8);
						CheckSumL <= bitSum(7 downto 0);
						if (CheckSumH = packet(3) and  CheckSumL = packet(4)) then
							Valid <= '1';
							address_row := to_integer(unsigned(packet(1)));--(7 downto 3)));
							--address_col := to_integer(unsigned(packet(1)(2 downto 0)));
							if address_row > 31 then
								Valid <= '0';
							end if;
						end if;
						if Valid = '1' then
							-- Write Operation
							Memory(address_row) <= packet(2);
						end if;
					when Rea_d =>
						-- Validation:
						intSum <= to_integer(signed(packet(0))) + to_integer(signed(packet(1)));
						bitSum <= std_logic_vector(to_signed(intSum, 16));
						CheckSumH <= bitSum(15 downto 8);
						CheckSumL <= bitSum(7 downto 0);
						
						if (CheckSumH = packet(2) and  CheckSumL = packet(3)) then
							Valid <= '1';
							address_row := to_integer(unsigned(packet(1)));--(7 downto 3)));
							--address_col := to_integer(unsigned(packet(1)(2 downto 0)));
							if address_row > 31 then
								Valid <= '0';
							end if;
						end if;
						if Valid = '1' then
							-- Read Operation
							Ram_Response(0) <= "11001111";
							Ram_Response(1) <= Memory(address_row);
							intSum <= to_integer(signed(Memory(address_row))) - 49;
							bitSum <= std_logic_vector(to_signed(intSum, 16));
							Ram_Response(2) <= bitSum(15 downto 8);
							Ram_Response(3) <= bitSum(7 downto 0);
						end if;
					when others =>
						Valid <= '0';
				end case;
			end if;
		end if;
	end process;
	
end Behavioral;

