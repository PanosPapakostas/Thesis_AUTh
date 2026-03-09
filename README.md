# Thesis_AUTh
Scripts produced for the Synthesis and Physical Implementation of the APS25 CPU for my thesis.

There are 2 working directories for the entire process, **dc_aps25** out of which Synthesis and Formal Equivalence Check are done, and **inn_aps25** out of which the Physical Implementation is done.

### Synthesis & FEC
In order to begin an iteration with a certain set of constraints (e.g. 20 ns period, 50% duty cycle, 4 ns input & output delay), the script is executed as such: `source sourceme.sh 20 0.5 4 4`.

The script produces the _config.sdc_ file which is used for the constraints during Synthesis, and then executes the _dc_synthesize.sh_ script. That's when Design Compiler is called with the _dc_synthesize.tcl_ script, where all the TCL commands for the Synthesis are.

This is the only script during the Synthesis iterations where commands need to be added/removed before almost every iteration in order to achieve different results. The example script that is in this repository is a Synthesis with most techniques used in the Thesis enabled, apart from Multibit Flip-Flops and forcing a steep max transition constraint.

After Synthesis is done and the netlist, reports etc. are produced, the script exits the tool and calls the execution of Formality, to step into the Formal Equivalence Check, by calling the _formality.sh_ script in the **lec** directory.

Finally for the first part of the work flow, we execute the _transfer.sh_ script, which transfers all the necessary files needed as input for the Physical Implementation flow into the **inn_aps25** directory, and executes the _prefix_scan_def.py_ and _inject_rtl.py_ Python scripts that are required to turn the input files into the desired forms (more details about the scripts in the Thesis, tl;dr _prefix_scan_def_ fixes a mismatch between the output scandef file after Synthesis and the expected input scandef file during Physical Implementation, and _inject_rtl_ adds the I/O pads and the wrapper that connects them with the CPU module to the netlist.

### Physical Implementation
The flow starts by executing the _source.sh_ script. It calls the _cleanup.sh_, which is used to clean up miscellaneous files produced by past iterations, and then calls Innovus. Ideally, Innovus should be called as such: `innovus -files innovus_script.tcl`, where Innovus is executed with the according TCL script as source input to be executed on launch, but during my workflow there were some problems being presented when the `-files` flag was used, and so the alternative is launching the script in an editor, copy-pasting and executing it into the Innovus terminal.

After Innovus launches, we paste and execute the right script among the 3 different ones (these are the final iterations of the scripts, they underwent many changes during the many workflow iterations):
- _flat.tcl_ has the bare-minimum TCL commands to complete the workflow, with as few steps that perform any kind of optimization as possible.
- _innovus_script.tcl_ has the TCL commands for the timing optimization workflow.
- _power.tcl_ has the TCL commands for the power optimization workflow.

Finally we save all the desired outputs, such as saved states from each flow, reports, logs etc. in a dedicated directory, using the _save.sh_ script as such: `source save.sh <Iteration Name>`, saving the current iteration's resutlts and landing in the **dc_aps25** directory ready to move on to the next iteration.
