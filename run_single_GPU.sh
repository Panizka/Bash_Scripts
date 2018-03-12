#!/bin/bash

# Constants
TRUE=true
FALSE=false
GREEN='\033[1;32m'

usage() { echo "Usage: $0 -s [number_of_jobs]" 1>&2; exit 1; }

# Run the pCT program w using the kodiak queue
run_pct() {

# Read the last line of the pct_configs/pct_config.cfg file and extract the value of the --run_on_kodiak key 
last_line=$( tail -n 1 pct_configs/pct_config.cfg )
second_field=$( echo $last_line | cut -d ' ' -f 2 )
if [ "$second_field" == "$TRUE" ]; then
	
	# Create the necessary directories if they already does not exist and run the program using Kodiak queue
	mkdir -p ./pct_jobs
	rm pct_jobs/*
	mkdir -p obj
	
	echo -e "${GREEN}*************************************************************"
	echo -e "${GREEN}Submitting a single reconstruction job to the Kodiak queue..."
	echo -e "${GREEN}Job ID: "
	qsub ./pct_job.sh
	echo -e "${GREEN}*************************************************************"
else 
	# Run the pCT program w/o using the kodiak queue	
	args=`cat ./pct_configs/pct_config.cfg | grep -o '^[^#]*'`
	make clean
	make
	./pCT_Reconstruction $args
fi
}

# Run the pCT program using the job array assuming that the compiled version of code exists on all the nodes
run_pct_array() {

# Modify the pct_array.sh script based on the number of jobs
sed -i "8s/.*/#PBS -J 1-${num_jobs}:1/" pct_array.sh

# Create the necessary directories if they already does not exist, compile the code and then run the program using Kodiak queue
mkdir -p ./pct_jobs
rm pct_jobs/*
mkdir -p obj
module purge
module load cuda80 module-git
make clean
make	

echo -e "${GREEN}*************************************************************"
echo -e "${GREEN}Submitting ${num_jobs} reconstruction jobs to the Kodiak queue..."
echo -e "${GREEN}Job ID: "
qsub ./pct_array.sh
echo -e "${GREEN}*************************************************************"

}

while getopts "s:h" o; do
    case "${o}" in
	s)
	    num_jobs=$OPTARG
	    ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ "$num_jobs" -gt 1 ]; then
	run_pct_array
else
	run_pct
fi
