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
use std.textio.all;

entity TbNeuralNet is
end entity;

architecture Sim of TbNeuralNet is
	-- Constants
	constant Alpha                     : neuro_real := to_neuro_real(0.5);
	constant EtaBase                   : real       := 0.5;
	constant NumberInputs              : natural    := 2;
	constant NumberOutputs             : natural    := 1;
	constant NumberNeuronsHiddenLayer  : natural    := 5;
	constant cRecentAvgSmoothingFactor : real       := 0.5;

	-- Signals
	signal Clk, nRst, Start, Learn                        : std_ulogic                                    := '0';
	signal FinishedForward, FinishedBackward, FinishedAll : std_ulogic                                    := '0';
	signal Error                                          : neuro_real                                    := cNeuroNull;
	signal Eta                                            : neuro_real                                    := to_neuro_real(0.25);
	signal Inputs                                         : neuro_real_vector(NumberInputs - 1 downto 0)  := (others => cNeuroNull);
	signal Outputs                                        : neuro_real_vector(NumberOutputs - 1 downto 0) := (others => cNeuroNull);
	signal Targets                                        : neuro_real_vector(NumberOutputs - 1 downto 0) := (others => cNeuroNull);
	signal Outputs_Binary                                 : std_ulogic_vector(NumberOutputs - 1 downto 0) := (others => '0');

	-- Signals for recent average error measurement
	signal SqrtError      : real := 0.0;
	signal RecentAvgError : real := 0.0;

	-- File for writing error log
	file logFile : text is out "vhdl-sfixed-fixedeta.csv";

	-- Procedure for writing error to csv file
	procedure WriteToFile(i : in integer; RecentAvgError : in real) is
		variable logLine : line;
	begin
		write(logLine, i);
		write(logLine, ',');
		write(logLine, RecentAvgError);
		writeline(logFile, logLine);
	end procedure;
begin
	-- ------------------------------------------------------------------
	-- Net instantiation
	-- ------------------------------------------------------------------
	Net : entity work.BP_Net
		generic map(
			gLearning              => Supervised,
			gNumberInputs          => NumberInputs,
			gNumberOutputs         => NumberOutputs,
			gNumberHiddenLayers    => 1,
			gNumberNeuronsPerLayer => NumberNeuronsHiddenLayer
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

	-- ------------------------------------------------------------------
	-- Clock generator
	-- ------------------------------------------------------------------
	Clk <= not Clk after 500 ns;

	-- ------------------------------------------------------------------
	-- Error measurement
	-- ------------------------------------------------------------------
	SqrtError      <= calculate_sqrt(Error);
	RecentAvgError <= (RecentAvgError * cRecentAvgSmoothingFactor + SqrtError) /(cRecentAvgSmoothingFactor + 1.0);
	-- Eta            <= to_neuro_real(EtaBase * RecentAvgError);
	Eta            <= to_neuro_real(0.15);

	-- ------------------------------------------------------------------
	-- Stimulation process
	-- ------------------------------------------------------------------
	Stimulation : process
	begin
		wait for 1 us;
		nRst <= cnInactivated;

		for i in 0 to 199 loop
			wait for 1 us;
			Inputs  <= to_neuro_real_vector("00");
			Targets <= to_neuro_real_vector("0");
			Start   <= cActivated after 0 us, cInactivated after 1 us;
			Learn   <= cActivated after 0 us, cInactivated after 1 us;
			wait until FinishedAll = cActivated;

			wait for 1 us;
			Inputs  <= to_neuro_real_vector("01");
			Targets <= to_neuro_real_vector("1");
			Start   <= cActivated after 0 us, cInactivated after 1 us;
			Learn   <= cActivated after 0 us, cInactivated after 1 us;
			wait until FinishedAll = cActivated;

			wait for 1 us;
			Inputs  <= to_neuro_real_vector("10");
			Targets <= to_neuro_real_vector("1");
			Start   <= cActivated after 0 us, cInactivated after 1 us;
			Learn   <= cActivated after 0 us, cInactivated after 1 us;
			wait until FinishedAll = cActivated;

			wait for 1 us;
			Inputs  <= to_neuro_real_vector("11");
			Targets <= to_neuro_real_vector("0");
			Start   <= cActivated after 0 us, cInactivated after 1 us;
			Learn   <= cActivated after 0 us, cInactivated after 1 us;
			wait until FinishedAll = cActivated;
			WriteToFile(i * 4 + 4, RecentAvgError);
		end loop;

		wait;
	end process;
end architecture;
