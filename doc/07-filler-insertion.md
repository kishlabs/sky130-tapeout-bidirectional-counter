# Physical-Only Filler Insertion

## Objective

Populate legal gaps between standard cells with Sky130 filler cells so that well continuity and power-rail continuity are maintained across the standard-cell rows.

## Inputs

| Input | Role |
|---|---|
| `pd/placement.def` | Legalized placed logic |
| Sky130 technology and cell LEFs | Filler geometry and connectivity |
| `scripts/fill.tcl` | Filler-cell selection and checks |

## Process

The flow uses the following filler family:

```text
sky130_fd_sc_hd__fill_1
sky130_fd_sc_hd__fill_2
sky130_fd_sc_hd__fill_4
sky130_fd_sc_hd__fill_8
```

OpenROAD inserts fillers, checks placement legality, and writes the filled database.

## Outputs

| Output | Description |
|---|---|
| `pd/placement_filled.def` | Placement database with physical-only filler cells |
| Filler inventory | 101 filler cells in the final physical design |

## Yield

Filler insertion closes a physical continuity requirement that is invisible at the RTL and standard-cell logical-netlist levels. In this project, the filler step was essential to resolving independent Magic DRC violations associated with n-well spacing and cell-row continuity.

## CTS handoff discipline

CTS reads `pd/placement_filled.def` and immediately executes `remove_fillers` before adding clock buffers. This prevents physical-only cells from consuming placement capacity during a placement-modifying stage. Fillers are restored after CTS.

## Engineering takeaway

Physical-only cells are not optional decoration. They affect manufacturing-rule compliance and must be inserted and removed at the correct points in the flow.

