import pandas as pd
import numpy as np
import os

def OR_Generate(data):
    
    prevalence = data[data['IF'] == 1].shape[0] / data.shape[0]
    
    ac_case = data[(data['mutation'] == 1) & (data['IF'] == 1)].shape[0]
    ac_ctrl = data[(data['mutation'] == 1) & (data['IF'] == 0)].shape[0]
    
    AF_case = ac_case / (2 * data[data['IF'] == 1].shape[0])
    AF = (ac_case + ac_ctrl) / (2 * data.shape[0])
    
    beta = (2 * (AF_case - AF) * prevalence) / np.sqrt(2 * AF * (1 - AF) * prevalence * (1 - prevalence))
    twopq = 2 * AF * (1 - AF)
    beta_perallele = beta / np.sqrt(twopq)
    OR = np.exp(beta_perallele)
    
    result = {'OR': OR, 'SE': twopq, 'BETA': beta_perallele}
    return result
    
# Here provide the analysis of REVEL75-100 category as an example
survival_files = [f for f in os.listdir("./REVEL75") if f.endswith('.csv')]
survival_files = [f.split("REVEL_75_")[1].replace('.csv', '') for f in survival_files] #Obtain the genes that have variants in REVEL score 75-100

match = pd.read_csv("GeneList.csv") # the Total gene names file
match = match[match['Gene'].isin(survival_files)]
gene = match['Gene']

present_pheno = "AA"
