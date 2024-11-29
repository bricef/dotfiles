#!/usr/bin/env python3

#
# Suggestions for improvement:
#  * Use a file in /tmp instead of disk to reduce access latency.
#  * make the stack sortable in user defined way `ds mv 3,0`, `ds sw 3,0`
#  * allow tagging of stack items: `ds g projectA`
#

# See http://matt.might.net/articles/console-hacks-exploiting-frequency/
# for insights into improving the experience


import os,sys,shutil,fileinput,subprocess
import sqlite3
import datetime

STACK_FILE = os.path.expanduser("~/.config/bs-stack")
DIR_FILE = os.path.expanduser("~/.config/ds-dirlog.db")
conn = sqlite3.connect(DIR_FILE)

c = conn.cursor()
c.execute('''CREATE TABLE IF NOT EXISTS dircounts (
        path VARCHAR(255) PRIMARY KEY NOT NULL, 
        count INT NOT NULL DEFAULT 0,
        time TEXT NOT NULL
)''')

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
    try:
      os.getcwd()
    except OSError:
      sys.stderr.write("**************************************************************\n")
      sys.stderr.write("  The current working directory doesn't seem to exist. Wild!  \n")
      sys.stderr.write("**************************************************************\n")
      sys.exit(1)

    for line in fileinput.input(STACK_FILE):
      if line.strip():
        lines = True
        if os.path.isdir(cleanpath(line.strip())) and os.path.samefile(cleanpath(line.strip()), cleanpath(os.getcwd())):
          sys.stderr.write("%6s * %s"%(("[%d]:"%fileinput.lineno()), line))
        else:
          sys.stderr.write("%6s   %s"%(("[%d]:"%fileinput.lineno()), line))
    fileinput.close()
  if not lines:
    sys.stderr.write("  [-]:   Empty Stack\n")

def sort_stack():
  if os.path.isfile(STACK_FILE):
    fh = open(STACK_FILE, "r")
    lines = fh.readlines()
    fh.close()
    fh = open(STACK_FILE, "w")
    for line in sorted(lines):
      if line.strip():
        fh.write(line)
    fh.close()

def clean_stack():
  if os.path.isfile(STACK_FILE):
    fh = open(STACK_FILE, "r")
    lines = fh.readlines()
    fh.close()
    fh = open(STACK_FILE, "w")
    prev = ""
    for line in sorted(lines):
      if line.strip():
        if not prev == line:
          fh.write(line)
          prev = line
    fh.close()

def log_dir(): 
    try:
      cwd = os.getcwd()
    except OSError:
      sys.stderr.write("**************************************************************\n")
      sys.stderr.write("  The current working directory doesn't seem to exist. Wild!  \n")
      sys.stderr.write("**************************************************************\n")
      sys.exit(1)
    now = datetime.datetime.utcnow().isoformat()
    c = conn.cursor()
    c.execute('''INSERT INTO dircounts(path,count,time) 
            VALUES (?,1,?) 
            ON CONFLICT(PATH) DO UPDATE SET count = count + 1''', [cwd, now] )
    conn.commit()

def show_frequent():
    c = conn.cursor()
    # [(count,path)*]
    rows = c.execute('''SELECT count,path FROM dircounts ORDER BY count DESC LIMIT 10''')
    for row in enumerate(rows):
        human_index = row[0] + 1
        path = row[1][1]
        count = row[1][0]
        sys.stderr.write("{:>2}: {:>5} {}\n".format(human_index, "({})".format(count), path))

def jump_frequent(human_index):
    index = human_index - 1
    rows = c.execute('''SELECT count,path FROM dircounts ORDER BY count DESC LIMIT 10''')
    for row in enumerate(rows):
        if index == row[0]: # Bingo, we're looking for this
            print(row[1][1])


def cmd_template(alias, args):
    return """function {alias} {{
  dir=$(dirstack.py {args} "$@")
  if [ -n "$dir" ]; then
    echo "cd $dir"
    cd $dir
  else
    return 0
  fi
}}""".format(alias=alias, args=" ".join(args))

cmd_ds = cmd_template("ds", [])
cmd_f = cmd_template("f", ["frequent"])
enable_prompt="""export DIRSTACK_LASTDIR="/"

function dirstack_prompt_command {
  # Record new directory on change.
  dirstack_newdir=`pwd`
  if [ ! "$DIRSTACK_LASTDIR" = "$dirstack_newdir" ]; then
    dirstack.py l
  fi

  export DIRSTACK_LASTDIR="$dirstack_newdir"
}

# Cleanly add the new prompt command
export PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND; "}'dirstack_prompt_command'"""

def init_shell():
  print("\n\n".join([cmd_ds, cmd_f, enable_prompt]))

def usage():
  sys.stderr.write("""{name} [option] <directory|num>
Where option is one of:
    a  <dir>        Add a directory to the top of the stack
    r|d  <num>      Remove the directory at index <num> from the stack
    g  <num>        Get the directory at index <num>
    rg <num>        Remove Get the directory at index <num> and prints it to 
                    stdout
    p  <dir>        Push the directory <dir> to the top of the stack and print 
                    it to stdout
    t               Remove and get the top directory from the stack and print 
                    it to stdout (Top)
    s               Show the stack (default operation with no arguments
    edit            Edit the stack with your default editor
    sort            Sort the stack
    clean           Sort the stack and remove duplicate entries
    h|-h|--help     Show this message
    l|log           Log the current directory for frequency analysis 
                    (use as part of PROMPT_COMMAND)
    frequent        Show most frequent directories
    init_shell      Outputs the required initisalisation shell functions
    

If the first argument is a number <num>, it will try to get the directory at 
the index <num> if it is a directory <dir> which does not have the same name as
any of the options, it will push <dir> to the top of the stack and return it.

For this utility to work as intended, you may want to add the following function
to your .bashrc or equivalent:

{cmd_ds}

Similarly, to use this for frequency jumping, add the following to your .bashrc:

{cmd_f}{enable_prompt}

Feel free to contact brice.fernandes@gmail.com with suggestions for improvement!
""".format(
    name=os.path.basename(sys.argv[0]),
    cmd_ds = cmd_ds,
    cmd_f = cmd_f))


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
      elif sys.argv[1] in ["rg", "gr"]:
        print(delete(int(sys.argv[2])).strip())
      elif sys.argv[1] in ["r", "d"]:
        delete(int(sys.argv[2])).strip()
      elif sys.argv[1] == "g":
        print(get(int(sys.argv[2])).strip())
      elif sys.argv[1] in ["p", "ga", "ag"]:
        print(add(sys.argv[2]))
      elif sys.argv[1] == "t":
        dir = pop()
        if dir:
          print(dir.strip())
      elif sys.argv[1] == "s":
        show()
      elif sys.argv[1] == "edit":
        subprocess.call([os.getenv("EDITOR"), STACK_FILE])
      elif sys.argv[1] == "clean":
        clean_stack()
      elif sys.argv[1] == "sort":
        sort_stack()
      elif sys.argv[1] in ["h", "-h", "--help"]:
        usage()
      elif sys.argv[1] in ["l", "log"]:
        log_dir()
      elif sys.argv[1] in ["frequent"]:
        if len(sys.argv) > 2:
            jump_frequent(int(sys.argv[2]))
        else:
            show_frequent()
      elif sys.argv[1] in ["init_shell"]:
          init_shell()
      elif os.path.isdir(sys.argv[1]):
        print(add(sys.argv[1]))

  except RuntimeError as strerr:
    sys.stderr.write("[error]: %s\n"%strerr)
    


