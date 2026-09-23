# Physical DRC Sign-off

## Objective

Verify the final GDSII against layout design rules independently of the digital router, including geometry inside standard-cell abstractions that OpenROAD cannot inspect.

## Inputs

| Input | Role |
|---|---|
| `results/up_down_counter.gds` | Final layout database |
| Sky130 Magic technology setup | Rule deck and layer semantics |
| `scripts/drc.tcl` | DRC execution |
| `scripts/drc_detail.tcl` | Detailed DRC inspection |

## Two-level verification

### Router-level check

OpenROAD detailed routing emits `pd/route_drc.rpt`. The final route converged with zero reported routing violations.

### Independent layout-level check

Magic reads the generated GDSII and runs:

```tcl
drc catchup
drc count
```

This check is independent of OpenROAD's abstract-cell view.

## Issue found and corrected

The first independent Magic run found 17 `nwell.2a` spacing violations. The root cause was the absence of filler/tap continuity after detailed placement. These violations were not visible to placement and routing because digital P&R operates on LEF abstracts rather than transistor-level well geometry.

The correction was:

1. Insert Sky130 filler cells after detailed placement.
2. Remove fillers before CTS and routing modifications.
3. Reinsert fillers in the final physical database.
4. Re-run CTS and routing from the corrected database.
5. Re-run independent Magic DRC.

The final independent DRC result is **0 violations**.

## Outputs

| Output | Description |
|---|---|
| DRC result | 0 violations after correction |
| `results/up_down_counter_gds_overview.png` | Sign-off layout overview |
| `results/up_down_counter_gds_zoomed.png` | Detailed layout inspection view |

## Yield

The project is physically clean with respect to the executed Magic DRC checks. This is the strongest completed sign-off milestone in the repository.

## Scope and limitation

DRC cleanliness does not prove logical equivalence between the extracted layout and the source netlist. LVS remains a separate, pending verification step.

