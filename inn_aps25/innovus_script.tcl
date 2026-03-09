set _PRECTS reports/preCTS
set _POSTCTS reports/postCTS
set _POSTROUTE reports/postRoute
set _SIGNOFF reports/signOff
set _SAVE_PRECTS saves/preCTS
set _SAVE_POSTCTS saves/postCTS
set _SAVE_POSTROUTE saves/postRoute
set _SAVE_SIGNOFF saves/signOff
set TOP aps25

setMultiCpuUsage -localCpu 4



# Import design
source Default.globals

init_design

defIn rtl/aps25_cpu_scan_prefixed.def

setDesignMode -process 45
setDesignMode -flowEffort extreme
setDesignMode -congEffort high
setDesignMode -earlyClockFlow true
#setOptMode -holdSlackFixingThreshold 
#setOptMode  -holdTargetSlack 0.005
#setOptMode -setupTargetSlack 0.001
setOptMode -setupTargetSlackForReclaim 0.005
setOptMode -usefulSkewCCOpt extreme
setOptMode -postRouteSetupRecovery true
setOptMode -reclaimArea true
setOptMode -postRouteAreaReclaim setupAware
setOptMode -fixFanoutLoad true
setOptMode -fixHoldAllowSetupTnsDegrade false
setOptMode -postRouteCheckAntennaRules false
setOptMode -verbose true

#set_interactive_constraint_modes gpdk_45_constraint_mode
#set_false_path -from [get_ports hold]
#set_interactive_constraint_modes {}

# Create floorplan
floorPlan -site CoreSite -r 1 0.70 15 15 15 15

# Create power rings
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {VDD VSS} -type core_rings -follow core -layer {top Metal11 bottom Metal11 left Metal10 right Metal10} -width {top 3 bottom 3 left 3 right 3} -spacing {top 3 bottom 3 left 3 right 3} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 1 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None

# Create power stripes

setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring } -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape   }
#addStripe -nets {VDD VSS} -layer Metal10 -direction vertical -width 3 -spacing 3 -number_of_sets 3 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

addStripe -nets {VDD VSS} -layer Metal11 -direction horizontal -width 3 -spacing 3 -number_of_sets 3 -area {243.085 2520 5096.605 2640} -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

addStripe -nets {VDD VSS} -layer Metal10 -direction vertical -width 3 -spacing 3 -number_of_sets 3 -area {2520 243.085 2640 5096.605} -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

# Create VDD VSS Pins and connect them
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VDD -type tiehi -instanceBasename *
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VSS -type tielo -instanceBasename *
#createPGPin VDD_IN -net VDD -geom Metal10 0 17 2 20
#createPGPin VSS_IN -net VSS -geom Metal10 0 11 2 14

