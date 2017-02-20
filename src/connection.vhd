library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use work.Global.all;
use work.NeuroFPGA.all;

entity Connection is
	port (
		iClk	: in std_ulogic;
		inRst	: in std_ulogic;
		-- Connection inputs
		iInput	: in neuro_real;
		iGradient	: in neuro_real;
		-- Weight update inputs
		iEta	: in neuro_real;
		iAlpha	: in neuro_real;
		iUpdateWeight	: in std_ulogic;
		-- Connection outputs
		oOutput	: out neuro_real;
		oDow	: out neuro_real
	)
end entity;

architecture Bhv of Connection is
begin
	
end architecture;