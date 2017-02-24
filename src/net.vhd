-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : This is the entity where all parts of the neural net are assembled.   |
-- |               If you use this implementation, you only need to instantiate this     |
-- |               entity in your own design.                                            |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity Net is
	generic(
		gNumberInputs          : natural := 2;
		gNumberOutputs         : natural := 1;
		gNumberHiddenLayers    : natural := 1;
		gNumberNeuronsPerLayer : natural := 5
	);
	port(
		iClk      : in  std_ulogic;
		inRst     : in  std_ulogic;
		-- Neural net inputs
		iInputs   : in  std_ulogic_vector(gNumberInputs - 1 downto 0);
		iTargets  : in  std_ulogic_vector(gNumberOutputs - 1 downto 0);
		iStart    : in  std_ulogic;
		-- Weight update inputs
		iEta      : in  std_ulogic_vector(cPercentageBitWidth - 1 downto 0);
		iAlpha    : in  std_ulogic_vector(cPercentageBitWidth - 1 downto 0);
		iLearn    : in  std_ulogic;
		-- Neural net outputs
		oOutputs  : out std_ulogic_vector(gNumberOutputs - 1 downto 0);
		oFinished : out std_ulogic;
		oError    : out neuro_real
	);
end entity;

architecture Bhv of Net is
	-- Connection signals
	signal inputs              : neuro_real_vector(gNumberInputs - 1 downto 0)                                 := (others => cNeuroNull);
	signal targets             : neuro_real_vector(gNumberOutputs - 1 downto 0)                                := (others => cNeuroNull);
	signal outputs             : neuro_real_vector(gNumberOutputs - 1 downto 0)                                := (others => cNeuroNull);
	signal Eta                 : neuro_real                                                                    := cNeuroNull;
	signal Alpha               : neuro_real                                                                    := cNeuroNull;
	signal gradientsFirstLayer : neuro_real_vector(gNumberNeuronsPerLayer - 1 downto 0)                        := (others => cNeuroNull);
	signal outputsFirstLayer   : neuro_real_vector((gNumberInputs + 1) * gNumberNeuronsPerLayer - 1 downto 0)  := (others => cNeuroNull);
	signal gradientsLastLayer  : neuro_real_vector(gNumberOutputs - 1 downto 0)                                := (others => cNeuroNull);
	signal outputsLastLayer    : neuro_real_vector((gNumberNeuronsPerLayer + 1) * gNumberOutputs - 1 downto 0) := (others => cNeuroNull);

	-- Statemachine types and signals
	type aNetState is (eIdle, eForwardPropagate, eBackPropagate, eFinished);
	type aNetRegSet is record
		State        : aNetState;
		Learn        : std_ulogic;
		TickCount    : natural;
		UpdateWeight : std_ulogic;
		AvgError     : neuro_real;
	end record;
	constant cNetRegInit : aNetRegSet := (
		State        => eIdle,
		Learn        => '0',
		TickCount    => 0,
		UpdateWeight => '0',
		AvgError     => cNeuroNull
	);
	signal NetR, NetNxR : aNetRegSet := cNetRegInit;
begin
	--------------------------------------------------------------------
	-- Conversions and output assignments
	--------------------------------------------------------------------
	inputs   <= to_neuro_real_vector(iInputs);
	targets  <= to_neuro_real_vector(iTargets);
	Eta      <= percentage_to_neuro_real(iEta);
	Alpha    <= percentage_to_neuro_real(iAlpha);
	oOutputs <= to_std_ulogic_vector(outputs);
	oError   <= NetR.AvgError;

	--------------------------------------------------------------------
	-- Layer instantiations
	--------------------------------------------------------------------
	InputLayer : entity work.InputLayer
		generic map(
			gNumberInputs    => gNumberInputs,
			gNumberNextLayer => gNumberNeuronsPerLayer
		)
		port map(
			iClk          => iClk,
			inRst         => inRst,
			iInputs       => inputs,
			iGradients    => gradientsFirstLayer,
			iEta          => Eta,
			iAlpha        => Alpha,
			iUpdateWeight => NetR.UpdateWeight,
			oOutputs      => outputsFirstLayer
		);

	HiddenLayer : entity work.HiddenLayer
		generic map(
			gNumberNeurons   => gNumberNeuronsPerLayer,
			gNumberPrevLayer => gNumberInputs,
			gNumberNextLayer => gNumberOutputs
		)
		port map(
			iClk          => iClk,
			inRst         => inRst,
			iInputs       => outputsFirstLayer,
			iGradients    => gradientsLastLayer,
			iEta          => Eta,
			iAlpha        => Alpha,
			iUpdateWeight => NetR.UpdateWeight,
			oOutputs      => outputsLastLayer,
			oGradients    => gradientsFirstLayer
		);

	OutputLayer : entity work.OutputLayer
		generic map(
			gNumberNeurons   => gNumberOutputs,
			gNumberPrevLayer => gNumberNeuronsPerLayer
		)
		port map(
			iClk       => iClk,
			inRst      => inRst,
			iInputs    => outputsLastLayer,
			iTargets   => targets,
			oOutputs   => outputs,
			oGradients => gradientsLastLayer
		);

	--------------------------------------------------------------------
	-- Register process
	--------------------------------------------------------------------
	Reg : process(iClk, inRst)
	begin
		if (inRst = cnActivated) then
			NetR <= cNetRegInit;
		elsif (iClk'event and iClk = cActivated) then
			NetR <= NetNxR;
		end if;
	end process;

	--------------------------------------------------------------------
	-- Combinational process with control
	--------------------------------------------------------------------
	Comb : process(NetR, iStart, iLearn, gradientsLastLayer)
	begin
		NetNxR           <= NetR;
		NetNxR.TickCount <= NetR.TickCount + 1;
		oFinished        <= cInactivated;

		case NetR.State is
			-- In this state, we wait until we get a start signal.
			when eIdle =>
				NetNxR.TickCount <= 0;
				if (iStart = cActivated) then
					NetNxR.Learn <= iLearn;
					NetNxR.State <= eForwardPropagate;
				end if;
			-- We wait until the neural net has processed the input,
			-- after which we either backpropagate or send a finished
			-- signal depending on iLearn.
			when eForwardPropagate =>
				-- We wait one tick per layer (Hidden + Input + Output)
				if (NetR.TickCount = gNumberHiddenLayers + 2) then
					NetNxR.TickCount <= 0;
					if (NetR.Learn = cActivated) then
						NetNxR.State <= eBackPropagate;
					else
						NetNxR.State <= eFinished;
					end if;
				end if;
			-- We wait again until the net has calculated all gradients.
			-- After that, the weights can be updated.
			when eBackPropagate =>
				if (NetR.TickCount = gNumberHiddenLayers + 2) then
					NetNxR.UpdateWeight <= cActivated;
				elsif (NetR.TickCount = gNumberHiddenLayers + 3) then
					NetNxR.UpdateWeight <= cInactivated;
					NetNxR.AvgError     <= resize(abs (calculate_rms(gradientsLastLayer)));
					NetNxR.State        <= eFinished;
				end if;
			-- A finish signal is set and the net returns to IDLE state.
			when eFinished =>
				oFinished    <= cActivated;
				NetNxR.Learn <= cInactivated;
				NetNxR.State <= eIdle;
		end case;
	end process;
end architecture;
