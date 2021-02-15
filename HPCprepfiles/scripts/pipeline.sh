#!/bin/bash

# first job - Energy Minimization
jid1=$(sbatch 1emin.sh)

# Equilibriation, dependent on sucessful completion of energy minimization
jid2=$(sbatch  --dependency=afterok:$jid1 21eqwat.sh)
jid3=$(sbatch  --dependency=afterok:$jid1 22eqwat.sh)
jid4=$(sbatch  --dependency=afterok:$jid1 23eqwat.sh)

#production run, dependent on succesful completion of equilibriation step
#jid5=$(sbatch  --dependency=afterok:$jid2 31production.sh)
#jid6=$(sbatch  --dependency=afterok:$jid3 32production.sh)
#jid7=$(sbatch  --dependency=afterok:$jid4 33production.sh)
