`include "cpu.svh"  // Include the system verilog header file for CPU definitions

module cpu
    (
        input logic clk_100M,       // 100 MHz clock signal
        input logic clk_en,         // Clock enable signal
        input logic rst,            // Reset signal
        input logic [31:0] r_data,  // Data read from memory
        output logic wr_en,         // Write enable signal for memory
        output logic [31:0] mem_addr, w_data,  // Memory address and write data signals
        input logic [4:0] rdbg_addr,           // Debug address for register file
        output logic [31:0] rdbg_data,         // Debug data from register file
        output logic [31:0] instr              // Current instruction being executed
    );
    
    // Internal signals for control and data path connections
    logic IorD, AluSrcA, PCEn, RegWrite, IRWrite, PCWrite, Branch, BranchCtrl;
    logic [1:0] PCSrc, MemWrite, MemtoReg, RegDst;
    logic [2:0] AluSrcB;
    logic [3:0] AluOp;
    logic [31:0] newPC, addr, AluResult, AluOut, B;
    logic [31:0] currentPC;
    
    // Instantiate the controller module, which generates control signals based on the instruction
    controller my_controller 
    (
        .clk_100M(clk_100M),
        .clk_en(clk_en),
        .rst(rst),
        .op(instr[31:26]),          // Opcode field from the instruction
        .funct(instr[5:0]),         // Function field for R-type instructions
        .IorD(IorD),
        .AluSrcA(AluSrcA),
        .MemtoReg(MemtoReg),
        .AluSrcB(AluSrcB),
        .PCSrc(PCSrc),
        .RegDst(RegDst),
        .AluOp(AluOp),
        .IRWrite(IRWrite),
        .PCWrite(PCWrite),
        .RegWrite(RegWrite),
        .Branch(Branch),
        .BranchCtrl(BranchCtrl),
        .MemWrite(wr_en)            // Write enable output connected to memory write enable
    );
    
    // Instantiate the datapath module, which performs the data operations and arithmetic
    datapath my_datapath
    (
        .clk_100M(clk_100M),
        .clk_en(clk_en),
        .rst(rst),
        .r_data(r_data),
        .IorD(IorD),
        .AluSrcA(AluSrcA),
        .MemtoReg(MemtoReg),
        .AluSrcB(AluSrcB),
        .PCSrc(PCSrc),
        .RegDst(RegDst),
        .AluOp(AluOp),
        .IRWrite(IRWrite),
        .PCWrite(PCWrite),
        .RegWrite(RegWrite),
        .Branch(Branch),
        .BranchCtrl(BranchCtrl),
        .currentPC(currentPC),      // Current Program Counter
        .newPC(newPC),              // Next Program Counter value
        .PCEn(PCEn),                // Program Counter enable signal
        .AluResult(AluResult),      // Result of ALU operation
        .AluOut(AluOut),            // ALU output register
        .B(w_data),                 // Write data for memory
        .instruction(instr)         // Current instruction being executed
    );
    
    // Register to hold the Program Counter value
    reg_en #(.INIT(32'h00400000)) reg_en_pc 
    (
        .clk(clk_100M),
        .rst(rst),
        .en(clk_en & PCEn),         // Enable signal for the Program Counter
        .d(newPC),                  // New Program Counter value
        .q(currentPC)               // Current Program Counter value
    );
    
    // MUX to select the memory address source (Program Counter or ALU output)
    always_comb begin
        case (IorD)
            1'b0: mem_addr = currentPC;  // Select Program Counter for instruction fetch
            1'b1: mem_addr = AluOut;     // Select ALU output for memory access
        endcase
    end
    
    // Memory interface and control logic
    // The CPU interacts with external memory using the memory address, write data,
    // and write enable signals. The memory stores instructions and data used by the CPU.
    // The CPU fetches instructions from memory, executes them, and stores results back in memory.
    // The register file stores intermediate results and provides data for operations.
    // The control FSM dictates the flow of data through the CPU depending on the instruction.
    // You can add additional modules and logic to enhance the CPU functionality.
    
    // Note: The memory module is external to the CPU and should be instantiated elsewhere in the design.
    // The interface signals (r_data, wr_en, mem_addr, w_data) connect the CPU to the memory.
    
endmodule
