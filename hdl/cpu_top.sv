module cpu_top
    (
        input logic clk_100M,      // 100 MHz clock signal
        input logic [15:0] sw,     // Input switches for control and debugging
        input logic reset_n,       // Active-low reset signal
        output logic [0:0] led,    // Output LED indicator
        output logic [7:0] an,     // Output for 7-segment display anodes
        output logic [7:0] sseg    // Output for 7-segment display segments
    );

    logic clk_en, clk_dbg, rst;
    assign rst = ~reset_n;           // Active-low reset logic
    assign led[0] = clk_dbg;         // LED indicates clock debug signal

    logic [27:0] divide_sw;
    assign divide_sw = sw[5:0] << 20; // Create clock division value from lower 6 bits of switches

    // Instantiate clock divider to generate an enable signal for the CPU
    clk_divider clk_div_unit (
        .clk(clk_100M), 
        .rst(1'b0),
        .max(divide_sw),
        .out_clk(clk_en),
        .dbg_out(clk_dbg)
    );

    // Signals for memory and register file operations
    logic wr_en;
    logic [31:0] mem_addr, w_data, r_data;
    logic [31:0] mem_rdbg_data, rf_rdbg_data, instr;
    logic [7:0]  rdbg_addr;           // Debug address derived from switches
    logic [4:0]  rf_rdbg_addr;        // Register file debug address
    logic [31:0] mem_rdbg_addr;       // Memory debug address

    // Assign debug addresses based on switch input
    assign rdbg_addr = sw[13:6];                         // Use middle bits of switches for debug address
    assign rf_rdbg_addr = rdbg_addr[4:0];                // Lower 5 bits for register file debug address
    assign mem_rdbg_addr = {22'd0, rdbg_addr << 2};      // Align memory debug address to word boundaries

    // Instantiate the RAM module
    rw_ram ram_unit (
        .clk_100M(clk_100M),
        .clk_en(clk_en),
        .wr_en(wr_en),
        .addr(mem_addr),
        .w_data(w_data),
        .r_data(r_data),
        .rdbg_addr(mem_rdbg_addr),
        .rdbg_data(mem_rdbg_data)
    );

    // Instantiate the CPU module
    cpu cpu_unit (
        .clk_100M(clk_100M),
        .clk_en(clk_en),
        .rst(rst),
        .r_data(r_data),
        .wr_en(wr_en),
        .mem_addr(mem_addr),
        .w_data(w_data),
        .rdbg_addr(rf_rdbg_addr),
        .rdbg_data(rf_rdbg_data),
        .instr(instr)
    );

    // Signal to be displayed on the 7-segment display
    logic [31:0] disp;
    
    // Select the signal to be displayed on the 7-segment display based on the switch settings
    always_comb begin
        case (sw[15:14]) // Use the upper 2 bits of switches to select the display source
            2'b?1: disp = instr;          // Display instruction code
            2'b00: disp = rf_rdbg_data;   // Display register file debug data
            2'b10: disp = mem_rdbg_data;  // Display memory debug data
        endcase
    end

    // Instantiate the 7-segment display multiplexer
    disp_hex_mux disp_unit (
        .clk(clk_100M),
        .reset(1'b0),
        .hex7(disp[31:28]), 
        .hex6(disp[27:24]),
        .hex5(disp[23:20]), 
        .hex4(disp[19:16]), 
        .hex3(disp[15:12]),
        .hex2(disp[11:8]), 
        .hex1(disp[7:4]), 
        .hex0(disp[3:0]),
        .dp_in(8'b11111111),  // All decimal points off
        .an(an),
        .sseg(sseg)
    );
endmodule
