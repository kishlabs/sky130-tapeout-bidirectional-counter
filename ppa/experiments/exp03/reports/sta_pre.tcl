read_liberty /home/kumar/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog ppa/experiments/exp03/synth/up_down_counter_synth.v

link_design up_down_counter
read_sdc constraints/counter.sdc

report_checks -path_delay max -group_path_count 10 -format full_clock_expanded
report_checks -path_delay min -group_path_count 10 -format full_clock_expanded
report_worst_slack -max
report_worst_slack -min
report_tns
report_clock_skew
report_clock_min_period
report_design_area
