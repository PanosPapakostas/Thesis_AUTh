# !/bin/bash
export TOP=$1

fm_shell -file formality.tcl -x "setenv TOP ${TOP};setenv PROJ_ROOT ${PROJ_ROOT};setenv SYNTH_TARGET_DB ${SYNTH_TARGET_DB}" | tee formality_report.logs
