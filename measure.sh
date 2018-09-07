#!/bin/bash

##ssh -Y -v pi@192.168.1.5 "cd patus && source util/patusvars.sh && cd benchmark/out && make tune x_max=64 y_max=64 z_max=64" && echo -e "done"
##ssh -Y -v pi@192.168.1.5 "cd patus && source util/patusvars.sh && cd benchmark && patus wave-1-float.stc --architecture=\"ARM_NEON\""


script_name="measure.sh"
patus_folder="patus" 			#patus-aa ... but currently has errors?
results_folder="patus_results"		#The results folder for the measurements


#echo -e "\t\t---> SCRIPT NAME: $script_name"


# either "+measure" or empty
measure=""

# either "local" or "host"
command_type=""

# for example: stc_name="wave-2-float"
stc_name=""

# for example: patus_command="patus wave-2-float.stc"
patus_command=""

# for example: tune_command="make tune x_max=$2 y_max=$3 z_max=$4"
tune_command=""

# looks like: tune_YYYY-MM-DD_HH.MM.SS.txt
tune_name=""

# looks like: YYYY-MM-DD_HH.MM.SS
date_name=""

# looks like: TYPE_STENCIL_DATE
type_stencil_date_name=""

# optimal parameters (for example for blur-float): 16 16 16 16 2 1 
optimal_parameters=""

# parameters_file (e.g. parameters.txt)
parameters_file=""

# current_parameter_set: e.g. 16 16 4 ... (Thread_number independent)
current_parameter_set=""

# number of total parameter sets in the testbench (e.g. parameters_file has 120 lines --> 120 parameters
number_of_parameter_sets=""

# Keeps an integral value
integral_value=""

# The file(s) where the performance/energy values will be in
perf_energy_file=""

# Keeps a specific performance value (per thread, per parameter set)
tmp_perf=""

# for measurement: Number of max threads...
max=""
max_default="2"

# for the Multiple repetition thing
multiple_flag=""
multiple_count=""

# dimensions (height/width OR x_max/y_max/z_max, in "16x32x24" format)
# will be useful for the plot later
dimensions=""

# processor type (used for graphing... either ARM or Intel)
processor_type=""



print_all_variables(){
	if !([ -z "$1" ]);
	then
		echo -e "Remaining stuff: $0 $@"
	fi
	echo -e "script_name = $script_name"
	echo -e "measure = $measure"
	echo -e "command_type = $command_type"
	echo -e "stc_name = $stc_name"
	echo -e "patus_command = $patus_command"
	echo -e "tune_command = $tune_command"
	echo -e "tune_name = $tune_name"
	echo -e "date_name = $date_name"
	echo -e "type_stencil_date_name = $type_stencil_date_name"
	echo -e "optimal_parameters = $optimal_parameters"
	echo -e "parameters_file = $parameters_file"
	echo -e "current_parameter_set = $current_parameter_set"
	echo -e "integral_value = $integral_value"
	echo -e "perf_energy_file = $perf_energy_file"
	echo -e "tmp_perf = $tmp_perf"
	echo -e "max = $max"
	echo -e "max_default = $max_default"
	echo -e "multiple_flag = $multiple_flag"
	echo -e "multiple_count = $multiple_flag"
	echo -e "dimensions = $dimensions"
	echo -e "processor_type = $processor_type"
}



check_ip_address(){
	if !([ -z "$1" ]);
	then
		given_ip=$(echo -e "$1" \
		| grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}")
		if ([ -z "$given_ip" ] || !([ "$given_ip" = "$1" ]))
		then
			echo -e "$1 is not a valid IP address! Exiting..."
			exit 0
		fi
	else
		echo -e "No IP address specified?"
		exit 0
	fi
}



check_ssh_connection(){
	echo -e "Checking SSH Connection! (pi@$1)"
	ssh -q pi@$1 exit
	check=$?
	if [ "$check" = "255" ]; then
		echo -e "Code $check: SSH Connection not possible... exiting now!"
		exit 1
	elif [ "$check" = "0" ]; then
		echo -e "Code $check: SSH Connection will be established!"
	else
		echo -e "Something went wrong... exiting!"
		exit 0
	fi
}



