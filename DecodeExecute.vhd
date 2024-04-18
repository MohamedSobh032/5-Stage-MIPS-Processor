LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DecodeExecute IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;

		InData_ConSignal  : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		OutData_ConSignal : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);

		InData_ALUopCode  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		OutData_ALUopCode : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

		InData_Rsrc1Data  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_Rsrc1Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

		InData_Rsrc2Data  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

		InData_Immediate  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		OutData_Immediate : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

		InData_RdstAddr  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutData_RdstAddr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END DecodeExecute;

ARCHITECTURE a_DecodeExecute OF DecodeExecute IS
    	SIGNAL ConSignal : STD_LOGIC_VECTOR(14 DOWNTO 0);
	SIGNAL ALUopCode : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Rsrc1Data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Immediate : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL RdstAddr  : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
		PROCESS (CLK, RST)
		BEGIN
			IF (RST = '1') THEN
				ConSignal <= (OTHERS => '0');
				ALUopCode <= (OTHERS => '0');
				Rsrc1Data <= (OTHERS => '0');
				Rsrc2Data <= (OTHERS => '0');
				Immediate <= (OTHERS => '0');
				RdstAddr  <= (OTHERS => '0');
			ELSIF falling_edge(CLK) THEN
				ConSignal <= InData_ConSignal;
				ALUopCode <= InData_ALUopCode;
				Rsrc1Data <= InData_Rsrc1Data;
				Rsrc2Data <= InData_Rsrc2Data;
				Immediate <= InData_Immediate;
				RdstAddr  <= InData_RdstAddr;
			END IF;
		END PROCESS;	
		OutData_ConSignal <= ConSignal;
		OutData_ALUopCode <= ALUopCode;
		OutData_Rsrc1Data <= Rsrc1Data;
		OutData_Rsrc2Data <= Rsrc2Data;
		OutData_Immediate <= Immediate;
		OutData_RdstAddr  <= RdstAddr;
END a_DecodeExecute;