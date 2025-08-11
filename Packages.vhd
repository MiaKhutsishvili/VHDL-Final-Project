--	Package File

--	In this file we will introduce different packages used.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package Packages is

	subtype byte is STD_LOGIC_VECTOR(7 downto 0);
	subtype hamming is STD_LOGIC_VECTOR(0 to 12);
	type hamming_packet is array (0 to 6) of hamming;
	type data_packet is array (0 to 6) of byte;
	type packet_type is (zero, Operand_Alu, Writ_e, Rea_d, Immediate_Alu, Array_Alu, Indirect_Addressing);
	type alu_operation is (Add, Sub, BitwiseOr, BitwiseAnd);
	
	--type ram_row is array (0 to 7) of byte;
	type ram_matrix is array (0 to 31) of byte; --Ram_Row;
	type ram_resp_pack is array (0 to 3) of byte;  
	
	type alu_read_cash_array is array (0 to 31) of byte;
	
	function ByteSum (Packet : data_packet) return STD_LOGIC_VECTOR;
	function CheckSumH (Packet : data_packet) return byte;
	function CheckSumL (Packet : data_packet) return byte;
	function Validate (Packet : data_packet) return STD_LOGIC;
	
end Packages;

package body Packages is

	function ByteSum (Packet : data_packet) return STD_LOGIC_VECTOR is 
			variable Sum : integer := 0;
	begin
		for i in 0 to 4 loop
			Sum := Sum + to_integer(signed(Packet(i)));
		end loop;
		return STD_LOGIC_VECTOR(to_signed(Sum, 16));
	end function;

	function CheckSumH (Packet : data_packet) return byte is 
			variable SumL : byte;
	begin
		SumL := ByteSum(Packet)(15 downto 8);
		return SumL;
	end function;
	
	function CheckSumL (Packet : data_packet) return byte is 
			variable SumR : byte;
	begin
		SumR := ByteSum(Packet)(7 downto 0);
		return SumR;
	end function;
	
	function Validate(Packet : data_packet) return STD_LOGIC is
		variable CheckH, CheckL : byte;
	begin
		CheckH := CheckSumH(Packet);
		CheckL := CheckSumL(Packet);
		if (CheckH = Packet(5) and CheckL = Packet(6)) then
			return '1';
		else 
			return '0';
		end if;
	end function;
	
	
end Packages;
