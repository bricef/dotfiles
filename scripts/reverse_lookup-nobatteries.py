#!/usr/bin/env python

import sys, re, os, popen2

hosts_locs = [
  "/etc/hosts",
  "C:/Windows/system32/drivers/etc/hosts"
  ]

hosts = {}
 
def query_hosts(address):
  """Looks for a hostname to match the given address in the hosts file. """
  filename = ""
  for hosts_name in hosts_locs:
    if os.path.isfile(hosts_name):
      filename = hosts_name
      lines = open(hosts_name).readlines()
      slines = [line.split() for line in lines]
      for sline in slines:
        if (len(sline) > 1) and (sline[0][0] is not "#") :
          hosts[sline[0]] = sline[1].split(".")[0]
    break
  if not hosts:
    print("[lookup]: We could not find any hosts file. We looked in:")
    for hosts_name in hosts_locs:
      print("[lookup]:\t - %s"%hosts_name)
    return None, None
  elif hosts.has_key(address):
      return hosts[address],filename
  else:
      return None,filename


def usage():
  print("[usage]: %s [ip]"%(sys.argv[0]))
  print("")
  print("performs a reverse lookup on a host ip.")


def query_nslookup(address):
  """Queries 'nslookup' for a hostname using the give ip address.
     Note that this uses popen2 instead of the newer apis to retain
     backwards compatibility.
     >>> query_nslookup("127.0.0.1")
     'localhost'
     """
  fin,fout,ferr = popen2.popen3("nslookup %s"%address)
  results = fin.read()
  exp = re.compile(".*name[\s]*=[\s]*(.*)", re.M)
  for line in results.split("\n"):
    mo = exp.match(line)
    if mo:
      return mo.group(1).split(".")[0]
  return None

if __name__ == "__main__":
  if len(sys.argv) > 1 :
    print("[lookup]: Looking at hosts file.")

    hostname,file = query_hosts(sys.argv[1])
    if hostname and file:
      print("[lookup]: Found in '%s'"%file)
      print("name = %s"%hostname)
    else:
      if file:
        print("[lookup]: Not in '%s'"%file)
      print("[lookup]: Trying dns lookup. (you must have 'nslookup' on your system).")
      hostname = query_nslookup(sys.argv[1])
      if hostname:
        print("name = %s"%(hostname))
      else:
        print("[lookup]: Could not find a hostname for %s"%(sys.argv[1]))
    
  else:
    usage()

