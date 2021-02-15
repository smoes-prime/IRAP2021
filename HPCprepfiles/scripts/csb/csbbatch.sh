#!/bin/bash
#-n for core -N for node, 16 or 32 cores per node
#SBATCH -N 1
#Time      D-HH-MM-SS
#SBATCH -t 3-00:00:00
#Handly line of code you can use to ask for your queue status, it's set to 20
#here, so just change it to a longer or shorter interval if you wish
# $ while sleep 20; do (squeue -u smoes) ; done
module purge
module load module load gcc/6.2.0
module load gromacs/2020

jobdir=$(pwd)
tmpdir=$(mktemp -d /state/partition1/tmp.$USER.smoes)

echo "Copying files to tmp dir: $tmpdir"
rsync -arL ${jobdir}/ ${tmpdir}/ --exclude="slurm*"
cd ${tmpdir}

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
echo 13 | gmx genion -s em.tpr -o solv_ions.gro -p topol.top -pname NA -nname CL -neutral -conc 0.1
# regrompp for safety
gmx grompp -f em.mdp -p topol.top -c solv_ions.gro -o em.tpr

mkdir Rmin
mv em.tpr Rmin/
cd Rmin

mpprun gmx_mpi mdrun -v -s em.tpr -deffnm emin

cd..

# We can ignore the warning and hope it'll work out after the simulation
gmx grompp -f eqwat.mdp -p topol.top -c Rmin/confout.gro -o eqwat.tpr -r Rmin/confout.gro -maxwarn 2

mkdir Reqwat
cd Reqwat
cp ../eqwat.tpr .
gmx mdrun -v -s eqwat.tpr -deffnm eqwat


gmx grompp -f production.mdp -p topol.top -c Reqwat/confout.gro -o run.tpr
mkdir Rprod
cd Rprod
cp ../run.tpr .

gmx mdrun -v -s run.tpr -deffnm mdprod

echo "Done... Copying files back to work dir..."
rsync -ar ${tmpdir}/ ${jobdir}/
