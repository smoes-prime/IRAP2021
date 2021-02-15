#!/bin/bash
#SBATCH -J 3production
#-n for core -N for node, 16 or 32 cores per node
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#SBATCH -N 1
#Time      D-HH-MM-SS
#SBATCH -t 0-24:00:00


ml purge > /dev/null 2>&1

ml GCC/8.3.0  OpenMPI/3.1.4
ml GROMACS/2020

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
  ntomp="1"
fi
# Make sure to set OMP_NUM_THREADS equal to the value used for ntomp
# to avoid complaints from GROMACS
export OMP_NUM_THREADS=$ntomp

gmx grompp -f production.mdp -p topol.top -c Reqwat/eqwat.gro -o run.tpr

mkdir -p Rrun
mv run.tpr Rrun/
cd Rrun

$MPIRUN $GMX mdrun -v -s run.tpr -deffnm mdprod
