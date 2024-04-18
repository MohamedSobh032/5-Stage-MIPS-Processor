LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY ControlUnit IS
	PORT (
		---------------- INSTRUCTION OPCODE ----------------
		INSTRUCTION : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

		---------------- CONTROL SIGNALS ----------------
		-- WRITE BACK 1 --> 0
		-- WRITE BACK 2 --> 1
		-- Z/N F	--> 2
		-- C/OV F       --> 3
		-- MemRead	--> 4
		-- MemWrite	--> 5
		-- FREE		--> 6
		-- PROTECT	--> 7
		-- IMMEDIATE    --> 8
		-- BRANCH	--> 9
		-- BRANCH ZERO 	--> 10
		-- SP INCREMENT --> 11
		-- SP DECREMENT --> 12
		-- OUTPUT PORT  --> 13
		-- INPUT PORT   --> 14
		CONTROL_SIGNALS : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);

		---------------- ALU OPCODE ----------------
		-- NOT  --> 0001
		-- NEG  --> 0010
		-- INC  --> 0011
		-- DEC  --> 0100
		-- ADD  --> 0101
		-- ADDI --> 0101
		-- SUB  --> 0110
		-- SUBI --> 0110
		-- AND  --> 0111
		-- OR   --> 1000
		-- XOR  --> 1001
		-- CMP  --> 0110
		-- LDD  --> 0101
		-- STD  --> 0101
		ALU_OPCODE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE a_ControlUnit OF ControlUnit IS
	BEGIN
		---- ALU OPCODE SIGNAL SELECTION ----
		WITH INSTRUCTION SELECT
			ALU_OPCODE <=
				"0001" WHEN "00001", -- NOT
				"0010" WHEN "00010", -- NEG
				"0011" WHEN "00011", -- INC
				"0100" WHEN "00100", -- DEC
				"0101" WHEN "01001", -- ADD
				"0101" WHEN "01010", -- ADDI
				"0110" WHEN "01011", -- SUB
				"0110" WHEN "01100", -- SUBI
				"0111" WHEN "01101", -- AND
				"1000" WHEN "01110", -- OR
				"1001" WHEN "01111", -- XOR
				"0110" WHEN "10000", -- CMP
				"0101" WHEN "10100", -- LDD
				"0101" WHEN "10101", -- STD
				"0000" WHEN OTHERS;

		---- CONTROL SIGNAL SELECTION ----
		WITH INSTRUCTION SELECT
			CONTROL_SIGNALS <=
				"000000000000000" WHEN "00000",	-- NOP
				"000000000000101" WHEN "00001",	-- NOT
				"000000000001101" WHEN "00010",	-- NEG
				"000000000001101" WHEN "00011",	-- INC
				"000000000001101" WHEN "00100",	-- DEC
				"010000000000000" WHEN "00101",	-- OUT
				"100000000000001" WHEN "00110",	-- IN
				"000000000000001" WHEN "00111",	-- MOV
				"000000000000011" WHEN "01000",	-- SWAP
				"000000000001101" WHEN "01001",	-- ADD
				"000000100001101" WHEN "01010",	-- ADDI
				"000000000001101" WHEN "01011",	-- SUB
				"000000100001101" WHEN "01100",	-- SUBI
				"000000000000101" WHEN "01101",	-- AND
				"000000000000101" WHEN "01110",	-- OR
				"000000000000101" WHEN "01111",	-- XOR
				"000000000000100" WHEN "10000",	-- CMP
				"001000000100000" WHEN "10001",	-- PUSH
				"000100000010001" WHEN "10010",	-- POP
				"000000100000001" WHEN "10011",	-- LDM
				"000000100010001" WHEN "10100",	-- LDD
				"000000100100000" WHEN "10101",	-- STD
				"000000010000000" WHEN "10110",	-- PROTECT
				"000000001000000" WHEN "10111",	-- FREE
				"000010000000000" WHEN "11000",	-- JZ
				"000001000000000" WHEN "11001",	-- JMP
				"001001000100000" WHEN "11010",	-- CALL
				"000101000010000" WHEN "11011",	-- RET
				"000101000010000" WHEN "11100",	-- RTI
				(OTHERS => '0') WHEN OTHERS;

END a_ControlUnit;