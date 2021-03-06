#!/bin/bash
# Name of the job
#SBATCH -J Gromacs-job
#SBATCH -N 1
#SBATCH -A snic2020-3-1
#              d-hh:mm:ss
#SBATCH --time=2-00:00:00


ml purge > /dev/null 2>&1

# Load the module for GROMACS and its prerequisites.
# This is for GROMACS/2016.4 with GPU support
ml GCC/5.4.0-2.26 CUDA/8.0.61_375.26 impi/2017.3.196
ml GROMACS/2016.4

# Automatic selection of single or multi node based GROMACS
if [ $SLURM_JOB_NUM_NODES -gt 1 ]; then
    GMX="gmx_mpi"
    MPIRUN="mpirun"
    ntmpi=""
else
    GMX="gmx"
    MPIRUN=""
    ntmpi="-ntmpi $SLURM_NTASKS"
fi

# Automatic selection of ntomp argument based on "-c" argument to sbatch
if [ -n "$SLURM_CPUS_PER_TASK" ]; then
    ntomp="$SLURM_CPUS_PER_TASK"
else
    ntomp="1"
fi
# Make sure to set OMP_NUM_THREADS equal to the value used for ntomp
# to avoid complaints from GROMACS
export OMP_NUM_THREADS=$ntomp

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

# We can ignore the warning and hope it'll work out after the simulation
gmx grompp -f eqwat.mdp -p topol.top -c Rmin/confout.gro -o eqwat.tpr -r Rmin/confout.gro -maxwarn 2

mkdir Reqwat
cd Reqwat
cp ../eqwat.tpr .
$MPIRUN $GMX mdrun -v -s eqwat.tpr -deffnm eqwat


gmx grompp -f production.mdp -p topol.top -c Reqwat/confout.gro -o run.tpr
mkdir Rprod
cd Rprod
cp ../run.tpr .

gmx mdrun -s run.tpr -c prod_output.gro -cpo state.cpt -x traj_comp.xtc -gputasks 0123 -nb gpu -pme gpu -bonded cpu -npme 1 $ntmpi -ntomp $ntomp -deffnm mdprod
