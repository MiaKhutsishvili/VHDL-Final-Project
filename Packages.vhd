
--	Package File

--	In this file we will introduce different packages used.

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package Packages is

	type data_packet is array (0 to 6) of STD_LOGIC_VECTOR(7 downto 0);
--	type Operand_Alu is array (0 to 5) of STD_LOGIC_VECTOR(7 downto 0);			
--	type Writ_e is array (0 to 4) of STD_LOGIC_VECTOR(7 downto 0);		  		
--	type Rea_d is array (0 to 3) of STD_LOGIC_VECTOR(7 downto 0);				
--	type Immediate_Alu is array (0 to 5) of STD_LOGIC_VECTOR(7 downto 0);		
--	type Array_Alu is array (0 to 6) of STD_LOGIC_VECTOR(7 downto 0);			
--	type Indirect_Addressing is array (0 to 5) of STD_LOGIC_VECTOR(7 downto 0);	

	type pack_type is (Operand_Alu, Writ_e, Rea_d, Immediate_Alu, Array_Alu, Indirect_Addressing, zero, Read_Response);
	
end Packages;

package body Packages is
end Packages;
