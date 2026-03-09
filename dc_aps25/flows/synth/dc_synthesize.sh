# source dc_synthesize.sh aps25_cpu
export TOP=$1

dc_shell -f dc_synthesize.tcl -x "setenv TOP ${TOP};setenv PROJ_ROOT ${PROJ_ROOT};setenv SYNTH_TARGET_DB ${SYNTH_TARGET_DB}" | tee dc_synth_report.log
