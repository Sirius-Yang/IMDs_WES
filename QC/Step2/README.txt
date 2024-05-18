Step2 mainly involves variant quality control.
---
Since the WES data from UKB is provided in many small files, the results from QCStep1 are first merged by chromosome using the Combination.sh script. 
We provide two filename lists used by Combination.sh. 

After generating complete bed/bim/fam files for chromosomes 1-22, the Variant.sh script is used to remove variants with:
· a call rate of less than 90%
· those deviating from Hardy-Weinberg equilibrium (P<1×10−15). 

Finally, LowComplex.sh removes variants present in regions of low complexity.
