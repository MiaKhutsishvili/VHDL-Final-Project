----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi 
-- 40223030            40223019 

-- Create Date:    16:46:01 08/05/2025 
-- Module Name:    TopModule - Behavioral 
-- Project Name:   Logical Circuits Final Project
-- Description:    Here we connect all the modules and do the validations
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.All;

entity TopModule is
    Port ( Dec_In_Bit : in STD_LOGIC;		
	 
           Enc_Out_Bit : out Byte;		
			  Valid : out STD_LOGIC;
			  
           RST : inout STD_LOGIC; 
           clk : inout STD_LOGIC
			  );
end TopModule;

architecture Behavioral of TopModule is

	signal Dec_Out_Byte : Byte;
	signal Dec_Validation : STD_LOGIC;
	
	signal Packet : data_packet;
	signal Packet_Type : pack_type;
	
	signal Ram_In_Pack : Ram_In_Packet;
	signal Ram_Mode : pack_type;
	signal Ram_Response : Ram_Resp_Pack;
	signal Ram_Validation : STD_LOGIC;
	
	signal Alu_In_Pack : Alu_In_Packet;
	signal Alu_Out_Pack : Ram_In_Packet;
	
	signal Enc_In_Bit : STD_LOGIC;
	
begin

	Decoder: entity work.HammingDecoder
		port map
		(
			in_data => Dec_In_Bit,
			out_data => Dec_Out_Byte,
			valid_out => Dec_Validation,
			RST => RST,
			clk => clk
		);

	ControlUnit: entity work.ControlUnit
		port map
		(
			in_data => Dec_Out_Byte,
			out_data => Packet,
			packet_type => Packet_Type,
			RST => RST,
			clk => clk
		);
	
	RAM: entity work.RAM
		port map
		(
			in_packet => Ram_In_Pack,
			mode => Ram_Mode,
			ram_response => Ram_Response,
			valid => Ram_Validation,
			RST => RST,
			clk => clk
		);

	ALU: entity work.ALU
		port map
		(
			in_packet => Alu_In_Pack,
			output => Alu_Out_Pack,
			clk => clk
		);
	
	Encoder: entity work.HammingEncoder
		port map
		(
			in_data => Enc_In_Bit,
			out_data => Enc_Out_Bit,
			RST => RST,
			clk => clk
		);
end Behavioral;

