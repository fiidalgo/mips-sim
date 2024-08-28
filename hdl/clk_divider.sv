module clk_divider
    #(parameter N = 28)  // Parameterized bit-width, default is 28-bit
    (
        input logic clk, rst,         // Clock and reset signals
        input logic [N-1:0] max,      // Maximum count value for the clock divider
        output logic out_clk,         // Divided clock output
        // for debugging
        output logic dbg_out          // Debugging output to monitor the clock state
    );

    // Internal registers to hold the current count and the next count value
    logic [N-1:0] r_reg;
    logic [N-1:0] r_next;
    
    // Sequential logic to update the current count or reset it
    always_ff @(posedge clk, posedge rst)
        if (rst)
            r_reg <= 0;  // Reset the count to 0 when reset is asserted
        else
            r_reg <= r_next;  // Update the count with the next value
    
    // Sequential logic to control the output clocks based on the count value
    always_ff @(posedge clk, posedge rst)
        if (rst) begin
            out_clk <= 0;  // Reset the output clock to 0 when reset is asserted
            dbg_out <= 0;  // Reset the debug output to 0
        end
        else if (r_reg == max / 2)
            dbg_out <= 0;  // Set the debug output to 0 at half the max count (half duty-cycle)
        else if (r_reg == max) begin
            out_clk <= ~out_clk;  // Set the output clock high when the count reaches the max value
            dbg_out <= 1;  // Set the debug output high when the count reaches the max value
        end
        else
            out_clk <= 0;  // Otherwise, keep the output clock low

    // Combinational logic to determine the next count value
    assign r_next = (r_reg >= max) ? 0 : r_reg + 1;  // Reset the count or increment it
endmodule
