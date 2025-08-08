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
			  Finish : inout STD_LOGIC; 			-- Is 1 when the process is done.
			  
			  Enable : in STD_LOGIC;				-- Alu is On only when we are in Alu Mode.
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
				return std_logic_vector(In1 or In2);		-- Bitwise or for signed = direct or
			when Andd => 
				return std_logic_vector(In1 and In2);		-- Bitwise and for signed = direct and
			when others =>
				return "00000000";
		end case;
	end function;
	
	signal operation : Alu_Operation;
	---
	--- Ram Interaction
	signal SendToRamPack: data_packet;
	signal mode : byte;
	signal RamAdd : byte;								-- The Address given to the ram
	---
	signal DataI : byte := (others => '0');
	signal DataII : byte := (others => '0');
	signal AddressI : byte;
	signal AddressII : byte;
	signal AddAddressII : byte;
	signal DestinationAddress : byte;
	signal ArrayLength : integer range 0 to 32 := 0;
	signal ArrayIndPusher : integer range 0 to 31 := 0;
	signal Output : byte := (others => '0');		-- Calculator output
	signal ReadArray : alu_read_cash_array := (others => (others => '0'));
	
--	signal RamRespError : STD_LOGIC;
	
	signal Step : integer := 0;
	
begin
	
	process(clk)
	begin
		if rising_edge(clk) then
			Error <= '0';
			if Enable = '1' then
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
				end if;
				
				case PackMode is 
					when Operand_Alu => -- 3 Clocks
						if Step = 0 then							-- Clock 0 till 1
							AddressII <= InPack(2);
							DestinationAddress <= InPack(3);
							AddressI <= InPack(1);
							RamAdd <= AddressI;
							mode <= "00001111";
						elsif Step = 1 then						-- Clock 1 till 2
							DataI <= ReadResponse(1);
							RamAdd <= AddressII;
							mode <= "00001111";
						elsif Step = 2 then						-- Clock 2 till 3
							DataII <= ReadResponse(1);
							Output <= Operator(signed(DataI), signed(DataII), Operation);
							RamAdd <= DestinationAddress;
							mode <= "11110000";	
							Finish <= '1';
						end if;
							
					when Immediate_Alu =>
						if Step = 0 then							-- Clock 0 till 1
							DataII <= InPack(2);
							DestinationAddress <= InPack(3);
							AddressI <= InPack(1);
							RamAdd <= AddressI;
							mode <= "00001111";
						elsif Step = 1 then						-- Clock 1 till 2
							DataI <= ReadResponse(1);
							Output <= Operator(signed(DataI), signed(DataII), Operation);
							RamAdd <= DestinationAddress;
							mode <= "11110000";
							Finish <= '1';
						end if;
							
					when Array_Alu =>
						if Step = 0 then							-- Clock 0 till 1					
							AddressI <= InPack(1);
							DataII <= InPack(2);
							ArrayLength <= to_integer(unsigned(InPack(3)));
							if ArrayLength > 32 then
								Error <= '1';
							end if;
							DestinationAddress <= InPack(4);
							ArrayIndPusher <= 0;
							ReadArray <= (others => (others => '0'));
							mode <= "00001111";
						end if;
						if mode = "00001111" then
							if Step > ArrayLength then
								mode <= "11110000";
								Step <= 0;		-- Step will + 1
								ArrayIndPusher <= 0;
							else
								if 0 < Step then 
									ReadArray(Step - 1) <= ReadResponse(1);
								end if;
								if to_integer(unsigned(AddressI)) + ArrayIndPusher > 31 then
									AddressI <= (others => '0');
									ArrayIndPusher <= 0;
								end if;	
								RamAdd <= byte(unsigned(AddressI) + to_unsigned(ArrayIndPusher, 8));
								ArrayIndPusher <= ArrayIndPusher + 1;
							end if;
						elsif mode = "11110000" then
							if Step > ArrayLength then
								Step <= -1;		-- Step will + 1
								Finish <= '1';
							else 
								Output <= Operator(signed(ReadArray(ArrayIndPusher)), signed(DataII), Operation); -- Initail ArrayIndPusher = 0
								if to_integer(unsigned(DestinationAddress)) + ArrayIndPusher > 31 then
									DestinationAddress <= (others => '0');
									ArrayIndPusher <= 0;
								end if;	
								RamAdd <= byte(unsigned(DestinationAddress) + to_unsigned(ArrayIndPusher, 8));
								ArrayIndPusher <= ArrayIndPusher + 1;
							end if;
						else 
							Error <= '1';
						end if;
						
					when Indirect_Addressing =>
						if Step = 0 then										-- Clock 0 till 1		
							AddAddressII <= InPack(2);
							DestinationAddress <= InPack(3);
							AddressI <= InPack(1);
							RamAdd <= AddressI;
							mode <= "00001111";
						elsif Step = 1 then									-- Clock 1 till 2
							DataI <= ReadResponse(1);
							mode <= "00001111";
							RamAdd <= AddAddressII;
						elsif Step = 2 then									-- Clock 2 till 3
							AddressII <= ReadResponse(1);
							RamAdd <= AddressII;
							mode <= "00001111";	
						elsif Step = 3 then									-- Clock 3 till 4
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

