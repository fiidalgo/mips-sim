module disp_hex_mux
    (
        input  logic clk, reset,                                     // Clock and reset signals
        input  logic [3:0] hex7, hex6, hex5, hex4, hex3, hex2, hex1, hex0, // 4-bit hex digits to be displayed
        input  logic [7:0] dp_in,                                    // 8 decimal points (1 per digit)
        output logic [7:0] an,                                       // Enable signals for the 7-segment displays
        output logic [7:0] sseg                                      // Segments for the 7-segment displays
    );

    // Parameter declaration
    localparam N = 18;  // Counter width to create a refresh rate around 800 Hz (50 MHz / 2^16)
    
    // Internal signal declarations
    logic [N-1:0] q_reg;  // Register to hold the current counter value
    logic [N-1:0] q_next; // Next state of the counter
    logic [3:0] hex_in;   // Current hex digit to be displayed
    logic dp;             // Current decimal point to be displayed

    // N-bit counter to generate a refresh rate for the display
    // Register logic to store the counter value
    always_ff @(posedge clk, posedge reset)
        if (reset)
            q_reg <= 0;  // Reset the counter to 0 on reset
        else
            q_reg <= q_next;  // Update the counter with the next value

    // Next-state logic for the counter
    assign q_next = q_reg + 1;  // Increment the counter on each clock cycle

    // Multiplexing logic to control which digit is enabled and which hex digit is displayed
    // The 3 MSBs of the counter determine which digit is currently active
    always_comb begin
        case (q_reg[N-1:N-3])  // Use the 3 most significant bits to select the digit
            3'b000: begin
                an = 8'b11111110;  // Enable the first digit (hex0)
                hex_in = hex0;      // Select the hex digit to display
                dp = dp_in[0];      // Select the corresponding decimal point
            end
            3'b001: begin
                an = 8'b11111101;  // Enable the second digit (hex1)
                hex_in = hex1;     // Select the hex digit to display
                dp = dp_in[1];     // Select the corresponding decimal point
            end
            3'b010: begin
                an = 8'b11111011;  // Enable the third digit (hex2)
                hex_in = hex2;     // Select the hex digit to display
                dp = dp_in[2];     // Select the corresponding decimal point
            end
            3'b011: begin
                an = 8'b11110111;  // Enable the fourth digit (hex3)
                hex_in = hex3;     // Select the hex digit to display
                dp = dp_in[3];     // Select the corresponding decimal point
            end
            3'b100: begin
                an = 8'b11101111;  // Enable the fifth digit (hex4)
                hex_in = hex4;     // Select the hex digit to display
                dp = dp_in[4];     // Select the corresponding decimal point
            end
            3'b101: begin
                an = 8'b11011111;  // Enable the sixth digit (hex5)
                hex_in = hex5;     // Select the hex digit to display
                dp = dp_in[5];     // Select the corresponding decimal point
            end
            3'b110: begin
                an = 8'b10111111;  // Enable the seventh digit (hex6)
                hex_in = hex6;     // Select the hex digit to display
                dp = dp_in[6];     // Select the corresponding decimal point
            end
            3'b111: begin
                an = 8'b01111111;  // Enable the eighth digit (hex7)
                hex_in = hex7;     // Select the hex digit to display
                dp = dp_in[7];     // Select the corresponding decimal point
            end
        endcase
    end

    // Hex to seven-segment LED display decoding
    // This logic converts a 4-bit hex digit to the corresponding 7-segment display code
    always_comb begin
       case(hex_in)
            4'h0: sseg[6:0] = 7'b1000000; // Display 0
            4'h1: sseg[6:0] = 7'b1111001; // Display 1
            4'h2: sseg[6:0] = 7'b0100100; // Display 2
            4'h3: sseg[6:0] = 7'b0110000; // Display 3
            4'h4: sseg[6:0] = 7'b0011001; // Display 4
            4'h5: sseg[6:0] = 7'b0010010; // Display 5
            4'h6: sseg[6:0] = 7'b0000010; // Display 6
            4'h7: sseg[6:0] = 7'b1111000; // Display 7
            4'h8: sseg[6:0] = 7'b0000000; // Display 8
            4'h9: sseg[6:0] = 7'b0010000; // Display 9
            4'ha: sseg[6:0] = 7'b0001000; // Display A
            4'hb: sseg[6:0] = 7'b0000011; // Display b
            4'hc: sseg[6:0] = 7'b1000110; // Display C
            4'hd: sseg[6:0] = 7'b0100001; // Display d
            4'he: sseg[6:0] = 7'b0000110; // Display E
            default: sseg[6:0] = 7'b0001110; // Display F
        endcase
      sseg[7] = dp; // Set the decimal point based on the selected digit
    end
endmodule
