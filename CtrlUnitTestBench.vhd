--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:47:29 08/10/2025
-- Design Name:   
-- Module Name:   /home/ise/FinalProject/CtrlUnitTestBench.vhd
-- Project Name:  FinalProject
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ControlUnit
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
USE work.Packages.ALL;
 
ENTITY CtrlUnitTestBench IS
END CtrlUnitTestBench;
 
ARCHITECTURE behavior OF CtrlUnitTestBench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ControlUnit
    PORT(
         InByte : IN  byte;
         Switch : OUT  std_logic;
         Packet : INOUT  data_packet;
         PackType : INOUT  packet_type;
			PackIsReady : INOUT STD_LOGIC;
         Validation : OUT  std_logic;
         clk : IN  std_logic;
         RST : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal InByte : byte := (others => '0');
   signal clk : std_logic := '0';
   signal RST : std_logic := '0';

 	--Outputs
   signal Switch : std_logic;
   signal Packet : data_packet;
   signal PackType : packet_type;
	signal PackIsReady : STD_LOGIC;
   signal Validation : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ControlUnit PORT MAP (
          InByte => InByte,
          Switch => Switch,
          Packet => Packet,
          PackType => PackType,
			 PackIsReady => PackIsReady,
          Validation => Validation,
          clk => clk,
          RST => RST
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
		variable InputPacket : data_packet;
   begin		
      -- hold reset state for 100 ns.
		RST <= '1';
      wait for clk_period*10;
		RST <= '0';
      InputPacket := ("00000000", 
							 "00000001",
							 "00000010",
							 "00000100",
							 "00000000",
							 "00000111",
							 "00000000");
		for i in 0 to 5 loop
			InByte <= InputPacket(i);
			wait for 10 ns;
		end loop;
		wait for 10 ns;
		
   end process;

END;
