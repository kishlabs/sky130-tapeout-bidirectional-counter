# Clock-Tree Synthesis

## Objective

Transform the ideal clock connection into a buffered physical clock tree with legal placement and controlled clock distribution to the eight sequential sinks.

## Inputs

| Input | Role |
|---|---|
| `pd/placement_filled.def` | Filled placement database |
| Sky130 technology and cell LEFs | Physical cell and routing views |
| Sky130 Liberty | Timing and clock-cell data |
| `constraints/counter.sdc` | Clock definition |
| `scripts/cts.tcl` | CTS policy |

## Process

1. Read the filled placement and remove fillers before placement modification.
2. Model clock-wire resistance/capacitance using `met3`.
3. Exclude generic buffers and inverters from CTS.
4. Build the tree using dedicated Sky130 clock buffers.
5. Repair the clock connection from the input pin to the tree root.
6. Re-legalize the inserted buffers.
7. Mark clocks as propagated for downstream timing.
8. Generate CTS/skew reports.
9. Reinsert fillers and write the CTS DEF.

## CTS configuration

| Policy | Value |
|---|---|
| Clock RC layer | `met3` |
| Root buffer | `sky130_fd_sc_hd__clkbuf_16` |
| Allowed buffer list | `clkbuf_8`, `clkbuf_4`, `clkbuf_2` |
| Sink clustering | Enabled |
| Generic buffers/inverters | `dont_use` |

## Outputs

| Output | Description |
|---|---|
| `pd/cts.def` | Clock-buffered physical database |
| `results/cts.png` | Clock-tree visualization |

## Reported result

| Metric | Result |
|---|---:|
| Sequential sinks | 8 |
| Inserted CTS buffers | 3 |
| Clock buffer type observed | `sky130_fd_sc_hd__clkbuf_16` |
| Clock path depth | 2 stages to each sink |
| Reported setup skew | 0.00 ns |
| Final CTS DEF components | 168, including physical-only cells |

## Yield

The stage yields a propagated-clock physical database with an explicit clock tree, legal buffer placement, and reported zero setup skew for the implemented topology.

The result is a CTS metric, not a substitute for full post-route setup/hold sign-off. Final timing closure would require post-route parasitic extraction and STA.

