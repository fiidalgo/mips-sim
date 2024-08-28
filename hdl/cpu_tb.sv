module cpu_tb();
    // Signal declarations for clock, reset, and control signals
    logic clk_100M, clk_en, rst;  // Clock signals and reset
    logic wr_en;                  // Write enable signal
    logic [31:0] mem_addr, w_data, r_data;  // Memory address, write data, read data signals
    logic [31:0] mem_rdbg_data;    // Debug read data from memory
    logic [31:0] instr;            // Instruction signal
    logic [31:0] rdbg_addr;        // Debug address signal
    logic [31:0] rdbg_data;        // Debug data signal
    
    // Instantiation of the memory module (RAM)
    rw_ram ram_unit (
        .clk_100M(clk_100M),      // Clock signal for RAM
        .clk_en(clk_en),          // Clock enable signal
        .wr_en(wr_en),            // Write enable signal
        .addr(mem_addr),          // Address for memory access
        .w_data(w_data),          // Data to write to memory
        .r_data(r_data),          // Data read from memory
        .rdbg_addr(rdbg_addr),    // Debug address for memory
        .rdbg_data(mem_rdbg_data) // Debug data read from memory
    );
   
    // Instantiation of the CPU module
    cpu cpu_unit (
        .clk_100M(clk_100M),        // Clock signal for CPU
        .clk_en(clk_en),            // Clock enable signal
        .rst(rst),                  // Reset signal for CPU
        .r_data(r_data),            // Data read from memory
        .wr_en(wr_en),              // Write enable signal from CPU
        .mem_addr(mem_addr),        // Address for memory access from CPU
        .w_data(w_data),            // Data to write to memory from CPU
        .rdbg_addr(rdbg_addr[4:0]), // Debug address for CPU (5-bit slice)
        .rdbg_data(rdbg_data),      // Debug data signal from CPU
        .instr(instr)               // Current instruction from CPU
    );

    // Initial block to control the reset signal
    initial begin
        rst <= 1;  // Assert reset at the beginning
        #22;       // Wait for 22 time units
        rst <= 0;  // Deassert reset to start the CPU
    end

    // Always block to generate a simple clock signal
    always begin
        clk_en <= 1;    // Enable clock
        clk_100M <= 1;  // Set clock high
        #5;
        clk_en <= 0;    // Disable clock
        clk_100M <= 0;  // Set clock low
        #5;
    end
endmodule
