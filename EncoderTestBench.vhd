--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:31:01 08/10/2025
-- Design Name:   
-- Module Name:   /home/ise/IDK/EncoderTestBench.vhd
-- Project Name:  IDK
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: HammingEncoder
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

ENTITY EncoderTestBench IS
END EncoderTestBench;
 
ARCHITECTURE behavior OF EncoderTestBench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT HammingEncoder
    PORT(
         BitIn : IN  std_logic;
         BitOut : OUT  std_logic;
         TestBenchCheck : OUT  std_logic_vector(0 to 12);
         TestBenchInputDisplay : OUT  std_logic_vector(7 downto 0);
         OutRdy : INOUT  std_logic;
         RST : IN  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal BitIn : std_logic := '0';
   signal RST : std_logic := '0';
   signal clk : std_logic := '0';

	--BiDirs
   signal OutRdy : std_logic;

 	--Outputs
   signal BitOut : std_logic;
   signal TestBenchCheck : std_logic_vector(0 to 12);
   signal TestBenchInputDisplay : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: HammingEncoder PORT MAP (
          BitIn => BitIn,
          BitOut => BitOut,
          TestBenchCheck => TestBenchCheck,
          TestBenchInputDisplay => TestBenchInputDisplay,
          OutRdy => OutRdy,
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
		variable Input : byte;
   begin		
      -- hold reset state for 100 ns.
      RST <= '1';
      wait for clk_period*10;
		RST <= '0';
		
      -- Test #1
		-- Input : "11111111" , Answer : "011011101111"
		Input := "11111111";
		for i in 0 to 7 loop
			BitIn <= Input(i);
			wait for 10 ns;
		end loop;
		wait for 15*clk_period;
		
		-- Test #2
		-- Input : "01011100" , Answer : "1000101011000"
		Input := "01011100";
		for i in 0 to 7 loop
			BitIn <= Input(i);
			wait for 10 ns;
		end loop;
		wait for 15*clk_period;
   end process;

END;
