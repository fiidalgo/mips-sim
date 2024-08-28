# MIPS CPU Implementation in Verilog

This repository contains a Verilog implementation of a simple MIPS CPU. The CPU supports a basic set of MIPS instructions, including arithmetic, logic, memory access, and control flow operations. The design includes a 32x32 register file, ALU, datapath, controller, and additional components necessary to execute instructions.

## Project Structure

### Files and Modules

- **cpu.svh**: Header file containing definitions for instruction opcodes, ALU operation codes, and other constants used throughout the design.

- **cpu.v**: The top-level module of the CPU, which integrates the datapath and controller modules to create a functioning MIPS processor.

- **datapath.v**: Contains the datapath implementation, including the register file, ALU, and logic for updating the program counter.

- **controller.v**: Implements the control unit of the CPU, generating control signals based on the instruction opcode and function fields.

- **reg_file.v**: Implements the 32x32 register file, allowing two simultaneous reads and one write per clock cycle.

- **alu.v**: Implements the arithmetic logic unit (ALU), capable of performing arithmetic and logic operations specified by the control signals.

- **clk_divider.v**: Generates a slower clock signal by dividing the main clock, used for timing control in the CPU.

- **disp_hex_mux.v**: Controls the multiplexing of 7-segment displays for visual output of hex values, typically used for debugging on FPGA boards.

- **reg_en.v**: Implements a register with an asynchronous reset and synchronous enable, used in various parts of the datapath.

- **reg_reset.v**: Implements a register with an asynchronous reset, used in the datapath for storing intermediate results.

- **rw_ram.v**: Implements the memory interface, allowing read and write operations to both instruction and data memory.

### Testbenches

- **cpu_tb.v**: Testbench for simulating the CPU. It drives the clock and reset signals and monitors the CPU's outputs to verify correct operation.

## How to Run the Simulation

### Prerequisites

- **Verilog Simulator**: Ensure you have a Verilog simulator like ModelSim, VCS, or Icarus Verilog installed.
- **Vivado**: If you are targeting an FPGA, you should have Xilinx Vivado installed to synthesize and implement the design.

### Running the Simulation

1. Compile the Verilog files using your preferred simulator.
2. Run the `cpu_tb.v` testbench to simulate the CPU.
3. Observe the outputs in the waveform viewer to verify the CPU's operation.

### Synthesizing the Design (for FPGA)

1. Open Xilinx Vivado and create a new project.
2. Add all the Verilog source files to the project.
3. Set the top module to `cpu.v`.
4. Synthesize, implement, and generate the bitstream.
5. Program your FPGA with the generated bitstream.

## Using the CPU on an FPGA

### Loading Instructions and Data

- Place the assembled machine code in the `asm/instr.mem` file.
- Data can be initialized in `asm/data.mem`.
- Use the provided scripts to load these memory files into the FPGA design (`tcl.sh refresh` in Vivado).

### Debugging

- The `disp_hex_mux.v` module allows you to observe register values or other internal signals on a 7-segment display connected to the FPGA.
- The `rdbg_addr` and `rdbg_data` ports in the `reg_file.v` module are designed for debugging purposes, allowing you to inspect the contents of specific registers.

## Acknowledgments

- **Xilinx Vivado**: For providing the tools necessary for FPGA synthesis and implementation.
- **Verilog HDL**: The hardware description language used to design and implement the MIPS CPU.
- **MIPS Architecture**: The architecture upon which this CPU design is based.