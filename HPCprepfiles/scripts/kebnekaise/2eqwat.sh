#!/bin/bash
#IRAP investigation nolig Energy minimization
#SBATCH -A SNIC2020-3-1
#specify job name
#SBATCH -J eqwat_4pj6_no_ZN
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#request a certain number of hours for the run HR:MIN:SEC
#SBATCH -t 24:00:00
# specify number of cores you want
#SBATCH -n 20

# It is always best to do a ml purge before loading modules in a submit file
ml purge > /dev/null 2>&1

ml GCC/7.3.0-2.30  CUDA/9.2.88  OpenMPI/3.1.1
ml GROMACS/2019

echo "loaded"

# We can ignore the warning and hope it'll work out after the simulation
gmx grompp -f eqwat.mdp -p topol.top -c Rmin/emin.gro -o eqwat1.tpr -r Rmin/emin.gro -maxwarn 1 || echo "failed grompp1"
gmx grompp -f eqwat.mdp -p topol.top -c Rmin/emin.gro -o eqwat2.tpr -r Rmin/emin.gro -maxwarn 1 || echo "failed grompp2"
gmx grompp -f eqwat.mdp -p topol.top -c Rmin/emin.gro -o eqwat3.tpr -r Rmin/emin.gro -maxwarn 1 || echo "failed grompp3"

echo "grompp complete"
pwd

mkdir -p Reqwat
mv eqwat1.tpr Reqwat/ || echo "failed to move tpr 1"
mv eqwat2.tpr Reqwat/ || echo "failed to move tpr 2"
mv eqwat3.tpr Reqwat/ || echo "failed to move tpr 3"
cd Reqwat

pwd
"starting mdrun"

gmx mdrun -v -s eqwat1.tpr -deffnm eqwat1 || echo "failed 1"

gmx mdrun -v -s eqwat2.tpr -deffnm eqwat2 || echo "failed 2"

gmx mdrun -v -s eqwat3.tpr -deffnm eqwat3 || echo "failed 3"

echo "mdrun compelete"
