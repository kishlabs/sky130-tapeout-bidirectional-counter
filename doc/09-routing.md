# Global and Detailed Routing

## Objective

Connect every signal, clock, and power net using legal metal tracks and vias, then produce a routed DEF and router-level DRC report.

## Inputs

| Input | Role |
|---|---|
| `pd/cts.def` | Placement and clock-tree database |
| Sky130 technology and cell LEFs | Routing rules and pin geometries |
| Sky130 Liberty | OpenROAD timing database |
| `constraints/counter.sdc` | Clock constraint |
| `scripts/routing.tcl` | Routing-layer and iteration policy |

## Routing policy

```tcl
set_routing_layers -signal met1-met5 -clock met3-met5
global_route -congestion_iterations 30
detailed_route -droute_end_iter 20
```

Clock routing is restricted to `met3` through `met5`, consistent with the clock RC model used during CTS. Signal routing may use `met1` through `met5`.

## Process

1. Read the CTS database and mark clocks as propagated.
2. Build congestion-aware global routes.
3. Convert global routes into exact track/via geometries.
4. Emit a router DRC report and maze-routing log.
5. Write the routed DEF.

## Outputs

| Output | Description |
|---|---|
| `pd/routed.def` | Fully routed physical database |
| `pd/route_drc.rpt` | Detailed-router DRC report |
| `pd/route_maze.log` | Detailed-router routing log |
| `results/Routing.png` | Routing visualization |

## Reported result

| Metric | Result |
|---|---:|
| Routed signal nets | 71 |
| Special power nets | 2 |
| Total wirelength | 1185 µm |
| Vias | 490 |
| Final routing DRC | 0 violations |
| Detailed-route optimization | Converged after 3 optimization iterations |

The route optimization history was non-monotonic before convergence. That behavior is expected in an iterative router; the acceptance criterion is the final legal result.

## Yield

The stage yields a routed DEF that can be converted to GDSII. Router-level DRC is clean, while independent layout-level DRC is still required because the router operates on abstract cell views.