check_and_set_stencil_specification(){
	if ([ "$1" = "blur-float" ] && [ $# -eq 3 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ]); then	
		stc_name="blur-float"
		patus_command="patus blur-float.stc"
		tune_command="make tune width=$2 height=$3"
		dimensions="$2""x""$3"
	elif ([ "$1" = "divergence-float" ] && [ $# -eq 4 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ] && [ "$4" -eq "$4" ]); then
		stc_name="divergence-float"
		patus_command="patus divergence-float.stc"
		tune_command="make tune x_max=$2 y_max=$3 z_max=$4"
		dimensions="$2""x""$3""x""$4"
	elif ([ "$1" = "edge-float" ] && [ $# -eq 3 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ]); then
		stc_name="edge-float"
		patus_command="patus edge-float.stc"
		tune_command="make tune width=$2 height=$3"
		dimensions="$2""x""$3"
	elif ([ "$1" = "game-of-life-float" ] && [ $# -eq 3 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ]); then
		stc_name="game-of-life-float"
		patus_command="patus game-of-life-float.stc"
		tune_command="make tune width=$2 height=$3"
		dimensions="$2""x""$3"
	elif ([ "$1" = "hinterp-float" ] && [ $# -eq 3 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ]); then
		stc_name="hinterp-float"
		patus_command="patus hinterp-float.stc"
		tune_command="make tune width=$2 height=$3"
		dimensions="$2""x""$3"
	elif ([ "$1" = "gradient-float" ] && [ $# -eq 4 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ] && [ "$4" -eq "$4" ]); then
		patus_command="patus gradient-float.stc"
		tune_command="make tune x_max=$2 y_max=$3 z_max=$4"
		stc_name="gradient-float"
		dimensions="$2""x""$3""x""$4"
	elif ([ "$1" = "laplacian6-float" ] && [ $# -eq 4 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ] && [ "$4" -eq "$4" ]); then
		stc_name="laplacian6-float"
		patus_command="patus laplacian6-float.stc"
		tune_command="make tune x_max=$2 y_max=$3 z_max=$4"
		dimensions="$2""x""$3""x""$4"
	elif ([ "$1" = "laplacian-float" ] && [ $# -eq 4 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ] && [ "$4" -eq "$4" ]); then
		stc_name="laplacian-float"
		patus_command="patus laplacian-float.stc"
		tune_command="make tune x_max=$2 y_max=$3 z_max=$4"
		dimensions="$2""x""$3""x""$4"
	elif ([ "$1" = "tricubic-float" ] && [ $# -eq 4 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ] && [ "$4" -eq "$4" ]); then
		stc_name="tricubic-float"
		patus_command="patus tricubic-float.stc"
		tune_command="make tune x_max=$2 y_max=$3 z_max=$4"
		dimensions="$2""x""$3""x""$4"
	elif ([ "$1" = "vinterp-float" ] && [ $# -eq 3 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ]); then
		stc_name="vinterp-float"
		patus_command="patus vinterp-float.stc"
		tune_command="make tune width=$2 height=$3"
		dimensions="$2""x""$3"
	elif ([ "$1" = "wave-1-float" ] && [ $# -eq 4 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ] && [ "$4" -eq "$4" ]); then
		stc_name="wave-1-float"
		patus_command="patus wave-1-float.stc"
		tune_command="make tune x_max=$2 y_max=$3 z_max=$4"
		dimensions="$2""x""$3""x""$4"
	elif ([ "$1" = "wave-2-float" ] && [ $# -eq 4 ] && [ "$2" -eq "$2" ] \
			&& [ "$3" -eq "$3" ] && [ "$4" -eq "$4" ]); then
		stc_name="wave-2-float"
		patus_command="patus wave-2-float.stc"
		tune_command="make tune x_max=$2 y_max=$3 z_max=$4"
		dimensions="$2""x""$3""x""$4"
	else
		echo -e "INCORRECT USAGE!"
		echo -e "          $0 $command_type blur-float height width"
		echo -e "          $0 $command_type divergence-float x_max y_max z_max"
		echo -e "          $0 $command_type edge-float height width"
		echo -e "          $0 $command_type game-of-life-float height width"
		echo -e "          $0 $command_type gradient-float x_max y_max z_max"
		echo -e "          $0 $command_type hinterp-float height width"
		echo -e "          $0 $command_type laplacian6-float x_max y_max z_max"
		echo -e "          $0 $command_type laplacian-float x_max y_max z_max"
		echo -e "          $0 $command_type tricubic-float x_max y_max z_max"
		echo -e "          $0 $command_type vinterp-float height width"
		echo -e "          $0 $command_type wave-1-float x_max y_max z_max"
		echo -e "          $0 $command_type wave-2-float x_max y_max z_max"
		exit 0
	fi

	if [ "$command_type" = "host" ]; then
		patus_command="$patus_command"" --architecture=\"ARM_NEON\""
	fi
}



create_graph(){
	tmp='tmp.txt'
	txt="$type_stencil_date_name.txt"
	pic="$type_stencil_date_name.png"

	#Put all performance information into a new file ($tmp)
	grep -w "^(INFO) Performance:" $results_folder/$type_stencil_date_name/$tune_name | grep -o -w "[[:digit:]]*.[[:digit:]]\{6\}" > $tmp

	#create a file of tuple (iteration,performance)	--- creates file called iter_$tmp
	python calc_iteration.py $tmp
	#keep the best performance up until iteration X	--- creates file called max_iter_$tmp
	python calc_maximum.py iter_$tmp ","

	#result from max_iter_$tmp is put into a new file (see above)
	cat max_iter_$tmp > $txt

	#temp files are deleted
	rm -r $tmp
	rm -r iter_$tmp
	rm -r max_iter_$tmp

	echo -e > gnuplot.in
	echo -e "set terminal png size 1280,720" >> gnuplot.in
	echo -e "set output \"$pic\"" >> gnuplot.in
	echo -e "set xlabel \"evaluations\"" >> gnuplot.in
	echo -e "set logscale x 2" >> gnuplot.in
	echo -e "set ylabel \"performance in GFlop/s\"" >> gnuplot.in
	#echo -e "ymin=3" >> gnuplot.in
	#echo -e "ymax=8" >> gnuplot.in
	#echo -e "set yrange [ymin:ymax]" >> gnuplot.in
	#echo -e "set key right bottom box" >> gnuplot.in	#legend moved top left with box
	echo -e "set title \"$stc_name ($dimensions) on $processor_type\"" >> gnuplot.in
	#echo -e "set key below box" >> gnuplot.in	#legend moved below graph in a box
	#echo -e "set key outside" >> gnuplot.in	#legend moved outside of graph
	echo -e "set datafile separator \",\"" >> gnuplot.in
	echo -e "plot '$txt' with lines notitle" >> gnuplot.in 
	gnuplot gnuplot.in
	
	#rm -r gnuplot.in
	mv gnuplot.in $results_folder/$type_stencil_date_name/gnuplot_simple_graph.in

	#echo -e $txt
	#echo -e $pic
	mv $txt $results_folder/$type_stencil_date_name/
	mv $pic $results_folder/$type_stencil_date_name/

	#creating a little script for easy future use in same folder
	SCRIPT="SCRIPT_simple_graph.sh"
	echo -e "#!/bin/bash" > $SCRIPT
	echo -e "gnuplot gnuplot_simple_graph.in" >> $SCRIPT
	echo -e "exit 0" >> $SCRIPT
	chmod a+rx $SCRIPT
	mv $SCRIPT $results_folder/$type_stencil_date_name/
}



create_averages(){
	m=1
	while [ $m -le $multiple_count ];
	do	
		lines_nr[$m]=$(wc -l $results_folder/${type_stencil_date_name_array[$m]}/${type_stencil_date_name_array[$m]}.txt | cut -f 1 -d " ")
		m=$((m+1))
	done

	#echo -e "\${lines_nr[@]}: ${lines_nr[@]}"

	max_lines="0"
	n="1"
	while [ $n -le $multiple_count ];
	do
		if [ ${lines_nr[$n]} -gt $max_lines ]; then
			max_lines=${lines_nr[$n]}
		fi
		n=$((n+1))
	done

	echo -e "Max. evaluations: $max_lines"
	
	i="1"
	while [ $i -lt $max_lines ];
	do
		#sed "${i}q;d" $results_folder/${type_stencil_date_name_array[1]}/${type_stencil_date_name_array[1]}.txt | cut -f 2 -d ","

		#average
		avg[$i]=0
	
		#devisor
		d=0

		m=1
		while [ $m -le $multiple_count ];
		do
			if [ $i -le ${lines_nr[$m]} ]; then
				sed "${i}q;d" $results_folder/${type_stencil_date_name_array[$m]}/${type_stencil_date_name_array[$m]}.txt
				value=$(sed "${i}q;d" $results_folder/${type_stencil_date_name_array[$m]}/${type_stencil_date_name_array[$m]}.txt | cut -f 2 -d ",")
				#value="1"
				avg[$i]=$(echo -e "${avg[$i]} + $value" | bc)
				d=$((d+1))
			fi
			m=$((m+1))
		done

		avg[$i]=$(echo -e print ${avg[$i]}/$d | python)


		if [ $i = "1" ];
		then
			echo -e "$i,${avg[$i]}" > ${command_type}_average.txt
		else
			echo -e "$i,${avg[$i]}" >> ${command_type}_average.txt 
		fi


		i=$((i+1))
	done

	#echo -e "${avg[@]}"
}


create_average_graph_multiple(){

	#echo -e "\t\t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	#echo -e "\t\ttype_stencil_date_name_array = ${type_stencil_date_name_array[@]}"
	#echo -e "\t\t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	if [ "$log" = "NO" ]; then
		multiple_type_date=$(date +AVG_NORMAL_MULTIPLE_${command_type}) #_%F_%H.%M.%S)
	else
		multiple_type_date=$(date +AVG_LOG_MULTIPLE_${command_type}) #_%F_%H.%M.%S)
	fi

	echo -e > gnuplot.in
	echo -e "set terminal pngcairo size 1280,720" >> gnuplot.in
	echo -e "set output \"${multiple_type_date}.png\"" >> gnuplot.in
	echo -e "set xlabel \"evaluations\"" >> gnuplot.in
	if !([ "$log" = "NO" ]); then
		echo -e "set logscale x 2" >> gnuplot.in
	fi
	echo -e "set ylabel \"performance in GFlop/s\"" >> gnuplot.in
	#echo -e "ymin=3" >> gnuplot.in
	#echo -e "ymax=8" >> gnuplot.in
	#echo -e "set yrange [ymin:ymax]" >> gnuplot.in
	echo -e "set key right bottom box" >> gnuplot.in	#legend moved top left with box
	#echo -e "set key below box" >> gnuplot.in	#legend moved below graph in a box
	#echo -e "set key outside" >> gnuplot.in	#legend moved outside of graph
	echo -e "set datafile separator \",\"" >> gnuplot.in
	echo -e "set style line 1 lt rgb \"black\" lw 3" >> gnuplot.in
	echo -e "set title \"$stc_name ($dimensions) on $processor_type\"" >> gnuplot.in

	n=1
	if [ "$multiple_count" -eq "1" ];
	then
		echo -e "plot '$results_folder/${type_stencil_date_name_array[$n]}/${type_stencil_date_name_array[$n]}.txt' with lines title \"iteration ${n}\"" >> gnuplot.in 
	else
		while [ "$n" -le "$multiple_count" ];
		do
			#echo -e "\t\tn = $n"
			#echo -e "\t\ttype_stencil_date_name_array[$n] = ${type_stencil_date_name_array[$n]}"

			if [ "$n" -eq "1" ];
			then
				echo -e "plot '$results_folder/${type_stencil_date_name_array[$n]}/${type_stencil_date_name_array[$n]}.txt' with lines title \"iteration ${n}\", \\" >> gnuplot.in
			else
				echo -e "'$results_folder/${type_stencil_date_name_array[$n]}/${type_stencil_date_name_array[$n]}.txt' with lines title \"iteration ${n}\", \\" >> gnuplot.in 
			fi
			n=$((n+1))
		done
	fi


	#this part creates the optimal value & 90% of optimal value lines in the plot
	p=1
	optimal=0
	while [ "$p" -le "$multiple_count" ];
	do
		line_nr=$(wc -l $results_folder/${type_stencil_date_name_array[$p]}/${type_stencil_date_name_array[$p]}.txt | cut -f 1 -d " ")
		#echo -e "line_nr: $line_nr"

		tmp_value=$(sed "${line_nr}q;d" $results_folder/${type_stencil_date_name_array[$p]}/${type_stencil_date_name_array[$p]}.txt | cut -f 2 -d ",")
		#echo -e "tmp_value: $tmp_value"

		optimal=$(echo -e "print(max(${optimal},${tmp_value}))" | python)
		#echo -e "optimal: $optimal"

		p=$((p+1))
	done

	optimal_90=$(echo -e print ${optimal}*0.9 | python)
	#echo -e "optimal_90: ${optimal_90}"
	
	echo -e "${optimal} dt 3 lt rgb \"#44FF0000\" lw 2 title \"found optimum\", \\" >> gnuplot.in 

	echo -e "${optimal_90} dt 3 lt rgb \"#88000000\" lw 2 title \"90% of optimum\", \\" >> gnuplot.in 

	echo -e "'${command_type}_average.txt' ls 1 with lines title \"average\"" >> gnuplot.in 


	gnuplot gnuplot.in


	sed -i "s/$results_folder\///g" gnuplot.in

	if [ "$log" = "NO" ];
	then
		mv gnuplot.in $results_folder/$multiple_folder_name/gnuplot_NORMAL_$command_type.in
	else
		mv gnuplot.in $results_folder/$multiple_folder_name/gnuplot_LOG_$command_type.in
	fi
		

	#creating a little script for easy future use in same folder
	SCRIPT="SCRIPT_averages.sh"
	echo -e "#!/bin/bash" > $SCRIPT
	echo -e "for file in \`ls -a | egrep 'gnuplot_.*'\`" >> $SCRIPT
	echo -e "do" >> $SCRIPT
	echo -e "\techo \$file" >> $SCRIPT
	echo -e "\tgnuplot \$file" >> $SCRIPT
	echo -e "done" >> $SCRIPT
	echo -e "exit 0" >> $SCRIPT
	chmod a+rx $SCRIPT
	mv $SCRIPT $results_folder/$multiple_folder_name/


	optimum_file="optimum_${command_type}.txt"
	touch $optimum_file
	echo -e "found optimum:  $optimal" 	 > $optimum_file
	echo -e "90% of optimum: $optimal_90" 	>> $optimum_file
	mv $optimum_file $results_folder/$multiple_folder_name/
}



create_graph_multiple_WITH_average(){
	#create_averages
	echo -e "Creating averages!"
	create_averages

	echo -e "Creating LOG Graphs!"
	log="YES"
	create_average_graph_multiple

	echo -e "Creating NO LOG Graphs!"
	log="NO"
	create_average_graph_multiple

	echo -e "Moving Graphs & averages file!"
	mv AVG_LOG_MULTIPLE_${command_type}.png $results_folder/$multiple_folder_name
	mv AVG_NORMAL_MULTIPLE_${command_type}.png $results_folder/$multiple_folder_name
	mv ${command_type}_average.txt $results_folder/$multiple_folder_name
}


### NOT USED ###
create_graph_multiple_NO_average(){
	echo -e "\t\t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo -e "\t\ttype_stencil_date_name_array = ${type_stencil_date_name_array[@]}"
	echo -e "\t\t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"


	echo -e > gnuplot.in
	echo -e "set terminal png size 1280,720" >> gnuplot.in
	echo -e "set output \"${multiple_type_date}.png\"" >> gnuplot.in
	echo -e "set xlabel \"evaluations\"" >> gnuplot.in
	echo -e "set logscale x 2" >> gnuplot.in
	echo -e "set ylabel \"performance in GFlop/s\"" >> gnuplot.in
	#echo -e "ymin=3" >> gnuplot.in
	#echo -e "ymax=8" >> gnuplot.in
	#echo -e "set yrange [ymin:ymax]" >> gnuplot.in
	echo -e "set key right top box" >> gnuplot.in	#legend moved top left with box
	#echo -e "set key below box" >> gnuplot.in	#legend moved below graph in a box
	#echo -e "set key outside" >> gnuplot.in	#legend moved outside of graph
	echo -e "set datafile separator \",\"" >> gnuplot.in
	echo -e "set title \"$stc_name ($dimensions) on $processor_type\"" >> gnuplot.in

	n=1
	if [ "$multiple_count" -eq "1" ];
	then
		echo -e "plot '$results_folder/${type_stencil_date_name_array[$n]}/${type_stencil_date_name_array[$n]}.txt' with lines title \"iteration #${n}\"" >> gnuplot.in 
	else
		while [ "$n" -le "$multiple_count" ];
		do
			#echo -e "\t\tn = $n"
			#echo -e "\t\ttype_stencil_date_name_array[$n] = ${type_stencil_date_name_array[$n]}"

			if [ "$n" -eq "1" ];
			then
				echo -e "plot '$results_folder/${type_stencil_date_name_array[$n]}/${type_stencil_date_name_array[$n]}.txt' with lines title \"iteration #${n}\", \\" >> gnuplot.in 	
			elif [ "$n" -eq "$multiple_count" ];
			then		
				echo -e "'$results_folder/${type_stencil_date_name_array[$n]}/${type_stencil_date_name_array[$n]}.txt' with lines title \"iteration #${n}\"" >> gnuplot.in 
			else
				echo -e "'$results_folder/${type_stencil_date_name_array[$n]}/${type_stencil_date_name_array[$n]}.txt' with lines title \"iteration #${n}\", \\" >> gnuplot.in 
			fi
			n=$((n+1))
		done
	fi

	gnuplot gnuplot.in


	n=1
	while [ "$n" -le "$multiple_count" ];
	do
		sed -i "s/$results_folder\///g" gnuplot.in
		n=$((n+1))
	done


	#rm -r gnuplot.in
	mv gnuplot.in $results_folder/$multiple_folder_name/gnuplot_$multiple_folder_name.in

	mv $multiple_type_date.png $results_folder/$multiple_folder_name
}



perf_energy_graph_change_threads(){
	i=1
	while [ "$i" -le "$max" ];
	do
		#remove just in case it already exists
		rm -r "$results_folder/$type_stencil_date_name/measurements/t${i}_integral.txt" 2>/dev/null
		#this file will be used to store the performance/energy value (one for each thread count)
		perf_energy_file="$results_folder/$type_stencil_date_name/t${i}_perf_energy.txt"

		#remove such file if it already exists & create anew
		rm -r $perf_energy_file 2>/dev/null
		touch $perf_energy_file

		echo -e "Calculating the integral! This might take a while..."

		j=1
		while [ "$j" -le "$number_of_parameter_sets" ];
		do

			# Create tmp file to temporarily store the value's of the measurement since the data of column 2 (voltage) & 3 (current) are not used for calculation
			tmp_measure="$results_folder/$type_stencil_date_name/tmp.txt"
			measure_file="$results_folder/$type_stencil_date_name/measurements/t${i}_measure_device_${j}.txt"
			# Reduce measure_file "data" (only sec,power is left, everything else will be dropped)
			# $measure_file is the input > new_$measure_file is the output
			grep -w "^[[:digit:]]*.[[:digit:]]\{6\},[[:digit:]]*.[[:digit:]]\{6\},[[:digit:]]*.[[:digit:]]\{6\},[[:digit:]]*.[[:digit:]]\{6\}" $measure_file | cut -d "," -f 1,4 > $tmp_measure
			
			# calculate the integrals, then they are put into a file named 'measure_result' which will be deleted later (file gets overwritten in each iteration)
			python calc_integral.py $tmp_measure "," > /dev/null
			
			# measure_result only has a single value (integral)
			integral_value=$(cat measure_result)
			
			# integral value is put into a file containing all integral values for a specific thread count
			echo -e "$integral_value" | tee -a $results_folder/$type_stencil_date_name/measurements/t${i}_integral.txt >/dev/null

			#getting the performance value for the current step
			tmp_perf=$(grep -w "^Performance:" $results_folder/$type_stencil_date_name/measurements/t${i}_measure_bench_${j}.txt | grep -o -w "[[:digit:]]*.[[:digit:]]\{6\}")

			#echo -e "$tmp_perf"
			#"performce,energy" inserted into file
			echo -e "$tmp_perf"",""$integral_value" | tee -a $perf_energy_file >/dev/null

			j=$((j+1))
		done
		i=$((i+1))
	done

	rm -r $tmp_measure
	rm -r measure_result

	
	#calculate pearson
	pearson_file="pearson.txt"
	touch $pearson_file
	r=1
	while [ "$r" -le "$max" ];
	do
		pearson[$r]=$(python calc_pearson.py $results_folder/$type_stencil_date_name/t${r}_perf_energy.txt)
		#cut the string a little shorter (5 decimals)
		pearson[$r]=${pearson[$r]:0:7}
		echo -e "${pearson[$r]}" >> $pearson_file
		r=$((r+1))
	done
	mv $pearson_file $results_folder/$type_stencil_date_name/


	pic=""

	k="1"
	while [ "$k" -le "$max" ];
	do 
		if [ "$k" -eq "1" ];
		then		
			pic="$results_folder/$type_stencil_date_name/perf_energy_${k}_thread.png"
		else
			pic="$results_folder/$type_stencil_date_name/perf_energy_${k}_threads.png"
		fi

		# Graph for performance/energy
		echo -e > gnuplot.in
		echo -e "set terminal png size 1280,720" >> gnuplot.in
		echo -e "set output \"$pic\"" >> gnuplot.in
		echo -e "set xlabel \"performance in GFlop/s\"" >> gnuplot.in
		#echo -e "set logscale x 2" >> gnuplot.in
		echo -e "set ylabel \"energy consumption in Ws\"" >> gnuplot.in
		#echo -e "ymin=3" >> gnuplot.in
		#echo -e "ymax=8" >> gnuplot.in
		#echo -e "set yrange [ymin:ymax]" >> gnuplot.in
		#echo -e "set key right top box" >> gnuplot.in	#legend moved top left with box
		#echo -e "set key below box" >> gnuplot.in	#legend moved below graph in a box
		#echo -e "set key outside" >> gnuplot.in	#legend moved outside of graph
		echo -e "set datafile separator \",\"" >> gnuplot.in
		
		if [ $k -eq "1" ];
		then		
			echo -e "set title \"$stc_name ($dimensions) on $processor_type ($k thread)\"" >> gnuplot.in
		else
			echo -e "set title \"$stc_name ($dimensions) on $processor_type ($k threads)\"" >> gnuplot.in
		fi


		#add pearson
		echo -e "LABEL = \"r = ${pearson[$k]}\"" >> gnuplot.in
		echo -e "set obj 1 rect at graph 0.95,0.95 size char 9, char 1" >> gnuplot.in
		echo -e "set obj 1 fillstyle empty border -1 front" >> gnuplot.in
		echo -e "set label 1 at graph 0.95,0.95 LABEL front center offset 0.0,-0.1" >> gnuplot.in


		echo -e "plot '$results_folder/$type_stencil_date_name/t${k}_perf_energy.txt' notitle" >> gnuplot.in 


		gnuplot gnuplot.in


		sed -i "s/$results_folder\/$type_stencil_date_name\///g" gnuplot.in

		#rm -r gnuplot.in
		mv gnuplot.in $results_folder/$type_stencil_date_name/gnuplot_${k}_threads.in


		k=$((k+1))
	done


	i="1"
	while [ $i -le $max ];
	do
		perf_energy_array[$i]="$results_folder/$type_stencil_date_name/t${i}_perf_energy"
		#echo -e "${perf_energy_array[$i]} added!"
		i=$((i+1))
	done


	all_threads_type_date=$(date +ALL_THREADS_${command_type}_%F_%H.%M.%S)

	echo -e > gnuplot.in
	echo -e "set terminal png size 1280,720" >> gnuplot.in
	echo -e "set output \"${all_threads_type_date}.png\"" >> gnuplot.in
	echo -e "set xlabel \"performance in GFlop/s\"" >> gnuplot.in
	#echo -e "set logscale x 2" >> gnuplot.in
	echo -e "set ylabel \"energy consumption in Ws\"" >> gnuplot.in
	#echo -e "ymin=3" >> gnuplot.in
	#echo -e "ymax=8" >> gnuplot.in
	#echo -e "set yrange [ymin:ymax]" >> gnuplot.in
	echo -e "set key right top box" >> gnuplot.in	#legend moved top left with box
	#echo -e "set key below box" >> gnuplot.in	#legend moved below graph in a box
	#echo -e "set key outside" >> gnuplot.in	#legend moved outside of graph
	echo -e "set datafile separator \",\"" >> gnuplot.in
	if [ "$max" = "1" ];
	then
		echo -e "set title \"$stc_name ($dimensions) on $processor_type (1 thread)\"" >> gnuplot.in
	else
		echo -e "set title \"$stc_name ($dimensions) on $processor_type (1 to $max threads)\"" >> gnuplot.in
	fi

	n=1
	if [ "$max" -eq "1" ];
	then
		echo -e "plot '${perf_energy_array[$n]}.txt' title \"$n thread (r_${n} = ${pearson[$n]})\"" >> gnuplot.in 
	else
		while [ "$n" -le "$max" ];
		do
			#echo -e "\t\tn = $n"
			#echo -e "\t\tperf_energy_array[$n] = ${perf_energy_array[$n]}"

			if [ "$n" -eq "1" ];
			then
				echo -e "plot '${perf_energy_array[$n]}.txt' title \"$n thread (r_${n} = ${pearson[$n]})\", \\" >> gnuplot.in 	
			elif [ "$n" -eq "$max" ];
			then		
				echo -e "'${perf_energy_array[$n]}.txt' title \"$n threads (r_${n} = ${pearson[$n]})\"" >> gnuplot.in 
			else
				echo -e "'${perf_energy_array[$n]}.txt' title \"$n threads (r_${n} = ${pearson[$n]})\", \\" >> gnuplot.in 
			fi
			n=$((n+1))
		done
	fi


	gnuplot gnuplot.in


	sed -i "s/$results_folder\/$type_stencil_date_name\///g" gnuplot.in

	#rm -r gnuplot.in
	mv gnuplot.in $results_folder/$type_stencil_date_name/gnuplot_ALL_THREADS.in

	mv ${all_threads_type_date}.png $results_folder/$type_stencil_date_name/


	#creating a little script for easy future use in same folder
	SCRIPT="SCRIPT_multiple_threads_graphs.sh"
	echo -e "#!/bin/bash" > $SCRIPT
	echo -e "for file in \`ls -a | egrep 'gnuplot_.*'\`" >> $SCRIPT
	echo -e "do" >> $SCRIPT
	echo -e "\techo \$file" >> $SCRIPT
	echo -e "\tgnuplot \$file" >> $SCRIPT
	echo -e "done" >> $SCRIPT
	echo -e "exit 0" >> $SCRIPT
	chmod a+rx $SCRIPT
	mv $SCRIPT $results_folder/$type_stencil_date_name/
}



perf_energy_graph_no_thread_change(){
	#remove just in case it already exists
	rm -r "$results_folder/$type_stencil_date_name/measurements/integral.txt" 2>/dev/null
	#this file will be used to store the performance/energy value (one for each thread count)
	perf_energy_file="$results_folder/$type_stencil_date_name/perf_energy.txt"

	#remove such file if it already exists & create anew
	rm -r $perf_energy_file 2>/dev/null
	touch $perf_energy_file

	echo -e "Calculating the integral! This might take a while..."

	j=1
	while [ "$j" -le "$number_of_parameter_sets" ];
	do

		# Create tmp file to temporarily store the value's of the measurement since the data of column 2 (voltage) & 3 (current) are not used for calculation
		tmp_measure="$results_folder/$type_stencil_date_name/tmp.txt"
		measure_file="$results_folder/$type_stencil_date_name/measurements/measure_device_${j}.txt"
		# Reduce measure_file "data" (only sec,power is left, everything else will be dropped)
		# $measure_file is the input > new_$measure_file is the output
		grep -w "^[[:digit:]]*.[[:digit:]]\{6\},[[:digit:]]*.[[:digit:]]\{6\},[[:digit:]]*.[[:digit:]]\{6\},[[:digit:]]*.[[:digit:]]\{6\}" $measure_file | cut -d "," -f 1,4 > $tmp_measure
		
		# calculate the integrals, then they are put into a file named 'measure_result' which will be deleted later (file gets overwritten in each iteration)
		python calc_integral.py $tmp_measure "," > /dev/null
		
		# measure_result only has a single value (integral)
		integral_value=$(cat measure_result)
			
		# integral value is put into a file containing all integral values for one thread count
		echo -e "$integral_value" | tee -a $results_folder/$type_stencil_date_name/measurements/integral.txt >/dev/null

		#getting the performance value for the current step
		tmp_perf=$(grep -w "^Performance:" $results_folder/$type_stencil_date_name/measurements/measure_bench_${j}.txt | grep -o -w "[[:digit:]]*.[[:digit:]]\{6\}")

		#echo -e "$tmp_perf"
		#"performce,energy" inserted into file
		echo -e "$tmp_perf"",""$integral_value" | tee -a $perf_energy_file >/dev/null
			
		j=$((j+1))
	done

	rm -r $tmp_measure
	rm -r measure_result


	#calculate pearson
	pearson_file="pearson.txt"
	touch $pearson_file
	pearson_value=$(python calc_pearson.py $results_folder/$type_stencil_date_name/perf_energy.txt)
	#cut the string a little shorter (5 decimals)
	pearson_value=${pearson_value:0:7}
	echo -e "$pearson_value" >> $pearson_file
	r=$((r+1))
	
	mv $pearson_file $results_folder/$type_stencil_date_name/


	pic="$results_folder/$type_stencil_date_name/perf_energy.png"

	# Graph for performance/energy
	echo -e > gnuplot.in
	echo -e "set terminal png size 1280,720" >> gnuplot.in
	echo -e "set output \"$pic\"" >> gnuplot.in
	echo -e "set xlabel \"performance in GFlop/s\"" >> gnuplot.in
	#echo -e "set logscale x 2" >> gnuplot.in
	echo -e "set ylabel \"energy consumption in Ws\"" >> gnuplot.in

	#echo -e "ymin=3" >> gnuplot.in
	#echo -e "ymax=8" >> gnuplot.in
	#echo -e "set yrange [ymin:ymax]" >> gnuplot.in
	#echo -e "set key right bottom box" >> gnuplot.in	#legend moved top left with box
	#echo -e "set key below box" >> gnuplot.in	#legend moved below graph in a box
	#echo -e "set key outside" >> gnuplot.in	#legend moved outside of graph
	echo -e "set datafile separator \",\"" >> gnuplot.in
	echo -e "set title \"$stc_name ($dimensions) on $processor_type\"" >> gnuplot.in

	#add pearson
	echo -e "LABEL = \"r = ${pearson_value}\"" >> gnuplot.in
	echo -e "set obj 1 rect at graph 0.95,0.95 size char 9, char 1" >> gnuplot.in
	echo -e "set obj 1 fillstyle empty border -1 front" >> gnuplot.in
	echo -e "set label 1 at graph 0.95,0.95 LABEL front center offset 0.0,-0.1" >> gnuplot.in

	echo -e "plot '$results_folder/$type_stencil_date_name/perf_energy.txt' notitle" >> gnuplot.in 


	gnuplot gnuplot.in

	
	sed -i "s/$results_folder\/$type_stencil_date_name\///g" gnuplot.in

	#rm -r gnuplot.in
	mv gnuplot.in $results_folder/$type_stencil_date_name/gnuplot_perf_energy.in


	#creating a little script for easy future use in same folder
	SCRIPT="SCRIPT_perf_energy.sh"
	echo -e "#!/bin/bash" > $SCRIPT
	echo -e "gnuplot gnuplot_perf_energy.in" >> $SCRIPT
	echo -e "exit 0" >> $SCRIPT
	chmod a+rx $SCRIPT
	mv $SCRIPT $results_folder/$type_stencil_date_name/
}



local_no_measure(){
	# source util/patusvars.sh
	cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../

	# patus wave-1-float.stc
	cd $patus_folder/benchmark && $patus_command && cd ../../
		
	#make
	cd $patus_folder/benchmark/out && make && cd ../../../
	
	# make tune x_max=$2 y_max=$3 z_max=$4
	cd $patus_folder/benchmark/out && $tune_command && cd ../../../

	# new name for folder (type_stencil_date_name)
		# tune_YYYY-MM-DD_HH.MM.SS.txt
	tune_name=$(find $patus_folder/benchmark/out | grep -m 1 -o "tune_.*\.txt")
		# YYYY-MM-DD_HH.MM.SS
	date_name=$(echo -e "$tune_name" | grep -o "[0-9]*-[0-9]*-[0-9]*_[0-9]*\.[0-9]*\.[0-9]*")
		# TYPE_STENCIL_DATE
	type_stencil_date_name="$command_type""_""$stc_name""_""$date_name"

			#echo -e $type_stencil_date_name

	# create the new folder for our output
	mkdir -p $results_folder/$type_stencil_date_name

	# move "out" content into the results_folder and delete old "out" folder
	mv $patus_folder/benchmark/out/* $results_folder/$type_stencil_date_name
	rm -r "$patus_folder/benchmark/out/"
		
	# creating the graph...
	create_graph

	#./graph.sh $results_folder/$type_stencil_date_name/$tune_name $stc_name $command_type
	#rm -r $results_folder/$type_stencil_date_name
}



host_without_measure(){
	# patus wave-1-float.stc
	ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark && $patus_command && cd ../../"
		
	# make
	ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && make && cd ../../../"

	# make tune x_max=$2 y_max=$3 z_max=$4
	ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && $tune_command && cd ../../../"

	# new name for folder (type_stencil_date_name)
		# tune_YYYY-MM-DD_HH.MM.SS.txt
	tune_name=$(ssh -Y pi@$ip_address "find $patus_folder/benchmark/out | grep -m 1 -o "tune_.*\.txt"")
		# YYYY-MM-DD_HH.MM.SS
	date_name=$(echo -e "$tune_name" | grep -o "[0-9]*-[0-9]*-[0-9]*_[0-9]*\.[0-9]*\.[0-9]*")
		# TYPE_STENCIL_DATE
	type_stencil_date_name="$command_type""_""$stc_name""_""$date_name"

		#echo -e $type_stencil_date_name

	# create the new folder for our output
	mkdir -p $results_folder/$type_stencil_date_name

	# move "out" content into the results_folder and delete old "out" folder
	scp -r pi@$ip_address:/home/pi/$patus_folder/benchmark/out/* $results_folder/$type_stencil_date_name
	ssh -Y pi@$ip_address "rm -r /home/pi/$patus_folder/benchmark/out"

	# creating the graph...
	create_graph

	#./graph.sh $results_folder/$type_stencil_date_name/$tune_name $stc_name $command_type
	#rm -r $results_folder/$type_stencil_date_name
}



host_with_measure_no_thread_change(){
		# ----- NOTE ----
		# REMOVE THIS LINE IF WORKING WITH SAME FOLDER ON HOST
		# UNCOMMENT THE TWO LINES BELOW HOWEVER (make clean & delete previous tune file)
	# patus wave-1-float.stc
	ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark && $patus_command && cd ../../"

	# make clean
	# ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && make clean && cd ../../../" > /dev/null

	# delete previous tune file
	# ssh -Y pi@$ip_address "cd $patus_folder/benchmark/out && rm -r tune_*"


	# make
	echo -e "\t\t---MAKE---"
	ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && make && cd ../../../"
		
	# make tune x_max=$2 y_max=$3 z_max=$4
	ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && $tune_command && cd ../../../"


	# new name for folder (type_stencil_date_name)
		# tune_YYYY-MM-DD_HH.MM.SS.txt
	tune_name=$(ssh -Y pi@$ip_address "find $patus_folder/benchmark/out | grep -m 1 -o "tune_.*\.txt"")
		# YYYY-MM-DD_HH.MM.SS
	date_name=$(echo -e "$tune_name" | grep -o "[0-9]*-[0-9]*-[0-9]*_[0-9]*\.[0-9]*\.[0-9]*")
		# TYPE_STENCIL_DATE
	type_stencil_date_name="$command_type""_""$stc_name""_""$date_name"

		#echo -e $type_stencil_date_name


	parameters_file="parameters.txt"
		ssh -Y pi@$ip_address "grep -w \"^(INFO) Executing\" $patus_folder/benchmark/out/$tune_name | grep -o -w \"[[:digit:], ]*\" | sed \"s/,//g\"" > $parameters_file

	#echo -e "Showing the content of $parameters_file"
	#cat $parameters_file
	#exit 0


	# !!! really fast dummy_measure to reset the timer properly (it sometimes wouldn't be reset otherwise)...
	#echo -e "\t\tDUMMY MEASURE START"
	(tub_measurement/./client -s 1 -b 64 > /dev/null) &
	Process_ID="$!"
	if !([ -z "$Process_ID" ]);
	then
		#echo -e "\t\tFINISH MEASUREMENT!!!"
		kill -PIPE $Process_ID
	else
		echo -e "/t/t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo -e "/t/tSOME WEIRD ERROR WHERE MEASUREMENT HAD NO PROCESS ID!!!"
		echo -e "/t/t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	fi
	#echo -e "\t\tDUMMY MEASURE END"

	number_of_parameter_sets=$(grep -c ^ $parameters_file)
	echo -e "total number of parameter sets: $number_of_parameter_sets"


	# j = parameter set variable
	j=1
	while [ "$j" -le "$number_of_parameter_sets" ];
	do
		current_parameter_set=$(sed "${j}q;d" $parameters_file)
		echo -e "($j/$number_of_parameter_sets) Currently used parameter set: $current_parameter_set"
		# MEASURE (by starting a process in the background)
		Process_ID=""
		#echo -e "\t\tSTART MEASUREMENT!!!"
		(tub_measurement/./client -s 1 -b 64 > measure_device_${j}.txt) &
		Process_ID="$!"
		#echo -e "$Process_ID"
	
		# run the bench executable once
		ssh -Y pi@$ip_address "./$patus_folder/benchmark/out/bench $current_parameter_set" > measure_bench_${j}.txt

		#STOP THE MEASUREMENT (by killing the background process)
		if !([ -z "$Process_ID" ]);
		then
			#echo -e "\t\tFINISH MEASUREMENT!!!"
			kill -PIPE $Process_ID
		else
			echo -e "/t/t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			echo -e "/t/tSOME WEIRD ERROR WHERE MEASUREMENT HAD NO PROCESS ID!!!"
			echo -e "/t/t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		fi
		j=$((j+1))
	done

	# create the new folder for our output
	mkdir -p $results_folder/$type_stencil_date_name

	# move "out" content into the results_folder and delete old "out" folder
	scp -r pi@$ip_address:/home/pi/$patus_folder/benchmark/out/* $results_folder/$type_stencil_date_name
		
		# ----- NOTE ----
		# REMOVE THIS LINE IF WORKING WITH SAME FOLDER ON HOST
	#remove the out folder on host
	ssh -Y pi@$ip_address "rm -r /home/pi/$patus_folder/benchmark/out"


	# if measurement happened, then move the measurement files into the results folder too
	mkdir -p $results_folder/$type_stencil_date_name/measurements/
	mv measure_device_*.txt $results_folder/$type_stencil_date_name/measurements/
	mv measure_bench_*.txt $results_folder/$type_stencil_date_name/measurements/
	mv $parameters_file $results_folder/$type_stencil_date_name/measurements/


	#CREATE THE GRAPHS FOR THE MEASURED STUFF
	perf_energy_graph_no_thread_change

	
	# creating the 'classic' graph...
	create_graph

	#./graph.sh $results_folder/$type_stencil_date_name/$tune_name $stc_name $command_type
	#rm -r $results_folder/$type_stencil_date_name	

}



host_with_measure_change_threads(){
	#		+++ Explanation +++
	#	RUN MAKE TUNE WITHOUT THE CHANGED LINE(S)
	#	GET THE INFO ON ALL PARAMETER SETS & PUT THEM INTO A FILE
	#	AFTER THAT CHANGE THE NUMBER_OF_THREADS EACH TIME (driver.c)
	#	RUN ./bench
	#		-----> GET INFO ON PERFORMANCE FROM THERE (grep)
	#	RUN ./client parallel to that
	#	SAVE BOTH OUTPUTS INTO FILES
	#	RUN THE SCRIPT TO 'ADJUST' THE MEASURE FILE
	#	RUN THE SCRIPT TO GET THE INTEGRAL VALUE(S)
	#		-----> CREATE FILE THAT HAS ALL THE INTEGRAL VALUES (energy)
	#	CREATE FILE OF TYPE (performance,energy)
	#		-----> CREATE GRAPHS WITH THAT INFO
	#			(ONE GRAPH PER THREAD_NUMBER)
	#-----------------------------------------------------


		# ----- NOTE ----
		# REMOVE THIS LINE IF WORKING WITH SAME FOLDER ON HOST
		# UNCOMMENT THE TWO LINES BELOW HOWEVER (make clean & delete previous tune file)
	# patus wave-1-float.stc
	ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark && $patus_command && cd ../../"

	# make clean
	# ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && make clean && cd ../../../" > /dev/null

	# delete previous tune file
	# ssh -Y pi@$ip_address "cd $patus_folder/benchmark/out && rm -r tune_*"


	# make
	echo -e "\t\t---MAKE---"
	ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && make && cd ../../../"
		
	# make tune x_max=$2 y_max=$3 z_max=$4
	ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && $tune_command && cd ../../../"


	# new name for folder (type_stencil_date_name)
		# tune_YYYY-MM-DD_HH.MM.SS.txt
	tune_name=$(ssh -Y pi@$ip_address "find $patus_folder/benchmark/out | grep -m 1 -o "tune_.*\.txt"")
		# YYYY-MM-DD_HH.MM.SS
	date_name=$(echo -e "$tune_name" | grep -o "[0-9]*-[0-9]*-[0-9]*_[0-9]*\.[0-9]*\.[0-9]*")
		# TYPE_STENCIL_DATE
	type_stencil_date_name="$command_type""_""$stc_name""_""$date_name"

		#echo -e $type_stencil_date_name


	parameters_file="parameters.txt"
		ssh -Y pi@$ip_address "grep -w \"^(INFO) Executing\" $patus_folder/benchmark/out/$tune_name | grep -o -w \"[[:digit:], ]*\" | sed \"s/,//g\"" > $parameters_file

	#echo -e "Showing the content of $parameters_file"
	#cat $parameters_file
	#exit 0


	#----- FOR DEBUGGING...
	#Include if you want to see number of threads and/or the thread ID
	#ssh -Y pi@$ip_address "sed -i 's/int numthds0 = omp_get_num_threads();/int numthds0 = omp_get_num_threads(); printf(\"Number of threads: %i\\\n\",numthds0);/g' $patus_folder/benchmark/out/kernel.c"

	#ssh -Y pi@$ip_address "sed -i 's/int thdidx0 = omp_get_thread_num();/int thdidx0 = omp_get_thread_num(); printf(\"Thread Number: %i\\\n\",thdidx0);/g' $patus_folder/benchmark/out/kernel.c"

	# ^^^ For above to work, need to include stdio.h as well ^^^
	#ssh -Y pi@$ip_address "sed -i 's/#include \"tuned_params.h\"/#include \"tuned_params.h\"\n#include <stdio.h>/g' $patus_folder/benchmark/out/kernel.c"
	#-----



	#i = THREADS_NUMBER
	i=1
	while [ "$i" -le "$max" ];
	do
		echo -e "------------------------------"
		echo -e "Number of threads will now be: $i"
		echo -e "------------------------------"
		#sed "s/#pragma omp parallel/#pragma omp parallel num_threads($i)/g" $1 > NEW.c

		# make clean
		ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && make clean && cd ../../../" > /dev/null


		if [ "$i" -eq "1" ]; then
			# turn "#pragma omp parallel into same with num_threads(x) at end
			#echo -e "\t\tChanging 'THE line' (#pragma...) before make (i=$i)..."
			ssh -Y pi@$ip_address "sed -i \"s/#pragma omp parallel/#pragma omp parallel num_threads($i)/g\" $patus_folder/benchmark/out/driver.c"
		else
			# turn "#pragma omp parallel num_threads(x) into same but with num_threads(y) [different number]
			#echo -e "\t\tChanging 'THE line' (#pragma...) before make (i=$i)..."
			ssh -Y pi@$ip_address "sed -i \"s/#pragma omp parallel num_threads([0-9]*)/#pragma omp parallel num_threads($i)/g\" $patus_folder/benchmark/out/driver.c"
		fi



		# find line of main function of driver and insert/adjust line to set the number of threads
		if [ "$i" -eq "1" ];
		then
			#echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\t------------------------------------"
			ssh -Y pi@$ip_address "grep -n 'int main (.*)' $patus_folder/benchmark/out/driver.c | cut -d : -f1"
			#echo -e "\t------------------------------------"

			#echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\t------------------------------------"
			line=$(ssh -Y pi@$ip_address "grep -n 'int main (.*)' $patus_folder/benchmark/out/driver.c | cut -d : -f1")
			#echo -e "Line (1): $line"
			#echo -e "\t------------------------------------"

			#echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\t------------------------------------"
			line=$((line+1))
			#echo -e "Line (2): $line"
			#echo -e "\t------------------------------------"

			ssh -Y pi@$ip_address "sed -i '${line}s/{/{\n\tomp_set_num_threads(${i});/g' $patus_folder/benchmark/out/driver.c"
		else
			ssh -Y pi@$ip_address "sed -i 's/omp_set_num_threads(.*);/omp_set_num_threads(${i});/g' $patus_folder/benchmark/out/driver.c"
		fi




		# make
		echo -e "\t\t---MAKE---"				
		ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && make && cd ../../../"
			
		# NO NEED TO TUNE AGAIN!!!
		# make tune x_max=$2 y_max=$3 z_max=$4
		# ssh -Y pi@$ip_address "cd $patus_folder && . util/patusvars.sh 1>/dev/null && cd ../ && cd $patus_folder/benchmark/out && $tune_command && cd ../../../"


		# !!! really fast dummy_measure to reset the timer properly (it sometimes wouldn't be reset otherwise)...
		#echo -e "\t\tDUMMY MEASURE START"
		(tub_measurement/./client -s 1 -b 64 > /dev/null) &
		Process_ID="$!"
		if !([ -z "$Process_ID" ]);
		then
			#echo -e "\t\tFINISH MEASUREMENT!!!"
			kill -PIPE $Process_ID
		else
			echo -e "/t/t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			echo -e "/t/tSOME WEIRD ERROR WHERE MEASUREMENT HAD NO PROCESS ID!!!"
			echo -e "/t/t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		fi
		#echo -e "\t\tDUMMY MEASURE END"


		number_of_parameter_sets=$(grep -c ^ $parameters_file)
		echo -e "Total number of parameter sets: $number_of_parameter_sets"


		# j = parameter set variable
		j=1
		while [ "$j" -le "$number_of_parameter_sets" ];
		do
			current_parameter_set=$(sed "${j}q;d" $parameters_file)
			echo -e "($j/$number_of_parameter_sets) Currently used parameter set: $current_parameter_set"

			# MEASURE (by starting a process in the background)
			Process_ID=""
			#echo -e "\t\tSTART MEASUREMENT!!!"
			(tub_measurement/./client -s 1 -b 64 > t${i}_measure_device_${j}.txt) &
			Process_ID="$!"
			#echo -e "$Process_ID"
		
			# run the bench executable once
			ssh -Y pi@$ip_address "./$patus_folder/benchmark/out/bench $current_parameter_set" > t${i}_measure_bench_${j}.txt

			#STOP THE MEASUREMENT (by killing the background process)
			if !([ -z "$Process_ID" ]);
			then
				#echo -e "\t\tFINISH MEASUREMENT!!!"
				kill -PIPE $Process_ID
			else
				echo -e "/t/t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
				echo -e "/t/tSOME WEIRD ERROR WHERE MEASUREMENT HAD NO PROCESS ID!!!"
				echo -e "/t/t+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			fi
			j=$((j+1))
		done
		i=$((i+1))
	done

	#echo -e "\t\tCHANGING THE CHANGED LINE BACK TO IT'S ORIGINAL!"
	#ssh -Y pi@$ip_address "sed -i \"s/#pragma omp parallel num_threads($max)/#pragma omp parallel/g\" $patus_folder/benchmark/out/driver.c"

	# create the new folder for our output
	mkdir -p $results_folder/$type_stencil_date_name

	# move "out" content into the results_folder and delete old "out" folder
	scp -r pi@$ip_address:/home/pi/$patus_folder/benchmark/out/* $results_folder/$type_stencil_date_name
		
		# ----- NOTE ----
		# REMOVE THIS LINE IF WORKING WITH SAME FOLDER ON HOST
	#remove the out folder on host
	ssh -Y pi@$ip_address "rm -r /home/pi/$patus_folder/benchmark/out"


	# if measurement happened, then move the measurement files into the results folder too
	mkdir -p $results_folder/$type_stencil_date_name/measurements/
	mv t*.txt $results_folder/$type_stencil_date_name/measurements/
	mv $parameters_file $results_folder/$type_stencil_date_name/measurements/


	#CREATE THE GRAPHS FOR THE MEASURED STUFF
	perf_energy_graph_change_threads

	
	# creating the 'classic' graph...
	create_graph

	#./graph.sh $results_folder/$type_stencil_date_name/$tune_name $stc_name $command_type
	#rm -r $results_folder/$type_stencil_date_name		
}




# If you need help...
if (!([ -z $1 ])) && ([ $1 = "--help" ]);
then
	echo -e "Correst usage: "
	echo -e "	$0 [+measure] TYPE (ip-address) STENCIL PARAMETERS"
	exit 1
fi
# always exits execution



# If you want to collect the data points multiple times
if (!([ -z $1 ])) && ([ $1 = "multiple" ] || [ $1 = "Multiple" ]);
then
	echo -e "\t------------------------------"
	multiple_flag="multiple"
	shift
	if !([ -z "$1" ]) && ([ "$1" -eq "$1" ]) 2>/dev/null;
	then
		if ([ "$1" -gt "1" ]);
		then
			multiple_count=$1
			#echo -e "\tMultiple repetition will be set to: $1"	
			shift
			echo -e "\tMultiple repetition was set to: $multiple_count"	
		else
			multiple_count="2"
			echo -e "\t$1 is not valid, multiple repetition will INSTEAD be set to: $multiple_count (default)"
			shift
		fi
	else
		echo -e "You need to specify the number of times the repetition should happen (e.g. ... Multiple 6 ... )"
		echo -e "Exiting for your own safety..."
		exit -1
	fi
	echo -e "\t------------------------------"
fi



# Regarding the measurement device
if (!([ -z $1 ])) && ([ $1 = "+measure" ]);
then
	echo -e "\t------------------------------"
	shift
	
	# setting the maximum number of threads for the measurement
	if !([ -z "$1" ]) && ([ "$1" -eq "$1" ]) 2>/dev/null;
	then
		if ([ "$1" -gt "0" ]);
		then
			echo -e "\tmax number of threads will be set to $1 (custom)"
			max=$1
			shift
		else
			echo -e "\t$1 is not a valid number of threads..."
			echo -e "\tmax number of threads will instead be set to $max_default (default)"
			max=$max_default
			shift
		fi
	else
		echo -e "\tMeasurement will happen without changing the number of threads!!"
	fi	
	#echo -e "\t------------------------------"

	#echo -e "\t\t$1"

	#echo -e "\t------------------------------"
	# checking if "host" comes after +measure, as it is not allowed to be used for local only
	if (!([ -z $1 ])) && ([ $1 = "local" ]) 2>/dev/null;
	then
			echo -e "Can't use +measure with local... exiting!"
			exit 0
	elif (  !([ -z $1 ]) && (
		[ $1 = "both-network" ] ||
		[ $1 = "both-cable" ] 	|| 
		[ $1 = "host-network" ] ||
		[ $1 = "host-cable" ] 	||
		[ $1 = "both" ] 	|| 
		[ $1 = "host" ])); then
			measure="+measure"
	else
			echo -e "Please specify that you want to use host/host-cable/host-network"
			echo -e "e.g.   $0 +measure [max] host ..."
			echo -e "...exiting!"
			exit 0
	fi
	echo -e "\t------------------------------"
fi
# at this point $measure is either set to "" (nothing) or "+measure"



# Setting the IP_address for host/both-cable/network
# If the file does not exit or no IP address can be found in the file --> exit!
ip_address_file="ip_address_config.txt"
ip_address_cable=""
ip_address_network=""
find_ip_address_from_config_file(){
	ip_address_cable=$(grep -v "#.*" $ip_address_file | grep -w "cable" | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | head -1)
	ip_address_network=$(grep -v "#.*" $ip_address_file | grep -w "network" | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | head -1)

	if ([ "$1" = "both-network" ] || [ "$1" = "host-network" ]); then
		if [ -z "$ip_address_network" ]; then
			echo -e "\tError! Could not retrieve IP address from file: $ip_address_file"
				if [ -e "$ip_address_file" ]; then
				    echo -e "\t\tFile does exist, but maybe wrong data? (Invalid IP Address for example)"
				else 
				    echo -e "\t\tFile does not exist..."
				fi 
			echo -e "\tExiting now for your own safety..."
			exit -1
		else
			echo -e "\tIP address will be set to: $ip_address_network (network)"
		fi
	elif ([ "$1" = "both-cable" ] || [ "$1" = "host-cable" ]); then
		if [ -z "$ip_address_cable" ]; then
			echo -e "\tError! Could not retrieve IP address from file: $ip_address_file"
				if [ -e "$ip_address_file" ]; then
				    echo -e "\t\tFile does exist, but maybe wrong data? (Invalid IP Address for example)"
				else 
				    echo -e "\t\tFile does not exist..."
				fi 
			echo -e "\tExiting now for your own safety..."
			exit -1
		else
			echo -e "\tIP address will be set to: $ip_address_cable (cable)"
		fi
	else
		echo -e "\tShould not be here... exiting!"
		exit -1
	fi
}



if [ "$1" = "both-network" ]; then
	find_ip_address_from_config_file "$1"
	shift
	./$script_name $multiple_flag $multiple_count $measure $max "both" $ip_address_network $@
elif [ "$1" = "both-cable" ]; then
	find_ip_address_from_config_file "$1"
	shift
	./$script_name $multiple_flag $multiple_count $measure $max "both" $ip_address_cable $@
elif [ "$1" = "host-network" ]; then
	find_ip_address_from_config_file "$1"
	shift
	./$script_name $multiple_flag $multiple_count $measure $max "host" $ip_address_network $@
elif [ "$1" = "host-cable" ]; then
	find_ip_address_from_config_file "$1"
	shift
	./$script_name $multiple_flag $multiple_count $measure $max "host" $ip_address_cable $@

elif [ "$1" = "both" ]; then
	check_ip_address "$2"
	check_ssh_connection "$2"

	shift	
	./$script_name $multiple_flag $multiple_count $measure $max "host" $@
	shift
	./$script_name $multiple_flag $multiple_count "local" $@

elif [ "$1" = "local" ]; then	
	command_type="local"
	processor_type="Intel"
	shift
	
	check_and_set_stencil_specification "$@"
	# print_all_variables "$@"	# optional

	if !([ -z "$patus_command" ] || [ -z "$tune_command" ]); then
		if !([ -z "$multiple_flag" ]) && !([ -z "$multiple_count" ]) ;
		then
			m=1
			while [ "$m" -le "$multiple_count" ];
			do
				# do everything as usual with no measure
				local_no_measure
				# keep the TYPE_STENCIL_DATE name saved in an array
				type_stencil_date_name_array[$m]=$type_stencil_date_name
				m=$((m+1))
			done

			# will be the new name for folder, multi_graph_file, gnuplot script...
			multiple_type_date=$(date +[${multiple_count}x]_${command_type}_%F_%H.%M.%S)

			# new folder that will have all the "subfolders", graphs & scripts
			multiple_folder_name="${stc_name}_${dimensions}_${multiple_type_date}"
			mkdir -p $results_folder/$multiple_folder_name

			# create a graphic with multiple graphs in one picture
			echo -e "Creating_graph_multiple"
			#create_graph_multiple_NO_average
			create_graph_multiple_WITH_average

			echo -e "Moving the folders..."
			# finally move the "subfolders" into the new folder
			o=1
			while [ "$o" -le "$multiple_count" ];
			do
				mv $results_folder/${type_stencil_date_name_array[$o]}/ $results_folder/$multiple_folder_name
				o=$((o+1))
			done
			
		else
			local_no_measure
		fi
	else
		echo -e "Some Unknown Error (local)... exiting!"
		exit 0
	fi

	exit 1


elif [ "$1" = "host" ]; then	
	command_type="host"
	processor_type="ARM"
	shift

	ip_address=""
	if !([ -z "$1" ]);
	then
		check_ip_address "$1"
		check_ssh_connection "$1"
		ip_address="$1"
		#echo -e "Given IP-Address: $ip_address"
		shift
	else
		echo -e "No IP-Address given..."
		exit 0
	fi
		
	check_and_set_stencil_specification "$@"
	# print_all_variables "$@"	# optional	

	if !([ -z "$patus_command" ] || [ -z "$tune_command" ]); then
		if [ "$measure" = "+measure" ];
		then
			if !([ -z "$max" ]) && ([ "$max" -gt "0" ]) 2>/dev/null;
			then
				host_with_measure_change_threads
			else
				host_with_measure_no_thread_change
			fi
		else
			if !([ -z "$multiple_flag" ]) && !([ -z "$multiple_count" ]) ;
			then
				m=1
				while [ "$m" -le "$multiple_count" ];
				do
					# do everything as usual with no measure
					host_without_measure
					# keep the TYPE_STENCIL_DATE name saved in an array
					type_stencil_date_name_array[$m]=$type_stencil_date_name
					m=$((m+1))
				done

				# will be the new name for folder, multi_graph_file, gnuplot script...
				multiple_type_date=$(date +[${multiple_count}x]_${command_type}_%F_%H.%M.%S)

				# new folder that will have all the "subfolders", graphs & scripts
				multiple_folder_name="${stc_name}_${dimensions}_${multiple_type_date}"
				mkdir -p $results_folder/$multiple_folder_name

				# create a graphic with multiple graphs in one picture
				echo -e "Creating_graph_multiple"
				#create_graph_multiple_NO_average
				create_graph_multiple_WITH_average

				echo -e "Moving the folders..."
				# finally move the "subfolders" into the new folder
				o=1
				while [ "$o" -le "$multiple_count" ];
				do
					mv $results_folder/${type_stencil_date_name_array[$o]}/ $results_folder/$multiple_folder_name
					o=$((o+1))
				done

			else
				host_without_measure
			fi
		fi
	else
		echo -e "Some Unknown Error (host)... exiting!"
		exit 0
	fi

	exit 1

else
	echo -e "Your input: "
	echo -e "	$0 $multiple_flag $multiple_count $measure $max $@"
	echo -e "is NOT valid!"
	echo -e ""
	echo -e "Please specify TYPE & IP-ADDRESS!!! (TYPE = 'local', 'host' or 'both')"
	echo -e "e.g. do: "
	echo -e "$0 TYPE (IP-address) [...]"
	echo -e ""
	echo -e "NOTE: no need for IP-address when selecting local"
	exit 0
fi
