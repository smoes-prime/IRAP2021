# Use: from command line, call combine_gro_protlig.py with 2 arguments, first
# the protein .gro file and then the ligand .gro file
# write a combined file using the > bash operator
import sys
pro_gro = sys.argv[1]
lig_gro = sys.argv[2]
pro = open(pro_gro,'r').readlines()
lig = open(lig_gro,'r').readlines()
pro_dat = [line.rstrip() for line in pro]
lig_dat = [line.rstrip() for line in lig]
tot_num = int(pro_dat[1])+int(lig_dat[1])
com_dat = [pro_dat[0],'%5d'%tot_num]+pro_dat[2:-1] + lig_dat[2:-1] + [pro_dat[-1]]
for line in com_dat: print line
