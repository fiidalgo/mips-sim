// Base address for instruction memory in MIPS architecture
`define I_START_ADDRESS 32'h00400000  // Instructions start at address 0x00400000

// ALU op-codes: These define the operations the ALU can perform
`define ALU_AND 4'b0000  // Perform bitwise AND
`define ALU_OR  4'b0001  // Perform bitwise OR
`define ALU_XOR 4'b0010  // Perform bitwise XOR
`define ALU_NOR 4'b0011  // Perform bitwise NOR (inverted OR)
`define ALU_ADD 4'b0101  // Perform addition
`define ALU_SUB 4'b0110  // Perform subtraction
`define ALU_SLT 4'b0117  // Set on less than (signed comparison)
`define ALU_SRL 4'b1000  // Perform logical right shift
`define ALU_SLL 4'b1001  // Perform logical left shift
`define ALU_SRA 4'b1010  // Perform arithmetic right shift

// R-Type funct: Function field values for R-type instructions
`define F_AND 6'b100100  // AND: rd = rs & rt
`define F_OR  6'b100101  // OR: rd = rs | rt
`define F_XOR 6'b100110  // XOR: rd = rs ^ rt
`define F_NOR 6'b100111  // NOR: rd = ~(rs | rt)
`define F_SLL 6'b000000  // SLL: rd = rt << sa (shift left logical)
`define F_SRL 6'b000010  // SRL: rd = rt >> sa (shift right logical)
`define F_SRA 6'b000011  // SRA: rd = rt >> sa (shift right arithmetic)
`define F_SLT 6'b101010  // SLT: rd = (rs < rt) ? 1 : 0 (set on less than)
`define F_ADD 6'b100000  // ADD: rd = rs + rt
`define F_SUB 6'b100010  // SUB: rd = rs - rt
`define F_JR  6'b001000  // JR: Jump to address in register rs

// I-Type op-code: Operation codes for I-type instructions (immediate)
`define OP_ANDI 6'b001100 // ANDI: rt = rs & imm (bitwise AND with immediate)
`define OP_ORI  6'b001101 // ORI: rt = rs | imm (bitwise OR with immediate)
`define OP_XORI 6'b001110 // XORI: rt = rs ^ imm (bitwise XOR with immediate)
`define OP_SLTI 6'b001010 // SLTI: rt = (rs < imm) ? 1 : 0 (set on less than immediate)
`define OP_ADDI 6'b001000 // ADDI: rt = rs + imm (add immediate)
`define OP_BEQ  6'b000100 // BEQ: Branch if rs == rt (branch on equal)
`define OP_BNE  6'b000101 // BNE: Branch if rs != rt (branch on not equal)
`define OP_LW   6'b100011 // LW: Load word, rt = mem[rs + offset]
`define OP_SW   6'b101011 // SW: Store word, mem[rs + offset] = rt

// J-Type op-code: Operation codes for J-type instructions (jump)
`define OP_J   6'b000010 // J: Jump to address
`define OP_JAL 6'b000011 // JAL: Jump and link, reg[31] = pc + 4, pc = addr

// R-Type base op-code: All R-Type instructions have this opcode
`define OP_RTYPE 6'b000000 // R-Type instruction base opcode
