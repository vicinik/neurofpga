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

entity MLP_Connection is
	port(
		-- Connection inputs
		iInput        : in  neuro_real;
		iWeight		  : in  neuro_real;
		-- Connection outputs
		oOutput       : out neuro_real
	);
end entity;

architecture Bhv of MLP_Connection is
begin
	-- ------------------------------------------------------------------
	-- Output port assignments
	-- ------------------------------------------------------------------
	oOutput <= resize(iInput * iWeight);
end architecture;
