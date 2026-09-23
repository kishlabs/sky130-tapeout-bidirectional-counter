# Logic Synthesis

## Objective

Convert the RTL into a technology-mapped gate-level netlist using real Sky130 HD standard cells. This creates the logical implementation consumed by physical design and establishes the initial area baseline.

## Inputs

| Input | Role |
|---|---|
| `rtl/up_down_counter.v` | RTL source |
| `scripts/synth.ys` | Yosys flow control |
| Sky130 HD Liberty | Sequential mapping, combinational mapping, and area data |
| Top module | `up_down_counter` |

The Liberty corner used by the script is `tt_025C_1v80`.

## Process

```text
read_verilog
  -> synth -top up_down_counter
  -> dfflibmap
  -> abc
  -> opt_clean -purge
  -> stat -liberty
  -> write_verilog
```

- Generic sequential elements are mapped with `dfflibmap`.
- Generic combinational logic is mapped with ABC.
- Cleanup removes redundant implementation artifacts.
- Library-aware statistics are generated before writing the output netlist.

## Outputs

| Output | Description |
|---|---|
| `synth/up_down_counter_synth.v` | Sky130-mapped gate-level Verilog |
| `synth/synth_log.txt` | Yosys execution log and statistics |

## Reported result

| Metric | Result |
|---|---:|
| Technology-mapped cells | 64 |
| Sequential cells | 8 × `sky130_fd_sc_hd__dfxtp_1` |
| Combinational cells | 56 |
| Reported area baseline | 500.48 µm² |
| Sequential area | 160.1536 µm² |
| Processes remaining | 0 |
| Memories | 0 |
| Yosys check problems | 0 |

The eight flip-flops are expected from the 8-bit state vector and are confirmed in the mapped netlist.

## Yield

The synthesis stage yields a fully technology-mapped netlist with no RTL processes or memories remaining. The netlist is structurally suitable for OpenROAD physical implementation.

## Scope of the result

The area value is a synthesis baseline. It is not the final die area and it does not constitute post-route timing or power sign-off. Those require physical parasitics and dedicated analysis reports.

