----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

-- Create Date:    11:51:06 07/31/2025 
-- Module Name:    HammingDecoder - Behavioral 
-- Project Name:   Logical Circuit Final Project
-- Description:    This module will encode a 13 bit extended hamming coded data to extract 8 data bits

-- Dependencies:   Odd_Mode = 1 /constant
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HammingDecoder is
    Port ( in_data : in  STD_LOGIC;
           out_data : out  STD_LOGIC;
           open_in : inout  STD_LOGIC;
           valid_out : out  STD_LOGIC;
           out_rdy : inout  STD_LOGIC;
			  in_start : in STD_LOGIC;
			  RST : in STD_LOGIC;
			  clk : in STD_LOGIC);
end HammingDecoder;

architecture Behavioral of HammingDecoder is

	signal marker : STD_LOGIC_VECTOR (3 downto 0);
	signal extention : STD_LOGIC;
	signal inp_enc_data : STD_LOGIC_VECTOR (12 downto 0);
	signal code_rdy : STD_LOGIC;
	
begin
		process (clk, RST)
			variable cnt : integer := 0;	-- cnt is 0 at the begining of simulation
			variable ind : integer := 0; 
		begin
			if rising_edge(clk) then
				if (RST = '1' or in_start = '1') then
					open_in <= '1';
					valid_out <= '0';
					out_rdy <= '0';
					out_data <= '0';
					marker <= "0000";
					inp_enc_data <= "0000000000000";
					cnt := 0;
					code_rdy <= '0';
				end if;
				
				if open_in = '1' then
					if in_start = '1' then 
						code_rdy <= '1';
					end if;
					case cnt is
						when 0 => 
							inp_enc_data(0) <= in_data;
						when 1 =>
							inp_enc_data(1) <= in_data;
						when 2 => 
							inp_enc_data(2) <= in_data;
						when 3 =>
							inp_enc_data(3) <= in_data;
						when 4 => 
							inp_enc_data(4) <= in_data;
						when 5 =>
							inp_enc_data(5) <= in_data;
						when 6 => 
							inp_enc_data(6) <= in_data;
						when 7 =>
							inp_enc_data(7) <= in_data;
						when 8 => 
							inp_enc_data(8) <= in_data;
						when 9 =>
							inp_enc_data(9) <= in_data;
						when 10 => 
							inp_enc_data(10) <= in_data;
						when 11 =>
							inp_enc_data(11) <= in_data;
						when 12 => 
							inp_enc_data(12) <= in_data;
							cnt := 0;
							Open_In <= '0';
						when others =>
							-- Impossible!
					end case;
					cnt := cnt + 1;
				end if;
				
				if (open_in = '0' and out_rdy = '0') then
					-- Constructing the new parities
					marker(0) <= inp_enc_data(0) xor (inp_enc_data(2) xor (inp_enc_data(4) xor
									(inp_enc_data(6) xor (inp_enc_data(8) xor inp_enc_data(10)))));
					marker(1) <= inp_enc_data(1) xor (inp_enc_data(2) xor (inp_enc_data(5) xor
									(inp_enc_data(6) xor (inp_enc_data(9) xor inp_enc_data(10)))));
					marker(2) <= inp_enc_data(3) xor (inp_enc_data(4) xor (inp_enc_data(5) xor
									(inp_enc_data(6) xor inp_enc_data(11))));
					marker(3) <= inp_enc_data(7) xor (inp_enc_data(8) xor (inp_enc_data(9) xor
									(inp_enc_data(10) xor inp_enc_data(11))));
					extention <= inp_enc_data(0) xor (inp_enc_data(1) xor (inp_enc_data(2) xor
									(inp_enc_data(3) xor (inp_enc_data(4) xor (inp_enc_data(5) xor
									(inp_enc_data(6) xor (inp_enc_data(7) xor (inp_enc_data(8) xor
									(inp_enc_data(9) xor (inp_enc_data(10) xor inp_enc_data(11)))))))))));
					-- Correction
					ind :=  to_integer(unsigned(marker));
					ind := ind - 1;
					if ((ind = -1 and extention = inp_enc_data(12)) or
					     ((ind > -1 and ind < 12) and (extention = not inp_enc_data(12)))) then
						valid_out <= '1';
						if ind > -1 then
							inp_enc_data(ind) <= not inp_enc_data(ind);
						end if;
					else
						valid_out <= '0';
					end if;
					if code_rdy = '1' then
						out_rdy <= '1';
					end if;
				end if;
				
				if out_rdy = '1' then
					case cnt is
						when 0 => 
							out_data <= inp_enc_data(2);
						when 1 =>
							out_data <= inp_enc_data(4);
						when 2 => 
							out_data <= inp_enc_data(5);
						when 3 =>
							out_data <= inp_enc_data(6);
						when 4 => 
							out_data <= inp_enc_data(8);
						when 5 =>
							out_data <= inp_enc_data(9);
						when 6 => 
							out_data <= inp_enc_data(10);
						when 7 =>
							out_data <= inp_enc_data(11);
							cnt := 0;
							Open_In <= '1';
						when others =>
							-- Impossible!
					end case;
					cnt := cnt + 1;
				end if;
			end if;
		end process;
end Behavioral;

