# -*- coding: utf-8 -*-

# usage: python name.py FILENAME DELIMITER

import sys

DEBUG = 0

if len(sys.argv) != 3:
	print (r"FORMAT: python %s FILE_NAME DELIMITER" % sys.argv[0])
	print (r"FOR DELIMITER: Use  $'\t'  for tab etc.")
	print (r"FULL EXAMPLE: python %s" % sys.argv[0]),
	print ("\"test.data\""),
	print (r"$'\t'$'\t'")
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
		### [1, 0.123, 2, 0.234, 3, 0.345, 4, ... ###
	i = 0
	tmp = ""

	iter_list = []
	value_list = []

	i_or_v = 0	#TODO can be dropped I think?

	while i < len(ch_list):

			# IF CH = DELIMITER #
		if (not(ch_list[i].isdigit())) & (ch_list[i] != '.') & (ch_list[i] != '\n'):
			iter_list.append(tmp)
			tmp = ""
			j = 0
			while j < len(sys.argv[2]):
				if ch_list[i] != sys.argv[2][j]:
					print "Problem... WRONG DELIMITER?!"
					print "quit()"
					quit()
				i += 1
				j += 1

			# IF CH = '\n'
		elif ch_list[i] == '\n':
			value_list.append(tmp)
			tmp = ""
			i +=1

			# ELSE (normal value (float)) #
		else:
			tmp += ch_list[i]
			i += 1


	if DEBUG == 1:
		print "iter_list LENGTH: ",
		print len(iter_list)
		print "value_list LENGTH: ",
		print len(value_list)
		print iter_list
		print value_list


		### FIND THE 'MAXIMUM VALUE' UP TO EACH ITERATION ###
	maxv_list = []	
	i = 0
	temp_value = 0
	while (i < len(value_list)):
		temp_value = float(value_list[i])
		
		j = 0
		while (j < i):
			if temp_value < maxv_list[j]:
				temp_value = maxv_list[j]
			j += 1
			
		maxv_list.append(temp_value)
		i += 1
	

		### WRITE THE VALUE'S BACK INTO NEW FILE tmp_NAME ###
	write_name = "max_" + sys.argv[1]
	write_file = open(write_name, "w")
	
	if DEBUG == 1:
		print "SUCCESS!"
		print "Writing new table into: ",
		print write_name

	i = 0
	while (i < len(iter_list)):
		write_file.write(iter_list[i] + sys.argv[2] + str(maxv_list[i]) + "\n")
		i += 1
		

	write_file.close()
	read_file.close()
