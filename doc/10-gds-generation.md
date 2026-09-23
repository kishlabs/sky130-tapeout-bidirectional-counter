# GDSII Generation

## Objective

Convert the routed DEF and Sky130 cell-layout data into a stream-format GDSII database suitable for layout inspection and physical sign-off.

## Inputs

| Input | Role |
|---|---|
| `pd/routed.def` | Routed top-level physical database |
| Sky130 standard-cell GDS | Layout geometry for library cells |
| Sky130 technology and cell LEFs | DEF/GDS interpretation and layer mapping |
| `scripts/gds.tcl` | Magic import and export procedure |

## Process

Magic:

1. Reads the Sky130 LEF views.
2. Reads the Sky130 standard-cell GDS library.
3. Imports `pd/routed.def`.
4. Loads the `up_down_counter` top cell.
5. Expands the hierarchy.
6. Writes the top-level GDSII stream.

## Output

| Output | Description |
|---|---|
| `results/up_down_counter.gds` | Final routed GDSII database |
| `results/up_down_counter_gds_overview.png` | Full-layout view |
| `results/up_down_counter_gds_zoomed.png` | Cell-level layout view |

## Yield

The stage yields a hierarchical physical layout containing the routed design and instantiated Sky130 standard-cell geometry. The GDSII is the physical artifact consumed by independent Magic DRC.

## Review note

The overview and zoomed screenshots serve different purposes:

- The overview demonstrates die-scale organization and routing density.
- The zoomed view makes standard-cell boundaries, fillers, and clock buffers visually inspectable.

