LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ALU_dec IS
	PORT (
		Rsrc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rdst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Carry : OUT STD_LOGIC
	);
END ALU_dec;

ARCHITECTURE a_ALU_dec OF ALU_dec IS
	
	BEGIN
		Rdst <= std_logic_vector(signed(Rsrc) - 1);
       		Carry <= '1' WHEN (signed(Rsrc) = 0) ELSE '0';
END a_ALU_dec;
