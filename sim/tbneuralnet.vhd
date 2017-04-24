-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : Testbench for the neural net design.                                  |
-- |                                                                                     |
-- |                                                                                     |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity TbNeuralNet is
end entity;

architecture Sim of TbNeuralNet is
	-- Constants
	constant Eta                       : neuro_real := to_neuro_real(0.15);
	constant Alpha                     : neuro_real := to_neuro_real(0.5);
	constant NumberInputs              : natural    := 2;
	constant NumberOutputs             : natural    := 1;
	constant cRecentAvgSmoothingFactor : real       := 0.5;

	-- Signals
	signal Clk, nRst, Start, Learn                        : std_ulogic                                    := '0';
	signal FinishedForward, FinishedBackward, FinishedAll : std_ulogic                                    := '0';
	signal Error                                          : neuro_real                                    := cNeuroNull;
	signal Inputs                                         : neuro_real_vector(NumberInputs - 1 downto 0)  := (others => cNeuroNull);
	signal Outputs                                        : neuro_real_vector(NumberOutputs - 1 downto 0) := (others => cNeuroNull);
	signal Targets                                        : neuro_real_vector(NumberOutputs - 1 downto 0) := (others => cNeuroNull);
	signal Outputs_Binary                                 : std_ulogic_vector(NumberOutputs - 1 downto 0) := (others => '0');

	-- Signals for recent average error measurement
	signal SqrtError      : real := 0.0;
	signal RecentAvgError : real := 0.0;
begin
	--------------------------------------------------------------------
	-- Net instantiation
	--------------------------------------------------------------------
	Net : entity work.BP_Net
		generic map(
			gLearning              => Supervised,
			gNumberInputs          => NumberInputs,
			gNumberOutputs         => NumberOutputs,
			gNumberHiddenLayers    => 1,
			gNumberNeuronsPerLayer => 5
		)
		port map(
			iClk              => Clk,
			inRst             => nRst,
			iInputs           => Inputs,
			iTargets          => Targets,
			iStart            => Start,
			iEta              => Eta,
			iAlpha            => Alpha,
			iLearn            => Learn,
			oOutputs          => Outputs,
			oFinishedForward  => FinishedForward,
			oFinishedBackward => FinishedBackward,
			oFinishedAll      => FinishedAll,
			oError            => Error
		);
	Outputs_Binary <= to_std_ulogic_vector(Outputs);

	--------------------------------------------------------------------
	-- Clock generator
	--------------------------------------------------------------------
	Clk <= not Clk after 500 ns;

	--------------------------------------------------------------------
	-- Error measurement
	--------------------------------------------------------------------
	SqrtError <= sqrt(to_real(Error));
	RecentAvgErrorCalc : process(FinishedBackward)
	begin
		if (FinishedBackward'event and FinishedBackward = cActivated) then
			RecentAvgError <= (RecentAvgError * cRecentAvgSmoothingFactor + SqrtError) / (cRecentAvgSmoothingFactor + 1.0);
		end if;
	end process;

	--------------------------------------------------------------------
	-- Stimulation process
	--------------------------------------------------------------------
	Stimulation : process
	begin
		wait for 1 us;
		nRst <= cnInactivated;

		for i in 0 to 100 loop
			wait for 1 us;
			Inputs  <= to_neuro_real_vector("00");
			Targets <= to_neuro_real_vector("0");
			Start   <= cActivated after 0 us, cInactivated after 1 us;
			Learn   <= cActivated after 0 us, cInactivated after 1 us;
			wait until FinishedAll = cActivated;

			wait for 1 us;
			Inputs  <= to_neuro_real_vector("01");
			Targets <= to_neuro_real_vector("0");
			Start   <= cActivated after 0 us, cInactivated after 1 us;
			Learn   <= cActivated after 0 us, cInactivated after 1 us;
			wait until FinishedAll = cActivated;

			wait for 1 us;
			Inputs  <= to_neuro_real_vector("10");
			Targets <= to_neuro_real_vector("0");
			Start   <= cActivated after 0 us, cInactivated after 1 us;
			Learn   <= cActivated after 0 us, cInactivated after 1 us;
			wait until FinishedAll = cActivated;

			wait for 1 us;
			Inputs  <= to_neuro_real_vector("11");
			Targets <= to_neuro_real_vector("1");
			Start   <= cActivated after 0 us, cInactivated after 1 us;
			Learn   <= cActivated after 0 us, cInactivated after 1 us;
			wait until FinishedAll = cActivated;
		end loop;

		wait;
	end process;
end architecture;