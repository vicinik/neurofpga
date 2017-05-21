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

entity BP_Net is
	generic(
		gLearning              : tLearning := Supervised;
		gNumberInputs          : natural   := 2;
		gNumberOutputs         : natural   := 1;
		gNumberHiddenLayers    : natural   := 1;
		gNumberNeuronsPerLayer : natural   := 5
	);
	port(
		iClk              : in  std_ulogic;
		inRst             : in  std_ulogic;
		-- Neural net inputs
		iInputs           : in  neuro_real_vector(gNumberInputs - 1 downto 0);
		iTargets          : in  neuro_real_vector(gNumberOutputs - 1 downto 0);
		iStart            : in  std_ulogic;
		-- Weight update inputs
		iEta              : in  neuro_real;
		iAlpha            : in  neuro_real;
		iLearn            : in  std_ulogic;
		-- Neural net outputs
		oOutputs          : out neuro_real_vector(gNumberOutputs - 1 downto 0);
		oFinishedForward  : out std_ulogic;
		oFinishedBackward : out std_ulogic;
		oFinishedAll      : out std_ulogic;
		oError            : out neuro_real
	);
end entity;

architecture Bhv of BP_Net is
	-- Connection types
	type aHiddenLayerOutputArray is array (natural range <>) of neuro_real_vector((gNumberNeuronsPerLayer + 1) * gNumberNeuronsPerLayer - 1 downto 0);
	type aHiddenLayerGradientArray is array (natural range <>) of neuro_real_vector(gNumberNeuronsPerLayer - 1 downto 0);

	-- Connection signals
	signal gradientsFirstLayer      : neuro_real_vector(gNumberNeuronsPerLayer - 1 downto 0)                        := (others => cNeuroNull);
	signal outputsFirstLayer        : neuro_real_vector((gNumberInputs + 1) * gNumberNeuronsPerLayer - 1 downto 0)  := (others => cNeuroNull);
	signal gradientsLastLayer       : neuro_real_vector(gNumberOutputs - 1 downto 0)                                := (others => cNeuroNull);
	signal outputsLastLayer         : neuro_real_vector((gNumberNeuronsPerLayer + 1) * gNumberOutputs - 1 downto 0) := (others => cNeuroNull);
	signal dowsLastLayer            : neuro_real_vector(gNumberOutputs - 1 downto 0)                                := (others => cNeuroNull);
	signal hiddenLayerOutputArray   : aHiddenLayerOutputArray(gNumberHiddenLayers - 2 downto 0)                     := (others => (others => cNeuroNull));
	signal hiddenLayerGradientArray : aHiddenLayerGradientArray(gNumberHiddenLayers - 2 downto 0)                   := (others => (others => cNeuroNull));

	-- Statemachine types and signals
	type aNetState is (eIdle, eForwardPropagate, eBackPropagate, eFinished);
	type aNetRegSet is record
		State        : aNetState;
		Learn        : std_ulogic;
		TickCount    : natural;
		UpdateWeight : std_ulogic;
		SqrError     : neuro_real;
		OutError     : neuro_real;
	end record;
	constant cNetRegInit : aNetRegSet := (
		State        => eIdle,
		Learn        => '0',
		TickCount    => 0,
		UpdateWeight => '0',
		SqrError     => cNeuroNull,
		OutError     => cNeuroNull
	);
	signal NetR, NetNxR  : aNetRegSet := cNetRegInit;
