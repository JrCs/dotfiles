#!/usr/bin/env python

# Tools to see if a module can be import
# Example: test-python-import.py distutils.sysconfig

import sys

try:
      __import__(sys.argv[1])
      print ("Sucessfully import", sys.argv[1])
except:
      print ("Error!")
      sys.exit(4)
      
sys.exit(0)
