# Floorplanning and I/O Planning

## Objective

Create the physical canvas for the synthesized design: die/core boundaries, legal standard-cell rows, routing tracks, and boundary I/O pins.

## Inputs

| Input | Role |
|---|---|
| `synth/up_down_counter_synth.v` | Technology-mapped netlist |
| Sky130 technology LEF | Routing technology and manufacturing rules |
| Sky130 HD standard-cell LEF | Cell dimensions, pins, and sites |
| Sky130 HD Liberty | Timing library loaded for downstream analysis |
| `constraints/counter.sdc` | Clock definition |
| `scripts/floorplan.tcl` | Floorplan configuration |

## Configuration

```tcl
initialize_floorplan \
  -utilization 45 \
  -aspect_ratio 1.0 \
  -core_space 2 \
  -site {unithd}

make_tracks
place_pins -hor_layers met3 -ver_layers met2
```

The floorplan targets a square aspect ratio and 45% initial utilization. I/O pins are assigned to the die boundary using the specified routing layers.

## Outputs

| Output | Result |
|---|---|
| `pd/floorplan.def` | Initial physical database |
| `results/Floorplan.png` | Floorplan visualization |
| `results/IO_Floorplan.png` | I/O placement visualization |

## Reported physical result

| Metric | Result |
|---|---:|
| Die area | `(0, 0)` to `(37350, 37350)` database units |
| Physical die | 37.35 µm × 37.35 µm |
| I/O pins | 13 |
| Standard-cell rows | 11 |
| Initial target utilization | 45% |
| Signal pin routing assignment | Horizontal `met3`, vertical `met2` |

The generated DEF contains routing tracks for `li1`, `met1`, `met2`, `met3`, `met4`, and `met5`.

## Yield

The stage yields a legal physical canvas with:

- A defined die and core.
- Legal `unithd` placement rows.
- Routing tracks on the available layers.
- All top-level pins represented in the DEF.

This DEF becomes the input to power planning.

