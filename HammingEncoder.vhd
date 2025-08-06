----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

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
use work.Packages.All;

entity HammingEncoder is
    Port ( clk : in STD_LOGIC;           -- Receiving sequential data
			  in_data : in  STD_LOGIC;      -- Input data
           RST : in  STD_LOGIC;          -- Setting everything to the default
           
			  out_data : out  STD_LOGIC    -- Hamming coded data
			 );    
end HammingEncoder;

architecture Behavioral of HammingEncoder is

	signal code : BYTE := "00000000";
	signal enc_data : STD_LOGIC_VECTOR(12 downto 0) := "0000000000000";

begin

	process (clk)
		variable in_cnt : integer := 0;	-- cnt is 0 at the begining of simulation
		variable out_cnt : integer := 0;
	begin
		if rising_edge(clk) then
			if (RST = '1') then 
				out_data <= '0';
				code <= "00000000";
				enc_data <= "0000000000000";
				in_cnt := 0;
				out_cnt := 0;
			else
				if in_cnt < 8 then	-- Input gate is open, we are in INPUT MODE
					code <= in_data & code(7 downto 1);
					in_cnt := in_cnt + 1;
				else
					in_cnt := 0;
					enc_data(2) <= code(0);
					enc_data(4) <= code(1);
					enc_data(5) <= code(2);
					enc_data(6) <= code(3);
					enc_data(8) <= code(4);
					enc_data(9) <= code(5);
					enc_data(10) <= code(6);
					enc_data(12) <= code(7);
					-- Assigning parities
					enc_data(0) <= (((enc_data(2) xor enc_data(4)) xor enc_data(6)) xor enc_data(8)) xor enc_data(10);
					enc_data(1) <= (((enc_data(2) xor enc_data(5)) xor enc_data(6)) xor enc_data(9)) xor enc_data(10);
					enc_data(3) <= ((enc_data(4) xor enc_data(5)) xor enc_data(6)) xor enc_data(11);
					enc_data(7) <= ((enc_data(8) xor enc_data(9)) xor enc_data(10)) xor enc_data(11);
					enc_data(12) <= (((((enc_data(0) xor enc_data(1)) xor enc_data(2)) xor enc_data(3)) xor enc_data(4)) xor enc_data(5)) xor
									(((((enc_data(6) xor enc_data(7)) xor enc_data(8)) xor enc_data(9)) xor enc_data(10)) xor enc_data(11));
					-- Outputing
					--Out_Rdy <= '1';
					case out_cnt is
						when 0 => 
							out_data <= enc_data(0);
						when 1 =>
							out_data <= enc_data(1);
						when 2 => 
							out_data <= enc_data(2);
						when 3 =>
							out_data <= enc_data(3);
						when 4 => 
							out_data <= enc_data(4);
						when 5 =>
							out_data <= enc_data(5);
						when 6 => 
							out_data <= enc_data(6);
						when 7 =>
							out_data <= enc_data(7);
						when 8 => 
							out_data <= enc_data(8);
						when 9 =>
							out_data <= enc_data(9);
						when 10 => 
							out_data <= enc_data(10);
						when 11 =>
							out_data <= enc_data(11);
						when 12 => 
							out_data <= enc_data(12);
							out_cnt := -1;
						when others =>
					end case;
					out_cnt := out_cnt + 1;
				end if;
			end if;
		end if;	
	end process;

end Behavioral;

