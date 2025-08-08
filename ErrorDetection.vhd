----------------------------------------------------------------------------------
-- Kimia Khoodiyani & Maral Torabi
-- 40223030           40223019

-- Create Date:    09:53:45 08/08/2025 
-- Module Name:    ErrorDetection - Behavioral 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.ALL;

entity ErrorDetection is
    Port ( DecodingError : in  STD_LOGIC;
           PacketError : in  STD_LOGIC;
           RamError : in  STD_LOGIC;
           AluError : in  STD_LOGIC;
           Error : out  STD_LOGIC
			  );
end ErrorDetection;

architecture Behavioral of ErrorDetection is

begin

	Error <= (RamError or AluError) or (DecodingError or PacketError);

end Behavioral;

