--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:55:56 08/10/2025
-- Design Name:   
-- Module Name:   /home/ise/IDK/RamTestBench.vhd
-- Project Name:  IDK
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RAM
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
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.Packages.All;
 
ENTITY RamTestBench IS
END RamTestBench;
 
ARCHITECTURE behavior OF RamTestBench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RAM
    PORT(
         CtrlReq : IN  data_packet;
         AluReq : IN  data_packet;
         ReadResp : OUT  data_packet;
			ReadRespReady : OUT  std_logic;
         InChoose : IN  std_logic;
         Error : OUT  std_logic;
         RST : IN  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CtrlReq : data_packet := (others => (others => '0'));
   signal AluReq : data_packet := (others => (others => '0'));
	signal ReadRespReady : std_logic;
   signal InChoose : std_logic := '0';
   signal RST : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal ReadResp : data_packet;
   signal Error : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RAM PORT MAP (
          CtrlReq => CtrlReq,
          AluReq => AluReq,
          ReadResp => ReadResp,
			 ReadRespReady => ReadRespReady,
          InChoose => InChoose,
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
   begin		
      -- hold reset state for 100 ns.
      RST <= '0';
      wait for clk_period*10;
		RST <= '0';
      
		InChoose <= '0';
		CtrlReq <= ("11110000",
					  "00000001",
					  "11111111",
		           "00000000",
		           "00000000",
		           "00000000",
		           "00000000");
		wait for 10 ns;
		
		-- 11001111 + 111111111 = 11111111 11001110
		InChoose <= '1';
		AluReq <= ("00001111",
					  "00000001",
					  "00000000",
		           "00000000",
		           "00000000",
		           "00000000",
		           "00000000");
      wait for 10 ns;
   end process;

END;
