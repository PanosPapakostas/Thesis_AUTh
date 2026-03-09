import re
import os

def inject_verilog_modules(pads_file, chip_file, target_file):
    # Read pads.v
    with open(pads_file, 'r') as f:
        pads_content = f.read()

    # Read chip.v
    with open(chip_file, 'r') as f:
        chip_content = f.read()

    # Read aps25_cpu.v
    with open(target_file, 'r') as f:
        aps25_lines = f.readlines()

    # Find where `module aps25_cpu` begins
    module_start_index = None
    for i, line in enumerate(aps25_lines):
        if re.match(r'^\s*module\s+aps25_cpu\b', line):
            module_start_index = i
            break

    if module_start_index is None:
        print("Error: Could not find `module aps25_cpu` in target file.")
        return

    # Split the file around the aps25_cpu module
    before_module = aps25_lines[:module_start_index]
    module_and_after = aps25_lines[module_start_index:]

    # Find the last `endmodule` in module_and_after
    for i in range(len(module_and_after) - 1, -1, -1):
        if re.match(r'^\s*endmodule\b', module_and_after[i]):
            module_end_index = i + 1
            break
    else:
        print("Error: Could not find `endmodule` in aps25_cpu module.")
        return

    module_part = module_and_after[:module_end_index]
    after_module = module_and_after[module_end_index:]

    # Construct final output with spacing
    final_lines = []
    final_lines.extend(before_module)
    final_lines.extend(pads_content.splitlines(keepends=True))
    final_lines.append('\n')  # Blank line after pads
    final_lines.extend(module_part)
    final_lines.append('\n')  # Blank line before chip
    final_lines.extend(chip_content.splitlines(keepends=True))
    final_lines.extend(after_module)

    # Overwrite the original file
    with open(target_file, 'w') as f:
        f.writelines(final_lines)

    print(f"{target_file} updated successfully.")

if __name__ == "__main__":
    rtl_dir = os.path.join(os.path.dirname(__file__), 'rtl')

    pads_file = os.path.join(rtl_dir, 'pads.v')
    chip_file = os.path.join(rtl_dir, 'chip.v')
    target_file = os.path.join(rtl_dir, 'aps25_cpu.v')

    inject_verilog_modules(pads_file, chip_file, target_file)

