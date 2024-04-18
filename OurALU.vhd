LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY OurALU IS
	PORT (
		CLK    : IN  STD_LOGIC;

		OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		
		Rsrc1  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rsrc2  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rdst   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- (3 = OVF) (2 = CF) (1 = NF) (0 = ZF)
		CCR    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END OurALU;

ARCHITECTURE a_OurALU OF OurALU IS

	SIGNAL Mout : STD_LOGIC_VECTOR(31 DOWNTO 0);

	BEGIN
		PROCESS (CLK)
		BEGIN
			IF rising_edge(CLK) THEN
				-- OUTPUT AND CARRY
				CASE OpCode IS

					WHEN "00001" => -- NOT
						Mout   <= not Rsrc1;
						CCR(3 DOWNTO 2) <= "00";

					WHEN "00010" => -- NEG
						Mout <= std_logic_vector(0 - signed(Rsrc1));

					WHEN "00011" => -- INC
						Mout <= std_logic_vector(signed(Rsrc1) + 1);

					WHEN "00100" => -- DEC
						Mout <= std_logic_vector(signed(Rsrc1) - 1);
						CCR(2) <= '1' WHEN (signed(Rsrc1) = 0) ELSE '0';

					WHEN "01001" or "01010" => -- ADD or ADDI
						Mout <= std_logic_vector(signed(Rsrc1) + signed(Rsrc2));

					WHEN "01011" or "01100" => -- SUB or SUBI
						Mout <= std_logic_vector(signed(Rsrc1) - signed(Rsrc2));

					WHEN "01101" => -- AND
						Mout <= Rsrc1 and Rsrc2;
						CCR(3 DOWNTO 2) <= "00";

					WHEN "01110" => -- OR
						Mout <= Rsrc1 or Rsrc2;
						CCR(3 DOWNTO 2) <= "00";

					WHEN "10000" => -- CMP
						Mout <= Rsrc1 -- No output
						CCR(3 DOWNTO 2) <= "00";

					WHEN OTHERS =>
						Mout <= Rsrc1;
						CCR(3 DOWNTO 2) <= "00";
				END CASE;
			END IF;
		END PROCESS;

		-- ZERO FLAG
		CCR(0) <= '1' WHEN (signed(Mout) = 0) ELSE '0';
		-- NEGATIVE FLAG
		CCR(1) <= '1' WHEN (signed(Mout) < 0) ELSE '0';

END a_OurALU;
