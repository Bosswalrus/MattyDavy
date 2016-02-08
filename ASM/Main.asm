global _main

extern _printf
extern _scanf
extern _fopen
extern _fclose
extern _fread

section .data
	; REGISTERS
	%define REGAR	0
	%define REGBR	1
	%define REGSP	2
	%define REGIP	3

	Registers:
	RegAR:		DB 0
	RegBR:		DB 0
	RegSP:		DB 0
	RegIP:		DB 0

	; MEMORY
	Memory:		TIMES 256 DB 0
	State:		DB 0
	InputFMT:	DB "%d", 0
	OutputFMT:	DB "%d", 10, 0
	ReadFMT:	DB "r", 0

	Error:
		.BufferTooBig:	DB "Buffer too big, maximum is 256 bytes.", 10, 0
		.FileNotLoaded:	DB "Could not load/read file.", 10, 0
		.EndOfMemory:	DB "End of memory, final instruction malformed.", 10, 0
		.InvalidState:	DB "The VM is currently not initialized or has been terminated.", 10, 0
		.BadOpcode:	DB "Bad Opcode %X (byte %d).", 10, 0
		.BadArguments:	DB "Only 1 argument (file name) must be present.", 10, 0

	; OPCODE TABLE
	Opcode:
	DD	OP_MOV, OP_MOVIMM
	DD	OP_LDA, OP_LDAIMM, OP_STA
	DD	OP_PUSH, OP_POP
	DD	OP_ADD, OP_ADDIMM, OP_SUB, OP_SUBIMM
	DD	OP_JMP, OP_CALL, OP_RET
	DD	OP_IN, OP_OUT
	OpFormats:
	DB	2, 2
	DB	2, 2, 1
	DB	1, 1
	DB	2, 2, 2, 2
	DB	1, 1, 0
	DB	1, 1

section .text
	%include "Library.asm"
	%include "Instructions.asm"

	_main:
		PUSH	ebp
		MOV	ebp, esp

		MOV	ecx, [ebp + 8]		; argc
		CMP	ecx, 2
		JE	.LoadFile		; argc == 2

		PUSH	dword Error.BadArguments
		CALL	_printf
		ADD	esp, 4
		JMP	.End

		.LoadFile:
		MOV	ecx, [ebp + 12]
		MOV	esi, [ecx + 4]		; argv[1]
		CALL	VM_LoadFile		; LoadFile argv[1]
		CMP	eax, 0
		JE	.End			; LoadFile error

		CALL	VM_Init
		CALL	VM_StepAll

		.End:
		XOR	eax, eax
		MOV	esp, ebp
		POP	ebp
		RET
