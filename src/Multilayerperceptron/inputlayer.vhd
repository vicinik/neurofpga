-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : Input layer entity. Instantiates only connections, as input values    |
-- |               are processed directly.                                               |
-- |                                                                                     |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity MLP_InputLayer is
	generic(
		gNumberInputs    : natural;
		gNumberNextLayer : natural
	);
	port(
		iClk          : in  std_ulogic;
		inRst         : in  std_ulogic;
		-- Layer input
		iInputs       : in  neuro_real_vector(gNumberInputs - 1 downto 0);
		iWeights	  : in  neuro_real_vector((gNumberInputs + 1) * gNumberNextLayer - 1 downto 0);
		-- Layer output
		oOutputs      : out neuro_real_vector((gNumberInputs + 1) * gNumberNextLayer - 1 downto 0)
	);
end entity;

architecture Bhv of MLP_InputLayer is
	signal BiasNeuronOutput : neuro_real                                       := cNeuroNull;
begin
	--------------------------------------------------------------------
	-- Connections from input to next layer. No input neurons required,
	-- because input values are taken directly.
	--------------------------------------------------------------------
	Connections : for i in 0 to gNumberInputs * gNumberNextLayer - 1 generate
		Con : entity work.MLP_Connection
			port map(
				iInput        => iInputs(i mod gNumberInputs),
				iWeight		  => iWeights(i),
				oOutput       => oOutputs(i + (i / gNumberInputs))
			);
	end generate;

	--------------------------------------------------------------------
	-- Bias neuron
	--------------------------------------------------------------------
	BiasNeuron : entity work.MLP_Neuron
		generic map(
			gTypeOfNeuron => Bias_Neuron,
			gNumberInputs => cNumberBiasNeuronInputs
		)
		port map(
			iClk      => iClk,
			inRst     => inRst,
			iInputs   => cBiasNeuronInput,
			oOutput   => BiasNeuronOutput
		);

	--------------------------------------------------------------------
	-- Bias neuron connections
	--------------------------------------------------------------------
	BiasConnections : for i in 0 to gNumberNextLayer - 1 generate
		BiasCon : entity work.MLP_Connection
			port map(
				iInput        => BiasNeuronOutput,
				iWeight		  => iWeights(i + gNumberInputs * gNumberNextLayer),
				oOutput       => oOutputs((i + 1) * (gNumberInputs + 1) - 1)
			);
	end generate;
end architecture;
