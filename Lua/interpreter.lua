--[[ DOCUMENTATION
	Look at Documentation document
--]]

local interpreterLib = {};
local interpreterMetatable = {__index = interpreterLib};
local registerIndex = {
	[0] = "ar";
	[1] = "br";
	[2] = "sp";
	[3] = "ip";
};

function interpreterLib.new()
	local registers = {ar = 0, br = 0, sp = 0, ip = 0};

	local memory = {};
	for address = 0, 255 do
		memory[address] = 0;
	end

	return setmetatable({
		registers = registers;
		memory = memory;
		status = true;
	}, interpreterMetatable);
end

function interpreterLib:loadProgram(bytecode)
	-- load bytecode from mem[0] -> mem[#bytecode - 1]
	for i = 1,#bytecode do
		self.memory[i-1] = string.byte(bytecode:sub(i,i));
	end
end

function interpreterLib:readByte(count)
	return self.memory[self.registers.ip+count];
end

function interpreterLib:step()
	-- get instruction from IP (make instruction lookup table based on instruction format)
	local memory = self.memory;
	local registers = self.registers;
	local opcode = memory[registers.ip];
	local op0,op1 = self:readByte(1),self:readByte(2);
	local cReg0 = registerIndex[op0];
	local cReg1 = registerIndex[op1];
	if opcode == 0 then -- move
		registers.ip = self.registers.ip + 3;
		registers[cReg0] = registers[cReg1];
	elseif opcode == 1 then -- moveimm
		registers.ip = registers.ip + 3;
		registers[cReg0] = op1;
	elseif opcode == 2 then -- load
		registers.ip = registers.ip + 3;
		registers[cReg0] = self.memory[registers[cReg1]];
	elseif opcode == 3 then -- loadimm
		registers.ip = registers.ip + 3;
		registers[cReg0] = memory[op1];
	elseif opcode == 4 then -- sto
		registers.ip = registers.ip + 2;
		self.memory[registers.br] = registers[cReg0];
	elseif opcode == 5 then -- push
		registers.ip = registers.ip + 2;
		registers.sp = (registers.sp - 1) % 256;
		memory[registers.sp] = registers[cReg0];
	elseif opcode == 6 then -- pop
		registers.ip = registers.ip + 2;
		registers[cReg0] = memory[registers.sp];
		registers.sp = (registers.sp + 1) % 256;
	elseif opcode == 7 then -- add
		registers.ip = registers.ip + 3;
		registers[cReg0] = (registers[cReg0] + self.memory[registers[cReg1]]) % 256;
	elseif opcode == 8 then -- addimm
		registers.ip = registers.ip + 3;
		registers[cReg0] = (registers[cReg0] + op1) % 256;
	elseif opcode == 9 then -- sub
		registers.ip = registers.ip + 3;
		registers[cReg0] = (registers[cReg0] - self.memory[registers[cReg1]]) % 256;
	elseif opcode == 10 then -- subimm
		registers.ip = registers.ip + 3;
		registers[cReg0] = (registers[cReg0] - op1) % 256;
	elseif opcode == 11 then -- jmp
		registers.ip = op0;
	elseif opcode == 12 then -- call
		registers.sp = (registers.sp - 1) % 256;
		memory[registers.sp] = registers.ip + 2;
		registers.ip = op0;
	elseif opcode == 13 then -- ret
		if registers.sp == 0 then
			self.status = false;
		else
			registers.ip = memory[registers.sp];
			registers.sp = (registers.sp + 1) % 256;
		end
	elseif opcode == 14 then -- input
		registers.ip = registers.ip + 2;
		registers[cReg0] = math.floor(io.read("*n") or 0) % 256;
	elseif opcode == 15 then -- output
		registers.ip = registers.ip + 2;
		print("[OUT] " .. registers[cReg0]);
	else
		error("Invalid instruction: "..opcode);
	end
end

function interpreterLib:interpretAll()
	while self.status do
		self:step();
	end
end



--[[
	[00] MOVimm ar, 7		; ARG 2
	[03] PUSH ar
	[05] MOVimm ar, 10		; ARG 1
	[08] PUSH ar
	[10] CALL 20
	[12] ADDimm sp, 2
	[15] OUT sp
	[17] OUT ar
	[19] RET

	[20] MOV br, sp
	[23] ADDimm br, 1
	[26] LOAD ar, br
	[29] ADDimm br, 1
	[32] ADD ar, br
	[35] RET
--]]

local instructions = {
	"\1\0\50",
	"\5\0",
	"\1\0\69",
	"\5\0",
	"\12\20",
	"\8\2\2",
	"\15\2",
	"\15\0",
	"\13",
	"\0\1\2",
	"\8\1\1",
	"\2\0\1",
	"\8\1\1",
	"\7\0\1",
	"\13"
};

local ns = interpreterLib.new();
ns:loadProgram(table.concat(instructions, ""));
ns:interpretAll();