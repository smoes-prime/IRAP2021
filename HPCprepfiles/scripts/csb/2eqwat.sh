#!/bin/bash
#SBATCH -J 2eqwat
#-n for core -N for node, 16 or 32 cores per node
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#SBATCH -N 1
#Time      D-HH-MM-SS
#SBATCH -t 0-24:00:00


module purge
module load gcc/6.2.0
module load rocks-openmpi
module load gromacs/2020.5

echo "loaded"

# We can ignore the warning and hope it'll work out after the simulation
gmx grompp -f eqwat.mdp -p topol.top -c emin2.gro -o eqwat1.tpr -r emin2.gro -maxwarn 1 || echo "failed grompp1"

gmx grompp -f eqwat.mdp -p topol.top -c emin2.gro -o eqwat2.tpr -r emin2.gro -maxwarn 1 || echo "failed grompp2"

gmx grompp -f eqwat.mdp -p topol.top -c emin2.gro -o eqwat3.tpr -r emin2.gro -maxwarn 1 || echo "failed grompp3"

echo "grompp complete"

pwd

mkdir -p Reqwat
cp eqwat1.tpr Reqwat/eqwat1.tpr || echo "failed to move tpr 1"

cp eqwat2.tpr Reqwat/eqwat2.tpr || echo "failed to move tpr 2"

cp eqwat3.tpr Reqwat/eqwat3.tpr || echo "failed to move tpr 3"

cd Reqwat

pwd
"starting mdrun"

gmx mdrun -v -s eqwat1.tpr -deffnm eqwat1 || echo "failed 1"

gmx mdrun -v -s eqwat2.tpr -deffnm eqwat2 || echo "failed 2"

gmx mdrun -v -s eqwat3.tpr -deffnm eqwat3 || echo "failed 3"

echo "mdrun compelete"
