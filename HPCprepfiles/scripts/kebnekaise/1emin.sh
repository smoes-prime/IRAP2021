#!/bin/bash
#IRAP investigation nolig Energy minimization
#SBATCH -A SNIC2020-3-1
#specify job name
#SBATCH -J emin_4pj6
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#request a certain number of hours for the run HR:MIN:SEC
#SBATCH -t 04:00:00
# specify number of cores you want
#SBATCH -n 10

# It is always best to do a ml purge before loading modules in a submit file
ml purge > /dev/null 2>&1

ml GCC/8.3.0  OpenMPI/3.1.4
ml GROMACS/2020

gmx grompp -f em.mdp -p topol.top -c solv_ions.gro -o em.tpr || echo "failed grompp1"

gmx mdrun -v -s em.tpr -deffnm emin -nt 1 || echo "failed mdrun1"

gmx grompp -f em2.mdp -p ../topol.top -c emin.gro -o em2.tpr || echo "failed grompp2"

gmx mdrun -v -s em2.tpr -deffnm emin2 -nt 1 || echo "failed mdrun2"
