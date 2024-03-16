#!bin/bash/env python
print("Performing Genotype Quality Control")
import os, dxpy, pyspark, time
import hail as hl
from joblib import Parallel, delayed
hl.init(default_reference='GRCh38',worker_memory='highmem')


class File0:
      def __init__(data,name,dirin,dirout):
          data.name = name
          data.raw = f"{dirin}{name}" #the direction and name of input files in two steps
          data.cooked = f"{dirout}{name}" #the direction and name of output files in two steps
      # function for step 1
      def mttransfer(data):
          direction = data.cooked.strip('.vcf.gz') #provide a direction for hail to write after analysis
          hl.import_vcf(data.raw, force_bgz=True,array_elements_required=False).write(direction,overwrite=True)
          return None
      # function for step 2
      def genotypeqc(data):
          input_list = []
          mt = hl.read_matrix_table(data.raw)
          mt = hl.split_multi_hts(mt)
          mt_test = mt.filter_entries(((mt.GT.is_hom_ref()) & (mt.GQ>=20) & (mt.DP >=10) & (mt.DP<=200)) | ((mt.GT.is_het()) & ((mt.AD[0]+mt.AD[1])/mt.DP>=0.9) & (mt.AD[1]/mt.DP >=0.2) & (mt.PL[0] >=20) & (mt.DP >=10) & (mt.DP<=200)) | ((mt.GT.is_hom_var()) & ((mt.AD[0]+mt.AD[1])/mt.DP>=0.9) & (mt.AD[1]/mt.DP >=0.9) & (mt.PL[0] >=20) & (mt.DP >=10) & (mt.DP<=200)))
          hl.export_plink(mt_test,data.cooked)
          return None
          

#Step 1: pVCF files -> matrix files 
start = time.time()

os.chdir("/home/dnanexus/data/pVCF_raw/")

file_input1 = os.listdir(os.getcwd())
file_input1 = file_input1[1:]
file_index1 = []
for i in file_input1:
    i = File0(i,"/home/dnanexus/data/pVCF_raw/","/home/dnanexus/data/pVCF_mt/")
    file_index1.append(i)
    
Parallel(n_jobs=15)(delayed(lambda x: x)(item.mttransfer()) for item in file_index1)

Step1 = time.time() - start
print('Step 1 costed ' + str(Step1) + 's')


#Step 2: Performing genotype quality control
start = time.time()

os.chdir("/home/dnanexus/data/pVCF_mt/")

file_input2 = os.popen('ls | grep -v ".log"').read().splitlines() #using linux commands with os.popen to save time
file_index2 = []
for i in file_input2:
    i = File0(i,"/home/dnanexus/data/pVCF_mt/","/home/dnanexus/data/plink/")
    file_index2.append(i)
    
Parallel(n_jobs=15)(delayed(lambda x: x)(item.genotypeqc()) for item in file_index2)

Step2 = time.time() - start
print('Step 2 costed ' + str(Step2) + 's')

