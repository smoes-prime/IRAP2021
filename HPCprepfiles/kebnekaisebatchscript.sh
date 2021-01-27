#!/bin/bash
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -c 7
#SBATCH --gres=gpu:k80:2
#SBATCH -A snic2020-3-1
#              d-hh:mm:ss
#SBATCH --time=7-00:00:00


ml purge > /dev/null 2>&1

ml GCC/7.3.0-2.30  CUDA/9.2.88  OpenMPI/3.1.1
ml GROMACS/2019

if [ $SLURM_JOB_NUM_NODES -gt 1 ]; then
   GMX="gmx_mpi"
   MPIRUN="mpirun"
   ntmpi=""
else
   GMX="gmx"
   MPIRUN=""
   ntmpi="-ntmpi $SLURM_NTASKS"
fi


if [ -n "$SLURM_CPUS_PER_TASK" ]; then
     ntomp="$SLURM_CPUS_PER_TASK"
else
