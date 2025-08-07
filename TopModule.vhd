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
			  
           RST : inout STD_LOGIC; 
           clk : inout STD_LOGIC
			  );
end TopModule;

architecture Behavioral of TopModule is

	signal DataByte : byte;
	signal DecValidation : STD_LOGIC;
	
	signal Switch : main_switch;
	signal Packet : data_packet;
	signal PackType : packet_type;
	
	signal PackToRam : data_packet;
	signal RamMode : packet_type;
	signal RamReadResp : ram_resp_pack;
	signal RamError : STD_LOGIC;
	
	signal PackToAlu : data_packet;
	signal AluToRam : data_packet;
	signal RamToAlu : ram_resp_pack;
	signal AluDone : STD_LOGIC;
	signal AluError : STD_LOGIC;
	
	signal EncInBit : STD_LOGIC;
	signal EncInBitCnt : integer range 0 to 8 := 0;
	signal EncInCellCnt : integer range 0 to 7 := 0; 
	
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
			Switch => Switch,
			Packet => Packet,
			PackType => PackType,
			RST => RST,
			clk => clk
		);
		
	RAM: entity work.RAM
		port map
		(
			InPack => PackToRam,
			Mode => RamMode,
			ReadResp => RamReadResp,
			Error => RamError,
			RST => RST,
			clk => clk
		);
	
	ALU: entity work.ALU
		port map
		(
			InPack => PackToAlu,
			PackMode => PackType,
			SendToRamPack => AluToRam,
			ReadResponse => RamToAlu,
			Finish => AluDone,
			Error => AluError, 
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
		
	process(clk)
	begin
		if rising_edge(clk) then
			Error <= (not(DecValidation) or RamError) or AluError;
			if switch = RAM then
				PackToRam <= Packet;
				RamMode <= PackType;
				if EncInBitCnt = 8 then
					EncInBitCnt <= 0;
					EncInCellCnt <= EncInCellCnt + 1;
				end if;
				if EncInCellCnt = 4 then
					EncInCellCnt <= 0;
				end if;
				EncInBit <= RamReadResp(EncInCellCnt)(EncInBitCnt);
			else
				if AluDone = '1' then
					PackToAlu <= Packet;
					PackToRam <= AluToRam;
					if AluToRam(0) = "00001111" then
						RamMode <= Rea_d;
					else
						RamMode <= Writ_e;
					end if;
					RamToAlu <= RamReadResp;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

