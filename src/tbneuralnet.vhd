library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity TbNeuralNet is
end entity;

architecture Sim of TbNeuralNet is
	constant Eta           : neuro_real := to_neuro_real(0.15);
	constant Alpha         : neuro_real := to_neuro_real(0.5);
	constant NumberInputs  : natural    := 2;
	constant NumberOutputs : natural    := 1;

	signal Clk, nRst, Start, Learn, Finished : std_ulogic                                    := '0';
	signal Error                             : neuro_real                                    := cNeuroNull;
	signal Inputs                            : std_ulogic_vector(NumberInputs - 1 downto 0)  := (others => '0');
	signal Outputs                           : std_ulogic_vector(NumberOutputs - 1 downto 0) := (others => '0');
	signal Targets                           : std_ulogic_vector(NumberOutputs - 1 downto 0) := (others => '0');
begin
	Net : entity work.Net
		generic map(
			gNumberInputs          => NumberInputs,
			gNumberOutputs         => NumberOutputs,
			gNumberHiddenLayers    => 1,
			gNumberNeuronsPerLayer => 4
		)
		port map(
			iClk      => Clk,
			inRst     => nRst,
			iInputs   => Inputs,
			iTargets  => Targets,
			iStart    => Start,
			iEta      => Eta,
			iAlpha    => Alpha,
			iLearn    => Learn,
			oOutputs  => Outputs,
			oFinished => Finished,
			oError    => Error
		);
	
	Clk <= not Clk after 500 ns;
	
	Stimulation : process
	begin
		wait for 1 us;
		nRst <= cnInactivated;
		
		for i in 0 to 200 loop
			wait for 1 us;
			Inputs <= "00";
			Targets <= "0";
			Start <= cActivated after 0 us, cInactivated after 1 us;
			Learn <= cActivated after 0 us, cInactivated after 1 us;
			wait until Finished = cActivated;
			
			wait for 1 us;
			Inputs <= "01";
			Targets <= "0";
			Start <= cActivated after 0 us, cInactivated after 1 us;
			Learn <= cActivated after 0 us, cInactivated after 1 us;
			wait until Finished = cActivated;
			
			wait for 1 us;
			Inputs <= "10";
			Targets <= "0";
			Start <= cActivated after 0 us, cInactivated after 1 us;
			Learn <= cActivated after 0 us, cInactivated after 1 us;
			wait until Finished = cActivated;
			
			wait for 1 us;
			Inputs <= "11";
			Targets <= "1";
			Start <= cActivated after 0 us, cInactivated after 1 us;
			Learn <= cActivated after 0 us, cInactivated after 1 us;
			wait until Finished = cActivated;
		end loop;
	
		wait;
	end process;
end architecture;