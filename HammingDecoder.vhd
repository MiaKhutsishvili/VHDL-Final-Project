----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

-- Create Date:    11:51:06 07/31/2025 
-- Module Name:    HammingDecoder - Behavioral 
-- Project Name:   Logical Circuits Final Project
-- Description:    This module will encode a 13 bit extended hamming coded data to extract 8 data bits

-- Dependencies:   Odd_Mode = 1 /constant
-- It takes 14 Clks.
-- DONE.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.ALL;

entity HammingDecoder is
    Port ( DecInBit : in STD_LOGIC;                         -- 1 bit input data
			  TestBenchInputDisplay : out STD_LOGIC_VECTOR (0 to 12);
			  OutRdy : inout  STD_LOGIC;                      	-- is 1 if the output is calculated
			  DecOutByte : out byte;   								-- 8 bit output data
			  
           Valid : out STD_LOGIC;                     		-- is 1 if there is max 1 error in code
			  RST : in STD_LOGIC;                              -- resets everything
			  clk : in STD_LOGIC
			  );                             	
end HammingDecoder;

architecture Behavioral of HammingDecoder is

	signal Code : STD_LOGIC_VECTOR (0 to 12);	   		-- 13bit data
	signal cnt : integer := 0;											-- We don't want it to be initialized after eavh clock!
	
begin
		process (clk)
			variable ind : integer := 0;  -- possible error position
			variable ErrorMarker : STD_LOGIC_VECTOR (3 downto 0); 	  	-- possible 1 error position
			variable ExtentionBit : STD_LOGIC;                         -- remade bit #13
		begin
			if rising_edge(clk) then
				if RST = '1' then 
					Valid <= '0';
					OutRdy <= '0';
					ErrorMarker := "0000";
					Code <= "0000000000000";
					cnt <= 0;
					ind := 0;
				else																						-- 13 * Clk -> Input
					if cnt < 13 then
						Code <= Code(1 to 12) & DecInBit;
						cnt <= cnt + 1;
					elsif cnt = 13 then 																-- 1 * Clk -> Calculation
						-- Constructing the new parities
						TestBenchInputDisplay <= Code;
						ErrorMarker(0) := Code(0) xor (Code(2) xor (Code(5) xor
										(Code(8) xor (Code(10)))));
						ErrorMarker(1) := Code(1) xor (Code(4) xor (Code(5) xor
										(Code(9) xor (Code(10)))));
						ErrorMarker(2) := Code(3) xor (Code(6) xor (Code(8) xor
										(Code(9) xor Code(10))));
						ErrorMarker(3) := Code(7) xor Code(11);
						ExtentionBit := Code(0) xor (Code(1) xor (Code(2) xor
										(Code(3) xor (Code(4) xor (Code(5) xor
										(Code(6) xor (Code(7) xor (Code(8) xor
										(Code(9) xor (Code(10) xor Code(11)))))))))));
						
						cnt <= cnt + 1;
						-- Correction
						ind :=  to_integer(unsigned(ErrorMarker));
						ind := ind - 1;
						if ((ind = -1 and ExtentionBit = Code(12)) or
							  ((ind > -1 and ind < 12) and (ExtentionBit = not Code(12)))) then
							Valid <= '1';
							if ind > -1 then
								Code(ind) <= not Code(ind);
							end if;
						else
							Valid <= '0';
						end if;
					else 																					-- 1 * Clk -> Output 
						cnt <= 0;
						DecOutByte <= code(2) & code(4) & code (5) & code(6) & 
										  code(8) & code(9) & code(10) & code(11);
						OutRdy <= '1';
					end if;
				end if;
			end if;
		end process;
end Behavioral;

