# Global and Detailed Placement

## Objective

Place the synthesized standard cells into legal rows while balancing wirelength and density, then verify that no cells overlap or violate placement legality.

## Inputs

| Input | Role |
|---|---|
| `pd/pdn.def` | Floorplan and PDN database |
| Sky130 LEF/Liberty views | Physical and timing data |
| `constraints/counter.sdc` | Clock constraint |
| `scripts/placement.tcl` | Placement and legality checks |

## Process

```tcl
global_placement -density 0.60
detailed_placement
check_placement
write_def pd/placement.def
```

- **Global placement** performs analytic placement and optimizes approximate wirelength/congestion.
- **Detailed placement** legalizes cells onto actual sites and rows.
- **Placement checking** verifies that the final database is legal rather than assuming the optimizer succeeded.

## Outputs

| Output | Description |
|---|---|
| `pd/placement.def` | Legalized placed database |
| `results/Placement.png` | Placement visualization |

## Reported result

The project records detailed placement with **0 legality violations**. The placement visualization shows the standard-cell population distributed across the core rows.

The configured global-placement density is `0.60`.

## Yield

The stage yields a legal placement database suitable for filler insertion and clock-tree synthesis. It preserves the synthesized logic and PDN while assigning every design cell a legal physical location.

## Why this stage matters

Placement is where the abstract synthesized netlist first becomes a physically constrained design. Density, row capacity, pin accessibility, and clock distribution quality become practical constraints rather than purely logical concerns.