# Special Route (follow pins and via generation stripes)
setSrouteMode -viaConnectToShape { stripe }
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { Metal1(1) Metal11(11) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { Metal1(1) Metal11(11) } -nets { VDD VSS } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { Metal1(1) Metal11(11) }

selectWire 2520.0000 243.0850 2523.0000 5096.6050 10 VDD
editTrim
selectWire 2575.5000 243.0850 2578.5000 5096.6050 10 VDD
editTrim
selectWire 2631.0000 243.0850 2634.0000 5096.6050 10 VDD
editTrim
selectWire 243.0850 2520.0000 5096.6050 2523.0000 11 VDD
editTrim
selectWire 243.0850 2575.5000 5096.6050 2578.5000 11 VDD
editTrim
selectWire 243.0850 2631.0000 5096.6050 2634.0000 11 VDD
editTrim

# Place
set_dont_touch [get_cells aps25_pads/pad_scan_in]
setPlaceMode -place_global_timing_effort high -congEffort auto -timingDriven 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 1 -moduleAwareSpare 0 -preserveRouting 1 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0 
#place_design
#set_disable_timing 
#optDesign -preCTS
place_opt_design 
optDesign -preCTS -incr
#place_opt_design -incremental_timing
#place_opt_design -incremental

#report_timing -late -view slow > ${_PRECTS}/SLOW/report_setup_timing.txt
#report_timing -early -view slow > ${_PRECTS}/SLOW/report_hold_timing.txt
report_timing -late -view fast > ${_PRECTS}/FAST/report_setup_timing.txt
report_timing -early -view fast > ${_PRECTS}/FAST/report_hold_timing.txt
#report_power -view slow > ${_PRECTS}/SLOW/report_power.txt
report_power -view fast > ${_PRECTS}/FAST/report_power.txt
report_area > ${_PRECTS}/report_area.txt


# Save Design preCTS
savedesign ${_SAVE_PRECTS}/${TOP}_preCTS.enc

# Make Non Default Rule (2W2S)
add_ndr -width {Metal1 0.12 Metal2 0.16 Metal3 0.16 Metal4 0.16 Metal5 0.16 Metal6 0.16 Metal7 0.16 Metal8 0.16 Metal9 0.16 Metal10 0.44 Metal11 0.44 } -spacing {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 Metal10 0.4 Metal11 0.4 } -name 2w2s

# Create 2w2s route type and set Clock Concurrent Optimiaztion properties
create_route_type -top_preferred_layer 9 -bottom_preferred_layer 7 -non_default_rule 2w2s -name 2w2s_trunk
set_ccopt_property -route_type 2w2s_trunk -net_type trunk
set_ccopt_property -route_type default -net_type leaf
#set_ccopt_property -cell_halo_x 0.3
#set_ccopt_property -cell_halo_y 0.3
#set_ccopt_property -target_skew 0.7
#set_ccopt_property -target_max_trans 0.2
ccopt_design
optDesign -postCTS -setup
optDesign -postCTS -setup -incr
#-hold
#report_timing -late -view slow > ${_POSTCTS}/SLOW/report_setup_timing.txt
#report_timing -early -view slow > ${_POSTCTS}/SLOW/report_hold_timing.txt
report_timing -late -view fast > ${_POSTCTS}/FAST/report_setup_timing.txt
report_timing -early -view fast > ${_POSTCTS}/FAST/report_hold_timing.txt
#report_power -view slow > ${_POSTCTS}/SLOW/report_power.txt
report_power -view fast > ${_POSTCTS}/FAST/report_power.txt
report_area > ${_POSTCTS}/report_area.txt
#report_ccopt_clock_trees -view slow > ${_POSTCTS}/SLOW/report_clock_trees.txt
report_ccopt_clock_trees -view fast > ${_POSTCTS}/FAST/report_clock_trees.txt
#report_ccopt_skew_groups -view slow > ${_POSTCTS}/SLOW/report_skew_groups.txt
report_ccopt_skew_groups -view fast  > ${_POSTCTS}/FAST/report_skew_groups.txt

# Save Design postCTS
savedesign ${_SAVE_POSTCTS}/${TOP}_postCTS.enc

# Set and Execute NanoRoute

setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
setNanoRouteMode -quiet -droutePostRouteWidenWireRule LEFSpecialRouteSpec
setNanoRouteMode -quiet -drouteUseMultiCutViaEffort medium
setNanoRouteMode -quiet -timingEngine {}
setUsefulSkewMode -noBoundary false -maxAllowedDelay 1
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration 1
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup
#routeDesign -globalDetail
route_opt_design 
setAnalysisMode -analysisType onChipVariation -cppr both
optDesign -postRoute -setup 
optDesign -postRoute -incr
#-incr -holdVioData ${_POSTROUTE}/report_hold_violations_data
#report_timing -late -view slow > ${_POSTROUTE}/SLOW/report_setup_timing.txt
#report_timing -early -view slow > ${_POSTROUTE}/SLOW/report_hold_timing.txt
report_timing -late -view fast > ${_POSTROUTE}/FAST/report_setup_timing.txt
report_timing -early -view fast  > ${_POSTROUTE}/FAST/report_hold_timing.txt
#report_power -view slow > ${_POSTROUTE}/SLOW/report_power.txt
report_power -view fast > ${_POSTROUTE}/FAST/report_power.txt
report_area > ${_POSTROUTE}/report_area.txt
check_design -type all > ${_POSTROUTE}/check_design.txt
#report_ccopt_worst_chain -view fast > ${_POSTROUTE}/FAST/report_worst_chain.txt

reclaimArea
report_timing -late -view fast > ${_POSTROUTE}/FAST/report_setup_timing_reclaim.txt
report_timing -early -view fast  > ${_POSTROUTE}/FAST/report_hold_timing_reclaim.txt
report_power -view fast > ${_POSTROUTE}/FAST/report_power_reclaim.txt
report_area > ${_POSTROUTE}/report_area_reclaim.txt

# Save Design postRoute
savedesign ${_SAVE_POSTROUTE}/${TOP}_postRoute.enc


# Verify DRC
ecoRoute -fix_drc
verify_drc
verifyConnectivity

setNanoRouteMode -drouteFixAntenna true  -drouteSearchAndRepair true
routeDesign
ecoRoute -fix_drc
verify_drc

# Metal fill
setMetalFill -layer Metal1 -opcActiveSpacing 0.060 -minDensity 10.00
setMetalFill -layer Metal2 -opcActiveSpacing 0.070 -minDensity 10.00
setMetalFill -layer Metal3 -opcActiveSpacing 0.070 -minDensity 10.00
setMetalFill -layer Metal4 -opcActiveSpacing 0.070 -minDensity 10.00
setMetalFill -layer Metal5 -opcActiveSpacing 0.070 -minDensity 10.00
setMetalFill -layer Metal6 -opcActiveSpacing 0.070 -minDensity 10.00
setMetalFill -layer Metal7 -opcActiveSpacing 0.070 -minDensity 10.00
setMetalFill -layer Metal8 -opcActiveSpacing 0.070 -minDensity 10.00
setMetalFill -layer Metal9 -opcActiveSpacing 0.070 -minDensity 10.00
setMetalFill -layer Metal10 -opcActiveSpacing 0.200 -minDensity 10.00
setMetalFill -layer Metal11 -opcActiveSpacing 0.200 -minDensity 10.00
addMetalFill -layer { Metal1 Metal2 Metal3 Metal4 Metal5 Metal6 Metal7 Metal8 Metal9 Metal10 Metal11 } -net { VSS VDD }

# Save Design for Sign-off
savedesign ${_SAVE_SIGNOFF}/${TOP}_signOff.enc

# Extract parasitics
setExtractRCMode -engine postRoute -effortlevel high
extractRC

# Create SPEF file and perform Sign-off STA
setMultiCpuUsage -remoteHost 4
#setExtractRCMode -engine postRoute -effortlevel signoff -coupled true -lefTechFileMap extr.aps25_cpu_chip.layermap.log 
#extractRC
#signoffTimeDesign -reportOnly
#signoffOptDesign -all
#signoffOptDesign -setup
#signoffOptDesign -area
report_timing -late -view fast > ${_SIGNOFF}/FAST/report_setup_timing.txt
report_timing -early -view fast  > ${_SIGNOFF}/FAST/report_hold_timing.txt
report_power -view fast > ${_SIGNOFF}/FAST/report_power.txt
report_area > ${_SIGNOFF}/report_area.txt
check_design -type all > ${_SIGNOFF}/check_design.txt

