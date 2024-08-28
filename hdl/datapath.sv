`include "cpu.svh"  // Include CPU-related definitions and constants

module datapath(
        input  logic clk_100M, clk_en, rst,            // Clock, clock enable, and reset signals
        input  logic [31:0] r_data,                    // Data read from memory
        input  logic IorD, AluSrcA,                    // Control signals for ALU and memory addressing
        input  logic [1:0] PCSrc, MemtoReg, RegDst,    // Control signals for selecting PC, memory, and register file inputs
        input  logic [3:0] AluOp,                      // ALU operation code
        input  logic IRWrite, PCWrite, RegWrite,       // Control signals for instruction register, PC, and register file writing
        input  logic Branch, BranchCtrl,               // Branch control signals
        input  logic [31:0] currentPC,                 // Current value of the Program Counter (PC)
        input  logic [2:0] AluSrcB,                    // Control signal for selecting ALU source B
        output logic [31:0] newPC,                     // Next value of the Program Counter (PC)
        output logic PCEn,                             // Program Counter enable signal
        output logic [31:0] AluResult, AluOut, B,      // ALU result, ALU output register, and B register values
        output logic [31:0] instruction                // Current instruction being executed
    );
    
    // Internal signals for data and register values
    logic [31:0] rd1, rd2, SrcA, SrcB, w_data, data, w_addr, A;
    logic [4:0] rs, rt, rd;                 // Register addresses
    logic [31:0] sign_ext_imm;              // Sign-extended immediate value
    logic AluZero;                          // ALU zero flag
    
    // Instruction Register: Holds the current instruction
    reg_en reg_en_instruction (
        .clk (clk_100M),
        .rst (rst),
        .en (clk_en & IRWrite),             // Enabled when IRWrite is asserted
        .d (r_data),                        // Load the instruction from memory
        .q (instruction)                    // Output the current instruction
    );
    
    // Data Register: Holds the data read from memory
    reg_en reg_en_r_data (
        .clk (clk_100M),
        .rst (rst),
        .en (clk_en),                       // Always enabled during clock cycles
        .d (r_data),                        // Load data from memory
        .q (data)                           // Output the data
    );
    
    // Write Data Mux: Selects the source of data to be written to the register file
    always_comb begin
        case (MemtoReg)
            2'b00: w_data = AluOut;         // Write ALU output to register file
            2'b01: w_data = data;           // Write data from memory to register file
            2'b10: w_data = AluOut;         // (Unused case) Write ALU output to register file
        endcase
    end
    
    // Write Address Mux: Selects the destination register for writing
    always_comb begin
        case (RegDst)
            2'b00: w_addr = instruction[20:16]; // Use rt field for I-type instructions
            2'b01: w_addr = instruction[15:11]; // Use rd field for R-type instructions
            2'b10: w_addr = 5'b11111;            // Use $ra (register 31) for JAL instruction
        endcase
    end
    
    // Register File: Holds the general-purpose registers
    reg_file my_reg_file (
        .clk (clk_100M),
        .wr_en (RegWrite),                  // Enabled when RegWrite is asserted
        .w_addr (w_addr),                   // Write address selected by the mux
        .r0_addr (instruction[25:21]),      // Read address for rs (source register 0)
        .r1_addr (instruction[20:16]),      // Read address for rt (source register 1)
        .w_data (w_data),                   // Data to write to the register file
        .r0_data (rd1),                     // Data read from register rs
        .r1_data (rd2)                      // Data read from register rt
    );
    
    // Flip-flop: Holds the value of register rs (Source A)
    reg_en reg_en_Src1 (
        .clk (clk_100M),
        .rst (rst),
        .en (clk_en),                       // Always enabled during clock cycles
        .d (rd1),                           // Load data from register file (rs)
        .q (A)                              // Output the data to Source A
    );
    
    // Flip-flop: Holds the value of register rt (Source B)
    reg_en reg_en_Src2 (
        .clk (clk_100M),
        .rst (rst),
        .en (clk_en),                       // Always enabled during clock cycles
        .d (rd2),                           // Load data from register file (rt)
        .q (B)                              // Output the data to Source B
    );
    
    // Source A Mux: Selects the first operand for the ALU
    always_comb begin 
        case (AluSrcA)
            1'b0: SrcA = currentPC;         // Use Program Counter (PC) as the first operand
            1'b1: SrcA = A;                 // Use register A as the first operand
        endcase
    end
    
    // Source B Mux: Selects the second operand for the ALU
    always_comb begin
        case (AluSrcB)
            3'b000: SrcB = B;                                   // Use register B as the second operand
            3'b001: SrcB = 4;                                   // Use constant 4 (for PC increment)
            3'b010: SrcB = {{16{instruction[15]}}, instruction[15:0]}; // Sign-extend the immediate value
            3'b011: SrcB = {{16{instruction[15]}}, instruction[15:0]} << 2; // Sign-extend and shift the immediate value
            3'b100: SrcB = 0;                                   // Use constant 0 (for certain operations)
        endcase
    end
    
    // ALU: Performs arithmetic and logic operations
    alu my_alu (
        .x (SrcA),                        // First operand
        .y (SrcB),                        // Second operand
        .op (AluOp),                      // ALU operation code
        .z (AluResult),                   // ALU result output
        .zero (AluZero)                   // Zero flag (1 if result is zero)
    );
    
    // Program Counter Enable Mux: Determines whether the PC should be updated
    always_comb begin
        case (BranchCtrl)
            1'b0: PCEn = (AluZero & Branch) | PCWrite; // PC updated if branch condition is met or PCWrite is asserted
            1'b1: PCEn = (AluResult & Branch) | PCWrite; // Alternate condition for updating PC
        endcase
    end
    
    // Flip-flop: Stores the ALU result (used in the next clock cycle)
    reg_en reg_en_AluResult (
        .clk (clk_100M),
        .rst (rst),
        .en (clk_en),                     // Always enabled during clock cycles
        .d (AluResult),                   // Load ALU result
        .q (AluOut)                       // Output stored ALU result
    );
    
    // New Program Counter Mux: Selects the next value of the Program Counter (PC)
    always_comb begin 
        case (PCSrc[1:0])
            2'b00: newPC = AluResult;                              // Use ALU result as the next PC value
            2'b01: newPC = AluOut;                                 // Use stored ALU result as the next PC value
            2'b10: newPC = {currentPC[31:28], instruction[25:0] << 2}; // Use jump target address for the next PC value
        endcase
    end
    
endmodule
