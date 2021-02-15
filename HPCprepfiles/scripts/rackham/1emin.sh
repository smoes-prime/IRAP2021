#!/bin/bash
#project name
#SBATCH -A SNIC2020-3-1
#specify job name
#SBATCH -J 1emin
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#request a certain number of hours for the run HR:MIN:SEC
#SBATCH -t 01:00:00
# specify number of cores you want
#SBATCH -n 10
# specify number of threads per task
#SBATCH -c 1

ml purge

module load intel/18.3 intelmpi/18.3
module load gromacs/2019.6.th

gmx grompp -f em.mdp -p topol.top -c solv_ions.gro -o em.tpr

gmx mdrun -v -s em.tpr -deffnm emin -nt 1
