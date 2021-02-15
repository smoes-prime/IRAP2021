#!/bin/bash
# Name of the job
#SBATCH -J 3production
#SBATCH -N 1
#SBATCH -A snic2020-3-1
#              d-hh:mm:ss
#SBATCH --time=1-00:00:00


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

gmx grompp -f production.mdp -p topol.top -c Reqwat/confout.gro -o run.tpr

mkdir Rprod
cd Rprod
cp ../run.tpr .

$MPIRUN $GMX mdrun -v -s run.tpr -deffnm mdprod
