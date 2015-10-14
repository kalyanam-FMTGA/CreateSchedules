#! /software/users/FMTGA/Python-3.3.0/bin/python3.3

import sys

with open(sys.argv[1]) as f:
  lis=[x.split() for x in f]

for x in zip(*lis):
  for y in x:
    print(y+'\t',end='')
  print()
  
  
