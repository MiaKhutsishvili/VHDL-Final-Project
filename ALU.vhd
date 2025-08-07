----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi
-- 40223030            40223019

-- Create Date:    14:11:14 08/05/2025 
-- Module Name:    ALU - Behavioral 
-- Project Name: 	 Logical Circuits Final Project
-- Description:    This module is a simple calculator
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.All;

entity ALU is
    Port ( InPack : in  data_packet;
			  PackMode : in  packet_type;	
			  
			  SendToRamPack: inout data_packet;
			  ReadResponse : in ram_resp_pack;
			  Finish : inout STD_LOGIC; 
			  
			  Error : out STD_LOGIC;
			  --RST : in STD_LOGIC;
			  clk : in STD_LOGIC
			 );
end ALU;

architecture Behavioral of ALU is	
	
	function Operator(In1, In2: signed(7 downto 0); operate : Alu_Operation) return byte is
	begin
		case operate is
			when Add => 
				return std_logic_vector(In1 + In2);
			when Sub => 
				return std_logic_vector(In1 - In2);
			when Orr => 
				return std_logic_vector(In1 or In2);		-- Bitwise or for unsigned = direct or
			when Andd => 
				return std_logic_vector(In1 and In2);		-- Bitwise and for unsigned = direct and
			when others =>
				return "00000000";
		end case;
	end function;
	
	signal operation : Alu_Operation;
	
	signal DataI : byte := (others => '0');
	signal DataII : byte := (others => '0');
	signal AddressI : byte;
	signal AddressII : byte;
	signal AddAddressII : byte;
	signal DestinationAddress : byte;
	signal ArrayLength : integer range 0 to 31 := 0;
	signal ArrayOdd : STD_LOGIC;
	
	signal Output : byte;
	
--	signal PackError : STD_LOGIC;
--	signal RamRespError : STD_LOGIC;
	
	signal Step : integer := 0;
	
begin
	
	process(clk)
		variable CheckH : byte;
		variable CheckL : byte;
	begin
		if rising_edge(clk) then
			if (Step = 0 or Finish = '1') then
				Step <= 0;
				Finish <= '0';
					
				Error <= not(Validate(InPack));
				
				case InPack(0)(1 downto 0) is 
					when "00" =>
						operation <= Add;
					when "01" => 
						operation <= Sub;
					when "10" => 
						operation <= Orr;
					when "11" =>
						operation <= Andd;
					when others =>
				end case;			
					
				AddressI <= InPack(1);
			
				SendToRamPack <= ("00001111", AddressI, "00000000", "00000000", "00000000", "00000000", "00000000");
				SendToRamPack(5) <= CheckSumH(SendToRamPack);
				SendToRamPack(6) <= CheckSumL(SendToRamPack);
				
				case PackMode is 
					when Operand_Alu => 
						AddressII <= InPack(2);
						DestinationAddress <= InPack(3);
						
					when Immediate_Alu =>
						DataII <= InPack(2);
						DestinationAddress <= InPack(3);
						
					when Array_Alu =>
						DataII <= InPack(2);
						ArrayLength <= to_integer(unsigned(InPack(3)));
						ArrayOdd <= '0';
						DestinationAddress <= InPack(4);
						
					when Indirect_Addressing =>
						AddAddressII <= InPack(2);
						DestinationAddress <= InPack(3);
						
					when others =>
				end case;
				Step <= Step + 1;
			
			else
				--RamRespError <= not(RRRValidate(ReadResponse));
				case PackMode is 
					when Operand_Alu => 
						if Step = 1 then
							DataI <= ReadResponse(1);
							SendToRamPack <= ("00001111", AddressII, "00000000", "00000000", "00000000", "00000000", "00000000");
							SendToRamPack(5) <= CheckSumH(SendToRamPack);
							SendToRamPack(6) <= CheckSumL(SendToRamPack);
						elsif Step = 2 then
							Output <= Operator(signed(DataI), signed(DataII), Operation);
							SendToRamPack <= ("11110000", DestinationAddress, Output, "00000000", "00000000", "00000000", "00000000");
							SendToRamPack(5) <= CheckSumH(SendToRamPack);
							SendToRamPack(6) <= CheckSumL(SendToRamPack);
							Finish <= '1';
						end if;
						
					when Immediate_Alu =>
						DataI <= ReadResponse(1);
						Output <= Operator(signed(DataI), signed(DataII), Operation);
						SendToRamPack <= ("11110000", DestinationAddress, Output, "00000000", "00000000", "00000000", "00000000");
						SendToRamPack(5) <= CheckSumH(SendToRamPack);
						SendToRamPack(6) <= CheckSumL(SendToRamPack);
						Finish <= '1';
						
					when Array_Alu =>
						if Step < (ArrayLength + 1) then 
							if ArrayOdd = '0' then
								DataI <= ReadResponse(1);
								Output <= Operator(signed(DataI), signed(DataII), Operation);
								if to_integer(unsigned(DestinationAddress)) + Step - 1 > 31 then
									DestinationAddress <= "00000000";
								end if;	
								SendToRamPack <= ("11110000", byte(unsigned(DestinationAddress) + to_unsigned(Step - 1, 8)), 
														Output, "00000000", "00000000", "00000000", "00000000");
								SendToRamPack(5) <= CheckSumH(SendToRamPack);
								SendToRamPack(6) <= CheckSumL(SendToRamPack);
							else
								if to_integer(unsigned(AddressI)) + Step - 1 > 31 then
									AddressI <= "00000000";
								end if;	
								SendToRamPack <= ("00001111", byte(unsigned(AddressI) + to_unsigned(Step - 1, 8)), 
														"00000000", "00000000", "00000000", "00000000", "00000000");
								SendToRamPack(5) <= CheckSumH(SendToRamPack);
								SendToRamPack(6) <= CheckSumL(SendToRamPack);
							end if;
							ArrayOdd <= not(ArrayOdd);
						else
							Finish <= '1';
						end if;
						
					when Indirect_Addressing =>
						if Step = 1 then
							DataI <= ReadResponse(1);
							SendToRamPack <= ("00001111", AddAddressII, "00000000", "00000000", "00000000", "00000000", "00000000");
							SendToRamPack(5) <= CheckSumH(SendToRamPack);
							SendToRamPack(6) <= CheckSumL(SendToRamPack);
						elsif Step = 2 then
							AddressII <= ReadResponse(1);
							SendToRamPack <= ("00001111", AddressII, "00000000", "00000000", "00000000", "00000000", "00000000");
							SendToRamPack(5) <= CheckSumH(SendToRamPack);
							SendToRamPack(6) <= CheckSumL(SendToRamPack);
						elsif Step = 3 then
							DataII <= ReadResponse(1);
							Output <= Operator(signed(DataI), signed(DataII), Operation);
							SendToRamPack <= ("11110000", DestinationAddress, Output, "00000000", "00000000", "00000000", "00000000");
							SendToRamPack(5) <= CheckSumH(SendToRamPack);
							SendToRamPack(6) <= CheckSumL(SendToRamPack);
							Finish <= '1';
						end if;
						
					when others =>
				end case;
				Step <= Step + 1;
			end if;
		end if;
	end process;
	
end Behavioral;

