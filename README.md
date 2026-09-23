# sky130-rtl2gds-bidirectional-counter

### Open-Source RTL-to-GDSII Physical Design Flow on the SkyWater Sky130 PDK

[![Flow](https://img.shields.io/badge/flow-RTL--to--GDSII-blue)]()
[![PDK](https://img.shields.io/badge/PDK-Sky130A-orange)]()
[![DRC](https://img.shields.io/badge/DRC-0%20violations-brightgreen)]()
[![License](https://img.shields.io/badge/license-MIT-lightgrey)]()

<p align="center">
  <img src="results/up_down_counter_gds_overview.png" width="70%" alt="Final GDSII layout of the counter">
</p>

## What this is

This project takes an 8-bit synchronous up/down counter all the way from a blank Verilog file to a **manufacturable GDSII layout**, running every stage of the ASIC physical design flow by hand — Yosys for synthesis, OpenROAD for floorplanning through routing, Magic for GDSII generation and sign-off DRC — on the real, open-source SkyWater Sky130 process.

## Engineering documentation

The complete stage-by-stage implementation record is available in [`doc/README.md`](doc/README.md). It documents the objective, inputs, implementation decisions, outputs, acceptance criteria, measured results, and sign-off boundary for every major stage of the flow.

The counter itself is intentionally simple. The point of this repository isn't the circuit — it's the flow: every stage below was actually run, its output actually read and cross-checked against the stage before it, and at least two real bugs were found, root-caused, and fixed along the way rather than engineered around. That process — and the evidence for it — is what this README documents.

---

## Why manual, not OpenLane

This project deliberately runs each EDA tool directly — Yosys, OpenROAD, Magic, Netgen — rather than through an automated flow orchestrator. The goal wasn't the fastest path to a GDS file; it was to actually understand what each stage does and why, including reading every log, cross-checking numbers between independent tools, and tracing real bugs back to their root cause instead of just re-running until errors disappeared.

---

## Tool Chain

| Stage | Tool |
|---|---|
| RTL simulation | Icarus Verilog, GTKWave |
| Lint | Verilator |
| Logic synthesis | Yosys |
| Floorplanning · Power Planning · Placement · CTS · Routing | OpenROAD |
| GDSII generation · DRC | Magic VLSI |
| LVS | Netgen *(pending — see [Status](#project-status))* |
| PDK | SkyWater Sky130A (`sky130_fd_sc_hd`) |

---

## Design

An 8-bit synchronous up/down counter — simple enough to fully understand every stage of the flow, complex enough to exercise the complete tool chain (sequential timing, clock tree synthesis, real routing congestion).

| Signal | Dir | Width | Description |
|---|---|---|---|
| `clk` | in | 1 | Clock |
| `rst_n` | in | 1 | Active-low, **synchronous** reset |
| `en` | in | 1 | Count enable |
| `up_down` | in | 1 | 1 = count up, 0 = count down |
| `count` | out | 8 | Current count |
| `tc` | out | 1 | Terminal count — combinational, asserted at `0xFF` (counting up) or `0x00` (counting down) |

Target clock: **100 MHz** (10 ns period, `constraints/counter.sdc`)

---

## Verification

Simulated in Icarus Verilog, waveform-inspected in GTKWave, and independently lint-clean in Verilator.

**A real bug was found and fixed during testbench development**, worth noting on its own merit: boundary-condition tests (overflow/underflow/terminal count) forced the DUT's register directly to reach edge values without simulating hundreds of clock cycles. The first version raced against a pending non-blocking update from the prior clock edge, silently overwriting the forced value. Fixed by moving forced assignments to `negedge clk`, where no DUT update is in flight — and confirmed fixed via the actual `$monitor` trace and waveform, not just re-running until it looked right.

<p align="center">
  <img src="results/GTKWave%20Results.png" width="800" alt="GTKWave simulation showing terminal count and overflow behavior">
</p>

---

## Synthesis (Yosys)

RTL mapped to real Sky130 standard cells via `synth` → `dfflibmap` → `abc`, targeting the `tt_025C_1v80` (typical) timing corner.

| Metric | Value |
|---|---|
| Flip-flops | **8** × `sky130_fd_sc_hd__dfxtp_1` |
| Total cells | 64 |
| Chip area | 500.48 µm² |
| Sequential / Combinational split | 32% / 68% |

The flip-flop count was predicted *before* running synthesis (8 bits → 8 flops) and confirmed against the actual `stat` report — the first of several cross-checks that recur through every later stage.

---

## Physical Design (OpenROAD)

### Floorplan

Die: 37.35 × 37.35 µm · Core: 977.19 µm² · Target utilization 45%, effective 51.2% (core edges snap to the legal site grid, recomputed and confirmed by hand from the reported die/core coordinates). All 13 I/O pins placed on `met2`/`met3`, 0 unconnected.

<p align="center">
  <img src="results/Floorplan.png" width="49%" alt="Floorplan view">
  <img src="results/IO_Floorplan.png" width="49%" alt="I/O pin placement">
</p>

### Power Delivery Network

`met1` rails follow every standard-cell row; a single `met4` strap layer at a pitch scaled to this die's actual size (12 µm) rather than the ~150 µm pitch typical of chip-scale tutorials, which wouldn't fit even once on a 37 µm die. A core ring and `met5` were deliberately omitted — `met5`'s 1.6 µm minimum width is disproportionate to a core this small, and the floorplan margin is too tight for a ring without real DRC risk.

<p align="center">
  <img src="results/pdn.png" width="600" alt="Power delivery network">
</p>

### Placement

Global placement (RePlAce/Nesterov, target density 0.60) → detailed legalization with **0 violations**. Average cell displacement 2.6 µm.

<p align="center">
  <img src="results/Placement.png" width="600" alt="Cell placement">
</p>

### Clock Tree Synthesis

8 sinks, split by TritonCTS into two branches of 4 under a single root buffer — uniform path depth of exactly 2 buffer stages to every flop.

| Metric | Value |
|---|---|
| Buffers inserted | 3 (`sky130_fd_sc_hd__clkbuf_16`) |
| Path depth | 2 – 2 (uniform) |
| **Setup skew** | **0.00 ns** |

<p align="center">
  <img src="results/cts.png" width="600" alt="Clock tree synthesis">
</p>

### Routing

Global routing (FastRoute) → detailed routing (TritonRoute), converged to **0 DRC violations** after 3 optimization iterations (violations went 8 → 13 → 17 → 0 — a non-monotonic search is expected behavior, not a red flag; the number that matters is where it converges).

| Metric | Value |
|---|---|
| Total wirelength | 1185 µm |
| Vias | 490 (mostly `li1`/`met1` intra-cell contacts) |

<p align="center">
  <img src="results/Routing.png" width="600" alt="Routing / congestion view">
</p>

---

## GDSII & Sign-off DRC

TritonRoute's own DRC pass explicitly **skipped** `LEF58_ENCLOSURE` checks (unsupported `CUTCLASS` syntax on via layers) — a known gap in this router version, not a clean bill of health. An independent Magic DRC run on the final GDS was run specifically to close that gap.

**It found something real:** 17 `nwell.2a` n-well spacing violations — a transistor-level rule that no digital place-and-route stage checks, since P&R only ever sees LEF abstractions of each cell, never the internal well geometry. Root cause: no filler/tap cells had been inserted after detailed placement, leaving gaps in the n-well and power rails between adjacent standard cells.

**Fix:** `filler_placement` (101 `sky130_fd_sc_hd__fill_*` cells) inserted after detailed placement, with CTS and routing correctly re-run from the filled placement (fillers must be removed before any placement-modifying step and restored after — running CTS with stale fillers still present initially blew utilization past 100%, an error worth learning from, not hiding).

CTS and routing were verified **identical** before and after the filler fix (same 8 sinks/3 buffers/0.00 skew, same 1185 µm wirelength/490 vias) — confirming fillers are purely physical and never touched anything electrical.

**Final independent DRC: 0 errors.**

---

## Final Layout (GDSII)

Two views of the signed-off layout — a full-die overview for overall structure, and a zoomed section where individual cells (a flip-flop, a filler, a clock buffer) are actually legible.

<p align="center">
  <img src="results/up_down_counter_gds_overview.png" width="48%" alt="Full-die GDSII layout, labels off">
  <img src="results/up_down_counter_gds_zoomed.png" width="48%" alt="Zoomed-in cell-level GDSII detail">
</p>

*Full-die view captured with cell/net labels turned off (Magic's layer menu) — at this scale, labels just overlap into noise. Zoomed view captured by box-zooming into 2-3 rows so individual cell boundaries and names are readable.*

---

## Results Summary

| Metric | Value |
|---|---|
| Standard cells | 64 logic + 3 CTS buffers + 101 fillers = 168 |
| Flip-flops | 8 |
| Chip area | 500.48 µm² |
| Die / Core | 37.35×37.35 µm / 977.19 µm² |
| Utilization | 51.2% (58.9% post-CTS) |
| Setup skew | 0.00 ns |
| Total wirelength | 1185 µm |
| Routing DRC | 0 violations |
| **Independent sign-off DRC (Magic)** | **0 violations** (17 found and fixed — see above) |

---

## Project Status

- [x] RTL design + testbench (race condition found and fixed)
- [x] Lint (Verilator, clean)
- [x] Synthesis (Yosys)
- [x] Floorplan
- [x] Power delivery network
- [x] Placement
- [x] Clock tree synthesis
- [x] Routing
- [x] GDSII generation
- [x] Independent sign-off DRC (Magic) — 0 violations
- [ ] LVS (Netgen) — not yet run

The one item left unchecked above is left unchecked deliberately — everything else in this README is backed by a log or screenshot in this repo.

---

## Repository Structure

```
.
├── rtl/            RTL source
├── tb/             Testbench
├── constraints/     Timing constraints (SDC)
├── synth/          Yosys netlist + synthesis log
├── scripts/        Every OpenROAD/Magic Tcl script, in flow order
├── pd/             DEF output from every physical design stage
├── results/        Screenshots, GDSII, DRC report
└── README.md
```

## Reproducing This Flow

```bash
# Simulation
iverilog -o sim rtl/up_down_counter.v tb/up_down_counter_tb.v && vvp sim

# Lint
verilator --lint-only -Wall rtl/up_down_counter.v

# Synthesis
yosys -s scripts/synth.ys

# Physical design (run in order)
openroad scripts/floorplan.tcl
openroad scripts/pdn.tcl
openroad scripts/placement.tcl
openroad scripts/fill.tcl
openroad scripts/cts.tcl
openroad scripts/routing.tcl

# GDSII + sign-off DRC
magic -dnull -noconsole -rcfile <path-to-sky130A.magicrc> scripts/gds.tcl
magic -dnull -noconsole -rcfile <path-to-sky130A.magicrc> scripts/drc.tcl
```

---

## Author

**Kishore Kumar Subramanian**
Aspiring VLSI Engineer — RTL Design, Verification & Physical Design · Bangalore, India

[GitHub](https://github.com/kishlabs) · [LinkedIn](https://linkedin.com/in/kishorekumargcee) · [Email](mailto:kishorekumargcee@gmail.com)

## License

MIT
