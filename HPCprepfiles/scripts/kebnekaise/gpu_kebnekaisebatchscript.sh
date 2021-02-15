#!/bin/bash
# Name of the job
#SBATCH -J Gromacs-gpu-production
#SBATCH -N 1
# Use for 4 tasks
#SBATCH -n 4
# Usefor 7 threads per task
#SBATCH -c 7
# Remember the total number of cores = 28 (kebnekaise) so that
# n x c = 28 (running on a single node, or multiples of 28 for multi node runs)
#SBATCH --gres=gpu:k80:2
#SBATCH -A snic2020-3-1
#              d-hh:mm:ss
#SBATCH --time=7-00:00:00

ml GCC/7.3.0-2.30  CUDA/9.2.88  OpenMPI/3.1.1
ml GROMACS/2019

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
     ntomp="1"
fi

export OMP_NUM_THREADS=$ntomp

#Run manually before running the emin batch script
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

# the start of the emin batch script
gmx grompp -f em.mdp -p topol.top -c solv_ions.gro -o em.tpr

mkdir -p Rmin
mv em.tpr Rmin/
cd Rmin

gmx mdrun -v -s em.tpr -deffnm emin -nt 1

cd ..

#start of eqwat
# We can ignore the warning and hope it'll work out after the simulation
gmx grompp -f eqwat.mdp -p topol.top -c Rmin/emin.gro -o eqwat1.tpr -r Rmin/emin.gro -maxwarn 1
gmx grompp -f eqwat.mdp -p topol.top -c Rmin/emin.gro -o eqwat2.tpr -r Rmin/emin.gro -maxwarn 1
gmx grompp -f eqwat.mdp -p topol.top -c Rmin/emin.gro -o eqwat3.tpr -r Rmin/emin.gro -maxwarn 1

mkdir -p Reqwat
mv eqwat1.tpr Reqwat/
mv eqwat2.tpr Reqwat/
mv eqwat3.tpr Reqwat/
cd Reqwat

gmx mdrun -v -s eqwat1.tpr -deffnm eqwat1

gmx mdrun -v -s eqwat2.tpr -deffnm eqwat2

gmx mdrun -v -s eqwat3.tpr -deffnm eqwat3

cd ..

#start of production batch script
gmx grompp -f production.mdp -p topol.top -c Reqwat/eqwat1.gro -o run1.tpr

mkdir  -p Rprod
mv run.tpr /Rprod
cd Rprod

gmx mdrun -s run1.tpr -c prod_output1.gro -cpo state1.cpt -x traj_comp1.xtc -gputasks 0123 -nb gpu -pme gpu -bonded cpu -npme 1 $ntmpi -ntomp $ntomp -deffnm mdprod1
