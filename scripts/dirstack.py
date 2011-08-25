#!/usr/bin/env python
import os,sys,shutil,fileinput

STACK_FILE=os.path.expanduser("~/.config/bs-stack")

modified=False

def cleanpath(path):
  return os.path.abspath(os.path.expanduser(path))

def add(dir):
  expanded = cleanpath(dir)
  if os.path.exists(expanded):
    fh = open(STACK_FILE, "a")
    fh.write("%s\n"%expanded)
    fh.close()
    modified = True
    return dir
  else:
    raise RuntimeError("The directory path specified '%s' does not appear to exist."%expanded)
  
def delete(index):
  wanted=""
  for line in fileinput.input(STACK_FILE,inplace=1,backup=".bak"):   
    if index == fileinput.lineno():
      wanted=line
    else:
      sys.stdout.write(line)
  fileinput.close()
  return wanted

def pop():
  fi = open(STACK_FILE, "r")
  lines = fi.readlines()
  fi.close()

  fo = open(STACK_FILE, "w")
  fo.writelines(lines[:-1])
  fo.close()
  if len(lines) > 0:
    return lines[-1]
  else:
    return None


def get(index):
  for line in fileinput.input(STACK_FILE):
    if fileinput.lineno() == index:
      fileinput.close()
      return line
  fileinput.close()
  raise RuntimeError("The index selected does not exist.")

def show():
  lines=False
  if os.path.isfile(STACK_FILE):
    for line in fileinput.input(STACK_FILE):
      lines = True
      if os.path.isdir(cleanpath(line.strip())) and os.path.samefile(cleanpath(line.strip()), cleanpath(os.getcwd())):
        sys.stderr.write("%6s * %s"%(("[%d]:"%fileinput.lineno()), line))
      else:
        sys.stderr.write("%6s   %s"%(("[%d]:"%fileinput.lineno()), line))
    fileinput.close()
  if not lines:
    sys.stderr.write("  [-]:   Empty Stack\n")

def usage():
  sys.stderr.write("""%s [option] <directory|num>
Where option is one of:
    a  <dir>        Add a directory to the top of the stack
    r  <num>        Remove the directory at index <num> from the stack
    g  <num>        Get the directory at index <num>
    rg <num>        Remove Get the directory at index <num> and prints it to stdout
    p  <dir>        Push the directory <dir> to the top of the stack and print it to stdout
    t               Remove and get the top directory from the stack and print it to stdout (Top)
    s               Show the stack (default operation with no arguments
    h|-h|--help     Show this message

If the first argument is a number <num>, it will try to get the directory at 
the index <num> if it is a directory <dir> which does not have the same name as
any of the options, it will push <dir> to the top of the stack and return it.

For this utility to work as intended, you may want to add the following function
to your .bashrc or equivalent:

    function ds {
      dir=$(%s "$@")
      test dir && (echo "cd $dir"; cd $dir)
    }

Feel free to contact brice.fernandes@gmail.com with suggestions for improvement!
"""%(os.path.basename(sys.argv[0]), os.path.basename(sys.argv[0])) )

if __name__ == "__main__":
  try:
    if len(sys.argv) == 1:
      show()
    elif len(sys.argv) > 1 :
      try:
        print(get(int(sys.argv[1])))
        exit(0)
      except ValueError:
        pass

      if sys.argv[1] == "a":
        add(sys.argv[2])
      elif sys.argv[1] == "rg":
        print(delete(int(sys.argv[2])).strip())
      elif sys.argv[1] == "r":
        delete(int(sys.argv[2])).strip()
      elif sys.argv[1] == "g":
        print(get(int(sys.argv[2])).strip())
      elif sys.argv[1] == "p":
        print(add(sys.argv[2]))
      elif sys.argv[1] == "t":
        dir = pop()
        if dir:
          print(dir.strip())
      elif sys.argv[1] == "s":
        show()
      elif sys.argv[1] in ["h", "-h", "--help"]:
        usage()
      elif os.path.isdir(sys.argv[1]):
        print(add(sys.argv[1]))

  except RuntimeError as (strerr):
    sys.stderr.write("[error]: %s\n"%strerr)
    


