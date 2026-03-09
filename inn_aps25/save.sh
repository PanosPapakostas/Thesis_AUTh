#source current_run_save.sh <NAME OF THE NEW FOLDER>	

# Source and destination directories
SRC_DIR=$(pwd)
DEST_DIR="../Attempts/New Power/"
all_args="$*"

# Transfer all save files, reports etc.

cd "$DEST_DIR"
mkdir -p "$all_args"
cd "$SRC_DIR"
cp -r signoffTimingReports reports
cp -r saves rtl reports *.log *.cmd "$DEST_DIR"/"$all_args"

cd "$SRC_DIR"/../dc_aps25
cp -r dc_reports formality_reports flows/synth/dc_synthesize.tcl flows/synth/config.sdc flows/synth/dc_synth_report.log lec/formality_report.logs "$DEST_DIR"/"$all_args"

echo "All DC and Innovus files saved succsesfully"
