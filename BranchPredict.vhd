library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BranchPredictor is
    Port (
        clk : in STD_LOGIC;
        branch_taken : in STD_LOGIC;
        is_jump : in STD_LOGIC;
        pc_current : in STD_LOGIC_VECTOR (31 downto 0);
        branch_target : in STD_LOGIC_VECTOR (31 downto 0);
        prev_dest_reg : in STD_LOGIC_VECTOR (2 downto 0);
        curr_src_reg : in STD_LOGIC_VECTOR (2 downto 0);
        prediction : out STD_LOGIC;
        mispredict : out STD_LOGIC;
        ist_taken  : out std_logic;
        PC_OUT : OUT STD_LOGIC_VECTOR (31 downto 0);
        PC_old : OUT STD_LOGIC_VECTOR (31 downto 0)
    );
end BranchPredictor;

architecture Behavioral of BranchPredictor is
    signal last_branch : STD_LOGIC := '0';  -- Last branch result
    signal internal_mispredict : STD_LOGIC; 
begin
    process(clk)
    begin
        if falling_edge(clk) then
            -- Check if current instruction is a jump and not dependent
            if is_jump = '1' and prev_dest_reg /= curr_src_reg then
                -- Output prediction
                prediction <= last_branch;
                internal_mispredict <= not (last_branch xor branch_taken);
                -- Output misprediction
                mispredict <= internal_mispredict;
                -- Update last branch result only if prediction was correct
                if internal_mispredict = '0' then
                    last_branch <= branch_taken;
                end if;
                -- Update PC if misprediction occurred
                if internal_mispredict = '1' then
                    if branch_taken = '1' then
                        PC_OUT <= branch_target;  -- Branch was taken, update PC to branch target
                    else
                        PC_OUT <= pc_current ;  -- Branch was not taken, update PC to next instruction
                    end if;
                end if;
            ist_taken <= branch_taken;
            else
                -- If not a jump instruction or is dependent, set prediction and mispredict to '0'
                prediction <= '0';
                mispredict <= '0';
                ist_taken <= '0';
            end if;
        PC_OUT <= pc_current;
        PC_OLD <= pc_current;
        end if;
    end process;
end Behavioral;
