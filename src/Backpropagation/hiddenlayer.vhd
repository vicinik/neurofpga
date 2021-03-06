-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : Hidden layer entity. Instantiates neurons and connections, hence      |
-- |               hidden layers are very ressource intensive!                           |
-- |                                                                                     |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity BP_HiddenLayer is
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
		iGradients    : in  neuro_real_vector(gNumberNextLayer - 1 downto 0);
		-- Learning inputs
		iEta          : in  neuro_real;
		iAlpha        : in  neuro_real;
		iUpdateWeight : in  std_ulogic;
		-- Layer output
		oOutputs      : out neuro_real_vector((gNumberNeurons + 1) * gNumberNextLayer - 1 downto 0);
		oGradients    : out neuro_real_vector(gNumberNeurons - 1 downto 0)
	);
end entity;

architecture Bhv of BP_HiddenLayer is
	signal ConnectDowsNeuron : neuro_real_vector(gNumberNeurons * gNumberNextLayer - 1 downto 0) := (others => cNeuroNull);
	signal ConnectDowsCon    : neuro_real_vector(gNumberNeurons * gNumberNextLayer - 1 downto 0) := (others => cNeuroNull);
	signal ConnectOutputs    : neuro_real_vector(gNumberNeurons - 1 downto 0)                    := (others => cNeuroNull);
	signal BiasNeuronOutput  : neuro_real                                                        := cNeuroNull;
	signal BiasNeuronDows    : neuro_real_vector(gNumberNextLayer - 1 downto 0)                  := (others => cNeuroNull);
begin
	-- ------------------------------------------------------------------
	-- Neurons
	-- ------------------------------------------------------------------
	Neurons : for i in 0 to gNumberNeurons - 1 generate
		Neur : entity work.BP_Neuron
			generic map(
				gTypeOfNeuron => Hidden_Neuron,
				gNumberInputs => gNumberPrevLayer + 1,
				gNumberDows   => gNumberNextLayer
			)
			port map(
				iClk      => iClk,
				inRst     => inRst,
				iInputs   => iInputs((i + 1) *(gNumberPrevLayer + 1) - 1 downto i *(gNumberPrevLayer + 1)),
				iDows     => ConnectDowsNeuron((i + 1) * gNumberNextLayer - 1 downto i * gNumberNextLayer),
				oOutput   => ConnectOutputs(i),
				oGradient => oGradients(i),
				oDow      => open
			);
	end generate;

	-- ------------------------------------------------------------------
	-- Connections from neurons to next layer. 
	-- ------------------------------------------------------------------
	Connections : for i in 0 to gNumberNeurons * gNumberNextLayer - 1 generate
		Con : entity work.BP_Connection
			generic map(
				gInitWeight => to_neuro_real(cRandomNumbers2((i + (i / gNumberNeurons)) mod cRandomNumbers2'length))
			)
			port map(
				iClk          => iClk,
				inRst         => inRst,
				iInput        => ConnectOutputs(i mod gNumberNeurons),
				iGradient     => iGradients(i / gNumberNeurons),
				iEta          => iEta,
				iAlpha        => iAlpha,
				iUpdateWeight => iUpdateWeight,
				oOutput       => oOutputs(i + (i / gNumberNeurons)),
				oDow          => ConnectDowsCon(i)
			);
	end generate;

	-- ------------------------------------------------------------------
	-- Match dows from connections to neurons
	-- ------------------------------------------------------------------
	MatchDows : process(ConnectDowsCon)
	begin
		for i in 0 to ConnectDowsCon'length - 1 loop
			ConnectDowsNeuron(i) <= ConnectDowsCon((i mod gNumberNextLayer) * gNumberNeurons + i / gNumberNextLayer);
		end loop;
	end process;

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
				gInitWeight => to_neuro_real(cRandomNumbers2(((i + 1) *(gNumberNeurons + 1) - 1) mod cRandomNumbers2'length))
			)
			port map(
				iClk          => iClk,
				inRst         => inRst,
				iInput        => BiasNeuronOutput,
				iGradient     => iGradients(i),
				iEta          => iEta,
				iAlpha        => iAlpha,
				iUpdateWeight => iUpdateWeight,
				oOutput       => oOutputs((i + 1) *(gNumberNeurons + 1) - 1),
				oDow          => BiasNeuronDows(i)
			);
	end generate;
end architecture;
