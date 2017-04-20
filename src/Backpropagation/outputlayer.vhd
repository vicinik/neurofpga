-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : Output layer entity. Instantiates only output neurons.                |
-- |                                                                                     |
-- |                                                                                     |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity BP_OutputLayer is
	generic(
		gLearning		 : tLearning;
		gNumberNeurons   : natural;
		gNumberPrevLayer : natural
	);
	port(
		iClk          : in  std_ulogic;
		inRst         : in  std_ulogic;
		-- Layer input
		iInputs       : in  neuro_real_vector((gNumberPrevLayer + 1) * gNumberNeurons - 1 downto 0);
		iTargets      : in  neuro_real_vector(gNumberNeurons - 1 downto 0);
		-- Layer output
		oOutputs      : out neuro_real_vector(gNumberNeurons  - 1 downto 0);
		oGradients    : out neuro_real_vector(gNumberNeurons - 1 downto 0)
	);
end entity;

architecture Bhv of BP_OutputLayer is
begin
	--------------------------------------------------------------------
	-- Neurons
	--------------------------------------------------------------------
	Neurons : for i in 0 to gNumberNeurons - 1 generate
		Neur : entity work.BP_Neuron
			generic map(
				gLearning	  => gLearning,
				gTypeOfNeuron => Output_Neuron,
				gNumberInputs => gNumberPrevLayer + 1,
				gNumberDows   => 1
			)
			port map(
				iClk      => iClk,
				inRst     => inRst,
				iInputs   => iInputs((i + 1) * (gNumberPrevLayer + 1) - 1 downto i * (gNumberPrevLayer + 1)),
				iDows     => iTargets(i downto i),
				oOutput   => oOutputs(i),
				oGradient => oGradients(i)
			);
	end generate;
end architecture;
