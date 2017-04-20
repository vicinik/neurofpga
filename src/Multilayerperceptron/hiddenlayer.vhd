-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : Hidden layer entity. Instantiates neurons and connections, hence      |
-- |               hidden layers are very ressource intensive!                           |
-- |                                                                                     |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity MLP_HiddenLayer is
	generic(
		gNumberNeurons   : natural;
		gNumberPrevLayer : natural;
		gNumberNextLayer : natural
	);
	port(
		iClk          : in  std_ulogic;
		inRst         : in  std_ulogic;
		-- Layer input
		iInputs       : in  neuro_real_vector((gNumberPrevLayer + 1) * gNumberNeurons - 1 downto 0);
		iWeights	  : in  neuro_real_vector((gNumberNeurons + 1) * gNumberNextLayer - 1 downto 0);
		-- Layer output
		oOutputs      : out neuro_real_vector((gNumberNeurons + 1) * gNumberNextLayer - 1 downto 0)
	);
end entity;

architecture Bhv of MLP_HiddenLayer is
	signal ConnectOutputs    : neuro_real_vector(gNumberNeurons - 1 downto 0)                    := (others => cNeuroNull);
	signal BiasNeuronOutput  : neuro_real                                                        := cNeuroNull;
begin
	--------------------------------------------------------------------
	-- Neurons
	--------------------------------------------------------------------
	Neurons : for i in 0 to gNumberNeurons - 1 generate
		Neur : entity work.MLP_Neuron
			generic map(
				gTypeOfNeuron => Hidden_Neuron,
				gNumberInputs => gNumberPrevLayer + 1
			)
			port map(
				iClk      => iClk,
				inRst     => inRst,
				iInputs   => iInputs((i + 1) * (gNumberPrevLayer + 1) - 1 downto i * (gNumberPrevLayer + 1)),
				oOutput   => ConnectOutputs(i)
			);
	end generate;

	--------------------------------------------------------------------
	-- Connections from neurons to next layer. 
	--------------------------------------------------------------------
	Connections : for i in 0 to gNumberNeurons * gNumberNextLayer - 1 generate
		Con : entity work.MLP_Connection
			port map(
				iInput        => ConnectOutputs(i mod gNumberNeurons),
				iWeight		  => iWeights(i),
				oOutput       => oOutputs(i + (i / gNumberNeurons))
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
				iWeight		  => iWeights(i + gNumberNeurons * gNumberNextLayer),
				oOutput       => oOutputs((i + 1) * (gNumberNeurons + 1) - 1)
			);
	end generate;
end architecture;
