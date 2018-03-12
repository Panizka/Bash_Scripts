#!/bin/bash

#PBS -N pct_recon
#PBS -o ./pct_jobs/pct_job.out
#PBS -e ./pct_jobs/pct_job.err
#PBS -l nodes=1:ppn=24
#PBS -q tardis

# Constants
TRUE="true"
FALSE="false"
HOSTNAME=`hostname`
check_rsync=$FALSE

echo "Job ID: $PBS_JOBID"
echo "Job running on: $HOSTNAME"
cd $PBS_O_WORKDIR
echo "Job Working directory is: $PBS_O_WORKDIR"

echo "Loading necessary modules..."
module purge
module load cuda80  module-git
module list
echo "Modules successfully loaded."
echo "Compiling and running the pCT job..."
args=`cat ./pct_configs/pct_config.cfg | grep -o '^[^#]*'`
make clean
make
./pCT_Reconstruction $args

