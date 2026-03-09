import re

def add_prefix_to_scan_def(input_file, output_file, prefix):
    with open(input_file, 'r') as fin, open(output_file, 'w') as fout:
        # Pattern for regular instance lines
        instance_line_pattern = re.compile(r'^(\s*)([^\s()]+)(\s+\()')
        # Pattern for + ORDERED lines
        ordered_line_pattern = re.compile(r'^(\s*\+\s*ORDERED\s+)([^\s()]+)(\s+\()')
        # Pattern for + FLOATING lines
        floating_line_pattern = re.compile(r'^(\s*\+\s*FLOATING\s+)([^\s()]+)(\s+\()')

        for line in fin:
            # Check + ORDERED
            match = ordered_line_pattern.match(line)
            if match:
                prefix_text, inst_name, rest = match.groups()
                if not inst_name.startswith(prefix):
                    inst_name = prefix + inst_name
                new_line = f"{prefix_text}{inst_name}{rest}{line[match.end():]}"
                fout.write(new_line)
                continue

            # Check + FLOATING
            match = floating_line_pattern.match(line)
            if match:
                prefix_text, inst_name, rest = match.groups()
                if not inst_name.startswith(prefix):
                    inst_name = prefix + inst_name
                new_line = f"{prefix_text}{inst_name}{rest}{line[match.end():]}"
                fout.write(new_line)
                continue

            # Check regular instance line
            match = instance_line_pattern.match(line)
            if match:
                indent, inst_name, rest = match.groups()
                if not inst_name.startswith(prefix):
                    inst_name = prefix + inst_name
                new_line = f"{indent}{inst_name}{rest}{line[match.end():]}"
                fout.write(new_line)
                continue

            # Default: write line as-is
            fout.write(line)

if __name__ == "__main__":
    input_def = 'rtl/aps25_cpu_scan.def'      # Your original scan DEF
    output_def = 'rtl/aps25_cpu_scan_prefixed.def'  # Output file
    top_prefix = 'aps25/'

    add_prefix_to_scan_def(input_def, output_def, top_prefix)
    print(f"Processed DEF file saved to {output_def}")

