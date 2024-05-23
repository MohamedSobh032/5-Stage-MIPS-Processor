LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY PCount IS
	PORT (
		CLK      : IN  STD_LOGIC;
		RST      : IN  STD_LOGIC;
		ResetVal : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		INT      : IN  STD_LOGIC;
		IntptVal : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		EXCP     : IN  STD_LOGIC;
		EXCPVal  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		PAUSE    : IN  STD_LOGIC;
		JUMP     : IN  STD_LOGIC;
		JMPVAL   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		RET      : IN  STD_LOGIC;
		RETVAL   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		BRKPROT  : IN STD_LOGIC;
		NewValue : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Outdata  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END PCount;

ARCHITECTURE a_PCount OF PCount IS
	-- REGISTER --
    	SIGNAL PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- PREVENT UPDATE DURING INTERRUPT ROUTINE --
	SIGNAL PROTECTOR : STD_LOGIC;
	-- IS UPDATED DURING INTERRUPT ROUTINE --
	SIGNAL IS_UPDATED : STD_LOGIC;
	-- SAVE ANY JUMP VALUES DURING INTERRUPT ROUTINE --
	SIGNAL SAVED_VALUE : STD_LOGIC_VECTOR(31 DOWNTO 0);

	BEGIN
		PROCESS (CLK, RST, INT, EXCP, RET, JUMP, BRKPROT)
		BEGIN
			IF (RST = '1') THEN
				PC <= ResetVal;
				PROTECTOR <= '0';
				IS_UPDATED <= '0';
				SAVED_VALUE <= (OTHERS => '0');
			ELSIF (INT = '1') THEN
				PROTECTOR <= '1';
				PC <= IntptVal;
			ELSIF (EXCP = '1') THEN
				PC <= EXCPVal;
			ELSIF (RET = '1') THEN
				IF (IS_UPDATED = '1') THEN
					IS_UPDATED <= '0';
					PC <= SAVED_VALUE;
				ELSE
					PC <= RETVAL;
				END IF;
			ELSIF (JUMP = '1') THEN
				IF (PROTECTOR = '0') THEN
					PC <= JMPVAL;
				ELSE
					IS_UPDATED <= '1';
					SAVED_VALUE <= JMPVAL;
				END IF;
			ELSIF (BRKPROT = '1') THEN
				PROTECTOR <= '0';
			ELSIF rising_edge(CLK) THEN
				IF (PAUSE = '0') THEN
					PC <= NewValue;
				END IF;
			END IF;
		END PROCESS;	
		OutData <= PC;
END a_PCount;