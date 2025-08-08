----------------------------------------------------------------------------------
-- Kimia Khoodsiyani & Maral Torabi 
-- 40223030            40223019 

-- Create Date:    16:46:01 08/05/2025 
-- Module Name:    TopModule - Behavioral 
-- Project Name:   Logical Circuits Final Project
-- Description:    Here we connect all the modules and do the validations

-- Comments:       Only module outputs will contain CheckSum
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.All;

entity TopModule is
    Port ( Input : in STD_LOGIC;		

           Output : out STD_LOGIC;		
			  Error : out STD_LOGIC;
			  
           RST : in STD_LOGIC; 
           clk : in STD_LOGIC
			  );
end TopModule;

architecture Behavioral of TopModule is

	signal DataByte : byte;
	signal DecValidation : STD_LOGIC;
	
	signal Switch : STD_LOGIC;
	signal Packet : data_packet;
	signal PacketValidation : STD_LOGIC;
	
	--signal PackToRam : data_packet;
	signal RamReadResp : data_packet;
	signal RamError : STD_LOGIC;
	
	signal AluEnable : STD_LOGIC;
	--signal PackToAlu : data_packet;
	signal PackMode : packet_type;
	signal AluToRam : data_packet;
	--signal RamToAlu : ram_resp_pack;
	signal AluDone : STD_LOGIC;
	signal AluError : STD_LOGIC;
	--signal RamRespError : STD_LOGIC;
	
	signal EncByte : byte;
	signal EncInBit : STD_LOGIC;
	
begin

	Decoder: entity work.HammingDecoder
		port map
		(
			DecInBit => Input,
			DecOutByte => DataByte,				
			Valid => DecValidation,				
			RST => RST,
			clk => clk
		);
	
	CtrlUnit: entity work.ControlUnit
		port map
		(
			InByte => DataByte,
			Validation => PacketValidation,
			Switch => Switch,						
			Packet => Packet,		
			PackMode => PackMode,
			RST => RST,
			clk => clk
		);

	RAM: entity work.RAM
		port map
		(
			InChoose => AluEnable,
			CtrlReq => Packet,
			AluReq => AluToRam,
			ReadResp => RamReadResp,			
			Error => RamError,					
			RST => RST,
			clk => clk
		);
		
	ALU: entity work.ALU
		port map
		(
			Enable => AluEnable,
			InPack => Packet,
			PackMode => PackMode,
			SentToRam => AluToRam,
			ReadResponse => RamReadResp,
			Finish => AluDone,
			Error => AluError, 
			RST => RST,
			clk => clk
		);

	PacketToByte: entity work.PackToByte
		port map
		(
			PackIn => RamReadResp,
			ByteOut => EncByte,
			clk => clk
		);
	
	ByteToBit: entity work.ByteToBit
		port map
		(
			ByteIn => EncByte,
			BitOut => EncInBit,
			clk => clk
		);
		
	Encoder: entity work.HammingEncoder
		port map
		(
			BitIn => EncInBit,
			BitOut => Output,						
			RST => RST,
			clk => clk
		);
	
	ErrorDetection: entity work.ErrorDetection
		port map
		(
			DecodingError => not(DecValidation),
			PacketError => not(PacketValidation),
			RamError => RamError,
			AluError => AluError,
			Error => Error
		);
	AluEnable <= Switch or (not(AluDone)); 

end Behavioral;

