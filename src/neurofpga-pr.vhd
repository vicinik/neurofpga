-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : Package with types, constants and functions for the neural net        |
-- |               implementation.                                                       |
-- |                                                                                     |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use work.Global.all;

package NeuroFPGA is
	--------------------------------------------------------------------
	-- Type declarations
	--------------------------------------------------------------------
	subtype neuro_real is real;
	type neuro_real_vector is array (natural range <>) of neuro_real;
	type real_vector is array (natural range <>) of real;
	type tNeuron is (Hidden_Neuron, Bias_Neuron, Output_Neuron);
	type tLearning is (Supervised, Reinforced);

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
	function calculate_sqr(pInput : neuro_real_vector) return neuro_real;
	function calculate_sqrt(pInput : neuro_real) return real;
	function resize(pInput : neuro_real) return neuro_real;
	function random_number return neuro_real;

	--------------------------------------------------------------------
	-- Constants
	--------------------------------------------------------------------
	constant cNeuroNull              : neuro_real                    := 0.0;
	constant cNeuroOne               : neuro_real                    := 1.0;
	constant cNumberBiasNeuronInputs : natural                       := 1;
	constant cBiasNeuronInput        : neuro_real_vector(0 downto 0) := (others => cNeuroOne);
	constant cPercentageBitWidth     : natural                       := 7;
	constant cActLow                 : neuro_real                    := -1.0;
	constant cActHigh                : neuro_real                    := 1.0;
	constant cRandomNumbers1         : real_vector(0 to 14)          := (0 => 0.499329, 1 => 0.82134, 2 => 0.197782, 3 => 0.92432, 4 => 0.56872, 5 => 0.71432, 6 => 0.62982, 7 => 0.013340, 8 => 0.239322, 9 => 0.45102, 10 => 0.939329, 11 => 0.439293, 12 => 0.5439292, 13 => 0.664992, 14 => 0.8249392);
	constant cRandomNumbers2         : real_vector(0 to 5)           := (0 => 0.299943, 1 => 0.65329, 2 => 0.934993, 3 => 0.723292, 4 => 0.11943, 5 => 0.023994);
end package;

package body NeuroFPGA is
	--------------------------------------------------------------------
	-- Conversion from real to neuro_real
	--------------------------------------------------------------------
	function to_neuro_real(pInput : real) return neuro_real is
	begin
		return pInput;
	end function;

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
		if (pInput < cActLow) then
			vReturn := cActLow;
		elsif (pInput > cActHigh) then
			vReturn := cActHigh;
		else
			vReturn := pInput;
		end if;
		return vReturn;
	end function;
	-- Another activation function.
	function neuro_activation_func_1(pInput : neuro_real) return neuro_real is
		variable vReturn : neuro_real := cNeuroNull;
	begin
		if (pInput < cActLow) then
			vReturn := cActLow;
		elsif (pInput > cActHigh) then
			vReturn := cActHigh;
		else
			vReturn := to_neuro_real(tanh(pInput));
		end if;
		return vReturn;
	end function;

	--------------------------------------------------------------------
	-- Activation function derivative
	--------------------------------------------------------------------
	-- This is the derivative of the activation function. It is needed
	-- for the calculation of the gradient.
	function neuro_activation_deriv_1(pInput : neuro_real) return neuro_real is
		variable vReturn : neuro_real := cNeuroNull;
	begin
		if (pInput < cActLow) then
			vReturn := cNeuroNull;
		elsif (pInput > cActHigh) then
			vReturn := cNeuroNull;
		else
			vReturn := cNeuroOne;
		end if;
		return vReturn;
	end function;
	-- Derivative of the second activation function.
	function neuro_activation_deriv(pInput : neuro_real) return neuro_real is
	begin
		return resize(1.0 / (1.0 + pInput * pInput));
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
		elsif (pInput < to_neuro_real(0.5)) then
			return '0';
		else
			report "Metavalue in function to_std_ulogic" severity error;
			return 'X';
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
		return resize(sum / real(len));
	end function;

	--------------------------------------------------------------------
	-- Calculates the mean square error of a neuro_real_vector
	--------------------------------------------------------------------
	function calculate_sqr(pInput : neuro_real_vector) return neuro_real is
		variable sum : neuro_real := cNeuroNull;
		variable len : natural    := 0;
	begin
		len := pInput'length;
		for i in pInput'range loop
			sum := resize(sum + pInput(i) * pInput(i));
		end loop;
		return resize(sum / real(len));
	end function;
	
	--------------------------------------------------------------------
	-- Calculates the square root of a neuro_real
	--------------------------------------------------------------------
	function calculate_sqrt(pInput : neuro_real) return real is
	begin
		return sqrt(abs(pInput));
	end function;

	--------------------------------------------------------------------
	-- Resizes a sfixed to neuro_real dimensions
	--------------------------------------------------------------------
	function resize(pInput : neuro_real) return neuro_real is
	begin
		return pInput;
	end function;
	
	--------------------------------------------------------------------
	-- Generate a random neuro_real
	--------------------------------------------------------------------
	function random_number return neuro_real is
		variable seed1, seed2 : integer := 10;
		variable rand : real;
	begin
		uniform(seed1, seed2, rand);
		return to_neuro_real(rand);
	end function;
end package body;
