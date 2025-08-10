--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:01:50 08/10/2025
-- Design Name:   
-- Module Name:   /home/ise/IDK/DecoderTestBench.vhd
-- Project Name:  IDK
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: HammingDecoder
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
USE work.Packages.ALL;
 
ENTITY DecoderTestBench IS
END DecoderTestBench;
 
ARCHITECTURE behavior OF DecoderTestBench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT HammingDecoder
    PORT(
         DecInBit : IN  std_logic;
         TestBenchInputDisplay : out STD_LOGIC_VECTOR (0 to 12);
         OutRdy : INOUT  std_logic;
         DecOutByte : OUT  std_logic_vector(7 downto 0);
         Valid : OUT  std_logic;
         RST : IN  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal DecInBit : std_logic := '0';
   signal RST : std_logic := '0';
   signal clk : std_logic := '0';

	--BiDirs
   signal OutRdy : std_logic;

 	--Outputs
   signal TestBenchInputDisplay : STD_LOGIC_VECTOR (0 to 12);
   signal DecOutByte : std_logic_vector(7 downto 0);
   signal Valid : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: HammingDecoder PORT MAP (
          DecInBit => DecInBit,
          TestBenchInputDisplay => TestBenchInputDisplay,
          OutRdy => OutRdy,
          DecOutByte => DecOutByte,
          Valid => Valid,
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
		variable Input : std_logic_vector(12 downto 0);
   begin		
      -- hold reset state for 100 ns.
      RST <= '1';
      wait for clk_period*10;
		RST <= '0';
		
      -- Test #1
		-- Input : "1110111011110" , Answer : "11111111"
		Input := "1110111011110";
		for i in 12 downto 0 loop
			DecInBit <= Input(i);
			wait for 10 ns;
		end loop;
		wait for 2*clk_period;
		
		-- Test #2
		-- Input : "0110101100100" , Answer : "11010010"
		Input := "0110101100100";
		for i in 0 to 12 loop
			DecInBit <= Input(i);
			wait for 10 ns;
		end loop;
		wait for 2*clk_period;
   end process;


END;
