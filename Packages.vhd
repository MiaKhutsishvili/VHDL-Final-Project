--	Package File

--	In this file we will introduce different packages used.

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package Packages is

	type data_packet is array (0 to 6) of STD_LOGIC_VECTOR(7 downto 0);
	type pack_type is (Operand_Alu, Writ_e, Rea_d, Immediate_Alu, Array_Alu, Indirect_Addressing, zero, Read_Response);
	
	type Ram_Row is array (0 to 7) of STD_LOGIC_VECTOR(7 downto 0);
	type Ram_Matrix is array (0 to 31) of Ram_Row;
	type Ram_In_Pack is array (0 to 4) of STD_LOGIC_VECTOR(7 downto 0);
	type Ram_Resp_Pack is array (0 to 3) of STD_LOGIC_VECTOR(7 downto 0);
	
end Packages;

package body Packages is
 
end Packages;
