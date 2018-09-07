# -*- coding: utf-8 -*-

# usage: python name.py FILENAME

import sys

DEBUG = 0

if len(sys.argv) != 2:
	print (r"FORMAT: python %s FILE_NAME" % sys.argv[0])
else:

		### READ THE WHOLE FILE AND PUT IT INTO A STRING ###
	read_file = open(sys.argv[1])
	string = read_file.read()

	if DEBUG == 1:
		print string
		print "--------------------------------\n"


		### TURN STRING INTO A LIST OF ALL CHARS ###
	ch_list = list(string)

	if DEBUG == 1:
		print ch_list
		print "--------------------------------\n"


		### CREATE LIST THAT IS USEFUL ... ###
		### [0.123, 0.234, 0.345, ... ###
	i = 0
	tmp = ""

	value_list = []

	while i < len(ch_list):

			# IF CH = '\n'
		if ch_list[i] == '\n':
			value_list.append(tmp)
			tmp = ""
			i +=1

			# ELSE (normal value (float)) #
		else:
			tmp += ch_list[i]
			i += 1


	if DEBUG == 1:
		print "value_list LENGTH: ",
		print len(value_list)
		print value_list

	

		### WRITE THE VALUE'S BACK INTO NEW FILE iter_NAME WITH "iteration,value" FORMAT ###
	write_name = "iter_" + sys.argv[1]
	write_file = open(write_name, "w")
	
	if DEBUG == 1:
		print "SUCCESS!"
		print "Writing new table into: ",
		print write_name

	i = 0
	while (i < len(value_list)):
		write_file.write(str(i+1) + "," + str(value_list[i]) + "\n")
		#print (str(i+1) + ", " + str(value_list[i]) + "\n"),
		i += 1
		

	write_file.close()
	read_file.close()
