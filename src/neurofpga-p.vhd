library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use work.Global.all;

package NeuroFPGA is
	--------------------------------------------------------------------
	-- Type declarations
	--------------------------------------------------------------------
	subtype neuro_real is sfixed(4 downto -11);
	type neuro_real_vector is array (natural range <>) of neuro_real;
	type tNeuron is (Hidden_Neuron, Bias_Neuron, Output_Neuron);

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
	function to_std_ulogic(pInput : neuro_real) return std_ulogic;
	function to_std_ulogic_vector(pInput : neuro_real_vector) return std_ulogic_vector;
	function calculate_avg(pInput : neuro_real_vector) return neuro_real;
	function resize(pInput : sfixed) return neuro_real;
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
	-- Another activation function.
	function neuro_activation_func_1(pInput : neuro_real) return neuro_real is
		variable vReturn : neuro_real := cNeuroNull;
	begin
		if (pInput < to_neuro_real(-3.0)) then
			vReturn := to_neuro_real(-1.0);
		elsif (pInput < to_neuro_real(-2.0)) then
			vReturn := resize(pInput * to_neuro_real(0.0625) - 0.8125);
		elsif (pInput < to_neuro_real(-1.0)) then
			vReturn := resize(pInput * to_neuro_real(0.1875) - 0.5625);
		elsif (pInput > to_neuro_real(3.0)) then
			vReturn := to_neuro_real(1.0);
		elsif (pInput > to_neuro_real(2.0)) then
			vReturn := resize(pInput * to_neuro_real(0.0625) + 0.8125);
		elsif (pInput > to_neuro_real(1.0)) then
			vReturn := resize(pInput * to_neuro_real(0.1875) + 0.5625);
		else
			vReturn := resize(pInput * to_neuro_real(0.75));
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
		if (pInput < to_neuro_real(-3.0)) then
			vReturn := to_neuro_real(0.0);
		elsif (pInput > to_neuro_real(3.0)) then
			vReturn := to_neuro_real(0.0);
		else
			vReturn := to_neuro_real(1.0);
		end if;
		return vReturn;
	end function;
	-- Derivative of the second activation function.
	function neuro_activation_deriv_1(pInput : neuro_real) return neuro_real is
		variable vReturn : neuro_real := cNeuroNull;
	begin
		if (pInput < to_neuro_real(-3.0)) then
			vReturn := to_neuro_real(0.0);
		elsif (pInput < to_neuro_real(-2.0)) then
			vReturn := to_neuro_real(0.0625);
		elsif (pInput < to_neuro_real(-1.0)) then
			vReturn := to_neuro_real(0.1875);
		elsif (pInput > to_neuro_real(3.0)) then
			vReturn := to_neuro_real(0.0);
		elsif (pInput > to_neuro_real(2.0)) then
			vReturn := to_neuro_real(0.0625);
		elsif (pInput > to_neuro_real(1.0)) then
			vReturn := to_neuro_real(0.1875);
		else
			vReturn := to_neuro_real(0.75);
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
		for i in pInput'range loop
			ret(i) := to_neuro_real(pInput(i));
		end loop;
		return ret;
	end function;

	--------------------------------------------------------------------
	-- Conversion from neuro_real to std_ulogic
	--------------------------------------------------------------------
	function to_std_ulogic(pInput : neuro_real) return std_ulogic is
	begin
		if (pInput >= to_neuro_real(0.5)) then
			return '1';
		else
			return '0';
		end if;
	end function;

	--------------------------------------------------------------------
	-- Conversion from neuro_real_vector to std_ulogic_vector
	--------------------------------------------------------------------
	function to_std_ulogic_vector(pInput : neuro_real_vector) return std_ulogic_vector is
		variable ret : std_ulogic_vector(pInput'range) := (others => '0');
	begin
		for i in pInput'range loop
			ret(i) := to_std_ulogic(pInput(i));
		end loop;
		return ret;
	end function;

	--------------------------------------------------------------------
	-- Calculates the average of a neuro_real_vector
	--------------------------------------------------------------------
	function calculate_avg(pInput : neuro_real_vector) return neuro_real is
		variable sum : neuro_real := cNeuroNull;
		variable len : natural    := 0;
	begin
		len := pInput'length;
		for i in pInput'range loop
			sum := resize(sum + pInput(i));
		end loop;
		return resize(sum / len);
	end function;

	--------------------------------------------------------------------
	-- Resizes a sfixed to neuro_real dimensions
	--------------------------------------------------------------------
	function resize(pInput : sfixed) return neuro_real is
	begin
		return resize(pInput, neuro_real'high, neuro_real'low);
	end function;
end package body;
