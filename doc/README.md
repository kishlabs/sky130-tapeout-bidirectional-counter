# ASIC Implementation Documentation

## 8-bit Sky130 Bidirectional Counter

This documentation presents the project as an auditable RTL-to-GDSII implementation rather than as a collection of tool commands. Each stage explains:

- **Objective** — why the stage exists in an ASIC flow.
- **Inputs** — design data, technology views, and constraints consumed.
- **Implementation** — the important decisions and transformations.
- **Outputs** — the artifacts produced for the next stage.
- **Yield / acceptance criteria** — what the stage delivered and how it was checked.
- **Evidence** — the repository files that support the result.

The flow uses open-source tools and the SkyWater Sky130A PDK:

```text
RTL
  -> Simulation and lint
  -> Yosys synthesis
  -> OpenROAD floorplan
  -> Power delivery network
  -> Placement and legalization
  -> Filler insertion
  -> Clock-tree synthesis
  -> Global and detailed routing
  -> Magic GDSII generation
  -> Independent Magic DRC
```

## Executive result

| Item | Result |
|---|---|
| Design | 8-bit synchronous up/down counter |
| Target technology | SkyWater Sky130A, `sky130_fd_sc_hd` |
| Target clock | 100 MHz, 10 ns period |
| Technology-mapped cells | 64 before physical-only cells |
| Final standard-cell inventory | 64 logic/sequence cells + 3 CTS buffers + 101 fillers |
| Die | 37.35 µm × 37.35 µm |
| Reported chip area baseline | 500.48 µm² |
| Routed wirelength | 1185 µm |
| Routed vias | 490 |
| Routing DRC | 0 violations |
| Independent Magic sign-off DRC | 0 violations |
| LVS | Not yet run |

## Stage documents

| Stage | Document | Primary artifacts |
|---|---|---|
| 0 | [Project brief](01-project-brief.md) | RTL contract, interfaces, architecture |
| 1 | [Verification](02-verification.md) | Testbench, VCD, GTKWave evidence |
| 2 | [Synthesis](03-synthesis.md) | Yosys netlist and synthesis log |
| 3 | [Floorplanning](04-floorplanning.md) | `pd/floorplan.def` |
| 4 | [Power planning](05-power-planning.md) | `pd/pdn.def` |
| 5 | [Placement](06-placement.md) | `pd/placement.def` |
| 6 | [Filler insertion](07-filler-insertion.md) | `pd/placement_filled.def` |
| 7 | [Clock-tree synthesis](08-cts.md) | `pd/cts.def` |
| 8 | [Routing](09-routing.md) | `pd/routed.def`, `pd/route_drc.rpt` |
| 9 | [GDSII generation](10-gds-generation.md) | `results/up_down_counter.gds` |
| 10 | [DRC sign-off](11-drc-signoff.md) | Magic DRC result and screenshots |
| 11 | [LVS status](12-lvs-status.md) | Current closure gap |

## How to read the results

The repository distinguishes between:

- **Measured values**: directly present in a report or generated artifact.
- **Configured values**: explicitly selected in a script.
- **Derived engineering conclusions**: interpretations based on the flow and its evidence.
- **Unavailable values**: metrics that were not generated and are therefore not claimed.

This distinction is intentional. In a professional ASIC review, a credible sign-off record is more valuable than an impressive number without a traceable source.

## Reproduction entry points

The executable flow scripts are under `scripts/`. Run them in sequence from the repository root:

```bash
iverilog -o sim rtl/up_down_counter.v tb/up_down_counter_tb.v
vvp sim
verilator --lint-only -Wall rtl/up_down_counter.v
yosys -s scripts/synth.ys
openroad scripts/floorplan.tcl
openroad scripts/pdn.tcl
openroad scripts/placement.tcl
openroad scripts/fill.tcl
openroad scripts/cts.tcl
openroad scripts/routing.tcl
```

GDSII generation and Magic DRC require a Sky130 Magic technology setup. The exact commands are documented in the repository README and in the stage documents above.

