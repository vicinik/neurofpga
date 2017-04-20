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

entity TbdNeuralNet_MLP is
	port(
		iClk     : in  std_ulogic;
		inRst    : in  std_ulogic;
		iStart   : in  std_ulogic;
		iLearn   : in  std_ulogic;
		oOutputs : out neuro_real_vector(0 downto 0)
	);
end entity;

architecture bed of TbdNeuralNet_MLP is
	-- Constants
	constant Eta                      : neuro_real := to_neuro_real(0.15);
	constant Alpha                    : neuro_real := to_neuro_real(0.5);
	constant NumberInputs             : natural    := 2;
	constant NumberOutputs            : natural    := 1;
	constant NumberHiddenLayers       : natural    := 1;
	constant NumberNeuronsHiddenLayer : natural    := 5;

	-- Signals
	signal Finished      : std_ulogic                                                                     := '0';
	signal Inputs        : neuro_real_vector(NumberInputs - 1 downto 0)                                   := (others => cNeuroNull);
	signal Targets       : neuro_real_vector(NumberOutputs - 1 downto 0)                                  := (others => cNeuroNull);
	signal InputWeights  : neuro_real_vector((NumberInputs + 1) * NumberNeuronsHiddenLayer - 1 downto 0)  := (others => cNeuroNull);
	signal OutputWeights : neuro_real_vector((NumberNeuronsHiddenLayer + 1) * NumberOutputs - 1 downto 0) := (others => cNeuroNull);
	signal HiddenWeights : neuro_real_vector(-1 downto 0)                                                 := (others => cNeuroNull);
begin
	-- ------------------------------------------------------------------
	-- Net instantiation
	-- ------------------------------------------------------------------
	Net : entity work.MLP_Net
		generic map(
			gNumberInputs          => NumberInputs,
			gNumberOutputs         => NumberOutputs,
			gNumberHiddenLayers    => NumberHiddenLayers,
			gNumberNeuronsPerLayer => NumberNeuronsHiddenLayer
		)
		port map(
			iClk           => iClk,
			inRst          => inRst,
			iInputs        => Inputs,
			iInputWeights  => InputWeights,
			iHiddenWeights => HiddenWeights,
			iOutputWeights => OutputWeights,
			iStart         => iStart,
			oOutputs       => oOutputs,
			oFinishedAll   => Finished
		);
end architecture;
