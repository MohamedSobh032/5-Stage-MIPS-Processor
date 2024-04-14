LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY memor IS
	PORT (
		CLK : IN STD_LOGIC;
	    	RST : IN STD_LOGIC;
		Addr  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    		-- read
    		MemRead   : IN STD_LOGIC;
    		ReadData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    		-- write
    		MemWrite  : IN STD_LOGIC;
    		WriteData : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    	);
END memor;


ARCHITECTURE a_memor OF memor IS

	TYPE dm_type IS ARRAY(0 TO 4095) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    	SIGNAL datamemory : dm_type;

	BEGIN
		PROCESS (CLK, RST)
        	BEGIN
    	        	IF (RST = '1') THEN
    		        	datamemory <= ((OTHERS => (OTHERS => '0')));
				ReadData <= (OTHERS => '0');
    		        ELSIF RISING_EDGE(CLK) THEN
    		        	IF (memRead = '1') THEN
    			                ReadData <= datamemory(to_integer(unsigned(Addr)+1)) & datamemory(to_integer(unsigned(Addr)));
				ELSE
					ReadData <= (OTHERS => '0');
    		  	        END IF;
    		            	IF (memWrite = '1') THEN
    		               		datamemory(to_integer(unsigned(Addr))) <= WriteData(15 DOWNTO 0);
					datamemory(to_integer(unsigned(Addr)+1)) <= WriteData(31 DOWNTO 16);
    		            	END IF;
    		        END IF;
    	    	END PROCESS;  
END a_memor;