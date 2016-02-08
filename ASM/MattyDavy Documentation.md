# MattyDavy VM Documentation

**Specifications**
- Register-based VM
	- 1 byte register sizes
- 256 bytes of free memory
	- All memory is alterable
- Easy to extend
	- More than 200 available opcodes
	- Very simple implementation of instructions


## Registers

| IDX	| Name	| Description		|
|-------|-------|-----------------------|
| 0	| AR	| Accumulator		|
| 1	| BR	| Base			|
| 2	| SP	| Stack Pointer		|
| 3	| IP	| Instruction Pointer	|


## Instruction Formats

| FMT	| Encoding	|
|-------|---------------|
| iA	| OPCODE	|
| iB	| OPCODE OP1	|
| iC	| OPCODE OP1 OP2|



## Instructions

| Opcode (FMT)	| Mnemonic	| Description	|
|---------------|---------------|---------------|
| 00 (iC)	| MOV reg, reg	| R(A)=R(B)	|
| 01 (iC)	| MOV reg, imm	| R(A)=B	|
| 02 (iC)	| LDA reg, reg	| R(A)=M(R(B))	|
| 03 (iB)	| LDA reg, imm	| R(A)=M(B)	|
| 04 (iB)	| STA reg	| M(BR)=R(A)	|
| 05 (iB)	| PUSH reg	| push(R(A))	|
| 06 (iB)	| POP reg	| R(A)=pop()	|
| 07 (iC)	| ADD reg, reg	| R(A)+=R(B)	|
| 08 (iC)	| ADD reg, imm	| R(A)+=B	|
| 09 (iC)	| SUB reg, reg	| R(A)-=R(B)	|
| 0A (iC)	| SUB reg, imm	| R(A)-=B	|
| 0B (iB)	| JMP imm	| IP=A		|
| 0C (iB)	| CALL imm	| push(IP) IP=A	|
| 0D (iA)	| RET		| IP=pop()	|
| 0E (iB)	| IN reg	| R(A)=input()	|
| 0F (iB)	| OUT reg	| output(R(A))	|

In the standard *MattyDavy ASM VM*, operand 1 and operand 2 are passed in registers `eax` and `ebx` respectively. These registers should be considered volatile across all *VM instruction calls*.


## MattyDavy ASM Library

| Function	| Inputs			| Description					|
|---------------|-------------------------------|-----------------------------------------------|
| LoadBuffer	| ESI - pointer to buffer	| Loads a buffer into VM memory			|
|		| ECX - size range: [0, 256]	|
| LoadFile	| ESI - file name		| Loads 256 bytes of a file into VM memory	|
| Init		| 				| Initialized the VM
|		|				| VM registers set to 0, enables execution	|
| Step		|				| Steps one instruction				|
| StepAll	|				| Steps until program terminates		|
