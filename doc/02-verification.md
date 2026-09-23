# RTL Verification and Design Hygiene

## Objective

Establish that the RTL implements the intended counter behavior before synthesis, and generate a waveform that can be inspected independently of the implementation tools.

## Inputs

| Input | Purpose |
|---|---|
| `rtl/up_down_counter.v` | Design under test |
| `tb/up_down_counter_tb.v` | Clock, stimulus, monitoring, and VCD generation |
| Icarus Verilog | Event-driven RTL simulation |
| GTKWave | Waveform inspection |
| Verilator | Lint analysis |

## Verification plan

The testbench exercises:

1. Synchronous reset.
2. Counting up with enable asserted.
3. State hold when enable is deasserted.
4. Counting down.
5. Overflow behavior near `8'hFF`.
6. Underflow behavior near `8'h00`.
7. Terminal-count behavior at both boundaries.

The clock period is 10 ns in the testbench, matching the SDC target.

## Important verification detail

Boundary tests directly place the internal state at `8'hFE`, `8'h01`, `8'hFF`, and `8'h00` to avoid hundreds of setup cycles. The assignments are made on a falling edge so they cannot race with the DUT's positive-edge nonblocking assignment. This is a concrete testbench correctness fix, not merely a cosmetic change.

## Outputs

| Output | Location |
|---|---|
| Simulation executable / console trace | Generated during simulation |
| VCD waveform | `counter.vcd` when the testbench is run |
| Waveform screenshot | `results/GTKWave Results.png` |
| Lint result | Verilator command output |

## Yield and acceptance criteria

- The testbench reaches `Simulation Completed Successfully`.
- The waveform demonstrates enabled counting, state hold, direction changes, wraparound, and terminal-count behavior.
- Verilator lint is clean for the RTL.
- The design has no inferred latches or unintended asynchronous reset behavior.

## Reproduction

```bash
iverilog -o sim rtl/up_down_counter.v tb/up_down_counter_tb.v
vvp sim
verilator --lint-only -Wall rtl/up_down_counter.v
```

## Engineering value

This stage establishes traceability between the behavioral specification and the implementation. It also demonstrates awareness of Verilog event scheduling and the difference between a valid DUT and a reliable testbench.

