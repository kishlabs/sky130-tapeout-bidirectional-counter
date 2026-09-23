# Power Delivery Network

## Objective

Create the VDD/VSS distribution structure that connects standard-cell power pins to the core power network and provides legal layer transitions for the physical implementation.

## Inputs

| Input | Role |
|---|---|
| `pd/floorplan.def` | Die, rows, pins, and tracks |
| Sky130 technology and cell LEFs | Physical and connectivity definitions |
| Sky130 Liberty | Loaded for the OpenROAD database |
| `scripts/pdn.tcl` | Power-domain and stripe policy |

## Power-domain policy

| Domain | Cell pins |
|---|---|
| `VDD` | `VPWR`, `VPB` |
| `VSS` | `VGND`, `VNB` |

The script creates a core PDN grid named `core_grid`.

## Physical configuration

| Structure | Layer | Configuration |
|---|---|---|
| Follow-pin rails | `met1` | Width 0.48 µm |
| Core straps | `met4` | Width 0.5 µm, pitch 12 µm, offset 2 µm |
| Inter-layer connection | `met1` to `met4` | `add_pdn_connect` |

The implementation intentionally uses a compact PDN suitable for the small die. A `met5` strap/ring is not introduced in this design.

## Outputs

| Output | Description |
|---|---|
| `pd/pdn.def` | Floorplan plus generated power network |
| `results/pdn.png` | PDN visualization |

The generated DEF contains the special power nets `VDD` and `VSS` and three PDN via definitions.

## Yield

The stage yields a power-connected physical database suitable for placement. The key acceptance point is not the number of stripes alone; it is that the power-domain mapping, rails, straps, and layer connections are represented in the database passed to placement.

## Scope

This documentation records the implemented PDN topology. It does not claim IR-drop or electromigration sign-off because no such analysis report is included in the repository.

