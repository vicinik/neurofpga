library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity InputLayer is
	generic(
		gNumberInputs    : natural;
		gNumberNextLayer : natural
	);
	port(
		iClk          : in  std_ulogic;
		inRst         : in  std_ulogic;
		-- Layer input
		iInputs       : in  neuro_real_vector(gNumberInputs - 1 downto 0);
		iGradients    : in  neuro_real_vector(gNumberInputs * gNumberNextLayer - 1 downto 0);
		-- Learning inputs
		iEta          : in  neuro_real;
		iAlpha        : in  neuro_real;
		iUpdateWeight : in  std_ulogic;
		-- Layer output
		oOutput       : out neuro_real_vector(gNumberInputs * gNumberNextLayer - 1 downto 0)
	);
end entity;

architecture Bhv of InputLayer is
	signal BiasNeuronOutput : neuro_real                    := cNeuroNull;
	signal BiasNeuronDows   : neuro_real_vector(gNumberNextLayer - 1 downto 0);
begin
	--------------------------------------------------------------------
	-- Connections from input to next layer. No input neurons required,
	-- because input values are taken directly.
	--------------------------------------------------------------------
	Connections : for i in 0 to gNumberInputs * gNumberNextLayer - 1 generate
		Con : entity work.Connection
			port map(
				iClk          => iClk,
				inRst         => inRst,
				iInput        => iInputs(i / gNumberNextLayer),
				iGradient     => iGradients(i mod gNumberNextLayer),
				iEta          => iEta,
				iAlpha        => iAlpha,
				iUpdateWeight => iUpdateWeight,
				oOutput       => oOutput(i mod gNumberNextLayer),
				oDow          => open
			);
	end generate;

	--------------------------------------------------------------------
	-- Bias neuron
	--------------------------------------------------------------------
	BiasNeuron : entity work.Neuron
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
			oGradient => open
		);

	--------------------------------------------------------------------
	-- Bias neuron connections
	--------------------------------------------------------------------
	BiasConnections : for i in 0 to gNumberNextLayer - 1 generate
		BiasCon : entity work.Connection
			port map(
				iClk          => iClk,
				inRst         => inRst,
				iInput        => BiasNeuronOutput,
				iGradient     => iGradients(i),
				iEta          => iEta,
				iAlpha        => iAlpha,
				iUpdateWeight => iUpdateWeight,
				oOutput       => oOutput(i),
				oDow          => BiasNeuronDows(i)
			);
	end generate;
end architecture;
