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

entity MLP_OutputLayer is
	generic(
		gNumberNeurons   : natural;
		gNumberPrevLayer : natural
	);
	port(
		iClk          : in  std_ulogic;
		inRst         : in  std_ulogic;
		-- Layer input
		iInputs       : in  neuro_real_vector((gNumberPrevLayer + 1) * gNumberNeurons - 1 downto 0);
		-- Layer output
		oOutputs      : out neuro_real_vector(gNumberNeurons  - 1 downto 0)
	);
end entity;

architecture Bhv of MLP_OutputLayer is
begin
	--------------------------------------------------------------------
	-- Neurons
	--------------------------------------------------------------------
	Neurons : for i in 0 to gNumberNeurons - 1 generate
		Neur : entity work.MLP_Neuron
			generic map(
				gTypeOfNeuron => Output_Neuron,
				gNumberInputs => gNumberPrevLayer + 1
			)
			port map(
				iClk      => iClk,
				inRst     => inRst,
				iInputs   => iInputs((i + 1) * (gNumberPrevLayer + 1) - 1 downto i * (gNumberPrevLayer + 1)),
				oOutput   => oOutputs(i)
			);
	end generate;
end architecture;
