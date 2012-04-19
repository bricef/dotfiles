#!/usr/bin/env python3


import argparse
import subprocess
import fileinput
import shlex
import sys
import os
import re

usage = """
Harness.py tests a program for correctness against a known 
correct output. It takes an <input> file and a reference <output>
file and processes the input with the <program> under test, 
displaying a correctness report on stderr. 

Alternatively, the files to test can be specified with a test
script file. The test script file has the following format:

    # This is a comment
    command path/to/input_file path/to/output_file
    
    # whitespace lines are ignored
   
    command path/with spaces/file   path/to/output_file # this will fail
    command "path/with spaces/file" path/to/output_file # this will not

    # Arguments to the command are supported.
    command --arg path/to/input_file path/to/output_file

"""

def is_correct(command,input,reference):
  if not os.path.isfile(input): raise IOError("Could not find file '%s'"%input)
  if not os.path.isfile(reference): raise IOError("Could not find file '%s'"%reference)
  
  with open(input, 'rb') as fi: 
    output = subprocess.check_output(command, stdin=fi)

  with open(reference, 'rb') as fr:
    ref = fr.read()

  if ref == output:
    sys.stderr.write("   [OK]: %s < %s > %s\n"%(" ".join(command), input, reference) )
    return True
  else:
    sys.stderr.write(" [FAIL]: %s < %s > %s\n"%(" ".join(command), input, reference) )
    return False



if __name__ == "__main__":
  parser = argparse.ArgumentParser(
    description=usage,
    formatter_class=argparse.RawDescriptionHelpFormatter
  )
  parser.add_argument('program', nargs='?', help="The program under test")
  parser.add_argument('input', nargs='?', help="The input file to pass to the program under test.")
  parser.add_argument('reference', nargs='?', help="reference output.")
  parser.add_argument('-s', '--skip', dest="skip", action='store_true', help="Continue past IO errors when running a script.")
  parser.add_argument(
    '--script', 
    nargs=1, 
    help="""Provide a test script. The test script has a test per line, 
    with the format [cmd input reference]. Whitelines are ignored, as 
    are lines beginning with '#'"""
  )

  args = parser.parse_args()
  failed = 0

  if args.script:
    for line in fileinput.input(args.script[0]):
      if line:
        try:
          sline = shlex.split(line, comments=True)
          if sline:
            if not is_correct(sline[:-2],sline[-2],sline[-1]):
              failed += 1 
        except IOError as err:
          sys.stderr.write("[ERROR]: %s (in '%s' line %d)\n"%(str(err),fileinput.filename(),fileinput.lineno()) )
          if not args.skip:
            sys.exit(1)
      
  elif args.program and args.input and args.reference:
    try:
      if not is_correct(args.program, args.input, args.reference):
        sys.exit(1)
      else:
        sys.exit(0)
    except IOError as err:
      sys.stderr.write("[ERROR]: %s\n"%str(err))
      sys.exit(1)
  
  else:
    parser.print_help()





