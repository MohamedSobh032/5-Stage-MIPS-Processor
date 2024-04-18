LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FetchControl IS
	PORT (
		CurrentPC    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		CurrentInstr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		NewPc        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END FetchControl;

ARCHITECTURE a_FetchControl OF FetchControl IS
	
	SIGNAL PC_ADD_ONE : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_ADD_TWO : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SELECTOR : STD_LOGIC;

	BEGIN
		PC_ADD_ONE <= std_logic_vector(unsigned(CurrentPc) + 1);
		PC_ADD_TWO <= std_logic_vector(unsigned(CurrentPc) + 2);

		WITH CurrentInstr SELECT
			SELECTOR <=
				'1' WHEN "01010", -- ADDI
				'1' WHEN "01100", -- SUBI
				'1' WHEN "10011", -- LDM
				'1' WHEN "10100", -- LDD
				'1' WHEN "10101", -- STD
				'0' WHEN OTHERS;
		-- UPDATE PC
		NewPc <= PC_ADD_ONE WHEN SELECTOR = '0' ELSE PC_ADD_TWO;

END a_FetchControl;