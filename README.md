# MattyDavy
A fun little side project created for educational purposes.

*MattyDavy* is a very simple instruction set with no conditional instructions, this does not represent my real work; this project is pretty much a joke, it's purely for recreational (and slightly educational) purposes.

**Documentation**
- https://www.dropbox.com/s/514j56uho0kbtlo/MattyDavy%20Instruction%20Set%201.docx

**Credits**
- Instruction Set/Documentation: *Matthew* (CntKillMe)
- Lua-sided *MattyDavy* VM, Assembler, and Disassembler: *David* (CeaselessSoul)
- C-sided *MattyDavy* VM: *Matthew*
- Assembly(x86)-sided *MattyDavy* VM: *Matthew* (see note below)

The assembly-sided VM's instruction set slightly differs from the original instruction set. The original one actually contains a few mistakes (*ADD, ADDIMM, SUB, SUBIMM*) where memory was used for the second operand. As such, the C-sided and Lua-sided VM differs from the assembly-sided VM. No changes will be made to the VMs implemented in C or Lua, however if needed it's a simple fix. The *correct* instruction set is in a markdown file in the *ASM* folder.

**CntVM:** https://github.com/cntkillme/CntVM
A more realistic project.
