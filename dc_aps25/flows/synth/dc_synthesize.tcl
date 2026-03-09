#############################################################
# Environmental Libraries
#############################################################
set    TOP       $::env(TOP)
set    PROJ_ROOT $::env(PROJ_ROOT)

#############################################################
# Libraries setup
#############################################################
set target_library $::env(SYNTH_TARGET_DB)

#############################################################
# Folders and Reporting
#############################################################
set REPORTS_DIR   ../../dc_reports/reports_${TOP}
set RESULTS_DIR   ../../dc_reports/netlist_${TOP}

file mkdir ${REPORTS_DIR}
file mkdir ${RESULTS_DIR}

set_host_options -max_cores 4

#############################################################
# Standard settings
#############################################################
set_app_var synthetic_library "dw_foundation.sldb standard.sldb"
set_app_var link_library "* $target_library $synthetic_library"
set_app_var power_enable_minpower true

# Module name settings
set hdlin_shorten_long_module_name true
set hdlin_module_name_limit
#set hdlin_infer_multibit default_all

# Setting for LEC
set_app_var hdlin_enable_hier_map true
set_svf ${RESULTS_DIR}/${TOP}_lec.svf
#############################################################
# Analyze & Elaborate
#############################################################

# Source the dc.tcl file: In case that your design has multiple modules
source ${PROJ_ROOT}/filelists/${TOP}_dc.tcl -echo

# # Pass the pre-elab settings: In case that your design has parameters to be set
# set parameter_list ""
# if { [file exists ${PROJ_ROOT}/sdc/${TOP}_dc_pre_elab_settings.tcl] } {
#     source ${PROJ_ROOT}/sdc/${TOP}_dc_pre_elab_settings.tcl -echo
# }

# # Elaboration
elaborate ${TOP}
# elaborate ${TOP} -parameters $parameter_list
set_verification_top

# link
link

#############################################################
# Constraints
#############################################################
source ${PROJ_ROOT}/flows/synth/config.sdc -echo

#############################################################
# Optimization settings
#############################################################

#set_cost_priority -min_delay
set_app_var compile_register_replication true

#set_multibit_options -default 

set_leakage_optimization true
set_dynamic_optimization true

set simplified_verification_mode_allow_retiming true 
set simplified_verification_mode true                
set verilogout_no_tri true

ungroup -all -flatten

set_optimize_registers true

check_design                          > ${REPORTS_DIR}/check_design_detailed_early.rpt

#set_max_transition 0.05 [all_fanout -from [get_ports hold]]
#set_max_transition 0.05 [all_inputs] 
#############################################################
# Compile - Synthesis
#############################################################
compile_ultra -scan -retime -gate_clock
compile_ultra -incr
optimize_netlist -area
#############################################################
# Configure Scan Insertion
#############################################################
set_scan_configuration -chain_count 1
set_scan_configuration -clock_mixing no_mix

create_port scan_en
create_port scan_in
create_port -direction out scan_out

set_dft_signal -view existing_dft -type ScanEnable -port scan_en
set_dft_signal -view existing_dft -type ScanDataIn -port scan_in
set_dft_signal -view existing_dft -type ScanDataOut -port scan_out
set_dft_signal -view existing_dft -type ScanClock -port clk -timing {49 51}
set_dft_signal -view existing_dft -type Reset -port rst_n -active_state 0

create_test_protocol
dft_drc

preview_dft
insert_dft

dft_drc

#############################################################
# Reporting 
#############################################################
check_design -summary -no_warnings    > ${REPORTS_DIR}/check_design.rpt
check_design                          > ${REPORTS_DIR}/check_design_detailed.rpt
report_scan_path -chain all           > ${REPORTS_DIR}/report_scan_path.rpt
report_design -nosplit                > ${REPORTS_DIR}/report_design.rpt
report_qor                            > ${REPORTS_DIR}/report_qor.rpt
report_multibit                       > ${REPORTS_DIR}/report_multibit.rpt
report_multibit_banking		      > ${REPORTS_DIR}/report_multibit_banking.rpt
report_clock_gating                            > ${REPORTS_DIR}/report_clock_gating.rpt
report_area -nosplit -hierarchy                                          > ${REPORTS_DIR}/report_area_hierarchy.rpt
report_timing -transition_time -nets -attributes -nosplit -max_paths 100 > ${REPORTS_DIR}/report_setup_timing.rpt
report_timing -delay min -transition_time -nets -attributes -nosplit -max_paths 100 > ${REPORTS_DIR}/report_hold_timing.rpt
report_power -analysis_effort high                                       > ${REPORTS_DIR}/report_power_nosaif.rpt
report_constraint -all_violators                                         > ${REPORTS_DIR}/report_constraints.rpt

#############################################################
# Save Design
#############################################################
write_file -format verilog -hierarchy -output ${RESULTS_DIR}/${TOP}.v
write_sdc ${RESULTS_DIR}/${TOP}.sdc
write_file -format ddc -hierarchy -output ${RESULTS_DIR}/${TOP}.ddc
write_scan_def -output ${RESULTS_DIR}/${TOP}_scan.def
check_scan_def -file ${RESULTS_DIR}/${TOP}_scan.def
#write_parasitics

#############################################################
# Exit 
#############################################################
quit

