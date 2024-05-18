Step2: Variant QC
---

Since the WES data from UKB is provided in many small files, the results from QCStep1 are first merged by chromosome using Combination.sh 
We provide two filename lists used by Combination.sh

---

After generating complete bed/bim/fam files for chromosomes 1-22, Variant.sh is used to remove variants with:
· a call rate of less than 90%
· those deviating from Hardy-Weinberg equilibrium (P<1×10−15). 

Finally, LowComplex.sh removes variants present in regions of low complexity.
