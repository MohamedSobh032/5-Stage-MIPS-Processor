# ISA Specifications
## Overview
This document outlines the specifications for a custom Instruction Set Architecture (ISA). The ISA is designed to manage a basic processor that includes general-purpose registers, a program counter, stack pointer, condition code registers, and input-output ports. This readme provides a comprehensive guide to understanding the registers, input-output operations, instructions, and their functionalities within the ISA.

## Registers
#### General Purpose Registers
**R[0:7]<31:0>:** Eight 32-bit general-purpose registers (R0 to R7).
#### Special Purpose Registers
**PC<31:0>:** 32-bit Program Counter, points to the next instruction to be executed.

**SP<31:0>:** 32-bit Stack Pointer, points to the top of the stack.

**CCR<3:0>:** Condition Code Register, holds the status flags.
 1. Z (Zero flag): Set if the result of an arithmetic or logical operation is zero.
 2. N (Negative flag): Set if the result of an operation is negative.
 3. C (Carry flag): Set if there is a carry out from the most significant bit in an arithmetic operation.
 4. O (Overflow flag): Set if there is an overflow in arithmetic operations.
## Input-Output
**IN_PORT<31:0>:** 32-bit data input port.

**OUT_PORT<31:0>:** 32-bit data output port.

**INT_In<0>:** Single, non-maskable interrupt signal.

**RESET_IN<0>:** Reset signal, initializes the processor.

**Exception_out<0>:** Raised in cases of overflow or when accessing a protected memory address.
## Instructions
#### One Operand Instructions
**NOP:** No operation

**NOT Rdst:** R[Rdst] ← 1’s Complement(R[Rdst]);

**NEG Rdst:** R[Rdst] ← 0 - R[Rdst];

**INC Rdst:** R[Rdst] ← R[Rdst] + 1;

**DEC Rdst:** R[Rdst] ← R[Rdst] – 1;

**OUT Rdst:** OUT.PORT ← R[Rdst];

**IN Rdst:**  R[Rdst] ← IN.PORT;
#### Two Operand Instructions
**MOV Rdst, Rsrc:** R[Rdst] ← R[Rsrc];

**SWAP Rdst, Rsrc:** R[Rdst] ← R[Rsrc]; R[Rsrc] ← R[Rdst];

**ADD Rdst, Rsrc1, Rsrc2:** R[Rdst] ← R[Rsrc1] + R[Rsrc2];

**ADDI Rdst, Rsrc1, Imm:** R[Rdst] ← R[Rsrc1] + {Imm<15>,Imm<15:0>};

**SUB Rdst, Rsrc1, Rsrc2:** R[Rdst] ← R[Rsrc1] - R[Rsrc2];

**SUBI Rdst, Rsrc1, Imm:** R[Rdst] ← R[Rsrc1] - {Imm<15>,Imm<15:0>};

**AND Rdst, Rsrc1, Rsrc2:** R[Rdst] ← R[Rsrc1] AND R[Rsrc2];

**OR Rdst, Rsrc1, Rsrc2:** R[Rdst] ← R[Rsrc1] OR R[Rsrc2];

**XOR Rdst, Rsrc1, Rsrc2:** R[Rdst] ← R[Rsrc1] XOR R[Rsrc2];

**CMP Rsrc1, Rsrc2:** R[Rsrc1] - R[Rsrc2];
#### Memory Operations
**PUSH Rdst:** DataMemory[SP--] ← R[Rdst];

**POP Rdst:** R[Rdst] ← DataMemory[++SP];

**LDM Rdst, Imm:** R[Rdst]←{0,Imm<15:0>};

**LDD Rdst, EA(Rsrc1):** R[Rdst]←M[EA+R[Rsrc1]];

**STD Rdst, EA(Rsrc1):** M[EA+R[Rsrc1]]←R[Rsrc];

**PROTECT Rsrc:** Protects the memory location pointed to by the source register from being modified.

**FREE Rsrc:** Frees a protected memory location pointed to by the source register and resets its content.

#### Branching Operations
**JZ Rdst:** If(Z=1): PC ← R[Rdst]; (Z=0);

**JMP Rdst:** PC ← R[Rdst];

**CALL Rdst:** DataMemory[SP] ← PC + 1; SP -= 2; PC ← R[Rdst];

**RET:** SP += 2; PC ← DataMemory[SP];

**RTI:** SP += 2; PC ← DataMemory[SP]; SP += 2; CCR ← DataMemory[SP];

#### Reset and Interrupt Operations
**Reset:** PC ← {M[1], M[0]};

**Interrupt:** DataMemory[SP] ← PC; SP -= 2; DataMemory[SP] ← CCR; SP -= 2; PC ← {M[3], M[2]};

## Conclusion
This ISA provides a comprehensive set of instructions and register configurations designed to manage basic processing tasks, including arithmetic operations, memory management, input-output operations, and control flow. The architecture supports both single and multi-operand instructions, allowing for flexible and efficient programming. The inclusion of condition flags and exception handling ensures robust and reliable operation, making it suitable for a wide range of applications.
