library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use work.Global.all;

package NeuroFPGA is
	--------------------------------------------------------------------
	-- Type declarations
	--------------------------------------------------------------------
	subtype neuro_real is sfixed(3 downto -12);
	type neuro_real_vector is array (natural range <>) of neuro_real;
	type tNeuron is (Hidden_Neuron, Bias_Neuron, Output_Neuron);
	type tConnectionToNeuron is record
		Value    : neuro_real;
		Gradient : neuro_real;
	end record;
	type tNeuronToConnection is record
		Value : neuro_real;
		Dow   : neuro_real;
	end record;
	type con_to_neuron_vector is array (natural range <>) of tConnectionToNeuron;
	type neuron_to_con_vector is array (natural range <>) of tNeuronToConnection;

	--------------------------------------------------------------------
	-- Constants
	--------------------------------------------------------------------
	constant cNeuroNull              : neuro_real                    := to_sfixed(0.0, neuro_real'high, neuro_real'low);
	constant cNeuroOne               : neuro_real                    := to_sfixed(1.0, neuro_real'high, neuro_real'low);
	constant cNumberBiasNeuronInputs : natural                       := 1;
	constant cBiasNeuronInput        : neuro_real_vector(0 downto 0) := (others => cNeuroOne);

	--------------------------------------------------------------------
	-- Function declarations
	--------------------------------------------------------------------
	function neuro_activation_func(pInput : neuro_real) return neuro_real;
	function neuro_activation_deriv(pInput : neuro_real) return neuro_real;
	function to_neuro_real(pInput : real) return neuro_real;
	function to_neuro_real(pInput : std_ulogic) return neuro_real;
	function to_neuro_real_vector(pInput : std_ulogic_vector) return neuro_real_vector;
end package;

package body NeuroFPGA is
	--------------------------------------------------------------------
	-- Activation function
	--------------------------------------------------------------------
	-- The activation function is an essential part of a neuron.
	-- It takes the summarized value of all inputs and calculates an
	-- output. We try to approximate the tanh function, as it has been
	-- successfully used in neural networks.
	function neuro_activation_func(pInput : neuro_real) return neuro_real is
		variable vReturn : neuro_real := cNeuroNull;
	begin
		if (pInput < to_neuro_real(-1.0)) then
			vReturn := to_neuro_real(-1.0);
		elsif (pInput > to_neuro_real(1.0)) then
			vReturn := to_neuro_real(1.0);
		else
			vReturn := pInput;
		end if;
		return vReturn;
	end function;

	--------------------------------------------------------------------
	-- Activation function derivative
	--------------------------------------------------------------------
	-- This is the derivative of the activation function. It is needed
	-- for the calculation of the gradient.
	function neuro_activation_deriv(pInput : neuro_real) return neuro_real is
		variable vReturn : neuro_real := cNeuroNull;
	begin
		if (pInput < to_neuro_real(-1.0)) then
			vReturn := cNeuroNull;
		elsif (pInput > to_neuro_real(1.0)) then
			vReturn := cNeuroNull;
		else
			vReturn := cNeuroOne;
		end if;
		return vReturn;
	end function;

	--------------------------------------------------------------------
	-- Conversion from real to neuro_real
	--------------------------------------------------------------------
	function to_neuro_real(pInput : real) return neuro_real is
	begin
		return to_sfixed(pInput, neuro_real'high, neuro_real'low);
	end function;

	--------------------------------------------------------------------
	-- Conversion from std_ulogic to neuro_real
	--------------------------------------------------------------------
	function to_neuro_real(pInput : std_ulogic) return neuro_real is
	begin
		if (pInput = '1') then
			return to_neuro_real(1.0);
		else
			return to_neuro_real(0.0);
		end if;
	end function;

	--------------------------------------------------------------------
	-- Conversion from std_ulogic_vector to neuro_real_vector
	--------------------------------------------------------------------
	function to_neuro_real_vector(pInput : std_ulogic_vector) return neuro_real_vector is
		variable ret : neuro_real_vector(pInput'range) := (others => cNeuroNull);
	begin
		for i in 0 to pInput'length - 1 loop
			ret(i) := to_neuro_real(pInput(i));
		end loop;
		return ret;
	end function;
end package body;
