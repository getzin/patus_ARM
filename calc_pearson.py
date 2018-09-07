# -*- coding: utf-8 -*-

#NOTE: Following package needs to be installed! (pip is needed for python packages)
#sudo apt install python-pip
#python -m pip install --user numpy

import numpy
import sys

if len(sys.argv) != 2:
	print (r"FORMAT: python %s FILE_NAME" % sys.argv[0])
else:
	#With the help from: https://stackoverflow.com/a/7754205
	def readfile(filepath, delimiter): 
	    with open(filepath, 'r') as f: 
		for line in f:
		    yield tuple(line.split(delimiter))

	lines_as_tuples = readfile(sys.argv[1],',')

	list_x=[]
	list_y=[]

	for linedata in lines_as_tuples:
		list_x.append(float(linedata[0]))
		list_y.append(float(linedata[1]))

	#print list_x
	#print list_y

	#See: https://stackoverflow.com/a/16026737
	pearson=numpy.corrcoef(list_x,list_y)[0, 1]
	print pearson
