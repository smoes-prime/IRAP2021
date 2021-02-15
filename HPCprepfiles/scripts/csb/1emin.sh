#!/bin/bash
#SBATCH -J 1emin
#-n for core -N for node, 16 or 32 cores per node
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#SBATCH -n 16
#Time      D-HH-MM-SS
#SBATCH -t 0-04:00:00

hostname

module purge
module load gcc/6.2.0
module load rocks-openmpi
module load gromacs/2020.5

gmx grompp -f em.mdp -p topol.top -c solv_ions.gro -o em.tpr || echo "failed grompp1"

gmx mdrun -v -s em.tpr -deffnm emin -nt 1 || echo "failed mdrun1"

gmx grompp -f em2.mdp -p topol.top -c emin.gro -o em2.tpr || echo "failed grompp2"

gmx mdrun -v -s em2.tpr -deffnm emin2 -nt 1 || echo "failed mdrun2"
