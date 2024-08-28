// Register with Asynchronous Reset
// This module implements a register with an asynchronous reset. The register
// can be reset immediately when the reset signal is asserted and updated
// on the rising edge of the clock.

module reg_reset
    #(
        parameter N = 32  // Width of the register (default is 32 bits)
    )
    (
        input logic clk, rst,          // Clock and asynchronous reset signals
        input logic [N-1:0] d,         // Data input to the register
        output logic [N-1:0] q         // Data output from the register
    );
    
    // Always block to update the register value
    // The register is reset asynchronously on the rising edge of 'rst'.
    // On the rising edge of 'clk', the register is updated with the value of 'd'.
    always_ff @(posedge clk, posedge rst)
        if (rst)
            q <= 0;  // Asynchronously reset the register to 0
        else
            q <= d;  // Synchronously load the register with the input data 'd' on the clock edge
endmodule
