-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : This entity represents a neuron. Depending on gTypeOfNeuron, one can  |
-- |               instantiate a Bias, Hidden or Output neuron. An Input neuron is not   |
-- |               needed, since input values are directly forwarded!                    |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity MLP_Neuron is
	generic(
		gTypeOfNeuron : tNeuron;
		gNumberInputs : natural
	);
	port(
		iClk      : in  std_ulogic;
		inRst     : in  std_ulogic;
		-- Neuron inputs
		iInputs   : in  neuro_real_vector(gNumberInputs - 1 downto 0);
		-- Neuron outputs
		oOutput   : out neuro_real
	);
end entity;

architecture Bhv of MLP_Neuron is
	signal inputR, inputNxR, output : neuro_real := cNeuroNull;
begin
	--------------------------------------------------------------------
	-- Register process
	--------------------------------------------------------------------
	Reg : process(iClk, inRst)
	begin
		if (inRst = cnActivated) then
			inputR <= cNeuroNull;
		elsif (iClk'event and iClk = cActivated) then
			inputR <= inputNxR;
		end if;
	end process;

	--------------------------------------------------------------------
	-- Sum inputs (= outputs of previous layer neurons multiplied by
	-- the connections' weights)
	--------------------------------------------------------------------
	SumInputs : process(iInputs, inputR)
		variable sumInput : neuro_real := cNeuroNull;
	begin
		inputNxR <= inputR;
		sumInput := cNeuroNull;

		for i in 0 to gNumberInputs - 1 loop
			sumInput := resize(sumInput + iInputs(i));
		end loop;

		inputNxR <= sumInput;
	end process;

	--------------------------------------------------------------------
	-- Output port assignments
	--------------------------------------------------------------------
	output    <= cNeuroOne when gTypeOfNeuron = Bias_Neuron else neuro_activation_func(inputR);
	oOutput   <= output;
end architecture;
