-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : Testbed for the neural net design.                                    |
-- |                                                                                     |
-- |                                                                                     |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity TbdNeuralNet_BP is
	port (
		iClk		: in std_ulogic;
		inRst		: in std_ulogic;
		iStart		: in std_ulogic;
		iLearn		: in std_ulogic;
		
		oError		: out neuro_real
	);
end entity;

architecture bed of TbdNeuralNet_BP is
	-- Constants
	constant Eta                       : neuro_real := to_neuro_real(0.15);
	constant Alpha                     : neuro_real := to_neuro_real(0.5);
	constant NumberInputs              : natural    := 2;
	constant NumberOutputs             : natural    := 1;
	
	-- Signals
	signal FinishedForward, FinishedBackward, FinishedAll : std_ulogic                                    := '0';
	signal Inputs                                         : neuro_real_vector(NumberInputs - 1 downto 0)  := (others => cNeuroNull);
	signal Outputs                                        : neuro_real_vector(NumberOutputs - 1 downto 0) := (others => cNeuroNull);
	signal Targets                                        : neuro_real_vector(NumberOutputs - 1 downto 0) := (others => cNeuroNull);
begin
	--------------------------------------------------------------------
	-- Net instantiation
	--------------------------------------------------------------------
	Net : entity work.BP_Net
		generic map(
			gLearning              => Supervised,
			gNumberInputs          => NumberInputs,
			gNumberOutputs         => NumberOutputs,
			gNumberHiddenLayers    => 1,
			gNumberNeuronsPerLayer => 5
		)
		port map(
			iClk              => iClk,
			inRst             => inRst,
			iInputs           => Inputs,
			iTargets          => Targets,
			iStart            => iStart,
			iEta              => Eta,
			iAlpha            => Alpha,
			iLearn            => iLearn,
			oOutputs          => Outputs,
			oFinishedForward  => FinishedForward,
			oFinishedBackward => FinishedBackward,
			oFinishedAll      => FinishedAll,
			oError            => oError
		);
end architecture;