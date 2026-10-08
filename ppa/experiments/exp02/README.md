# Exp02: Shared Arithmetic and Reduction Terminal Detection

Exp02 is an exact-behavior PPA candidate derived from Exp01.

The candidate preserves:

- the same `up_down_counter` module interface;
- active-low synchronous reset;
- enable-controlled state updates;
- 8-bit modulo wraparound;
- combinational, direction-aware terminal count.

The RTL changes the arithmetic to one shared add operation, using `8'h01`
for increment and `8'hFF` for decrement, and expresses terminal detection
with reduction operators.

Exp02 is accepted only if simulation passes and the measured Sky130 synthesis
and physical-design results improve against Exp01.
