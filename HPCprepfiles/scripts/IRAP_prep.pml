#initialisation
from pymol import cmd

#get 4PJ6 from https://www.rcsb.org/structure/4PJ6
#and 5MJ6 from https://www.rcsb.org/structure/4MJ6
#and 5C97 from https://www.rcsb.org/structure/5C97
#and 4Z7I from https://www.rcsb.org/structure/4Z7I

fetch 4pj6, async=0
fetch 5mj6, async=0
fetch 5c97, async=0

#limit to chain A
sele all and (not chain A)
remove sele

fetch 4z7i, async=0
sele all and (not chain A+C+K)
remove sele

#remove solvent/cosolvent molecules
sele resname NAG
remove sele
sele resname HOH
remove sele
sele resname BR
remove sele

#add disulphide bonds
bond 828/sg,835/sg
unpick


#alignment of the two structures using only Domains 1 and 2 of the IRAP enzyme
align 5mj6 and resi 171-615, 4pj6 and resi 171-615
align 4z7i and resi 171-615, 4pj6 and resi 171-615
align 5c97 and resi 171-615, 4pj6 and resi 171-615


#Zoom in on the Zn site with GAMEN motif at bottom of screen
set_view (\
    -0.367732674,   -0.228111207,    0.901519716,\
    -0.782844186,   -0.447313190,   -0.432508379,\
     0.501921356,   -0.864798188,   -0.014085362,\
    -0.000001790,    0.000138998,  -63.407039642,\
    29.055479050,    3.574316025,   69.723068237,\
    51.382415771,   75.427711487,  -20.000000000 )


save 4pj6_align.pdb , 4pj6
save 5mj6_align.pdb , 5mj6
save 5c97_align.pdb , 5c97
save 4z7i_align.pdb , 4z7i

save 4pj6_align.fasta , 4pj6
save 5mj6_align.fasta , 5mj6
save 5c97_align.fasta , 5c97
save 4z7i_align.fasta , 4z7i
