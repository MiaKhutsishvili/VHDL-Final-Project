--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:06:09 08/10/2025
-- Design Name:   
-- Module Name:   /home/ise/IDK/AluTestBench.vhd
-- Project Name:  IDK
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ALU
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.Packages.All;


ENTITY AluTestBench IS
END AluTestBench;
 
ARCHITECTURE behavior OF AluTestBench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         InPack : IN  data_packet;
         PackMode : IN  packet_type;
         SendToRam : OUT  data_packet;
         ReadResponse : IN  data_packet;
         Finish : INOUT  std_logic;
         Enable : IN  std_logic;
         Error : OUT  std_logic;
         RST : IN  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal InPack : data_packet := (others => (others => '0'));
   signal PackMode : packet_type := zero;
   signal ReadResponse : data_packet := (others => (others => '0'));
   signal Enable : std_logic := '0';
   signal RST : std_logic := '0';
   signal clk : std_logic := '0';

	--BiDirs
   signal Finish : std_logic;

 	--Outputs
   signal SendToRam : data_packet := (others => (others => '0'));
   signal Error : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          InPack => InPack,
          PackMode => PackMode,
          SendToRam => SendToRam,
          ReadResponse => ReadResponse,
          Finish => Finish,
          Enable => Enable,
          Error => Error,
          RST => RST,
          clk => clk
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
		variable ArrayFromRam : data_packet := (others => (others => '0'));
   begin		
      -- hold reset state for 100 ns.
		RST <= '1';
      wait for clk_period*10;
		RST <= '0';
		
		Enable <= '1';
		
		-- Operand Alu : 10 + 1 = 11 in "11100011"
		PackMode <= Operand_Alu;
		InPack <= ("00000000",
					  "10101010",
					  "11111111",
		           "11100011",
		           "00000000",
		           "00000000",
		           "00000000");
		wait for 10 ns;
		ReadResponse <= ("11001111",
							  "00000001",
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000");
		wait for 10 ns;
		ReadResponse <= ("11001111",
							  "00000010",
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000");
		wait for 10 ns;
		
		-- Immediate ALU : 101 + 111 = 00001100 in "11111111"
		PackMode <= Immediate_Alu;
		InPack <= ("00111100",
					  "10000000",
					  "00000111",
		           "11111111",
		           "00000000",
		           "00000000",
		           "00000000");
		wait for 10 ns;
		ReadResponse <= ("11001111",
							  "00000101",
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000");
		wait for 10 ns;

	-- Arrat Alu : Size 4, (0, 01, 10, 11) + 1 -> (1, 10, 11, 111)
		PackMode <= Array_Alu;
		InPack <= ("11000000",
					  "00010000",	-- 10000(16) to 10011(19)
					  "00000001",
		           "00000100",
		           "00001001",	-- 1001(9) to 1100(12)
		           "00000000",
		           "00000000");
		ArrayFromRam := ("00000000",
					  "00000001",
					  "00000010",
		           "00000011",
		           "00000000",
		           "00000000",
		           "00000000");
		wait for 10 ns;
		for i in 0 to 3 loop
			ReadResponse(1) <= ArrayFromRam(i); 
			wait for 10 ns;
		end loop;
		wait for 4*clk_period;

		-- Indirect_Addressing : 64 + 6 = 70 (01000110) in "11111111"
		PackMode <= Indirect_Addressing;
		InPack <= ("00110000",
					  "00001111",  -- Address 1
					  "11110000",	-- Address Address 2
		           "11111111",	-- Detination
		           "00000000",
		           "00000000",
		           "00000000");
		wait for 10 ns;
		ReadResponse <= ("11001111",
							  "01000000",	-- Data 1
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000");
		wait for 10 ns;
		ReadResponse <= ("11001111",
							  "11111110",	-- Address 2
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000");
		wait for 10 ns;
		ReadResponse <= ("11001111",
							  "00000110",	-- Data 2
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000",
							  "00000000");
		wait for 10 ns;
	
   end process;

END;
