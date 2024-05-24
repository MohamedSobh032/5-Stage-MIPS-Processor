LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY memor IS
	PORT (
		CLK       : IN  STD_LOGIC;
	    	RST       : IN  STD_LOGIC;
		Addr      : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
    		-- READ --
    		MemRead   : IN  STD_LOGIC;
    		ReadData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    		-- WRITE --
    		MemWrite  : IN  STD_LOGIC;
    		WriteData : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- PROTECT AND FREE --
		free_i    : IN  STD_LOGIC;
		prot_i    : IN  STD_LOGIC;
		-- RAISE EXCEPTION --
		EXCEP     : OUT STD_LOGIC
    	);
END memor;

ARCHITECTURE a_memor OF memor IS

	-- (15 DOWNTO 0) data bits
	-- (16) enable for specific address (PROTECT, FREE)
	-- PROTECTED == 1 (prevent write if equals 1)
	-- FREE == 0 (enable write operations if equal 0)
	TYPE dm_type IS ARRAY(0 TO 4095) OF STD_LOGIC_VECTOR(16 DOWNTO 0);
    	SIGNAL datamemory : dm_type;

	BEGIN
		PROCESS (CLK, RST)
        	BEGIN
    	        	IF (RST = '1') THEN
    		        	datamemory <= ((OTHERS => (OTHERS => '0')));
				ReadData <= (OTHERS => '0');
				EXCEP <= '0';
			ELSIF (free_i = '1') THEN
				EXCEP <= '0';
				datamemory(to_integer(unsigned(Addr)))(16) <= '0';
			ELSIF (prot_i = '1') THEN
				EXCEP <= '0';
				datamemory(to_integer(unsigned(Addr)))(16) <= '1';
    		        ELSIF RISING_EDGE(CLK) THEN

    		        	IF (memRead = '1') THEN
					EXCEP <= '0';
    			                ReadData <= datamemory(to_integer(unsigned(Addr)+1))(15 DOWNTO 0)
							& datamemory(to_integer(unsigned(Addr)))(15 DOWNTO 0);
				ELSE
					EXCEP <= '0';
					ReadData <= WriteData;
    		  	        END IF;

    		            	IF (memWrite = '1') THEN
					IF (datamemory(to_integer(unsigned(Addr)))(16) = '0') THEN
						EXCEP <= '0';
    		               			datamemory(to_integer(unsigned(Addr)))  (15 DOWNTO 0) <= WriteData(15 DOWNTO 0);
						datamemory(to_integer(unsigned(Addr)+1))(15 DOWNTO 0) <= WriteData(31 DOWNTO 16);
					ELSE
						EXCEP <= '1';
					END IF;
    		            	END IF;

    		        END IF;
    	    	END PROCESS;  
END a_memor;
