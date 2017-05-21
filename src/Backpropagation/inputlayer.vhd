-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : Input layer entity. Instantiates only connections, as input values    |
-- |               are processed directly.                                               |
-- |                                                                                     |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity BP_InputLayer is
	generic(
		gNumberInputs    : natural;
		gNumberNextLayer : natural
	);
	port(
		iClk          : in  std_ulogic;
		inRst         : in  std_ulogic;
		-- Layer input
		iInputs       : in  neuro_real_vector(gNumberInputs - 1 downto 0);
		iGradients    : in  neuro_real_vector(gNumberNextLayer - 1 downto 0);
		-- Learning inputs
		iEta          : in  neuro_real;
		iAlpha        : in  neuro_real;
		iUpdateWeight : in  std_ulogic;
		-- Layer output
		oOutputs      : out neuro_real_vector((gNumberInputs + 1) * gNumberNextLayer - 1 downto 0)
	);
end entity;

architecture Bhv of BP_InputLayer is
	signal BiasNeuronOutput : neuro_real                                       := cNeuroNull;
	signal BiasNeuronDows   : neuro_real_vector(gNumberNextLayer - 1 downto 0) := (others => cNeuroNull);
begin
	-- ------------------------------------------------------------------
	-- Connections from input to next layer. No input neurons required,
	-- because input values are taken directly.
	-- ------------------------------------------------------------------
	Connections : for i in 0 to gNumberInputs * gNumberNextLayer - 1 generate
		Con : entity work.BP_Connection
			generic map(
				gInitWeight => to_neuro_real(cRandomNumbers1((i + (i / gNumberInputs)) mod cRandomNumbers1'length))
			)
			port map(
				iClk          => iClk,
				inRst         => inRst,
				iInput        => iInputs(i mod gNumberInputs),
				iGradient     => iGradients(i / gNumberInputs),
				iEta          => iEta,
				iAlpha        => iAlpha,
				iUpdateWeight => iUpdateWeight,
				oOutput       => oOutputs(i + (i / gNumberInputs)),
				oDow          => open
			);
	end generate;

	-- ------------------------------------------------------------------
	-- Bias neuron
	-- ------------------------------------------------------------------
	BiasNeuron : entity work.BP_Neuron
		generic map(
			gTypeOfNeuron => Bias_Neuron,
			gNumberInputs => cNumberBiasNeuronInputs,
			gNumberDows   => gNumberNextLayer
		)
		port map(
			iClk      => iClk,
			inRst     => inRst,
			iInputs   => cBiasNeuronInput,
			iDows     => BiasNeuronDows,
			oOutput   => BiasNeuronOutput,
			oGradient => open,
			oDow      => open
		);

	-- ------------------------------------------------------------------
	-- Bias neuron connections
	-- ------------------------------------------------------------------
	BiasConnections : for i in 0 to gNumberNextLayer - 1 generate
		BiasCon : entity work.BP_Connection
			generic map(
				gInitWeight => to_neuro_real(cRandomNumbers1(((i + 1) *(gNumberInputs + 1) - 1) mod cRandomNumbers1'length))
			)
			port map(
				iClk          => iClk,
				inRst         => inRst,
				iInput        => BiasNeuronOutput,
				iGradient     => iGradients(i),
				iEta          => iEta,
				iAlpha        => iAlpha,
				iUpdateWeight => iUpdateWeight,
				oOutput       => oOutputs((i + 1) *(gNumberInputs + 1) - 1),
				oDow          => BiasNeuronDows(i)
			);
	end generate;
end architecture;
