LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY registerfile IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;

		-- decode stage
		Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		Rsrc1Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

		-- write back
		WE       : IN STD_LOGIC;
		Rdst     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		RdstData : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END registerfile;

ARCHITECTURE a_registerfile OF registerfile IS

	TYPE register_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    	SIGNAL registerfile : register_type;

	BEGIN
		PROCESS (CLK, RST)
		BEGIN
			IF (RST = '1') THEN
				registerfile <= (OTHERS => (OTHERS => '0'));
			ELSIF RISING_EDGE(CLK) THEN
				Rsrc1Data <= registerfile(to_integer(unsigned(Rsrc1)));
				Rsrc2Data <= registerfile(to_integer(unsigned(Rsrc2)));
			ELSIF FALLING_EDGE(CLK) THEN
				registerfile(to_integer(unsigned(Rdst))) <= RdstData;
			END IF;
		END PROCESS;
		
END a_registerfile;