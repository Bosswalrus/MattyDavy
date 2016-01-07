/*
	MATTYDAVY
	Based on the Lua source of MattyDavy

	This was created purely for education and recreational purposes only, I'm merely mimicking the MattyDavy Instruction Set and the source code.
	Not all instructions were tested.
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "MDVM.h"

VM *VM_newState(void) {
	VM *state = (VM *)malloc(sizeof(VM));
	state->status = INVALID;
	return state;
}

void VM_freeState(VM *state) {
	free(state);
}

void VM_reset(VM *state) {
	memset(state->memory, 0, sizeof(VM));
	state->status = INVALID;
}

char VM_loadProgram(VM *state, size_t size, char *program) {
	if (size <= 256) {
		memcpy(state->memory, program, size);
		state->status = VALID;
		return 1;
	}
	return 0;
}

char VM_peek(VM *state, unsigned char disp) {
	size_t idx = state->registers[IP] + disp;
	if (idx > 256) {
		fputs("EOF unexpected", stderr);
		exit(1);
	}
	return state->memory[idx];
}

/* To-do: make safe */
void VM_step(VM *state, char count) {
	char opcode, operand0, operand1, read;
	while (count-- > 0 && state->status == VALID) {
		opcode = VM_peek(state, 0);
		operand0 = VM_peek(state, 1);
		operand1 = VM_peek(state, 2);
		switch (opcode) {
			case 0:		/* MOVE */
				state->registers[IP] += 3;
				state->registers[operand0] = state->registers[operand1];
				break;
			case 1:		/* MOVEIMM */
				state->registers[IP] += 3;
				state->registers[operand0] = operand1;
				break;
			case 2:		/* LOAD */
				state->registers[IP] += 3;
				state->registers[operand0] = state->memory[state->registers[operand1]];
				break;
			case 3:		/* LOADIMM */
				state->registers[IP] += 3;
				state->registers[operand0] = state->memory[operand1];
				break;
			case 4:		/* STORE */
				state->registers[IP] += 2;
				state->memory[state->registers[BP]] = state->registers[operand0];
				break;
			case 5:		/* PUSH */
				state->registers[IP] += 2;
				state->memory[--state->registers[SP]] = state->registers[operand0];
				break;
			case 6:		/* POP */
				state->registers[IP] += 2;
				state->registers[operand0] = state->memory[state->registers[SP]++];
				break;
			case 7:		/* ADD */
				state->registers[IP] += 3;
				state->registers[operand0] += state->memory[state->registers[operand1]];
				break;
			case 8:		/* ADDIMM */
				state->registers[IP] += 3;
				state->registers[operand0] += operand1;
				break;
			case 9:		/* SUB */
				state->registers[IP] += 3;
				state->registers[operand0] -= state->memory[state->registers[operand1]];
				break;
			case 10:	/* SUBIMM */
				state->registers[IP] += 3;
				state->registers[operand0] -= operand1;
				break;
			case 11:	/* JMP */
				state->registers[IP] += 2;
				state->registers[IP] = operand0;
				break;
			case 12:	/* CALL */
				state->registers[IP] += 2;
				state->memory[--state->registers[SP]] = state->registers[IP];
				state->registers[IP] = operand0;
				break;
			case 13:	/* RET */
				state->registers[IP] += 1;
				if (state->registers[SP] == 0)
					state->status = INVALID;
				state->registers[IP] = state->memory[state->registers[SP]++];
				break;
			case 14:	/* INPUT */
				state->registers[IP] += 2;
				printf("[IN] ");
				scanf("%u", &read);
				printf("\n");
				state->registers[operand0] = read;
				break;
			case 15:	/* OUTPUT */
				state->registers[IP] += 2;
				printf("[OUT] %i\n\n", state->registers[operand0]);
				break;
			default:
				fprintf(stderr, "Unknown instruction %d\n", (int)opcode);
				exit(1);
		}
	}
}

/* To-do: rewrite */
void VM_printRegs(VM *state) {
	printf("[REGISTERS] AR = 0x%.2X | BP = 0x%.2X | SP = 0x%.2X | IP = 0x%.2X\nNext Instruction: 0x%.2X\nState: %X\n\n", state->registers[AR], state->registers[BP], state->registers[SP], state->registers[IP], state->memory[state->registers[IP]], state->status);
}

/* To-do: rewrite */
void VM_printMemory(VM *state, unsigned char origin, unsigned char rows) {
	printf("[MEMORY]\n");
	while (rows-- > 0) {
		char buffer[8 * 3 + 1];		/* 25 bytes (3 bytes per value, 8 values per row, 1 extra for the NUL terminator) */
		unsigned char idx;
		for (idx = 0; idx < 8 && (unsigned char)(origin + idx) >= origin; idx++)
			sprintf(buffer + (idx * 3), "%.2X ", state->memory[origin + idx]);
		printf("0x%.2X: %s\n", origin, buffer);
		if ((unsigned char)(origin + 8) > origin)
			origin += 8;
		else
			break;
	}
	printf("\n");
}