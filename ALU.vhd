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
			  
			  SentToRam : out data_packet;
			  ReadResponse : in data_packet;
			  Finish : inout STD_LOGIC; 
			  
			  Enable : in STD_LOGIC;
			  Error : out STD_LOGIC;
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
	signal SendToRamPack: data_packet;
	signal mode : byte;
	signal DataI : byte := (others => '0');
	signal DataII : byte := (others => '0');
	signal AddressI : byte;
	signal AddressII : byte;
	signal AddAddressII : byte;
	signal DestinationAddress : byte;
	signal ArrayLength : integer range 0 to 31 := 0;
	signal ArrayOdd : STD_LOGIC;
	
	signal RamAdd : byte;
	signal Output : byte := (others => '0');
	
--	signal RamRespError : STD_LOGIC;
	
	signal Step : integer := 0;
	
begin
	
	process(clk)
	begin
		if rising_edge(clk) then
			if Enable = '1' then
				Error <= '0';
				if (Step = 0 or Finish = '1') then
					SentToRam <= SendToRamPack;
					Step <= 0;
					Finish <= '0';
											
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
					RamAdd <= AddressI;
					mode <= "00001111";
				end if;
				
				case PackMode is 
					when Operand_Alu => 
						if Step = 0 then
						AddressII <= InPack(2);
						DestinationAddress <= InPack(3);
						elsif Step = 1 then
							DataI <= ReadResponse(1);
							RamAdd <= AddressII;
							mode <= "00001111";
						elsif Step = 2 then
							Output <= Operator(signed(DataI), signed(DataII), Operation);
							RamAdd <= DestinationAddress;
							mode <= "11110000";	
							Finish <= '1';
						end if;
							
					when Immediate_Alu =>
						if Step = 0 then
							DataII <= InPack(2);
							DestinationAddress <= InPack(3);
						elsif Step = 1 then
							DataI <= ReadResponse(1);
							Output <= Operator(signed(DataI), signed(DataII), Operation);
							RamAdd <= DestinationAddress;
							mode <= "11110000";
							Finish <= '1';
						end if;
							
					when Array_Alu =>
						if Step = 0 then
							DataII <= InPack(2);
							ArrayLength <= to_integer(unsigned(InPack(3)));
							ArrayOdd <= '0';
							DestinationAddress <= InPack(4);
						elsif Step < (ArrayLength + 1) then 
							if ArrayOdd = '0' then
								mode <= "11110000";
								DataI <= ReadResponse(1);
								Output <= Operator(signed(DataI), signed(DataII), Operation);
								if to_integer(unsigned(DestinationAddress)) + Step - 1 > 31 then
									DestinationAddress <= "00000000";
								end if;	
								RamAdd <= byte(unsigned(DestinationAddress) + to_unsigned(Step - 1, 8));	
							else
								mode <= "00001111";
								if to_integer(unsigned(AddressI)) + Step - 1 > 31 then
									AddressI <= "00000000";
								end if;	
								RamAdd <= byte(unsigned(AddressI) + to_unsigned(Step - 1, 8));
							end if;
							ArrayOdd <= not(ArrayOdd);
						else
							Finish <= '1';
						end if;
							
					when Indirect_Addressing =>
						if Step = 0 then
							AddAddressII <= InPack(2);
							DestinationAddress <= InPack(3);
						elsif Step = 1 then
							DataI <= ReadResponse(1);
							mode <= "00001111";
							RamAdd <= AddAddressII;
						elsif Step = 2 then
							AddressII <= ReadResponse(1);
							RamAdd <= AddressII;
							mode <= "00001111";	
						elsif Step = 3 then
							DataII <= ReadResponse(1);
							Output <= Operator(signed(DataI), signed(DataII), Operation);
							RamAdd <= DestinationAddress;
							mode <= "11110000";
							Finish <= '1';
						end if;
					when others =>
						Error <= '1';
				end case;
				Step <= Step + 1;
				SendToRamPack(0) <= mode;
				SendToRamPack(1) <= RamAdd;
				SendToRamPack(2) <= Output;
				SendToRamPack(3) <= (others => '0');
				SendToRamPack(4) <= (others => '0');
				SendToRamPack(5) <= (others => '0');
				SendToRamPack(6) <= (others => '0');
			end if;
		end if;
	end process;
	
end Behavioral;

