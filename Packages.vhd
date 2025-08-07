--	Package File

--	In this file we will introduce different packages used.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package Packages is

	subtype byte is STD_LOGIC_VECTOR(7 downto 0);

	type data_packet is array (0 to 6) of Byte;
	type main_switch is (Ram, Alu);
	type packet_type is (Operand_Alu, Writ_e, Rea_d, Immediate_Alu, Array_Alu, Indirect_Addressing, zero, Read_Response);
	type alu_operation is (Add, Sub, Orr, Andd);
	
	--type ram_row is array (0 to 7) of STD_LOGIC_VECTOR(7 downto 0);
	type ram_matrix is array (0 to 31) of byte; --Ram_Row;
	type ram_resp_pack is array (0 to 3) of Byte;
	
	function Validate (Packet : data_packet) return STD_LOGIC;
	--function RRRValidate(Packet : ram_resp_pack) return STD_LOGIC;
	function CheckSumH (Packet : data_packet) return byte;
	function CheckSumL (Packet : data_packet) return byte;
	
end Packages;

package body Packages is
	
	function Validate(Packet : data_packet) return STD_LOGIC is
		variable Sum : signed(15 downto 0) := (others => '0');
		variable CheckH : byte;
		variable CheckL : byte;
	begin
		for i in 0 to 4 loop
			Sum := Sum + signed(Packet(i));
		end loop;
		CheckH := STD_LOGIC_VECTOR(Sum(15 downto 8));
		CheckL := STD_LOGIC_VECTOR(Sum(7 downto 0));
		if (CheckH = packet(5) and CheckL = Packet(6)) then
			return '1';
		else 
			return '0';
		end if;
	end function;
	
--	function RRRValidate(Packet : ram_resp_pack) return STD_LOGIC is
--		variable Sum : signed(15 downto 0) := (others => '0');
--		variable CheckH : byte;
--		variable CheckL : byte;
--	begin
--		Sum := signed(Packet(0)) + signed(Packet(1));
--		CheckH := STD_LOGIC_VECTOR(Sum(15 downto 8));
--		CheckL := STD_LOGIC_VECTOR(Sum(7 downto 0));
--		if (CheckH = packet(2) and CheckL = Packet(3)) then
--			return '1';
--		else 
--			return '0';
--		end if;
--	end function;
	
	function CheckSumH (Packet : data_packet) return byte is 
			variable Sum : signed(15 downto 0) := (others => '0');
	begin
		for i in 0 to 4 loop
			Sum := Sum + signed(Packet(i));
		end loop;
		return STD_LOGIC_VECTOR(Sum(15 downto 8));
	end function;
	
	function CheckSumL (Packet : data_packet) return byte is 
			variable Sum : signed(15 downto 0) := (others => '0');
	begin
		for i in 0 to 4 loop
			Sum := Sum + signed(Packet(i));
		end loop;
		return STD_LOGIC_VECTOR(Sum(7 downto 0));
	end function;
	
end Packages;
