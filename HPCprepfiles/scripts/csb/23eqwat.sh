#!/bin/bash
#SBATCH -J 2eqwat3
#-n for core -N for node, 16 or 32 cores per node
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#SBATCH -N 1
#Time      D-HH-MM-SS
#SBATCH -t 0-12:00:00


module purge
module load gcc/6.2.0
module load rocks-openmpi
module load gromacs/2020.5

#start of eqwat
# We can ignore the warning and hope it'll work out after the simulation
gmx grompp -f eqwat.mdp -p topol.top -c Rmin/emin2.gro -o eqwat3.tpr -r Rmin/emin2.gro -maxwarn 1 || echo "failed grompp1"

mkdir -p Reqwat3
mv eqwat3.tpr Reqwat3/ || echo "failed to move tpr 3"
cd Reqwat3

gmx mdrun -v -s eqwat3.tpr -deffnm eqwat3
