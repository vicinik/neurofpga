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
	-- ------------------------------------------------------------------
	-- Type declarations
	-- ------------------------------------------------------------------
	subtype neuro_real is sfixed(5 downto -10);
	type neuro_real_vector is array (natural range <>) of neuro_real;
	type real_vector is array (natural range <>) of real;
	type tNeuron is (Hidden_Neuron, Bias_Neuron, Output_Neuron);
	type tLearning is (Supervised, Reinforced);

	-- ------------------------------------------------------------------
	-- Function declarations
	-- ------------------------------------------------------------------
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
	function resize(pInput : sfixed) return neuro_real;
	function percentage_to_neuro_real(pInput : std_ulogic_vector) return neuro_real;
	function neuro_real_to_percentage(pInput : neuro_real) return std_ulogic_vector;
	function random_number return neuro_real;
	function add_shift(r : neuro_real; l : neuro_real) return neuro_real;
	function mul_binary(input : neuro_real; weight : neuro_real) return neuro_real;

	-- ------------------------------------------------------------------
	-- Constants
	-- ------------------------------------------------------------------
	constant cNeuroNull              : neuro_real                    := to_sfixed(0.0, neuro_real'high, neuro_real'low);
	constant cNeuroOne               : neuro_real                    := to_sfixed(1.0, neuro_real'high, neuro_real'low);
	constant cNumberBiasNeuronInputs : natural                       := 1;
	constant cBiasNeuronInput        : neuro_real_vector(0 downto 0) := (others => cNeuroOne);
	constant cPercentageBitWidth     : natural                       := 7;
	constant cActLow                 : neuro_real                    := to_sfixed(-1.0, neuro_real'high, neuro_real'low);
	constant cActHigh                : neuro_real                    := to_sfixed(1.0, neuro_real'high, neuro_real'low);
	constant cRandomNumbers1         : real_vector(0 to 14)          := (0 => 0.49, 1 => 0.82, 2 => 0.19, 3 => 0.92, 4 => 0.56, 5 => 0.71, 6 => 0.62, 7 => 0.01, 8 => 0.23, 9 => 0.45, 10 => 0.93, 11 => 0.43, 12 => 0.54, 13 => 0.66, 14 => 0.82);
	constant cRandomNumbers2         : real_vector(0 to 5)           := (0 => 0.29, 1 => 0.65, 2 => 0.93, 3 => 0.72, 4 => 0.11, 5 => 0.02);
end package;

