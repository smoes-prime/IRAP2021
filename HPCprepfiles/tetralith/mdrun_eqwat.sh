#!/bin/bash
#IRAP investigation nolig Equilibriation in water
#SBATCH -A SNIC2020-3-1
#specify Restrained emin eq_wat
#SBATCH -J eq_water_4pj6
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
module add GROMACS/2020.3-nsc1-gcc-7.3.0-bare

mkdir Reqwat
cd Reqwat
cp ../eqwat.tpr .

mpprun gmx_mpi mdrun mdrun -v -s eqwat.tpr -deffnm eq_wat
