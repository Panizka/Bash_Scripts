#!/bin/bash

#PBS -N pct_array
#PBS -o ./pct_jobs/pct_job_^array_index^.out
#PBS -e ./pct_jobs/pct_job_^array_index^.err
#PBS -l nodes=1:ppn=24
#PBS -q tardis
#PBS -J 1-2:1

# Constants
HOSTNAME=`hostname`

echo "Job ID: $PBS_JOBID"
echo "Job sub_ID: $PBS_ARRAY_INDEX"
echo "Job running on: $HOSTNAME"
cd $PBS_O_WORKDIR
echo "Job Working directory is: $PBS_O_WORKDIR"

echo "Loading necessary modules..."
module purge
module load cuda80  module-git
module list
echo "Modules successfully loaded."
echo "Compiling and running the pCT job..."
args=`cat ./pct_configs/pct_config_${PBS_ARRAY_INDEX}.cfg | grep -o '^[^#]*'`
echo $args
./pCT_Reconstruction $args
