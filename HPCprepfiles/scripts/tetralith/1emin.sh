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
#SBATCH -n 32

# for tetralith
# It is always best to do a ml purge before loading modules in a submit file
module purge

# Substitute with your required GMX module
module load buildenv-impi-gcc/2018a-eb
module load GROMACS/2020.3-nsc1-gcc-7.3.0-bare

mpprun gmx_mpi grompp -f eqwat.mdp -p topol.top -c Rmin/confout.gro -o eqwat.tpr -r Rmin/confout.gro -maxwarn 2

mkdir Reqwat
cd Reqwat
cp ../eqwat.tpr .

mpprun gmx_mpi mdrun -v -s em.tpr -deffnm emin
