#!/usr/bin/env python

"""
pinc.py: an arbitraty text include filter.

Pinc.py reads a source file with include directives in the following format:

    ...
    (> file_to_include.ext <)
    (!> file_to_execute.sh --args foo <)
    ...

Included files will be included verbatim. If executing a file, the stdout will be included.

If a directive is indented, as follows:

    ...
    normal text
        (> file_to_include.ext <)
    more normal text
    ...

Then the indentation will be preserved for all included lines.

Includes cannot be escaped, but any non-whitespace character before a directive will make pinc.py ignore the directive. For example:

    ...
    some text
         (> will_be_included.txt <)
    some more text
    this (> will_NOT_be_included.txt <)
    even more text
    ...

pinc.py reads from the stdin and writes to stdout. It takes no arguments.

pinc.py is one pass non-recursive. The included text is not parsed for pinc.py directive.

"""

import sys
import re
import shlex
import subprocess as sp

exe_pat = re.compile(r'(\s*)\(!>(.*)<\)\s*')
inc_pat = re.compile(r'(\s*)\(>(.*)<\)\s*')

if __name__ == "__main__":
  for line in sys.stdin:
    match_exe = re.match(exe_pat, line)
    match_inc = re.match(inc_pat, line)
    if match_exe:
      space = match_exe.group(1)
      exe = match_exe.group(2).strip()
      args = shlex.split(exe)
      sys.stdout.writelines(map(lambda x: space+x+"\n", sp.check_output(args).split("\n")))
    elif match_inc:
      space = match_inc.group(1)
      inc = match_inc.group(2).strip()
      sys.stdout.writelines(map(lambda x: space+x, open(inc)))
    else:
      sys.stdout.write(line)
      
