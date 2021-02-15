#!/bin/bash
#project name
#SBATCH -A SNIC2020-3-1
#specify job name
#SBATCH -J production1
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#request a certain number of hours for the run HR:MIN:SEC
#SBATCH -t 24:00:00
# specify number of cores you want
#SBATCH -n 20
# specify number of threads per task
#SBATCH -c 1


ml purge > /dev/null 2>&1

module load intel/18.3 intelmpi/18.3
module load gromacs/2019.6.th

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

export OMP_NUM_THREADS=$ntomp

gmx grompp -f production.mdp -p topol.top -c eqwat1.gro -o run1.tpr

mkdir Rprod1
mv run1.tpr Rprod1/
cd Rprod1

$MPIRUN $GMX mdrun -s run1.tpr $ntmpi -ntomp $ntomp -deffnm mdprod1
