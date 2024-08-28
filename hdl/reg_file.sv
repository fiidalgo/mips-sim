// 32x32 Register File
// This module implements a 32x32 register file, where each register is 32 bits wide.
// The register file supports two simultaneous read operations and one write operation per clock cycle.

module reg_file
    #(
        parameter DATA_WIDTH = 32, // Number of bits per register (default is 32)
                  ADDR_WIDTH = 5   // Number of address bits (default is 5, allowing 32 registers)
    )
    (
        input logic clk,                                   // Clock signal
        input logic wr_en,                                 // Write enable signal
        input logic [ADDR_WIDTH-1:0] w_addr, r0_addr, r1_addr, // Write and read addresses
        input logic [DATA_WIDTH-1:0] w_data,               // Data to be written to the register
        output logic [DATA_WIDTH-1:0] r0_data, r1_data,    // Data read from the registers
        // Debug register read
        input logic [ADDR_WIDTH-1:0] rdbg_addr,            // Debug read address
        output logic [DATA_WIDTH-1:0] rdbg_data            // Debug data output
    );

    // Internal memory array to store the register values
    logic [DATA_WIDTH-1:0] regs [0:2**ADDR_WIDTH-1]; // Array of 32 registers, each 32 bits wide

    // Write operation
    // On the rising edge of the clock, if the write enable (wr_en) is asserted,
    // the data (w_data) is written into the register specified by the write address (w_addr).
    always_ff @(posedge clk)
        if (wr_en)
            regs[w_addr] <= w_data; // Write data to the specified register

    // Read operations
    // The module supports two simultaneous read operations:
    // r0_data: Reads the data from the register specified by r0_addr.
    // r1_data: Reads the data from the register specified by r1_addr.
    // If the read address is 0, the output is forced to 0, as register 0 is typically hardwired to 0 in MIPS architecture.
    assign r0_data = r0_addr == 0 ? 0 : regs[r0_addr];
    assign r1_data = r1_addr == 0 ? 0 : regs[r1_addr];

    // Debug read operation
    // rdbg_data: Reads the data from the register specified by rdbg_addr for debugging purposes.
    // Similar to the other read operations, if rdbg_addr is 0, the output is 0.
    assign rdbg_data = rdbg_addr == 0 ? 0 : regs[rdbg_addr];
endmodule
