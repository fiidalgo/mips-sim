`include "cpu.svh" // Include the system verilog header file for the CPU definitions

// ALU (Arithmetic Logic Unit) module
// This ALU performs a variety of arithmetic and logic operations on two inputs x and y
module alu
    #(parameter N = 32)  // Parameterized width of the inputs and output, default is 32-bit
    (
        input logic signed [N-1:0] x,    // First operand, signed
        input logic signed [N-1:0] y,    // Second operand, signed
        input logic [3:0] op,            // Operation code to determine which operation to perform
        output logic [N-1:0] z,          // Result of the operation
        output logic zero                // Flag to indicate if the result is zero
    );

    always_comb begin
        z = 0; // Initialize the result to 0
        case (op)  // Select the operation based on the op code
            `ALU_AND: z = x & y;          // Perform bitwise AND
            `ALU_OR: z = x | y;           // Perform bitwise OR
            `ALU_XOR: z = x ^ y;          // Perform bitwise XOR
            `ALU_NOR: z = ~(x | y);       // Perform bitwise NOR
            `ALU_ADD: z = x + y;          // Perform addition
            `ALU_SUB: z = x - y;          // Perform subtraction
            `ALU_SLT: z = x < y;          // Set if less than (signed comparison)
            `ALU_SRL: z = x >> y;         // Perform logical right shift
            `ALU_SLL: z = x << y;         // Perform logical left shift
            `ALU_SRA: z = x >>> y;        // Perform arithmetic right shift
            // Note: Additional ALU operations can be added here as needed
        endcase
    end

    // The zero flag is set to 1 if the result z is 0
    assign zero = (z == 32'b0);
endmodule
