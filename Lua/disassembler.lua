-- Disassembler --
-- THIS IS THE OLD DISASSEMBLER, WILL UPDATE TO THE NEW ONE WHEN I GET IT

local instructionLegend = {
	["0"] = {"MOV",3}, -- instructionName,totalSize
	["1"] = {"MOVimm",3},
	["2"] = {"LOAD",3},
	["3"] = {"LOADimm",3},
	["4"] = {"STO",2},
	["5"] = {"PUSH",2},
	["6"] = {"POP",2},
	["7"] = {"ADD",3},
	["8"] = {"ADDimm",3},
	["9"] = {"SUB",3},
	["10"] = {"SUBimm",3},
	["11"] = {"JMP",2},
	["12"] = {"CALL",2},
	["13"] = {"RET",1},
	["14"] = {"INPUT",2},
	["15"] = {"OUTPUT",2}
};

local registerLegend = {
	[0] = "ar";
	[1] = "br";
	[2] = "sp";
	[3] = "ip";
};

local bytecode = {
	"\1\0\2",
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

bytecode = table.concat(bytecode,"");

local assembly = "";

local skipUntil = 0;
for i = 1,#bytecode do
	if i == skipUntil or skipUntil == 0 then
		local byte = tostring(string.byte(bytecode:sub(i,i)));
		local instructionName = instructionLegend[byte][1];
		local instructionSize = instructionLegend[byte][2];
		local operand0 = "";
		local operand1 = "";
		local byteInc,byteInc2 = string.byte(bytecode:sub(i+1,i+1)),  string.byte(bytecode:sub(i+2,i+2));
		if instructionSize == 3 then
			operand0 = registerLegend[byteInc] and registerLegend[byteInc] or byteInc;
			if instructionName:match("imm") then
				operand1 = byteInc2;
			else
				operand1 = registerLegend[byteInc2];
			end
		elseif instructionSize == 2 then
			operand0 = registerLegend[byteInc] and registerLegend[byteInc] or byteInc;
		end
		skipUntil = i + instructionSize;
		instructionName = instructionName.." ";
		operand0 = operand1 ~= "" and operand0..", " or operand0;
		assembly = assembly..instructionName..operand0..operand1.."\n";
	end
end
