--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:26:54 08/10/2025
-- Design Name:   
-- Module Name:   C:/Windows/system32/last_ed/tb_ctrlunit.vhd
-- Project Name:  last_ed
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Packages.ALL;

entity tb_ctrlunit_operand_alu is end entity;

architecture tb of tb_ctrlunit_operand_alu is
  signal clk, rst : std_logic := '0';
  signal inbyte   : byte := (others=>'0');
  signal Switch, Validation : std_logic;
  signal Packet : data_packet;
  signal PackMode : packet_type;

  constant Tclk : time := 10 ns;

  function packmode_name(m : packet_type) return string is
  begin
    case m is
      when Operand_Alu         => return "Operand_Alu";
      when Immediate_Alu       => return "Immediate_Alu";
      when Array_Alu           => return "Array_Alu";
      when Indirect_Addressing => return "Indirect_Addressing";
      when Writ_e              => return "Writ_e";
      when Rea_d               => return "Rea_d";
      when zero                => return "zero";
    end case;
  end function;

  function sl_str(s : std_logic) return string is
  begin
    if s='1' then
      return "1";
    else
      return "0";
    end if;
  end function;

  procedure send(signal c: in std_logic; signal d: out byte; p: in data_packet) is
  begin
    for i in 0 to 6 loop
      d <= p(i);
      wait until rising_edge(c);
    end loop;
  end procedure;

begin
  DUT: entity work.ControlUnit
    port map (
      InByte     => inbyte,
      Switch     => Switch,
      Packet     => Packet,
      PackMode   => PackMode,
      Validation => Validation,
      clk        => clk,
      RST        => rst
    );

  clk <= not clk after Tclk/2;

  -- Stimulus
  stim: process
    variable pkt : data_packet;
  begin
    -- Reset
    rst <= '1'; wait for 3*Tclk;
    rst <= '0'; wait for 1*Tclk;
    pkt := (others => (others => '0'));
    pkt(0) := "00000000";
    pkt(1) := x"11"; pkt(2) := x"22"; pkt(3) := x"33"; pkt(4) := x"44";
    pkt(5) := CheckSumH(pkt);
    pkt(6) := CheckSumL(pkt);

    -- ?????
    send(clk, inbyte, pkt);

    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait for 1 ns;

    report "Mode   = " & packmode_name(PackMode) severity note;
    report "Switch = " & sl_str(Switch) severity note;
    report "Valid  = " & sl_str(Validation) severity note;
	 
    assert (PackMode = Operand_Alu)
      report "ERROR: PackMode != Operand_Alu" severity error;

    assert (Switch = '1')
      report "ERROR: Switch != '1' for ALU path" severity error;

    assert (Validation = '1')
      report "ERROR: Validation not asserted" severity error;

    report "Operand_Alu smoke OK" severity note;
    wait;
  end process;

end architecture;

