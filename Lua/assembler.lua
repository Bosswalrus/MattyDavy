-- assembler --
-- THIS IS THE OLD ASSEMBLER, WILL UPDATE TO THE NEW ONE WHEN I GET IT

local assembly = [[
	MOVimm ar, 2
	PUSH ar
	MOVimm ar, 69
	PUSH ar
	CALL lbl
	ADDimm sp, 2
	OUTPUT sp
	OUTPUT ar
	RET
	
	MOV br, sp
	ADDimm br, 1
	LOAD ar, br
	ADDimm br, 1
	ADD ar, br
	RET 
]];

assembly = assembly:gsub("[\t,]","");

local instructionLegend = {
	["MOV"] = "\0",
	["MOVimm"] = "\1",
	["LOAD"] = "\2",
	["LOADimm"] = "\3",
	["STO"] = "\4",
	["PUSH"] = "\5",
	["POP"] = "\6",
	["ADD"] = "\7",
	["ADDimm"] = "\8",
	["SUB"] = "\9",
	["SUBimm"] = "\10",
	["JMP"] = "\11",
	["CALL"] = "\12",
	["RET"] = "\13",
	["INPUT"] = "\14",
	["OUTPUT"] = "\15"
};

local registerLegend = {
	["ar"] = "\0",
	["br"] = "\1",
	["sp"] = "\2",
	["ip"] = "\3"
};

local bytecode = "";

for line in assembly:gmatch("[^\n]+") do
	local tempData = {};
	for key in line:gmatch("%S+") do
		tempData[#tempData+1] = key;
	end
	local instructionName = tempData[1];
	local op0 = tempData[2];
	local op1 = tempData[3];
	local instruction = instructionLegend[instructionName];
	local operand0 = "";
	local operand1 = "";
	if op0 then
		operand0 = instructionName == "CALL" and string.char(op0) or instructionName == "JMP" and string.char(op0) or registerLegend[op0];
	end
	if op1 then
		operand1 = instructionName:match("imm") and string.char(op1) or registerLegend[op1];
	end
	bytecode = bytecode..instruction..operand0..operand1;
end

for i = 1,#bytecode do
	print(string.byte(bytecode:sub(i,i)));
end
