library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity Net is
	generic(
		gNumberInputs          : natural;
		gNumberOutputs         : natural;
		gNumberHiddenLayers    : natural;
		gNumberNeuronsPerLayer : natural
	);
	port(
		iClk      : in  std_ulogic;
		inRst     : in  std_ulogic;
		-- Neural net inputs
		iInput    : in  std_ulogic_vector(gNumberInputs - 1 downto 0);
		iTarget   : in  std_ulogic_vector(gNumberOutputs - 1 downto 0);
		-- Weight update inputs
		iEta      : in  neuro_real;
		iAlpha    : in  neuro_real;
		iLearn    : in  std_ulogic;
		-- Neural net outputs
		oOutput   : out std_ulogic_vector(gNumberOutputs - 1 downto 0);
		oFinished : out std_ulogic;
		oError    : out neuro_real
	);
end entity;

architecture Bhv of Net is
	signal input             : neuro_real_vector(gNumberInputs - 1 downto 0);
	signal dow               : neuro_real_vector(gNumberInputs - 1 downto 0);
	signal connectFirstLayer : con_to_neuron_vector(gNumberInputs * gNumberNeuronsPerLayer - 1 downto 0);
	signal updateWeights     : std_ulogic := '0';
begin
	input <= to_neuro_real_vector(iInput);

	FirstLayer : for i in 0 to gNumberInputs * gNumberNeuronsPerLayer - 1 generate
		FirstLayerCon : work.Connection
			port map(
				iClk          => iClk,
				inRst         => inRst,
				iInput        => input(i / gNumberNeuronsPerLayer),
				iGradient     => connectFirstLayer(i mod gNumberNeuronsPerLayer).Gradient,
				iEta          => iEta,
				iAlpha        => iAlpha,
				iUpdateWeight => updateWeights,
				oOutput       => connectFirstLayer(i mod gNumberNeuronsPerLayer).Value,
				oDow          => dow(i / gNumberNeuronsPerLayer)
			);
	end generate;
end architecture;