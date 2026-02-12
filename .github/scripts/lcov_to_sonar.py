#!/usr/bin/env python3
"""Convert LCOV format to SonarQube Generic Coverage XML format."""

import sys
import os
import xml.etree.ElementTree as ET
from xml.dom import minidom


def parse_lcov(lcov_file, workspace_root=None):
    """Parse LCOV file and return coverage data with relative paths."""
    coverage_data = {}
    current_file = None
    
    with open(lcov_file, 'r') as f:
        for line in f:
            line = line.strip()
            
            if line.startswith('SF:'):
                # Source file
                filepath = line[3:]
                
                # Convert to relative path if workspace_root is provided
                if workspace_root and filepath.startswith(workspace_root):
                    filepath = os.path.relpath(filepath, workspace_root)
                
                # Normalize path separators
                filepath = filepath.replace('\\', '/')
                
                current_file = filepath
                if current_file not in coverage_data:
                    coverage_data[current_file] = {}
            
            elif line.startswith('DA:'):
                # Line coverage data: DA:line_number,hit_count
                if current_file:
                    parts = line[3:].split(',')
                    if len(parts) == 2:
                        line_num = int(parts[0])
                        hits = int(parts[1])
                        coverage_data[current_file][line_num] = hits
    
    return coverage_data


def create_sonar_xml(coverage_data):
    """Create SonarQube Generic Coverage XML from coverage data."""
    root = ET.Element('coverage')
    root.set('version', '1')
    
    for filepath, lines in coverage_data.items():
        if not lines:
            continue
            
        file_elem = ET.SubElement(root, 'file')
        file_elem.set('path', filepath)
        
        for line_num, hits in sorted(lines.items()):
            line_elem = ET.SubElement(file_elem, 'lineToCover')
            line_elem.set('lineNumber', str(line_num))
            line_elem.set('covered', 'true' if hits > 0 else 'false')
    
    return root


def prettify(elem):
    """Return a pretty-printed XML string."""
    rough_string = ET.tostring(elem, encoding='utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent='  ', encoding='utf-8').decode('utf-8')


def main():
    if len(sys.argv) < 3 or len(sys.argv) > 4:
        print(f"Usage: {sys.argv[0]} <input.lcov> <output.xml> [workspace_root]")
        sys.exit(1)
    
    lcov_file = sys.argv[1]
    output_file = sys.argv[2]
    workspace_root = sys.argv[3] if len(sys.argv) == 4 else None
    
    if workspace_root:
        workspace_root = os.path.abspath(workspace_root)
        print(f"Using workspace root: {workspace_root}")
    
    print(f"Parsing LCOV file: {lcov_file}")
    coverage_data = parse_lcov(lcov_file, workspace_root)
    
    print(f"Found coverage data for {len(coverage_data)} files")
    for filepath in list(coverage_data.keys())[:5]:  # Show first 5 files
        print(f"  - {filepath}")
    if len(coverage_data) > 5:
        print(f"  ... and {len(coverage_data) - 5} more")
    
    print(f"Creating SonarQube Generic Coverage XML...")
    root = create_sonar_xml(coverage_data)
    
    print(f"Writing to: {output_file}")
    with open(output_file, 'w') as f:
        f.write(prettify(root))
    
    print("Conversion complete!")


if __name__ == '__main__':
    main()
