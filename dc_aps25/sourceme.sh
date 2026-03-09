# source sourceme.sh period, duty cycle (decimal), input delay, output delay

CLK_PERIOD=$1
DUTY_CYCLE=$2
INPUT_DELAY=$3
OUTPUT_DELAY=$4
CLK_FALLING_EDGE=$(printf "%.2f" $(echo "$CLK_PERIOD * $DUTY_CYCLE" | bc -l))
CLK_TRANS=$(printf "%.2f" $(echo "$CLK_PERIOD * 0.01" | bc -l))

module load synopsys
export PROJ_ROOT=$(pwd)
#export SYNTH_TARGET_DB=/home/p/papakosp/Desktop/dc_aps25/fast_vdd1v0_basicCells.db
#export SYNTH_TARGET_DB=/home/p/papakosp/Desktop/dc_aps25/fast_vdd1v0_multibitsDFF.db
export SYNTH_TARGET_DB="/home/p/papakosp/Desktop/dc_aps25/fast_vdd1v0_basicCells.db /home/p/papakosp/Desktop/dc_aps25/fast_vdd1v0_multibitsDFF.db"
cd flows/synth
cat > config.sdc <<EOF
create_clock -name clk -period $CLK_PERIOD -waveform {0 $CLK_FALLING_EDGE} [get_ports clk] 
set_input_delay -clock clk  $INPUT_DELAY -network_latency_included [all_inputs]
set_output_delay -clock clk $OUTPUT_DELAY -network_latency_included [all_outputs]
set_clock_uncertainty -setup 0.1 [get_clocks clk] 
set_clock_uncertainty -hold 0.04 [get_clocks clk]
set_clock_transition $CLK_TRANS [get_clocks clk]
set_load -max 0.5 [all_outputs]
set_load -min 0.05 [all_outputs]
set_driving_cell -lib_cell BUFX2 -max [all_inputs]
set_driving_cell -lib_cell BUFX16 -min [all_inputs]
#set_driving_cell -lib_cell BUFX4 -max [get_ports hold]
EOF
source dc_synthesize.sh aps25_cpu
cd ${PROJ_ROOT}/lec
source formality.sh aps25_cpu
cd ../
