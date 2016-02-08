; VM_Instructions.ASM

OP_MOV:
	MOV	bl, [Registers + ebx]
	MOV	[Registers + eax], bl
	RET

OP_MOVIMM:
	MOV	[Registers + eax], bl
	RET

OP_LDA:
	MOVZX	ebx, byte [Registers + ebx]
	MOV	bl, [Memory + ebx]
	MOV	[Registers + eax], bl
	RET

OP_LDAIMM:
	MOVZX	ebx, bl
	MOV	bl, [Memory + ebx]
	MOV	[Registers + eax], bl
	RET

OP_STA:
	MOV	al, [Registers + eax]
	MOVZX	ebx, byte [RegBR]
	MOV	[Memory + ebx], al
	RET

OP_PUSH:
	MOV	al, [Registers + eax]
	SUB	byte [RegSP], 1
	MOVZX	ebx, byte [RegSP]
	MOV	[Memory + ebx], al
	RET

OP_POP:
	MOVZX	ebx, byte [RegSP]
	MOV	bl, [Memory + ebx]
	ADD	byte [RegSP], 1
	LEA	eax, [Registers + eax]
	MOV	[eax], bl
	RET

OP_ADD:
	MOV	bl, [Registers + ebx]
	LEA	eax, [Registers + eax]
	ADD	[eax], bl
	RET

OP_ADDIMM:
	LEA	eax, [Registers + eax]
	ADD	[eax], bl
	RET

OP_SUB:
	MOV	bl, [Registers + ebx]
	LEA	eax, [Registers + eax]
	SUB	[eax], bl
	RET

OP_SUBIMM:
	LEA	eax, [Registers + eax]
	SUB	[eax], bl
	RET

OP_JMP:
	MOV	[RegIP], al
	RET

OP_CALL:
	CALL	OP_JMP
	MOV	eax, REGIP
	CALL	OP_PUSH
	RET

OP_RET:
	MOV	eax, REGIP
	CMP	byte [RegSP], 0
	JE	.Terminate
	CALL	OP_POP
	RET

	.Terminate:
	MOV	byte [State], 0
	RET

OP_IN:
	SUB	esp, 4
	PUSH	esp
	PUSH	dword InputFMT
	CALL	_scanf
	ADD	esp, 8
	MOV	bl, [esp]
	ADD	esp, 4
	LEA	eax, [Registers + eax]
	MOV	[eax], bl
	RET

OP_OUT:
	MOVZX	eax, byte [Registers + eax]
	PUSH	eax
	PUSH	dword OutputFMT
	CALL	_printf
	ADD	esp, 8
	RET
