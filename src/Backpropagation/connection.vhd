-- +-------------------------------------------------------------------------------------+
-- | Author      : Nik Haminger                                                          |
-- | Description : Connection between the different layer neurons. Both previous layer   |
-- |               neuron's output and next layer neuron's gradient are weighted. The    |
-- |               weight update mechanism is implemented in this entity as well.        |
-- +-------------------------------------------------------------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity BP_Connection is
	generic(
		gInitWeight : neuro_real
	);
	port(
		iClk          : in  std_ulogic;
		inRst         : in  std_ulogic;
		-- Connection inputs
		iInput        : in  neuro_real;
		iGradient     : in  neuro_real;
		-- Weight update inputs
		iEta          : in  neuro_real;
		iAlpha        : in  neuro_real;
		iUpdateWeight : in  std_ulogic;
		-- Connection outputs
		oOutput       : out neuro_real;
		oDow          : out neuro_real
	);
end entity;

architecture Bhv of BP_Connection is
	signal weightNxR                    : neuro_real := cNeuroNull;
	signal deltaWeightR, deltaWeightNxR : neuro_real := cNeuroNull;
	signal weightR                      : neuro_real := gInitWeight;
begin
	-- ------------------------------------------------------------------
	-- Register process
	-- ------------------------------------------------------------------
	Reg : process(iClk, inRst)
	begin
		if (inRst = cnActivated) then
			deltaWeightR <= cNeuroNull;
			weightR      <= gInitWeight;
		elsif (iClk'event and iClk = cActivated) then
			if (iUpdateWeight = cActivated) then
				weightR      <= weightNxR;
				deltaWeightR <= deltaWeightNxR;
			end if;
		end if;
	end process;

	-- ------------------------------------------------------------------
	-- Weight update process
	-- ------------------------------------------------------------------
	WeightUpdate : process(weightR, deltaWeightR, iInput, iGradient, iEta, iAlpha)
		variable newDeltaWeight : neuro_real := cNeuroNull;
	begin
		weightNxR      <= weightR;
		deltaWeightNxR <= deltaWeightR;

		-- The new delta-weight is calculated
		if (iInput > to_neuro_real(-2.0)) then
			newDeltaWeight := resize(iEta * iInput * iGradient + iAlpha * deltaWeightR);
			-- newDeltaWeight := resize(iEta * iInput * iGradient);
			deltaWeightNxR <= newDeltaWeight;
			weightNxR      <= resize(weightR + newDeltaWeight);
		end if;
	end process;

	-- ------------------------------------------------------------------
	-- Output port assignments
	-- ------------------------------------------------------------------
	oOutput <= resize(iInput * weightR);
	oDow    <= resize(iGradient * weightR);
end architecture;
