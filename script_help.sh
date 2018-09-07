#!/bin/bash

script_name="measure.sh"

#network or cable
connection_type="cable"

date_time="$(date +%F_%H.%M.%S)"
log_file="log_$date_time.txt"
touch $log_file


help_2D(){
	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- Start of ./$script_name multiple ${multiple} both-${connection_type} ${stencil} ${dimensions} ${dimensions}" >> $log_file
	./$script_name multiple ${multiple} both-${connection_type} ${stencil} ${dimensions} ${dimensions}
	mkdir -p 			patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_BOTH
	mv patus_results/*.png 		patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_BOTH 2>/dev/null
	mv patus_results/host*  	patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_BOTH 2>/dev/null
	mv patus_results/local* 	patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_BOTH 2>/dev/null
	mv patus_results/*[*  		patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_BOTH 2>/dev/null
	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- End of ./$script_name multiple ${multiple} both-${connection_type} ${stencil} ${dimensions} ${dimensions}" >> $log_file


	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- Start of ./$script_name +measure host-${connection_type} ${stencil} ${dimensions} ${dimensions}" >> $log_file
	./$script_name +measure host-${connection_type} ${stencil} ${dimensions} ${dimensions}
	mkdir -p 			patus_results/default_${stencil}_${dimensions}_${dimensions}
	mv patus_results/*.png 		patus_results/default_${stencil}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/host*  	patus_results/default_${stencil}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/local* 	patus_results/default_${stencil}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/*[*	 	patus_results/default_${stencil}_${dimensions}_${dimensions} 2>/dev/null
	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- End of ./$script_name +measure host-${connection_type} ${stencil} ${dimensions} ${dimensions}" >> $log_file


	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- Start of ./$script_name +measure ${threads} host-${connection_type} ${stencil} ${dimensions} ${dimensions}" >> $log_file
	./$script_name +measure ${threads} host-${connection_type} ${stencil} ${dimensions} ${dimensions}
	mkdir -p 			patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions}
	mv patus_results/*.png 		patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/host*  	patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/local* 	patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/*[*	 	patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions} 2>/dev/null
	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- End of ./$script_name +measure ${threads} host-${connection_type} ${stencil} ${dimensions} ${dimensions}" >> $log_file



	date_time="$(date +%F_%H.%M.%S)"

	mkdir -p patus_results/${stencil}_${dimensions}_${dimensions}_${date_time}
	mv patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_BOTH 	patus_results/${stencil}_${dimensions}_${dimensions}_${date_time}
	mv patus_results/default_${stencil}_${dimensions}_${dimensions} 		patus_results/${stencil}_${dimensions}_${dimensions}_${date_time}
	mv patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions} 	patus_results/${stencil}_${dimensions}_${dimensions}_${date_time}

	echo "" >> $log_file	
}


help_3D(){
	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- Start of ./$script_name multiple ${multiple} both-${connection_type} ${stencil} ${dimensions} ${dimensions} ${dimensions}" >> $log_file
	./$script_name multiple ${multiple} both-${connection_type} ${stencil} ${dimensions} ${dimensions} ${dimensions}
	mkdir -p 			patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_${dimensions}_BOTH
	mv patus_results/*.png 		patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_${dimensions}_BOTH 2>/dev/null
	mv patus_results/host*  	patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_${dimensions}_BOTH 2>/dev/null
	mv patus_results/local* 	patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_${dimensions}_BOTH 2>/dev/null
	mv patus_results/*[*  		patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_${dimensions}_BOTH 2>/dev/null
	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- End of ./$script_name multiple ${multiple} both-${connection_type} ${stencil} ${dimensions} ${dimensions} ${dimensions}" >> $log_file


	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- Start of ./$script_name +measure host-${connection_type} ${stencil} ${dimensions} ${dimensions} ${dimensions}" >> $log_file
	./$script_name +measure host-${connection_type} ${stencil} ${dimensions} ${dimensions} ${dimensions}
	mkdir -p 			patus_results/default_${stencil}_${dimensions}_${dimensions}_${dimensions}
	mv patus_results/*.png 		patus_results/default_${stencil}_${dimensions}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/host*  	patus_results/default_${stencil}_${dimensions}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/local* 	patus_results/default_${stencil}_${dimensions}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/*[*	 	patus_results/default_${stencil}_${dimensions}_${dimensions}_${dimensions} 2>/dev/null
	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- End of ./$script_name +measure host-${connection_type} ${stencil} ${dimensions} ${dimensions} ${dimensions}" >> $log_file


	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- Start of ./$script_name +measure ${threads} host-${connection_type} ${stencil} ${dimensions} ${dimensions} ${dimensions}" >> $log_file
	./$script_name +measure ${threads} host-${connection_type} ${stencil} ${dimensions} ${dimensions} ${dimensions}
	mkdir -p 			patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions}_${dimensions}
	mv patus_results/*.png 		patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/host*  	patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/local* 	patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions}_${dimensions} 2>/dev/null
	mv patus_results/*[*	 	patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions}_${dimensions} 2>/dev/null
	date_time="$(date +%F_%H.%M.%S)" && echo -e "$date_time --- End of ./$script_name +measure ${threads} host-${connection_type} ${stencil} ${dimensions} ${dimensions} ${dimensions}" >> $log_file



	date_time="$(date +%F_%H.%M.%S)"

	mkdir -p patus_results/${stencil}_${dimensions}_${dimensions}_${dimensions}_${date_time}
	mv patus_results/${multiple}_times_${stencil}_${dimensions}_${dimensions}_${dimensions}_BOTH 	patus_results/${stencil}_${dimensions}_${dimensions}_${dimensions}_${date_time}
	mv patus_results/default_${stencil}_${dimensions}_${dimensions}_${dimensions} 			patus_results/${stencil}_${dimensions}_${dimensions}_${dimensions}_${date_time}
	mv patus_results/${threads}_threads_${stencil}_${dimensions}_${dimensions}_${dimensions} 	patus_results/${stencil}_${dimensions}_${dimensions}_${dimensions}_${date_time}

	echo "" >> $log_file	
}



multiple="4"
threads="4"
dimensions="2048"
stencil="blur-float"
help_2D

multiple="4"
threads="4"
dimensions="130"
stencil="gradient-float"
help_3D

multiple="4"
threads="8"
dimensions="258"
stencil="laplacian-float"
help_3D

multiple="4"
threads="4"
dimensions="128"
stencil="wave-1-float"
help_3D


mv $log_file patus_results


echo -e "bye..."
exit 0
