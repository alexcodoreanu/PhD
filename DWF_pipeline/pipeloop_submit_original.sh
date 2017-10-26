#!/bin/bash
# Name the job, error and output files
#PBS -N test

# Specify the log output and error files (job will fail if these aren.t specified)
#PBS -o g2.hpc.swin.edu.au:/lustre/projects/p025_swin/pipes/DWF_PIPE/TEST/test.out
#PBS -e g2.hpc.swin.edu.au:/lustre/projects/p025_swin/pipes/DWF_PIPE/TEST/test.err

# Specify the project name
#PBS -A p025_swin

# Specify the queue name
#PBS -q sstar

# Node, processor, and GPU requests
#PBS -l nodes=1:ppn=1
#PBS -l walltime=00:00:05:00
#PBS -l nodes=sstar101+sstar102+sstar103+sstar104+sstar105+sstar106+sstar107+sstar108

# Memory request
#PBS -l pmem=1gb

# List the assigned CPUs and GPUs
# echo Spawning this many processes:
# cat $PBS_NNODES
# echo Deploying job to CPUs ...
# cat $PBS_NODEFILE     
# echo and using GPUs ...
# cat $PBS_GPUFILE


echo `date`

/lustre/projects/p025_swin/pipes/DWF_PIPE/TEST/pipelooplaunch.sh ut151220 36

# cd /lustre/projects/p025_swin/pipes/DWF_PIPE/MARY_WORK/3hr_151220_m100/ccd19/
# idl < $MARY_DIR/mary2ccd.pro

echo `date`
echo 'Job done CCD      19'