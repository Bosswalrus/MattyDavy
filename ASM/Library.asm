; VM_Library.ASM

VM_LoadBuffer:
	; esi = pointer to buffer
	; ecx = length of buffer [0, 255]
	; Destroyed: eax, ecx, esi, edi
	CMP	ecx, 255
	JA	.BufferTooBig
	MOV	edi, Memory
	CLD
	REP MOVSB		; memcpy(Memory, esi, ecx)
	MOV	eax, 1
	RET

	.BufferTooBig:
	PUSH	dword Error.BufferTooBig
	CALL	_printf		; printf(Error.BufferTooBig)
	ADD	esp, 4
	XOR	eax, eax
	RET

VM_LoadFile:
	; esi = file name
	; Destroyed: eax, ecx?, edx?
	PUSH	dword ReadFMT
	PUSH	esi
	CALL	_fopen		; fopen(esi, "rb")
	ADD	esp, 8
	CMP	eax, 0
	JE	.FileNotLoaded
	PUSH	eax		; file handle
	PUSH	eax
	PUSH	dword 256
	PUSH	dword 1
	PUSH	dword Memory
	CALL	_fread		; fread(Memory, 1, 256, file)
	ADD	esp, 16
	CMP	eax, 0
	JE	.ReadFail
	CALL	_fclose		; fclose(file)
	ADD	esp, 4
	MOV	eax, 1
	RET

	.ReadFail:
	ADD	esp, 4

	.FileNotLoaded:
	PUSH	dword Error.FileNotLoaded
	CALL	_printf		; printf(Error.FileNotLoaded)
	ADD	esp, 4
	XOR	eax, eax
	RET

VM_PrintMemory:
	; to-do: implement
	RET

VM_Init:
	MOV	dword [Registers], 0
	MOV	byte [State], 1
	RET

VM_Step:
	; Destroyed: eax, ebx, ecx, edx
	CMP	byte [State], 0
	JE	.InvalidState
	MOVZX	eax, byte [RegIP]		; eax = ip
	MOVZX	ebx, byte [Memory + eax]	; ebx = opcode
	CMP	ebx, 15
	JA	.BadOpcode
	MOVZX	ecx, byte [OpFormats + ebx]	; ecx = argc
	ADD	byte [RegIP], 1			; ip++
	MOV	edx, eax
	ADD	edx, ecx			; edx = ip + argc

	CMP	edx, 255
	JA	.EndOfMemory			; if ip + argc > 255, jump
	MOV	edx, [Opcode + ebx*4]		; edx = operation
	CMP	ecx, 2
	JE	.BinaryArguments
	CMP	ecx, 1
	JE	.UnaryArguments
	; eax = ip
	; ebx = opcode
	; ecx = argc
	; edx = operation

	.NoArguments:
	CALL	edx
	MOV	eax, 1
	RET

	.UnaryArguments:
	ADD	byte [RegIP], 1		; ip += 1
	ADD	eax, 1
	MOVZX	eax, byte [Memory + eax]
	CALL	edx
	MOV	eax, 1
	RET

	.BinaryArguments:
	ADD	byte [RegIP], 2		; ip += 2
	ADD	eax, 1
	MOVZX	ebx, byte [Memory + eax]
	ADD	eax, 1
	MOVZX	eax, byte [Memory + eax]
	XCHG	eax, ebx
	CALL	edx
	MOV	eax, 1
	RET

	.EndOfMemory:
	PUSH	dword Error.EndOfMemory
	CALL	_printf
	ADD	esp, 4
	XOR	eax, eax
	RET

	.BadOpcode:
	PUSH	dword eax
	PUSH	dword ebx
	PUSH	dword Error.BadOpcode
	CALL	_printf
	ADD	esp, 12
	XOR	eax, eax
	RET

	.InvalidState:
	PUSH	dword Error.InvalidState
	CALL	_printf
	ADD	esp, 4
	XOR	eax, eax
	RET

VM_StepAll:
	.ExecNext:
	CALL	VM_Step
	CMP	eax, 0
	JNE	.ExecNext
	RET
