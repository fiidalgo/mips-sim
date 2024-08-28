`include "cpu.svh"  // Include CPU-related definitions and constants

module rw_ram
    #(
        parameter I_LENGTH = 512,  // Length of instruction memory in words
        parameter I_WIDTH = 9,     // Width of instruction memory address in bits
        parameter D_LENGTH = 1024, // Length of data memory in words
        parameter D_WIDTH = 10     // Width of data memory address in bits
    )
    (
        input logic clk_100M,      // 100 MHz clock signal
        input logic clk_en,        // Clock enable signal
        input logic wr_en,         // Write enable signal
        input logic [31:0] addr,   // Address for memory access
        input logic [31:0] w_data, // Data to be written to memory
        output logic [31:0] r_data,// Data read from memory
        // Debugging signals (used in synthesis)
        input logic [31:0] rdbg_addr,   // Debug address for memory
        output logic [31:0] rdbg_data   // Debug data output from memory
    );

    // Memory arrays for instruction memory (imem) and data memory (dmem)
    logic [31:0] imem [0:I_LENGTH-1];  // Instruction memory
    logic [31:0] dmem [0:D_LENGTH-1];  // Data memory

    // Internal signals for data registers and control logic
    logic [31:0] data_reg;             // Register to hold read data
    logic [31:0] dbg_data_reg;         // Register to hold debug data
    logic i, idbg, wr_i_en, wr_d_en;   // Flags for instruction/data memory access

    // Physical addresses for instruction and data memory accesses
    logic [I_WIDTH-1:0] phy_i_addr, phy_idbg_addr; // Instruction memory addresses
    logic [D_WIDTH-1:0] phy_d_addr, phy_ddbg_addr; // Data memory addresses

    // Determine if the address is for instruction memory or data memory
    assign i = (addr >= `I_START_ADDRESS);        // True if accessing instruction memory
    assign idbg = (rdbg_addr >= `I_START_ADDRESS);// True if debug access is for instruction memory
    assign wr_i_en = i & wr_en;  // Write enable for instruction memory
    assign wr_d_en = ~i & wr_en; // Write enable for data memory

    // Calculate physical addresses by shifting out the lower 2 bits (word alignment)
    assign phy_i_addr = addr[I_WIDTH+1:2];        // Physical address for instruction memory
    assign phy_d_addr = addr[D_WIDTH+1:2];        // Physical address for data memory
    assign phy_idbg_addr = rdbg_addr[I_WIDTH+1:2];// Physical debug address for instruction memory
    assign phy_ddbg_addr = rdbg_addr[D_WIDTH+1:2];// Physical debug address for data memory

    // Initialize memory contents from files
    initial begin
        $readmemh("data.mem", dmem);  // Load data memory from "data.mem"
        $readmemh("instr.mem", imem); // Load instruction memory from "instr.mem"
    end

    // Write data to data memory on a rising clock edge if enabled
    always_ff @(posedge clk_100M) begin
        if (wr_d_en && clk_en)
            dmem[phy_d_addr] <= w_data; // Write data to data memory
    end

    // Write data to instruction memory on a rising clock edge if enabled
    always_ff @(posedge clk_100M) begin
        if (wr_i_en && clk_en)
            imem[phy_i_addr] <= w_data; // Write data to instruction memory
    end

    // Read data from the appropriate memory (instruction or data)
    assign r_data = i ? imem[phy_i_addr] : dmem[phy_d_addr]; // Read data from memory

    // Read debug data from the appropriate memory (instruction or data)
    assign rdbg_data = idbg ? imem[phy_idbg_addr] : dmem[phy_ddbg_addr]; // Read debug data
endmodule
