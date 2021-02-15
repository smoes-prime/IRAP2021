#!/bin/bash
# Name of the job
#SBATCH -J 1emin
#SBATCH -N 1
#SBATCH -A snic2020-3-1
#              d-hh:mm:ss
#SBATCH --time=0-01:00:00

echo $SNIC_RESOURCE


ml purge > /dev/null 2>&1

ml GCC/8.3.0  OpenMPI/3.1.4
ml GROMACS/2020

if [ $SLURM_JOB_NUM_NODES -gt 1 ]; then
   GMX="gmx_mpi"
   MPIRUN="mpirun"
   ntmpi=""
else
   GMX="gmx"
   MPIRUN=""
   ntmpi="-ntmpi $SLURM_NTASKS"
fi


if [ -n "$SLURM_CPUS_PER_TASK" ]; then
     ntomp="$SLURM_CPUS_PER_TASK"
else

(echo 1 ; echo 3) | gmx pdb2gmx -f 4pj6_align_-_minimized.pdb -o protein.gro -ignh -i ZN.itp
# To generate a position restraint file to use for restrained minimization after regular minimization.
#gmx genrestr -f protein.gro -o posre.itp
gmx editconf -f protein.gro -bt cubic -d 1.0 -o prot_box.gro
echo 0 | gmx solvate -cp prot_box.gro -cs spc216.gro -o solv.gro -p topol.top

#fit protein to the center of the cube
echo 0 | gmx trjconv -s solv.gro -f solv.gro -o solv_center.gro -pbc atom -ur compact

#read output for genion and to prepare a minimization run
gmx grompp -f em.mdp -p topol.top -c solv_center.gro -o em.tpr
#neutralize charges
echo 15 | gmx genion -s em.tpr -o solv_ions.gro -p topol.top -pname NA -nname CL -neutral -conc 0.1
# regrompp for safety
gmx grompp -f em.mdp -p topol.top -c solv_ions.gro -o em.tpr

mkdir Rmin
mv em.tpr Rmin/
cd Rmin
$MPIRUN $GMX mdrun -v -s em.tpr -deffnm emin
cd..
