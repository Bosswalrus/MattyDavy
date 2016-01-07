#ifndef MDVM_H
#define MDVM_H

/* VM REGISTERS */
#define AR 0
#define BP 1
#define SP 2
#define IP 3

/* VM STATE STATUSES */
#define VALID 0
#define INVALID 1

/* VM STRUCTURE AND TYPEDEF */
struct VM {
	unsigned char memory[256];
	unsigned char registers[4];
	unsigned short status;
};
typedef struct VM VM;

/* FUNCTION PROTOTYPES */
VM *VM_newState(void);
void VM_freeState(VM *state);
void VM_reset(VM *state);
char VM_loadProgram(VM *state, size_t size, char *program);
char VM_peek(VM *state, unsigned char disp);
void VM_step(VM *state, char count);
void VM_printRegs(VM *state);
void VM_printMemory(VM *state, unsigned char origin, unsigned char rows);

#endif
