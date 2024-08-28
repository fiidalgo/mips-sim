// Register with asynchronous reset and synchronous enable
// This module implements a register that can be reset asynchronously and
// updated synchronously based on an enable signal.

module reg_en
    #(
        parameter N = 32,    // Width of the register (default is 32 bits)
        parameter INIT = 0   // Initial value of the register after reset (default is 0)
    )
    (
        input logic clk, rst,       // Clock and asynchronous reset signals
        input logic en,             // Synchronous enable signal
        input logic [N-1:0] d,      // Data input to the register
        output logic [N-1:0] q      // Data output from the register
    );
    
    // Always block to update the register value
    // The register is reset asynchronously on the rising edge of 'rst'.
    // When 'en' is high and 'rst' is low, the register is updated with the value of 'd' on the rising edge of 'clk'.
    always_ff @(posedge clk, posedge rst)
        if (rst)
            q <= INIT;  // Asynchronously reset the register to the initial value
        else if (en)
            q <= d;     // Synchronously load the register with the input data when 'en' is high
endmodule
