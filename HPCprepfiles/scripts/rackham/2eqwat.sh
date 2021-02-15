#!/bin/bash
#project name
#SBATCH -A SNIC2020-3-1
#specify job name
#SBATCH -J 2eqwat
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#request a certain number of hours for the run HR:MIN:SEC
#SBATCH -t 12:00:00
# specify number of cores you want
#SBATCH -n 20
# specify number of threads per task
#SBATCH -c 1


ml purge > /dev/null 2>&1

module load intel/18.3 intelmpi/18.3
module load gromacs/2019.6.th

#start of eqwat
# We can ignore the warning and hope it'll work out after the simulation
gmx grompp -f eqwat.mdp -p topol.top -c emin.gro -o eqwat.tpr -r emin.gro -maxwarn 1

mkdir -p Reqwat
mv eqwat.tpr Reqwat/
cd Reqwat

gmx mdrun -v -s eqwat.tpr -deffnm eqwat
