LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MIPS_Processor IS
	PORT (
		CLK     : IN  STD_LOGIC;
		RST     : IN  STD_LOGIC;
		INT     : IN  STD_LOGIC;
		EXCP    : OUT STD_LOGIC;
		INPORT  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OUTPORT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R0      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R1      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R2      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R3      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R4      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R5      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R6      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R7      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		FLAGS   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END MIPS_Processor;

ARCHITECTURE a_MIPS_Processor OF MIPS_Processor IS
	-- SIDE COMPONENTS --
	COMPONENT SignExtender IS
		PORT (
			input_16  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        	   	output_32 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	-- MAIN COMPONENTS -- 
	COMPONENT PCount IS
		PORT (
			CLK      : IN  STD_LOGIC;
			RST      : IN  STD_LOGIC;
			INT      : IN  STD_LOGIC;
			EXCP     : IN  STD_LOGIC;
			PAUSE    : IN  STD_LOGIC;
			RET      : IN  STD_LOGIC;
			RETVal   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			ResetVal : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			IntptVal : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			EXCPVal  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			NewValue : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			Outdata  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT InstrCache IS
		PORT (
			CLK          : IN  STD_LOGIC;
			Addr         : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
			ResetAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			IntptAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

			ExcptAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    			Instruction  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT FetchDecode IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			FLUSH : IN STD_LOGIC;
			PAUSE : IN STD_LOGIC;
			InData_Instruction  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			OutData_Instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			InData_NextPC  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_NextPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_CurrentPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_CurrentPC :OUT STD_LOGIC_VECTOR(31 DOWNTO 0)	
		);
	END COMPONENT;
	COMPONENT registerfile IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc1Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			WE1       : IN STD_LOGIC;
			Rdst1     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			RdstData1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			WE2       : IN STD_LOGIC;
			Rdst2     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			RdstData2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			R0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R5 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R6 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R7 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT ControlUnit IS
		PORT (
			INSTRUCTION : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			CONTROL_SIGNALS : OUT STD_LOGIC_VECTOR(21 DOWNTO 0);
			ALU_OPCODE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT StalledForwardUnit IS
		PORT (
			-- IS STALLED?
			STALLED                : IN STD_LOGIC;
			-- CURRENT ADDRESSES IN THE EXECUTE --
			Rsrc1Addr_DE           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc2Addr_DE           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			-- ADDRESSES_WRITEBACK --
			Rdst1Addr_WB           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst2Addr_WB           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			-- ADDRESSES DEPENDENCIES --
			Rdst1WB_WB             : IN STD_LOGIC;
			Rdst2WB_WB             : IN STD_LOGIC;
			-- TAKE WHO
			FORCE_UPDATE_Rsrc1     : OUT STD_LOGIC;
			FORCE_UPDATE_Rsrc2     : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT DecodeExecute IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			FLUSH : IN STD_LOGIC;
			PAUSE : IN STD_LOGIC;
			FORCE_INSERT_BOTH  : IN STD_LOGIC;
			FORCE_INSERT_Rsrc1 : IN STD_LOGIC;
			FORCE_INSERT_Rsrc2 : IN STD_LOGIC;
			FORCE_INPUT_Rsrc1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			FORCE_INPUT_Rsrc2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_NextPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_NextPC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_ConSignal  : IN STD_LOGIC_VECTOR(21 DOWNTO 0);
			OutData_ConSignal : OUT STD_LOGIC_VECTOR(21 DOWNTO 0);
			InData_ALUopCode  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			OutData_ALUopCode : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			InData_Rsrc1Addr  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rsrc1Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_Rsrc1Data  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_Rsrc1Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rsrc2Addr  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rsrc2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_Rsrc2Data  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Immediate  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_Immediate : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rdst1Addr  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst1Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_Rdst2Addr  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_CurrentPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_CurrentPC :OUT STD_LOGIC_VECTOR(31 DOWNTO 0)	
		);
	END COMPONENT;
	COMPONENT DataForwardUnit IS
		PORT (
			Rsrc1Addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc1Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rsrc2Addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc2Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rdst1Addr_MEM   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst1Data_MEM   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			WB1_MEM         : IN STD_LOGIC;
			Rdst2Addr_MEM   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst2Data_MEM   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			WB2_MEM         : IN STD_LOGIC;
			Rdst1Addr_WB    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst1Data_WB    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			WB1_WB          : IN STD_LOGIC;
			Rdst2Addr_WB    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst2Data_WB    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			WB2_WB          : IN STD_LOGIC;
			Rsrc1_FinalData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rsrc2_FinalData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT MemUseUnit IS
		PORT (
			Rsrc1Addr         : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc2Addr         : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst1Addr_MEM     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			MEM_READ          : IN STD_LOGIC;
			FIRST_DEPENDENCY  : IN STD_LOGIC;
		    	SECOND_DEPENDENCY : IN STD_LOGIC;
			STALL             : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT OurALU IS
		PORT (
			CLK: IN STD_LOGIC;
			OPERATION: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			OP1, OP2: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			RESULT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			FLAGS: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT ExecuteMemory IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			FLUSH : IN STD_LOGIC;
			InData_NextPC     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_NextPC    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_ConSignal  : IN  STD_LOGIC_VECTOR(21 DOWNTO 0);
			OutData_ConSignal : OUT STD_LOGIC_VECTOR(21 DOWNTO 0);
			InData_ALUresult  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_ALUresult : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_ALUflag    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			OutData_ALUflag   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			InData_Rsrc2Data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rdst1Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst1Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_Rdst2Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_CurrentPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_CurrentPC :OUT STD_LOGIC_VECTOR(31 DOWNTO 0)	
		);
	END COMPONENT;
	COMPONENT StackPointer IS
		PORT (
			CLK       : IN STD_LOGIC;
			RST       : IN STD_LOGIC;
			SP_INC    : IN STD_LOGIC;
			SP_DEC    : IN STD_LOGIC;
			SP_OUTPUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT ExceptionUnit IS
		PORT (
			Address      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			MEM_READ     : IN STD_LOGIC;
			MEM_WRITE    : IN STD_LOGIC;
			ExceptionOut : OUT STD_LOGIC
    		);
	END COMPONENT;
	COMPONENT memor IS
		PORT (
			CLK : IN STD_LOGIC;
	    		RST : IN STD_LOGIC;
			Addr  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    			MemRead   : IN STD_LOGIC;
    			ReadData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    			MemWrite  : IN STD_LOGIC;
    			WriteData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			free_i : IN STD_LOGIC;
			prot_i : IN STD_LOGIC
	    	);
	END COMPONENT;
	COMPONENT MemoryWriteback IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			InData_ConSignal  : IN  STD_LOGIC_VECTOR(21 DOWNTO 0);
			OutData_ConSignal : OUT STD_LOGIC_VECTOR(21 DOWNTO 0);
			InData_MemData  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_MemData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rsrc2Data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			InData_Rdst1Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst1Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_Rdst2Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			OutData_Rdst2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			InData_CurrentPC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutData_CurrentPC :OUT STD_LOGIC_VECTOR(31 DOWNTO 0)	
		);
	END COMPONENT;
	COMPONENT OutReg IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			OutEnable : IN STD_LOGIC;
			Data_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutputPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT CCR IS
		PORT (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;
			ZNF : IN STD_LOGIC;
			OVCF : IN STD_LOGIC;
			FlagIn: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			FlagOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT BranchPredictor IS
		Port (
        		clk : in STD_LOGIC;
       		 	branch_taken : in STD_LOGIC;
        		prev_miss : in std_logic;
        		is_jump : in STD_LOGIC;
		    	true_branch_value : in STD_LOGIC; 		--if equal to branch taken then correct prediction else misprediction
        		pc_current : in STD_LOGIC_VECTOR (31 downto 0);
        		branch_target : in STD_LOGIC_VECTOR (31 downto 0);
	    		prev2_dest_reg : in STD_LOGIC_VECTOR (2 downto 0);
        		prev_dest_reg : in STD_LOGIC_VECTOR (2 downto 0);
        		curr_src_reg : in STD_LOGIC_VECTOR (2 downto 0);
        		prediction : out STD_LOGIC;
       		 	mispredict : out STD_LOGIC;
        		ist_taken  : out std_logic;
        		PC_OUT : OUT STD_LOGIC_VECTOR (31 downto 0);
        		PC_old : OUT STD_LOGIC_VECTOR (31 downto 0)
    		);
	END COMPONENT;
	-------------------------------------------------------------------------------------------------

	----------------------------------------- FETCH SIGNALS -----------------------------------------
	SIGNAL PC                : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RESET_ADDRESS     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL INTERRUPT_ADDRESS : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EXCEPTION_ADDRESS : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL NewPC             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL NewPC_FROM_MUXING : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL CurrInstr_FROM_IC : STD_LOGIC_VECTOR(15 DOWNTO 0);
	-------------------------------------------------------------------------------------------------
	-- 1-bit global branch prediction--
	SIGNAL Predict				: STD_LOGIC := '0';--START BY PREDICT TAKEN
	SIGNAL PREDICT_OUT      		: STD_LOGIC;
	SIGNAL PREV_MISS			: STD_LOGIC := '0';
	SIGNAL MISPREDICTION			: STD_LOGIC;
	SIGNAL taken_now			: STD_LOGIC;
	SIGNAL PC_IF_WRONG_PREDICTION 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_AFTER_PREDICTION 		: STD_LOGIC_VECTOR(31 DOWNTO 0);

	----------------------------------------- DECODE SIGNALS ----------------------------------------
	-- F/D REGISTER OUTPUTS
	SIGNAL FETCH_DECODE_FLUSHER          : STD_LOGIC;
	SIGNAL FETCH_DECODE_PAUSER           : STD_LOGIC;
	SIGNAL CurrentInstr_FROM_FDP         : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL NextPC_FROM_FDP	             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL CurrentPC_FROM_FDP            : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- DIVIDE F/D VALUES
	SIGNAL Rsrc1Addr_DIV_CurrInstr       : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rsrc2Addr_DIV_CurrInstr       : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL RdstAddr_DIV_CurrInstr        : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL OpCode_DIV_CurrInstr          : STD_LOGIC_VECTOR(4 DOWNTO 0);
	-- REGISTER FILE OUTPUTS
	SIGNAL Rsrc1Data_FROM_RF             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Data_FROM_RF             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- CONTROL UNIT OUTPUTS
	SIGNAL SIGNALS_FROM_CONTROL          : STD_LOGIC_VECTOR(21 DOWNTO 0);
	SIGNAL ALUopCode_FROM_CONTROL        : STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- HANDLING FUNCTIONS
	SIGNAL Rdst1Addr_FROM_MUXING         : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_EXTEND_0    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_EXTEND_SIGN : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_EXTEND      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Data_FROM_MUXING         : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-------------------------------------------------------------------------------------------------

	----------------------------------------- EXECUTE SIGNALS ---------------------------------------
	-- D/E REGISTER OUTPUTS
	SIGNAL FORCE_BOTH_FROM_SFU    : STD_LOGIC;
	SIGNAL FORCE_Rsrc1_FROM_SFU   : STD_LOGIC;
	SIGNAL FORCE_Rsrc2_FROM_SFU   : STD_LOGIC;
	SIGNAL DECODE_EXECUTE_FLUSHER : STD_LOGIC;
	SIGNAL DECODE_EXECUTE_PAUSER  : STD_LOGIC;
	SIGNAL NextPC_FROM_DEP        : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL CurrentPC_FROM_DEP     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SIGNALS_FROM_DEP       : STD_LOGIC_VECTOR(21 DOWNTO 0);
	SIGNAL ALUopCode_FROM_DEP     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Rsrc1Addr_FROM_DEP     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rsrc1Data_FROM_DEP     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Addr_FROM_DEP     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rsrc2Data_FROM_DEP     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_DEP  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr_FROM_DEP     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr_FROM_DEP     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-- DATA FORWARD UNIT OUTPUTS
	SIGNAL Rsrc1Data_FROM_DFU     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Data_FROM_DFU     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- MEM USE UNIT OUTPUTS
	SIGNAL STALL_AND_FLUSH_FROM_MEMUSE : STD_LOGIC;
	-- ALU OUTPUTS
	SIGNAL ALUresult_FROM_ALU    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALUflag_FROM_ALU      : STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- FLAGS
	SIGNAL FLAG_FROM_CCR         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- HANDLING FUNCTIONS
	SIGNAL DATA_OUT_FROM_MUXING  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- JUMPING FUNCTIONS
	SIGNAL CHANGE_PC_FROM_EXECUTE : STD_LOGIC;
	SIGNAL ZERO_JUMP_FROM_MEMORY  : STD_LOGIC;
	-------------------------------------------------------------------------------------------------

	------------------------------------------ MEMORY SIGNALS ---------------------------------------
	-- E/M REGISTER OUTPUTS
	SIGNAL NextPC_FROM_EMP     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL CurrentPC_FROM_EMP  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SIGNALS_FROM_EMP    : STD_LOGIC_VECTOR(21 DOWNTO 0);
	SIGNAL ALUresult_FROM_EMP  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL FLAGS_FROM_EMP      : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Rdst2Data_FROM_EMP  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr_FROM_EMP  : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr_FROM_EMP  : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-- HANDLING FUNCTIONS
	SIGNAL EXCEPTION_FROM_EU   : STD_LOGIC;
	SIGNAL FULL_EXCEPTION      : STD_LOGIC;
	SIGNAL SP_FROM_STACK       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SP_FROM_MUXING	   : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ADDRESS_SELECTOR    : STD_LOGIC;
	SIGNAL ADDRESS_FROM_MUXING : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DATA_FROM_MUXING_1  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DATA_FROM_MUXING    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DATA_FROM_MEMORY    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AddrOut		   : STD_LOGIC_VECTOR(11 DOWNTO 0);
	-------------------------------------------------------------------------------------------------

	----------------------------------------- WRITEBACK SIGNALS -------------------------------------
	-- M/W REGISTER OUTPUTS
	SIGNAL SIGNALS_FROM_MWP   : STD_LOGIC_VECTOR(21 DOWNTO 0);
	SIGNAL Rdst1Data_FROM_MWP : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst2Data_FROM_MWP : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr_FROM_MWP : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr_FROM_MWP : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL CurrentPC_FROM_MWP  : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-------------------------------------------------------------------------------------------------

	BEGIN
		
		------------------------------------------ FETCH STAGE ------------------------------------------
		u00: PCount PORT MAP(CLK, RST, INT, FULL_EXCEPTION, STALL_AND_FLUSH_FROM_MEMUSE,
				SIGNALS_FROM_EMP(21), DATA_FROM_MEMORY, RESET_ADDRESS,
				INTERRUPT_ADDRESS, EXCEPTION_ADDRESS, NewPC_FROM_MUXING, PC);

		u01: InstrCache PORT MAP(CLK, PC(11 DOWNTO 0), RESET_ADDRESS, INTERRUPT_ADDRESS,
				EXCEPTION_ADDRESS, CurrInstr_FROM_IC);
		NewPC <= std_logic_vector(unsigned(PC) + 1);
		NewPC_FROM_MUXING <= Rsrc1Data_FROM_DFU WHEN (CHANGE_PC_FROM_EXECUTE = '1') ELSE
							PC_IF_WRONG_PREDICTION WHEN (MISPREDICTION = '1') ELSE 
							PC_AFTER_PREDICTION WHEN (taken_now = '1') ELSE NewPC;
		-------------------------------------------------------------------------------------------------

		------------------------------------ FETCH / DECODE PIPELINE ------------------------------------
		FETCH_DECODE_FLUSHER <= CHANGE_PC_FROM_EXECUTE or SIGNALS_FROM_CONTROL(8) or MISPREDICTION;
		FETCH_DECODE_PAUSER  <= STALL_AND_FLUSH_FROM_MEMUSE;
		u10: FetchDecode PORT MAP(CLK, RST, FETCH_DECODE_FLUSHER, FETCH_DECODE_PAUSER,
					CurrInstr_FROM_IC, CurrentInstr_FROM_FDP, PC,
					NextPC_FROM_FDP, PC, CurrentPC_FROM_FDP);
		-------------------------------------------------------------------------------------------------

		------------------------------------------ DECODE STAGE -----------------------------------------
		OpCode_DIV_CurrInstr    <= CurrentInstr_FROM_FDP(15 DOWNTO 11);
		RdstAddr_DIV_CurrInstr  <= CurrentInstr_FROM_FDP(10 DOWNTO  8);
		Rsrc1Addr_DIV_CurrInstr <= CurrentInstr_FROM_FDP(7  DOWNTO  5);
		Rsrc2Addr_DIV_CurrInstr <= CurrentInstr_FROM_FDP(4  DOWNTO  2);

		u20: registerfile PORT MAP(CLK, RST, Rsrc1Addr_DIV_CurrInstr, Rsrc2Addr_DIV_CurrInstr,
					Rsrc1Data_FROM_RF, Rsrc2Data_FROM_RF,
						SIGNALS_FROM_MWP(0), Rdst1Addr_FROM_MWP, Rdst1Data_FROM_MWP,
						SIGNALS_FROM_MWP(1), Rdst2Addr_FROM_MWP, Rdst2Data_FROM_MWP,
						R0, R1, R2, R3, R4, R5, R6, R7);

		u21: ControlUnit PORT MAP(OpCode_DIV_CurrInstr, SIGNALS_FROM_CONTROL,
						ALUopCode_FROM_CONTROL);
		u25: BranchPredictor PORT MAP(CLK, Predict, PREV_MISS, SIGNALS_FROM_CONTROL(10),ZERO_JUMP_FROM_MEMORY, 
					NewPC, Rsrc1Data_FROM_RF,
					Rdst1Addr_FROM_EMP, Rdst1Addr_FROM_DEP, Rsrc1Addr_DIV_CurrInstr,
					PREDICT_OUT, MISPREDICTION, taken_now, PC_AFTER_PREDICTION, PC_IF_WRONG_PREDICTION);
		PREV_MISS <= MISPREDICTION;
		Predict <= PREDICT_OUT;

		Rdst1Addr_FROM_MUXING <= RdstAddr_DIV_CurrInstr WHEN (SIGNALS_FROM_CONTROL(1) = '0')
		ELSE Rsrc2Addr_DIV_CurrInstr;

		u22: SignExtender PORT MAP(CurrInstr_FROM_IC, ImmediateVal_FROM_EXTEND_SIGN);
		ImmediateVal_FROM_EXTEND_0 <= x"0000" & CurrInstr_FROM_IC;

		ImmediateVal_FROM_EXTEND <= ImmediateVal_FROM_EXTEND_0 WHEN (SIGNALS_FROM_CONTROL(17) = '1')
				ELSE ImmediateVal_FROM_EXTEND_SIGN;
		-------------------------------------------------------------------------------------------------

		----------------------------------- DECODE / EXECUTE PIPELINE -----------------------------------
		u30: StalledForwardUnit PORT MAP(STALL_AND_FLUSH_FROM_MEMUSE,
				Rsrc1Addr_FROM_DEP, Rsrc2Addr_FROM_DEP,
				Rdst1Addr_FROM_MWP, Rdst2Addr_FROM_MWP,
				SIGNALS_FROM_MWP(0), SIGNALS_FROM_MWP(1),
				FORCE_Rsrc1_FROM_SFU, FORCE_Rsrc2_FROM_SFU);

		FORCE_BOTH_FROM_SFU <= FORCE_Rsrc1_FROM_SFU AND FORCE_Rsrc2_FROM_SFU;

		DECODE_EXECUTE_FLUSHER <= CHANGE_PC_FROM_EXECUTE;
		DECODE_EXECUTE_PAUSER  <= STALL_AND_FLUSH_FROM_MEMUSE;
		u31: DecodeExecute PORT MAP(CLK, RST, DECODE_EXECUTE_FLUSHER, DECODE_EXECUTE_PAUSER,
				FORCE_BOTH_FROM_SFU, FORCE_Rsrc1_FROM_SFU, FORCE_Rsrc2_FROM_SFU,
					Rdst1Data_FROM_MWP, Rdst1Data_FROM_MWP,
					NextPC_FROM_FDP, NextPC_FROM_DEP,
					SIGNALS_FROM_CONTROL, SIGNALS_FROM_DEP,
					ALUopCode_FROM_CONTROL, ALUopCode_FROM_DEP,
					Rsrc1Addr_DIV_CurrInstr, Rsrc1Addr_FROM_DEP,
					Rsrc1Data_FROM_RF, Rsrc1Data_FROM_DEP,
					Rsrc2Addr_DIV_CurrInstr, Rsrc2Addr_FROM_DEP,
					Rsrc2Data_FROM_RF, Rsrc2Data_FROM_DEP,
					ImmediateVal_FROM_EXTEND, ImmediateVal_FROM_DEP,
					Rdst1Addr_FROM_MUXING, Rdst1Addr_FROM_DEP,
					Rsrc1Addr_DIV_CurrInstr, Rdst2Addr_FROM_DEP,
					CurrentPC_FROM_FDP, CurrentPC_FROM_DEP);
		-------------------------------------------------------------------------------------------------

		----------------------------------------- EXECUTE STAGE -----------------------------------------
		u40: DataForwardUnit PORT MAP(Rsrc1Addr_FROM_DEP, Rsrc1Data_FROM_DEP,
					Rsrc2Addr_FROM_DEP, Rsrc2Data_FROM_DEP,
					Rdst1Addr_FROM_EMP, ALUresult_FROM_EMP, SIGNALS_FROM_EMP(0),
                                        Rdst2Addr_FROM_EMP, Rdst2Data_FROM_EMP, SIGNALS_FROM_EMP(1),
                                        Rdst1Addr_FROM_MWP, Rdst1Data_FROM_MWP, SIGNALS_FROM_MWP(0),
                                        Rdst2Addr_FROM_MWP, Rdst2Data_FROM_MWP, SIGNALS_FROM_MWP(1),
                                        Rsrc1Data_FROM_DFU, Rsrc2Data_FROM_DFU);

		u41: MemUseUnit PORT MAP(Rsrc1Addr_FROM_DEP, Rsrc2Addr_FROM_DEP, Rdst1Addr_FROM_EMP,
					SIGNALS_FROM_EMP(4), SIGNALS_FROM_DEP(18), SIGNALS_FROM_DEP(19),
							STALL_AND_FLUSH_FROM_MEMUSE);

		Rsrc2Data_FROM_MUXING <= ImmediateVal_FROM_DEP WHEN (SIGNALS_FROM_DEP(8) = '1')
			ELSE Rsrc2Data_FROM_DFU;

		u42: OurALU PORT MAP(CLK, ALUopCode_FROM_DEP, Rsrc1Data_FROM_DFU, Rsrc2Data_FROM_MUXING,
					ALUresult_FROM_ALU, ALUflag_FROM_ALU);

		u43: CCR PORT MAP(CLK, RST, SIGNALS_FROM_DEP(2), SIGNALS_FROM_DEP(3),
					ALUflag_FROM_ALU, FLAG_FROM_CCR);
		FLAGS <= FLAG_FROM_CCR;

		DATA_OUT_FROM_MUXING <= ALUresult_FROM_ALU WHEN (SIGNALS_FROM_DEP(14) = '0') ELSE INPORT;

		-- HANDLING JUMPS
		ZERO_JUMP_FROM_MEMORY <= SIGNALS_FROM_DEP(10) and SIGNALS_FROM_EMP(2) and FLAGS_FROM_EMP(0);		
		CHANGE_PC_FROM_EXECUTE <= ZERO_JUMP_FROM_MEMORY or SIGNALS_FROM_DEP(9);   
		-------------------------------------------------------------------------------------------------
	
		----------------------------------- EXECUTE / MEMORY PIPELINE -----------------------------------
		u50: ExecuteMemory PORT MAP(CLK, RST, STALL_AND_FLUSH_FROM_MEMUSE,
				NextPC_FROM_DEP, NextPC_FROM_EMP, SIGNALS_FROM_DEP,
				SIGNALS_FROM_EMP, DATA_OUT_FROM_MUXING, ALUresult_FROM_EMP,
				ALUflag_FROM_ALU, FLAGS_FROM_EMP, Rsrc2Data_FROM_DFU,
				Rdst2Data_FROM_EMP, Rdst1Addr_FROM_DEP, Rdst1Addr_FROM_EMP,
				Rdst2Addr_FROM_DEP, Rdst2Addr_FROM_EMP,
				CurrentPC_FROM_DEP, CurrentPC_FROM_EMP);
		-------------------------------------------------------------------------------------------------

		------------------------------------------ MEMORY STAGE -----------------------------------------
		u60: StackPointer PORT MAP(CLK, RST, SIGNALS_FROM_EMP(12),
				SIGNALS_FROM_EMP(11), SP_FROM_STACK);

		DATA_FROM_MUXING_1 <= ALUresult_FROM_EMP WHEN (SIGNALS_FROM_EMP(15) = '0')
		ELSE Rdst2Data_FROM_EMP;

		DATA_FROM_MUXING <= DATA_FROM_MUXING_1 WHEN (SIGNALS_FROM_EMP(16) = '0')
		ELSE std_logic_vector(unsigned(CurrentPC_From_MWP) + 1) WHEN (SIGNALS_FROM_EMP(20) = '1')
		ELSE NextPC_FROM_EMP;

		SP_FROM_MUXING <= SP_FROM_STACK WHEN (SIGNALS_FROM_EMP(11) = '1')
		ELSE std_logic_vector(unsigned(SP_FROM_STACK) + 2);

		ADDRESS_FROM_MUXING <= ALUresult_FROM_EMP
			WHEN (SIGNALS_FROM_EMP(11) = '0' and SIGNALS_FROM_EMP(12) = '0') ELSE
					SP_FROM_MUXING;

		u61: ExceptionUnit PORT MAP(ADDRESS_FROM_MUXING, SIGNALS_FROM_EMP(4),
				SIGNALS_FROM_EMP(5), EXCEPTION_FROM_EU);

		FULL_EXCEPTION <= EXCEPTION_FROM_EU OR (FLAG_FROM_CCR(3) AND SIGNALS_FROM_EMP(3));
		EXCP <= FULL_EXCEPTION;

		u62: memor PORT MAP(CLK, RST, ADDRESS_FROM_MUXING(11 DOWNTO 0), SIGNALS_FROM_EMP(4),
					DATA_FROM_MEMORY, SIGNALS_FROM_EMP(5), DATA_FROM_MUXING,
						SIGNALS_FROM_EMP(6), SIGNALS_FROM_EMP(7));
		-------------------------------------------------------------------------------------------------

		---------------------------------- MEMORY / WRITEBACK PIPELINE ----------------------------------
		u70: MemoryWriteback PORT MAP(CLK, RST, SIGNALS_FROM_EMP, SIGNALS_FROM_MWP,
				DATA_FROM_MEMORY, Rdst1Data_FROM_MWP, Rdst2Data_FROM_EMP, Rdst2Data_FROM_MWP,
				Rdst1Addr_FROM_EMP, Rdst1Addr_FROM_MWP, Rdst2Addr_FROM_EMP, Rdst2Addr_FROM_MWP,
						CurrentPC_FROM_EMP, CurrentPC_FROM_MWP);

		u44: OutReg PORT MAP(CLK, RST, SIGNALS_FROM_MWP(13), Rdst1Data_FROM_MWP, OUTPORT);
		-------------------------------------------------------------------------------------------------

END a_MIPS_Processor;	