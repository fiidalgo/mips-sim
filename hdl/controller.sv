`include "cpu.svh"  // Include the system verilog header file for CPU definitions

// Controller module
// This module controls the various signals required for the execution of MIPS instructions
module controller
    (
        input  logic clk_100M, clk_en, rst,  // Clock, clock enable, and reset signals
        input  logic [5:0] op,               // Opcode of the instruction
        input  logic [5:0] funct,            // Function field for R-type instructions
        output logic IorD, AluSrcA,          // Control signals for data path selection
        output logic [1:0] MemtoReg, PCSrc, RegDst,  // Control signals for register selection and data routing
        output logic [3:0] AluOp,            // ALU operation control signal
        output logic [2:0] AluSrcB,          // Control signal for ALU source B
        output logic IRWrite, PCWrite, RegWrite,  // Control signals for writing to IR, PC, and registers
        output logic Branch, BranchCtrl, MemWrite  // Control signals for branching and memory write
    );
    
    // Enumeration of states for the finite state machine (FSM)
    typedef enum {
        Fetch, Decode, 
        Execute, 
        MemAdr, MemRead, MemWriteBack, SMemWrite,  // Memory access states
        JrExecute,  // Execute JR instruction
        BneExecute,  // Execute BNE instruction
        BeqExecute,  // Execute BEQ instruction
        JExecute,  // Execute J instruction
        JalExecute, JalWrite,  // Execute JAL instruction and write return address
        AddiExecute, AndiExecute, OriExecute, XoriExecute, SltiExecute, IWrite,  // Immediate instruction execution and write-back
        AluWriteback  // ALU write-back state
    } state_t;
    state_t state, next_state;  // Current state and next state variables
    
    // State transition on the rising edge of the clock or reset signal
    always_ff @(posedge clk_en, posedge rst) begin
        if (rst) begin
            state <= Fetch;  // Reset state to Fetch
        end
        else if (clk_en) begin
            state <= next_state;  // Transition to the next state
        end
    end
    
    // Combinational logic for determining control signals based on the current state
    always_comb begin
        unique case (state)
            // Fetch state: Fetch the instruction and prepare for the next cycle
            Fetch: begin    
                IorD       = 1'b0;
                AluSrcA    = 1'b0;
                AluSrcB    = 3'b001;
                AluOp      = 4'b0101;
                PCSrc      = 2'b00;
                IRWrite    = 1'b1;
                PCWrite    = 1'b1;
                RegWrite   = 1'b0;
                MemWrite   = 1'b0;
                Branch     = 1'b0;
                BranchCtrl = 1'b0;
                MemtoReg   = 2'b00;
                
                next_state = Decode;  // Transition to Decode state
            end
            
            // Decode state: Decode the instruction and determine the next state
            Decode: begin
                AluSrcA = 1'b0;
                AluSrcB = 3'b011;
                AluOp   = 4'b0101;
                IRWrite = 1'b0;
                PCWrite = 1'b0;
                
                if (op == `OP_RTYPE && funct == `F_JR) next_state = JrExecute;
                else if (op == `OP_RTYPE)              next_state = Execute;
                else if (op == `OP_LW || op == `OP_SW) next_state = MemAdr;
                else if (op == `OP_BNE)                next_state = BneExecute;
                else if (op == `OP_BEQ)                next_state = BeqExecute;
                else if (op == `OP_J)                  next_state = JExecute;
                else if (op == `OP_JAL)                next_state = JalExecute;
                else if (op == `OP_ADDI)               next_state = AddiExecute;
                else if (op == `OP_ANDI)               next_state = AndiExecute;
                else if (op == `OP_ORI)                next_state = OriExecute;
                else if (op == `OP_XORI)               next_state = XoriExecute;
                else if (op == `OP_SLTI)               next_state = SltiExecute;
            end
            
            // Address calculation for memory access (load/store)
            MemAdr: begin
                AluSrcA = 1'b0;
                AluSrcB = 3'b010;
                AluOp   = 4'b0101;
                
                if (op == `OP_LW) next_state = MemRead;
                else if (op == `OP_SW) next_state = SMemWrite;
            end
            
            // Memory read state: Access memory to load data
            MemRead: begin
                IorD = 1'b1;
                next_state = MemWriteBack;  // Transition to write-back state
            end
            
            // Write back loaded data to the register
            MemWriteBack: begin
                RegDst   = 2'b01;
                MemtoReg = 2'b01;
                RegWrite = 1'b1;
                next_state = Fetch;  // Return to Fetch state
            end
            
            // Memory write state: Store data into memory
            SMemWrite: begin
                IorD     = 1'b1;
                MemWrite = 1'b1;
                next_state = Fetch;  // Return to Fetch state
            end 
            
            // Execute JR instruction: Jump to register address
            JrExecute: begin
                AluSrcA = 1'b1;
                AluSrcB = 3'b000;
                AluOp   = `ALU_ADD;
                PCSrc   = 2'b00;
                PCWrite = 1'b1;
                next_state = Fetch;  // Return to Fetch state
            end
            
            // Execute BNE instruction: Branch if not equal
            BneExecute: begin
                AluSrcA    = 1'b1;
                AluSrcB    = 3'b000;
                AluOp      = `ALU_SUB;
                PCSrc      = 2'b01;
                BranchCtrl = 1'b1;
                Branch     = 1'b1;
                next_state = Fetch;  // Return to Fetch state
            end
            
            // Execute BEQ instruction: Branch if equal
            BeqExecute: begin
                AluSrcA    = 1'b1;
                AluSrcB    = 3'b000;
                AluOp      = `ALU_SUB;
                PCSrc      = 2'b01;
                BranchCtrl = 1'b0;
                Branch     = 1'b1;
                next_state = Fetch;  // Return to Fetch state
            end 
            
            // Execute J instruction: Unconditional jump
            JExecute: begin
                PCSrc   = 2'b10;
                PCWrite = 1'b1;
                next_state = Fetch;  // Return to Fetch state
            end
            
            // Execute JAL instruction: Jump and link
            JalExecute: begin
                AluSrcA = 1'b0;
                AluSrcB = 3'b100;
                AluOp   = `ALU_ADD;
                PCSrc   = 2'b10;
                PCWrite = 1'b1;
                next_state = JalWrite;  // Transition to write return address
            end
            
            // Write return address for JAL instruction
            JalWrite: begin
                RegDst   = 2'b10;
                MemtoReg = 2'b10;
                RegWrite = 1'b1;
                PCWrite  = 1'b0;
                next_state = Fetch;  // Return to Fetch state
            end
            
            // Execute R-type instructions
            Execute: begin
                AluSrcA = 1'b1;
                AluSrcB = 3'b000;
                
                // Determine the ALU operation based on the function field
                if (funct == `F_AND)      AluOp = `ALU_AND;
                else if (funct == `F_OR)  AluOp = `ALU_OR;
                else if (funct == `F_XOR) AluOp = `ALU_XOR;
                else if (funct == `F_NOR) AluOp = `ALU_NOR;
                else if (funct == `F_SLL) AluOp = `ALU_SLL;
                else if (funct == `F_SRL) AluOp = `ALU_SRL;
                else if (funct == `F_SRA) AluOp = `ALU_SRA;
                else if (funct == `F_SLT) AluOp = `ALU_SLT;
                else if (funct == `F_ADD) AluOp = `ALU_ADD;
                else                      AluOp = `ALU_SUB;            
                
                next_state = AluWriteback;  // Transition to ALU write-back state
            end
            
            // Write back ALU result to the register
            AluWriteback: begin
                RegDst   = 2'b01;
                MemtoReg = 2'b00;
                RegWrite = 1'b1;
                next_state = Fetch;  // Return to Fetch state
            end
            
            // Execute ADDI instruction
            AddiExecute: begin
                AluSrcA = 1'b1;
                AluSrcB = 3'b010;
                AluOp   = `ALU_ADD;
                next_state = IWrite;  // Transition to immediate write-back state
            end
            
            // Execute ANDI instruction
            AndiExecute: begin
                AluSrcA = 1'b1;
                AluSrcB = 3'b010;
                AluOp   = `ALU_AND;
                next_state = IWrite;  // Transition to immediate write-back state
            end
            
            // Execute ORI instruction
            OriExecute: begin
                AluSrcA = 1'b1;
                AluSrcB = 3'b010;
                AluOp   = `ALU_OR;
                next_state = IWrite;  // Transition to immediate write-back state
            end
            
            // Execute XORI instruction
            XoriExecute: begin
                AluSrcA = 1'b1;
                AluSrcB = 3'b010;
                AluOp   = `ALU_XOR;
                next_state = IWrite;  // Transition to immediate write-back state
            end
            
            // Execute SLTI instruction
            SltiExecute: begin
                AluSrcA = 1'b1;
                AluSrcB = 3'b010;
                AluOp   = `ALU_SLT;
                next_state = IWrite;  // Transition to immediate write-back state
            end
            
            // Write back immediate instruction result to the register
            IWrite: begin
                RegDst   = 2'b00;
                MemtoReg = 2'b00;
                RegWrite = 1'b1;
                next_state = Fetch;  // Return to Fetch state
            end 
        endcase
    end
endmodule
