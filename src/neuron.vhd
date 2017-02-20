library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity Neuron is
	generic(
		gTypeOfNeuron : tNeuron;
		gNumberInputs : natural;
		gNumberDows   : natural
	);
	port(
		iClk      : in  std_ulogic;
		inRst     : in  std_ulogic;
		-- Neuron inputs
		iInputs   : in  neuro_real_vector(gNumberInputs - 1 downto 0);
		iDows     : in  neuro_real_vector(gNumberDows - 1 downto 0);
		-- Neuron outputs
		oOutput   : out neuro_real;
		oGradient : out neuro_real
	);
end entity;

architecture Bhv of Neuron is
	signal inputR, inputNxR, dowR, dowNxR, output, gradient : neuro_real := cNeuroNull;
begin
	--------------------------------------------------------------------
	-- Register process
	--------------------------------------------------------------------
	Reg : process(iClk, inRst)
	begin
		if (inRst = cnActivated) then
			inputR <= cNeuroNull;
			dowR   <= cNeuroNull;
		elsif (iClk'event and iClk = cActivated) then
			inputR <= inputNxR;
			dowR   <= dowNxR;
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

		for i in 0 to gNumberInputs loop
			sumInput := sumInput + iInputs(i);
		end loop;

		inputNxR <= sumInput;
	end process;

	--------------------------------------------------------------------
	-- Sum dows (= gradients of next layer neurons multiplied by
	-- the connections' weights)
	--------------------------------------------------------------------
	SumDows : process(iDows, dowR, output)
		variable dow : neuro_real := cNeuroNull;
	begin
		dowNxR <= dowR;
		dow    := cNeuroNull;

		if (gTypeOfNeuron = Output_Neuron) then
			dow := iDows(0) - output;
		elsif (gTypeOfNeuron = Hidden_Neuron) then
			for i in 0 to gNumberDows loop
				dow := dow + iDows(i);
			end loop;
		end if;
		
		dowNxR <= dow;
	end process;

	--------------------------------------------------------------------
	-- Output port assignments
	--------------------------------------------------------------------
	output    <= cNeuroOne when gTypeOfNeuron = Bias_Neuron else neuro_activation_func(inputR);
	gradient  <= cNeuroNull when gTypeOfNeuron = Bias_Neuron else dowR * neuro_activation_deriv(output);
	oOutput   <= output;
	oGradient <= gradient;
end architecture;