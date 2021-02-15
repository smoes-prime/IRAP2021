#!/bin/bash
#IRAP investigation 4pj6 nolig production
#SBATCH -A SNIC2020-3-1
#specify job name
#SBATCH -J production_4pj6
#set places for error and output files
#SBATCH --error=job.%j.err
#SBATCH --output=job.%j.out
#request a certain number of hours for the run HR:MIN:SEC
#SBATCH -t 24:00:00
# specify number of cores you want
#SBATCH -n 128

# for tetralith
# It is always best to do a ml purge before loading modules in a submit file
module purge

# Substitute with your required GMX module
module load buildenv-impi-gcc/2018a-eb
module load buildenv-impi-gcc/2018a-eb
module load GROMACS/2020.3-nsc1-gcc-7.3.0-bare

mpprun gmx_mpi grompp -f production.mdp -p topol.top -c Reqwat/confout.gro -o run.tpr

mkdir Rrun
cd Rrun
cp ../run.tpr .

mpprun gmx_mpi mdrun -v -s run.tpr -deffnm mdprod
