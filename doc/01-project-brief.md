# Project Brief

## Objective

Implement and physically realize an 8-bit synchronous bidirectional counter in the SkyWater Sky130A process. The project demonstrates the complete digital ASIC implementation path from synthesizable RTL through routed layout and independent physical verification.

The circuit is intentionally compact. The engineering value is in the complete, inspectable flow: technology mapping, physical constraints, clock distribution, routing, physical-only cell insertion, GDSII generation, and sign-off DRC.

## Functional contract

| Signal | Direction | Width | Definition |
|---|---:|---:|---|
| `clk` | Input | 1 | Positive-edge-triggered clock |
| `rst_n` | Input | 1 | Active-low synchronous reset |
| `en` | Input | 1 | Enables state updates when asserted |
| `up_down` | Input | 1 | `1`: increment; `0`: decrement |
| `count` | Output | 8 | Current counter state |
| `tc` | Output | 1 | Terminal-count indication |

Behavior:

- On a rising edge with `rst_n = 0`, `count` becomes `0`.
- On a rising edge with `rst_n = 1` and `en = 1`, `count` increments or decrements according to `up_down`.
- With `en = 0`, the state holds.
- `tc` is asserted when counting up at `8'hFF` or counting down at `8'h00`.
- Arithmetic wraps naturally at the 8-bit boundary.

## Technology and constraints

| Item | Project choice |
|---|---|
| PDK | SkyWater Sky130A |
| Standard-cell library | `sky130_fd_sc_hd` |
| Library corner | `tt_025C_1v80` |
| Clock constraint | `create_clock -name clk -period 10 [get_ports clk]` |
| Target frequency | 100 MHz |
| Physical implementation tool | OpenROAD |
| Layout and DRC tool | Magic |

## Inputs

- `rtl/up_down_counter.v` — synthesizable RTL.
- `tb/up_down_counter_tb.v` — directed simulation testbench.
- `constraints/counter.sdc` — clock definition.
- Sky130 technology LEF, standard-cell LEF, Liberty, and GDS views.

## Outputs

- Verified RTL behavior and waveform.
- Sky130-mapped gate-level netlist.
- DEF database for each physical implementation stage.
- Routed GDSII layout.
- Independent Magic DRC result.

## Acceptance boundary

The project is physically closed through DRC. LVS is explicitly listed as pending and is not presented as complete.

