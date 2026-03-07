#!/usr/bin/env python3

import sys

commit_msg_filepath = sys.argv[1]
required_prefix = 'MŁ42012'

with open(commit_msg_filepath, 'r') as f:
    content = f.readline().strip()

if not content.startswith(required_prefix):
    print(f"ERROR! The commit message must start with prefix {required_prefix}")
    sys.exit(1)