begin
	-- ------------------------------------------------------------------
	-- Output assignments
	-- ------------------------------------------------------------------
	oError <= NetR.SqrError;

	-- ------------------------------------------------------------------
	-- Layer instantiations
	-- ------------------------------------------------------------------
	InputLayer : entity work.BP_InputLayer
		generic map(
			gNumberInputs    => gNumberInputs,
			gNumberNextLayer => gNumberNeuronsPerLayer
		)
		port map(
			iClk          => iClk,
			inRst         => inRst,
			iInputs       => iInputs,
			iGradients    => gradientsFirstLayer,
			iEta          => iEta,
			iAlpha        => iAlpha,
			iUpdateWeight => NetR.UpdateWeight,
			oOutputs      => outputsFirstLayer
		);

	HiddenLayerGen : for i in 0 to gNumberHiddenLayers - 1 generate
		OneLayer : if (gNumberHiddenLayers = 1) generate
			HiddenLayer0 : entity work.BP_HiddenLayer
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
					iEta          => iEta,
					iAlpha        => iAlpha,
					iUpdateWeight => NetR.UpdateWeight,
					oOutputs      => outputsLastLayer,
					oGradients    => gradientsFirstLayer
				);
		end generate OneLayer;

		MoreLayersFirst : if (gNumberHiddenLayers > 1 and i = 0) generate
			HiddenLayer1 : entity work.BP_HiddenLayer
				generic map(
					gNumberNeurons   => gNumberNeuronsPerLayer,
					gNumberPrevLayer => gNumberInputs,
					gNumberNextLayer => gNumberNeuronsPerLayer
				)
				port map(
					iClk          => iClk,
					inRst         => inRst,
					iInputs       => outputsFirstLayer,
					iGradients    => hiddenLayerGradientArray(i),
					iEta          => iEta,
					iAlpha        => iAlpha,
					iUpdateWeight => NetR.UpdateWeight,
					oOutputs      => hiddenLayerOutputArray(i),
					oGradients    => gradientsFirstLayer
				);
		end generate MoreLayersFirst;

		MoreLayersBetween : if (gNumberHiddenLayers > 1 and i > 0 and i < gNumberHiddenLayers - 1) generate
			HiddenLayer2 : entity work.BP_HiddenLayer
				generic map(
					gNumberNeurons   => gNumberNeuronsPerLayer,
					gNumberPrevLayer => gNumberNeuronsPerLayer,
					gNumberNextLayer => gNumberNeuronsPerLayer
				)
				port map(
					iClk          => iClk,
					inRst         => inRst,
					iInputs       => hiddenLayerOutputArray(i - 1),
					iGradients    => hiddenLayerGradientArray(i),
					iEta          => iEta,
					iAlpha        => iAlpha,
					iUpdateWeight => NetR.UpdateWeight,
					oOutputs      => hiddenLayerOutputArray(i),
					oGradients    => hiddenLayerGradientArray(i - 1)
				);
		end generate MoreLayersBetween;

		MoreLayersLast : if (gNumberHiddenLayers > 1 and i = gNumberHiddenLayers - 1) generate
			HiddenLayer3 : entity work.BP_HiddenLayer
				generic map(
					gNumberNeurons   => gNumberNeuronsPerLayer,
					gNumberPrevLayer => gNumberNeuronsPerLayer,
					gNumberNextLayer => gNumberOutputs
				)
				port map(
					iClk          => iClk,
					inRst         => inRst,
					iInputs       => hiddenLayerOutputArray(i - 1),
					iGradients    => gradientsLastLayer,
					iEta          => iEta,
					iAlpha        => iAlpha,
					iUpdateWeight => NetR.UpdateWeight,
					oOutputs      => outputsLastLayer,
					oGradients    => hiddenLayerGradientArray(i - 1)
				);
		end generate MoreLayersLast;

	end generate HiddenLayerGen;

	OutputLayer : entity work.BP_OutputLayer
		generic map(
			gLearning        => gLearning,
			gNumberNeurons   => gNumberOutputs,
			gNumberPrevLayer => gNumberNeuronsPerLayer
		)
		port map(
			iClk       => iClk,
			inRst      => inRst,
			iInputs    => outputsLastLayer,
			iTargets   => iTargets,
			oOutputs   => oOutputs,
			oGradients => gradientsLastLayer,
			oDows      => dowsLastLayer
		);

	-- ------------------------------------------------------------------
	-- Register process
	-- ------------------------------------------------------------------
	Reg : process(iClk, inRst)
	begin
		if (inRst = cnActivated) then
			NetR <= cNetRegInit;
		elsif (iClk'event and iClk = cActivated) then
			NetR <= NetNxR;
		end if;
	end process;

	-- ------------------------------------------------------------------
	-- Combinational process with control
	-- ------------------------------------------------------------------
	Comb : process(NetR, iStart, iLearn, dowsLastLayer)
	begin
		NetNxR            <= NetR;
		NetNxR.TickCount  <= NetR.TickCount + 1;
		oFinishedForward  <= cInactivated;
		oFinishedBackward <= cInactivated;
		oFinishedAll      <= cInactivated;

		case NetR.State is
			-- In this state, we wait until we get a start signal.
			when eIdle =>
				NetNxR.TickCount <= 0;
				if (iStart = cActivated) then
					NetNxR.Learn <= iLearn;
					NetNxR.State <= eForwardPropagate;
				end if;
			-- We wait until the neural net has processed the input,
			-- after which we either backpropagate or directly go to
			-- finished state depending on iLearn.
			when eForwardPropagate =>
				-- We wait one tick per layer
				if (NetR.TickCount = gNumberHiddenLayers + 2) then
					NetNxR.TickCount <= 0;
					oFinishedForward <= cActivated;
					if (NetR.Learn = cActivated) then
						NetNxR.SqrError <= calculate_sqr(dowsLastLayer);
						NetNxR.State    <= eBackPropagate;
					else
						NetNxR.State <= eFinished;
					end if;
				end if;
			-- We wait again until the net has calculated all gradients.
			-- After that, the weights can be updated.
			when eBackPropagate =>
				if (NetR.TickCount = gNumberHiddenLayers + 2) then
					oFinishedBackward   <= cActivated;
					NetNxR.UpdateWeight <= cActivated;
				elsif (NetR.TickCount = gNumberHiddenLayers + 3) then
					NetNxR.UpdateWeight <= cInactivated;
					NetNxR.State        <= eFinished;
				end if;
			-- A finish signal is set and the net returns to IDLE state.
			when eFinished =>
				oFinishedAll    <= cActivated;
				NetNxR.OutError <= NetR.SqrError;
				NetNxR.Learn    <= cInactivated;
				NetNxR.State    <= eIdle;
		end case;
	end process;
end architecture;
