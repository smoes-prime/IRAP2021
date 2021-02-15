#!/bin/bash
# Name of the job
#SBATCH -J Gromacs-gpu-production3
#SBATCH -N 1
# Use for 4 tasks
#SBATCH -n 4
# Usefor 7 threads per task
#SBATCH -c 7
# Remember the total number of cores = 28 (kebnekaise) so that
# n x c = 28 (running on a single node, or multiples of 28 for multi node runs)
#SBATCH --gres=gpu:k80:2
#SBATCH -A snic2020-3-1
#              d-hh:mm:ss
#SBATCH --time=4-00:00:00

# for kebnekaise @ HPC2N
# It is always best to do a ml purge before loading modules in a submit file
ml purge > /dev/null 2>&1

# Load the module for GROMACS and its prerequisites.
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
  ntomp="1"
fi
# Make sure to set OMP_NUM_THREADS equal to the value used for ntomp
# to avoid complaints from GROMACS
export OMP_NUM_THREADS=$ntomp

#start of production batch script
gmx grompp -f production.mdp -p ../topol.top -c eqwat3.gro -o run3.tpr

gmx mdrun -s run3.tpr -c prod_output3.gro -cpo state3.cpt -x traj_comp3.xtc -gputasks 0123 -nb gpu -pme gpu -bonded cpu -npme 1 $ntmpi -ntomp $ntomp -deffnm mdprod3

echo "Finished"
