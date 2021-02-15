#!/bin/bash
#IRAP investigation nolig Equilibriation in water
#SBATCH -A SNIC2020-3-1
#specify Restrained emin eq_wat1
#SBATCH -J eq_water_4pj6
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#request a certain number of hours for the run HR:MIN:SEC
#SBATCH -t 04:00:00
# specify number of cores you want
#SBATCH -n 28

# for tetralith
# It is always best to do a ml purge before loading modules in a submit file
ml purge > /dev/null 2>&1

ml GCC/8.3.0  OpenMPI/3.1.4
ml GROMACS/2020

#start of eqwat
# We can ignore the warning and hope it'll work out after the simulation
gmx grompp -f eqwat.mdp -p topol.top -c emin2.gro -o eqwat1.tpr -r emin2.gro -maxwarn 1

mkdir -p Reqwat1
mv eqwat1.tpr Reqwat1/ || echo "failed to move tpr 1"
cd Reqwat1

gmx mdrun -v -s eqwat1.tpr -deffnm eqwat1
