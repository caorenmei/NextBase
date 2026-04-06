#!/usr/bin/env python3
import subprocess
import sys

if len(sys.argv) != 3:
    print("usage: smoke_test.py <node_bin> <entry_file>", file=sys.stderr)
    sys.exit(2)

node_bin = sys.argv[1]
entry_file = sys.argv[2]

output = subprocess.check_output([node_bin, entry_file], text=True).strip()

if output != "hello from typescript":
    print(f"unexpected output: {output}", file=sys.stderr)
    sys.exit(1)
