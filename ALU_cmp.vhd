LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ALU_cmp IS
	PORT (
		Rsrc1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rsrc2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rdst  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Carry : OUT STD_LOGIC
	);
END ALU_cmp;

ARCHITECTURE a_ALU_cmp OF ALU_cmp IS	
	BEGIN
		Rdst <= std_logic_vector(signed(Rsrc1) - signed(Rsrc2));
		Carry <= '1' WHEN signed(Rsrc1) < signed(Rsrc2) ELSE '0';
END a_ALU_cmp;