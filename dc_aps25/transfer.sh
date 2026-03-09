# Source and destination directories
SRC_DIR="dc_reports/netlist_aps25_cpu"
DEST_DIR="../inn_aps25/rtl"

# Copy all files from source to destination, overwrite if existing
cp -f "$SRC_DIR"/aps25_cpu_scan.def "$SRC_DIR"/aps25_cpu.v "$SRC_DIR"/aps25_cpu.sdc "$DEST_DIR"/
echo "Files transfered to "$DEST_DIR" succesfully."
cd ../inn_aps25
python prefix_scan_def.py
python inject_rtl.py