package body NeuroFPGA is
	-- ------------------------------------------------------------------
	-- Conversion from real to neuro_real
	-- ------------------------------------------------------------------
	function to_neuro_real(pInput : real) return neuro_real is
	begin
		return to_sfixed(pInput, neuro_real'high, neuro_real'low);
	end function;

	-- ------------------------------------------------------------------
	-- Own implementation of a multiplication, which uses only add
	-- and shift (therefore no DSPs are needed).
	-- Disadvantage: very time- and area-consuming!
	-- ------------------------------------------------------------------
	function add_shift(r : neuro_real; l : neuro_real) return neuro_real is
		variable sign            : std_ulogic := '0';
		variable res, posr, posl : neuro_real := (others => '0');
	begin
		sign := r(neuro_real'high) xor l(neuro_real'high);
		posr := resize(abs (r));
		posl := resize(abs (l));
		for i in neuro_real'high - 1 downto neuro_real'low loop
			if (posl(i) = '1') then
				res := resize(res + (posr sll i));
			end if;
		end loop;
		if (sign = '1') then
			res := resize(-res);
		end if;
		return res;
	end function;

	-- ------------------------------------------------------------------
	-- Helper function for generating a shift value out of a neuro_real
	-- ------------------------------------------------------------------
	function to_shiftval(pInput : neuro_real) return integer is
	begin
		for i in neuro_real'high - 1 downto neuro_real'low loop
			if (pInput(i) = '1') then
				return i;
			end if;
		end loop;
		return 0;
	end function;

	-- ------------------------------------------------------------------
	-- Own implementation of a multiplication in order to reduce the
	-- amount of DSPs needed. This one only shifts the multiplicand.
	-- Disadvantage: Quantization errors!
	-- ------------------------------------------------------------------
	function mul_binary(input : neuro_real; weight : neuro_real) return neuro_real is
		variable sign                     : std_ulogic := '0';
		variable res, posinput, posweight : neuro_real := (others => '0');
	begin
		sign      := input(neuro_real'high) xor weight(neuro_real'high);
		posinput  := resize(abs (input));
		posweight := resize(abs (weight));
		res       := resize(posinput sll to_shiftval(posweight));
		if (sign = '1') then
			res := resize(-res);
		end if;
		return res;
	end function;

	-- ------------------------------------------------------------------
	-- Activation function
	-- ------------------------------------------------------------------
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
			vReturn := to_neuro_real(tanh(to_real(pInput)));
		end if;
		return vReturn;
	end function;

	-- ------------------------------------------------------------------
	-- Activation function derivative
	-- ------------------------------------------------------------------
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
		return resize(1 /(1 + pInput * pInput));
	end function;

	-- ------------------------------------------------------------------
	-- Conversion from std_ulogic to neuro_real
	-- ------------------------------------------------------------------
	function to_neuro_real(pInput : std_ulogic) return neuro_real is
	begin
		if (pInput = '1') then
			return to_neuro_real(1.0);
		else
			return to_neuro_real(0.0);
		end if;
	end function;

	-- ------------------------------------------------------------------
	-- Conversion from std_ulogic_vector to neuro_real_vector
	-- ------------------------------------------------------------------
	function to_neuro_real_vector(pInput : std_ulogic_vector) return neuro_real_vector is
		variable ret : neuro_real_vector(pInput'range) := (others => cNeuroNull);
	begin
		for i in pInput'range loop
			ret(i) := to_neuro_real(pInput(i));
		end loop;
		return ret;
	end function;

	-- ------------------------------------------------------------------
	-- Conversion from neuro_real to std_ulogic
	-- ------------------------------------------------------------------
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

	-- ------------------------------------------------------------------
	-- Conversion from neuro_real_vector to std_ulogic_vector
	-- ------------------------------------------------------------------
	function to_std_ulogic_vector(pInput : neuro_real_vector) return std_ulogic_vector is
		variable ret : std_ulogic_vector(pInput'range) := (others => '0');
	begin
		for i in pInput'range loop
			ret(i) := to_std_ulogic(pInput(i));
		end loop;
		return ret;
	end function;

	-- ------------------------------------------------------------------
	-- Calculates the average of a neuro_real_vector
	-- ------------------------------------------------------------------
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

	-- ------------------------------------------------------------------
	-- Calculates the mean square error of a neuro_real_vector
	-- ------------------------------------------------------------------
	function calculate_sqr(pInput : neuro_real_vector) return neuro_real is
		variable sum : neuro_real := cNeuroNull;
		variable len : natural    := 0;
	begin
		len := pInput'length;
		for i in pInput'range loop
			sum := resize(sum + pInput(i) * pInput(i));
		end loop;
		return resize(sum / len);
	end function;

	-- ------------------------------------------------------------------
	-- Calculates the square root of a neuro_real
	-- ------------------------------------------------------------------
	function calculate_sqrt(pInput : neuro_real) return real is
	begin
		return sqrt(to_real(pInput));
	end function;

	-- ------------------------------------------------------------------
	-- Resizes a sfixed to neuro_real dimensions
	-- ------------------------------------------------------------------
	function resize(pInput : sfixed) return neuro_real is
	begin
		return resize(pInput, neuro_real'high, neuro_real'low);
	end function;

	-- ------------------------------------------------------------------
	-- Conversion from std_ulogic_vector with percentage value as
	-- unsigned integer to neuro_real
	-- ------------------------------------------------------------------
	function percentage_to_neuro_real(pInput : std_ulogic_vector) return neuro_real is
	begin
		return resize(to_integer(unsigned(pInput)) / to_neuro_real(100.0));
	end function;

	-- ------------------------------------------------------------------
	-- Conversion from neuro_real to std_ulogic_vector with percentage
	-- value as unsigned integer
	-- ------------------------------------------------------------------
	function neuro_real_to_percentage(pInput : neuro_real) return std_ulogic_vector is
		variable tmp : neuro_real := cNeuroNull;
	begin
		tmp := resize(pInput * to_neuro_real(100.0));
		return std_ulogic_vector(to_unsigned(to_shiftval(tmp(neuro_real'high downto 0)), cPercentageBitWidth));
	end function;

	-- ------------------------------------------------------------------
	-- Generate a random neuro_real
	-- ------------------------------------------------------------------
	function random_number return neuro_real is
		variable seed1, seed2 : integer := 10;
		variable rand         : real;
	begin
		uniform(seed1, seed2, rand);
		return to_neuro_real(rand);
	end function;

end package body;
