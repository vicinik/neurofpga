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

entity MLP_Net is
	generic(
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
		iInputWeights	  : in  neuro_real_vector((gNumberInputs + 1) * gNumberNeuronsPerLayer - 1 downto 0);
		iHiddenWeights	  : in  neuro_real_vector((gNumberHiddenLayers - 1) * (gNumberNeuronsPerLayer + 1) * gNumberNeuronsPerLayer - 1 downto 0);
		iOutputWeights	  : in  neuro_real_vector((gNumberNeuronsPerLayer + 1) * gNumberOutputs - 1 downto 0);
		iStart            : in  std_ulogic;
		-- Neural net outputs
		oOutputs          : out neuro_real_vector(gNumberOutputs - 1 downto 0);
		oFinishedAll	  : out std_ulogic
	);
end entity;

architecture Bhv of MLP_Net is
	-- Connection types
	type aHiddenLayerOutputArray is array (natural range <>) of neuro_real_vector((gNumberNeuronsPerLayer + 1) * gNumberNeuronsPerLayer - 1 downto 0);

	-- Connection signals
	signal outputsFirstLayer        : neuro_real_vector((gNumberInputs + 1) * gNumberNeuronsPerLayer - 1 downto 0)  := (others => cNeuroNull);
	signal outputsLastLayer         : neuro_real_vector((gNumberNeuronsPerLayer + 1) * gNumberOutputs - 1 downto 0) := (others => cNeuroNull);
	signal hiddenLayerOutputArray   : aHiddenLayerOutputArray(gNumberHiddenLayers - 2 downto 0)                     := (others => (others => cNeuroNull));

	-- Statemachine types and signals
	type aNetState is (eIdle, eForwardPropagate, eFinished);
	type aNetRegSet is record
		State        : aNetState;
		TickCount    : natural;
	end record;
	constant cNetRegInit : aNetRegSet := (
		State        => eIdle,
		TickCount    => 0
	);
	signal NetR, NetNxR : aNetRegSet := cNetRegInit;
begin
	--------------------------------------------------------------------
	-- Layer instantiations
	--------------------------------------------------------------------
	InputLayer : entity work.MLP_InputLayer
		generic map(
			gNumberInputs    => gNumberInputs,
			gNumberNextLayer => gNumberNeuronsPerLayer
		)
		port map(
			iClk          => iClk,
			inRst         => inRst,
			iInputs       => iInputs,
			iWeights	  => iInputWeights,
			oOutputs      => outputsFirstLayer
		);

	HiddenLayerGen : for i in 0 to gNumberHiddenLayers - 1 generate
		OneLayer : if (gNumberHiddenLayers = 1) generate
			HiddenLayer0 : entity work.MLP_HiddenLayer
				generic map(
					gNumberNeurons   => gNumberNeuronsPerLayer,
					gNumberPrevLayer => gNumberInputs,
					gNumberNextLayer => gNumberOutputs
				)
				port map(
					iClk          => iClk,
					inRst         => inRst,
					iInputs       => outputsFirstLayer,
					iWeights	  => iOutputWeights,
					oOutputs      => outputsLastLayer
				);
		end generate OneLayer;

		MoreLayersFirst : if (gNumberHiddenLayers > 1 and i = 0) generate
			HiddenLayer1 : entity work.MLP_HiddenLayer
				generic map(
					gNumberNeurons   => gNumberNeuronsPerLayer,
					gNumberPrevLayer => gNumberInputs,
					gNumberNextLayer => gNumberNeuronsPerLayer
				)
				port map(
					iClk          => iClk,
					inRst         => inRst,
					iInputs       => outputsFirstLayer,
					iWeights	  => iHiddenWeights((gNumberNeuronsPerLayer + 1) * gNumberNeuronsPerLayer - 1 downto 0),
					oOutputs      => hiddenLayerOutputArray(i)
				);
		end generate MoreLayersFirst;

		MoreLayersBetween : if (gNumberHiddenLayers > 1 and i > 0 and i < gNumberHiddenLayers - 1) generate
			HiddenLayer2 : entity work.MLP_HiddenLayer
				generic map(
					gNumberNeurons   => gNumberNeuronsPerLayer,
					gNumberPrevLayer => gNumberNeuronsPerLayer,
					gNumberNextLayer => gNumberNeuronsPerLayer
				)
				port map(
					iClk          => iClk,
					inRst         => inRst,
					iInputs       => hiddenLayerOutputArray(i - 1),
					iWeights	  => iHiddenWeights((i + 1) * (gNumberNeuronsPerLayer + 1) * gNumberNeuronsPerLayer - 1 downto i * (gNumberNeuronsPerLayer + 1) * gNumberNeuronsPerLayer),
					oOutputs      => hiddenLayerOutputArray(i)
				);
		end generate MoreLayersBetween;

		MoreLayersLast : if (gNumberHiddenLayers > 1 and i = gNumberHiddenLayers - 1) generate
			HiddenLayer3 : entity work.MLP_HiddenLayer
				generic map(
					gNumberNeurons   => gNumberNeuronsPerLayer,
					gNumberPrevLayer => gNumberNeuronsPerLayer,
					gNumberNextLayer => gNumberOutputs
				)
				port map(
					iClk          => iClk,
					inRst         => inRst,
					iInputs       => hiddenLayerOutputArray(i - 1),
					iWeights	  => iOutputWeights,
					oOutputs      => outputsLastLayer
				);
		end generate MoreLayersLast;

	end generate HiddenLayerGen;

	OutputLayer : entity work.MLP_OutputLayer
		generic map(
			gNumberNeurons   => gNumberOutputs,
			gNumberPrevLayer => gNumberNeuronsPerLayer
		)
		port map(
			iClk       => iClk,
			inRst      => inRst,
			iInputs    => outputsLastLayer,
			oOutputs   => oOutputs
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
	Comb : process(NetR, iStart)
	begin
		NetNxR            <= NetR;
		NetNxR.TickCount  <= NetR.TickCount + 1;
		oFinishedAll	  <= cInactivated;

		case NetR.State is
			-- In this state, we wait until we get a start signal.
			when eIdle =>
				NetNxR.TickCount <= 0;
				if (iStart = cActivated) then
					NetNxR.State <= eForwardPropagate;
				end if;
			-- We wait until the neural net has processed the input
			when eForwardPropagate =>
				-- We wait one tick per layer
				if (NetR.TickCount = gNumberHiddenLayers) then
					NetNxR.State <= eFinished;
				end if;
			-- A finish signal is set and the net returns to IDLE state.
			when eFinished =>
				oFinishedAll <= cActivated;
				NetNxR.State <= eIdle;
		end case;
	end process;
end architecture;
