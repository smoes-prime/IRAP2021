
#Run manually before running the emin batch script
(echo 1 ; echo 3) | gmx pdb2gmx -f 5C97.pdb -o protein.gro -ignh -i ZN.itp
(echo 1 ; echo 3) | gmx pdb2gmx -f 4Z7I_prepped_nolig.pdb -o protein.gro -ignh
# To generate a position restraint file to use for restrained minimization after regular minimization.
#gmx genrestr -f protein.gro -o posre.itp
grep LIG 5MJ6_homocombo.pdb > MJ6.pdb
gmx editconf -f LIG.pdb -o LIG.gro
gmx editconf -f complex.gro -bt cubic -d 1.5 -o prot_box.gro
gmx editconf -f protein.gro -bt cubic -d 1.5 -o prot_box.gro
echo 0 | gmx solvate -cp prot_box.gro -cs spc216.gro -o solv.gro -p topol.top

#fit protein to the center of the cube
echo 0 | gmx trjconv -s solv.gro -f solv.gro -o solv_center.gro -pbc atom -ur compact

#read output for genion and to prepare a minimization run
gmx grompp -f em.mdp -p topol.top -c solv_center.gro -o em.tpr
#neutralize charges
gmx genion -s em.tpr -o solv_ions.gro -p topol.top -pname NA -nname CL -neutral -conc 0.1

gmx grompp -f em.mdp -p topol.top -c solv_ions.gro -o em.tpr || echo "failed grompp1"

#After emin
(echo 10 ; 0) | gmx energy -f emin.edr -o potential.xvg
(echo 10 0) | gmx energy -f emin2.edr -o potential2.xvg

#ignore for now
#!/bin/bash

export HPCcenter=$SNIC_RESOURCE

if HPCcenter = rackham
then
  ml purge
  module load intel/18.3 intelmpi/18.3
  module load gromacs/2019.6.th
elif HPCcenter = kebnekaise
then
  ml purge > /dev/null 2>&1
  ml GCC/8.3.0  OpenMPI/3.1.4
  ml GROMACS/2020
elif HPCcenter = tetralith
then
  module purge
  module load buildenv-impi-gcc/2018a-eb
  module load GROMACS/2020.3-nsc1-gcc-7.3.0-bare
else
  module purge
  module load gcc/6.2.0
  module load rocks-openmpi
  module load gromacs/2020.5
fi

echo 0 | gmx trjconv -f eqwat1.trr -s emin2.gro -timestep 1000 -o eqwat1_small.trr
echo 0 | gmx trjconv -f eqwat1.trr -s emin2.gro -skip 1000 -o eqwat1_small.xtc
