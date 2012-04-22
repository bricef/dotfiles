#!/usr/bin/env python
import array

class ARC4:
  def __init__(self, key, offset=0):
    _key = array.array('b')
    _key.fromstring(key)
    self.S = [i for i in range(256)]
    j = 0
    for i in range(256):
      j = (j + self.S[i] + _key[i%len(key)]) % 256
      t = self.S[j]
      self.S[j] = self.S[i]
      self.S[i] = t
    self.i = 0
    self.j = 0
    self.read(offset)
 
  def read(self, n):
    buf = []
    for c in range(n):
      self.i = (self.i+1) % 256
      self.j = (self.j + self.S[self.i]) % 256
      t = self.S[self.j]
      self.S[self.j] = self.S[self.i]
      self.S[self.i] = t
      buf.append(self.S[ (self.S[self.i]+self.S[self.j])%256 ])
    arr = array.array('B')
    arr.fromlist(buf)
    return arr.tobytes()

  def encrypt(self, str):
    buf = []
    pt = array.array('B')
    pt.fromstring(str)
    ks = self.read(len(pt))
    for i in range(len(pt)):
      buf.append(pt[i]^ks[i])
    return array.array('B', buf).tobytes()
    
  def decrypt(self, str):
    return self.encrypt(str)

def hexify(str):
  buf = []
  for char in str:
    buf.append("%02x"%ord(char))
  return "".join(buf)
