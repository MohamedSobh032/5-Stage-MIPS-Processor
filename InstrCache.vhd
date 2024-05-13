LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY InstrCache IS
	PORT (
		CLK         : IN STD_LOGIC;
		Addr        : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    		Instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    	);
END InstrCache;

ARCHITECTURE a_InstrCache OF InstrCache IS

	TYPE ic_type IS ARRAY(0 TO 4095) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    	SIGNAL instructioncache : ic_type;

	BEGIN
		PROCESS (CLK)
		BEGIN
			Instruction <= instructioncache(to_integer(unsigned(Addr)));
		END PROCESS;
END a_InstrCache;