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
		### [0.1, 0.123, 0.2, 0.234, 0.3, 0.345, 0.4, ... ###
	i = 0
	tmp = ""

	time_list = []
	power_list = []


	while i < len(ch_list):

			# IF CH = DELIMITER #
		if (not(ch_list[i].isdigit())) & (ch_list[i] != '.') & (ch_list[i] != '\n'):
			time_list.append(float(tmp))
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
			power_list.append(float(tmp))
			tmp = ""
			i +=1

			# ELSE (normal value (float)) #
		else:
			tmp += ch_list[i]
			i += 1


	if DEBUG == 1:
		print "time_list LENGTH: ",
		print len(time_list)
		print "power_list LENGTH: ",
		print len(power_list)
		print time_list
		print power_list

	

	interval_result_list = []

	i = 0
	while(i < (len(time_list)-1)):

		if DEBUG == 1:
			print (r"time_list[i]:    %s" % time_list[i])
			print (r"time_list[i+1]:  %s" % time_list[i+1])
			print (r"power_list[i]:    %s" % power_list[i])
			print (r"power_list[i+1]:  %s" % power_list[i+1])
			

		m = (power_list[i+1] - power_list[i]) / (time_list[i+1] - time_list[i])

		b = power_list[i] - m * time_list[i]

		interval_high = 0.5 * m * time_list[i+1] * time_list[i+1] + b * time_list[i+1]

		interval_low = 0.5 * m * time_list[i] * time_list[i] + b * time_list[i]

		interval_integral = interval_high - interval_low

		interval_result_list.append(interval_integral)

		i += 1

		if DEBUG == 1:
			print (r"m: %s" % m)
			print (r"b: %s" % b)
			print (r"interval_high: %s" % interval_high)
			print (r"interval_low: %s" % interval_low)
			print (r"interval_integral: %s" % interval_integral)
			print (r"interval_result_list[i-1]: %s" % interval_result_list[i-1])
			print 
	

	tmp = 0
	i = 0
	while(i < len(interval_result_list)):
		tmp += interval_result_list[i]
		i += 1
	calc_result = tmp

	print "integral: ",
	print calc_result



		### WRITE THE VALUE'S BACK INTO NEW FILE tmp_NAME ###
	write_name = "measure_result"
	write_file = open(write_name, "w")
	
	if DEBUG == 1:
		print "SUCCESS!"
		print "Writing calculated value into: ",
		print write_name

	write_file.write(str(calc_result))
		

	write_file.close()
	read_file.close()
