LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ExceptionUnit IS
	PORT (
		Address      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		MEM_READ     : IN STD_LOGIC;
		MEM_WRITE    : IN STD_LOGIC;
		ExceptionOut : OUT STD_LOGIC
    	);
END ExceptionUnit;

ARCHITECTURE a_ExceptionUnit OF ExceptionUnit IS

	CONSTANT MAX_ADDRESS : unsigned(31 DOWNTO 0) := x"00000FFF";
	SIGNAL MEMORY_USE : STD_LOGIC;
	BEGIN
		MEMORY_USE <= MEM_READ OR MEM_WRITE;

		ExceptionOut <= '1' WHEN ( (to_integer(unsigned(Address)) > to_integer(MAX_ADDRESS)) AND MEMORY_USE = '1')
		ELSE '0';
END a_ExceptionUnit;