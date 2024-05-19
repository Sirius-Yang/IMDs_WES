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

match = pd.read_csv("GeneList.csv") 
match = match[match['Gene'].isin(survival_files)]
gene = match['Gene']

present_pheno = "AA"
# 循环处理每个基因
for i in range(len(gene)):
    gene_name = match.loc[i, 'Gene']
    pheno = match.loc[i, 'Pheno']
    
    gene_file = pd.read_csv(f"./REVEL75/REVEL_75_{gene_name}.csv")
    gene_file['eid'] = gene_file['eid'].apply(lambda x: int(x.split('0_')[1]))
    
    if PresentPheno != pheno:
        pheno_file = pd.read_csv(f"/home1/Huashan1/SiriusWhite/AIDs/DiseaseData/{pheno}/{pheno}_Caucasian.csv")
        PresentPheno = pheno
        
    clinical_data = pd.merge(pheno_file, gene_file, on='eid', how='inner')
    clinical_data = clinical_data.dropna(subset=['mutation'])
    
    no_mutation = pd.read_csv(f"./NoMutation/{gene_name}_SampleID.csv")
    no_mutation['eid'] = no_mutation['eid'].apply(lambda x: int(x.split('0_')[1]))
    no_mutation = no_mutation[no_mutation['mutation'] == 0]
    no_mutation = clinical_data[clinical_data['eid'].isin(no_mutation['eid'])]
    
    alt = clinical_data[clinical_data['mutation'] == 1]
    onset_alt = alt[alt['IF'] == 1]
    onset_alt = onset_alt[(onset_alt['Onset'] != np.inf) & (onset_alt['Onset'] > 0)]
    
    clean_data = pd.concat([no_mutation, alt]，ignore_index=T)
    onset = clean_data[clean_data['IF'] == 1]
    onset = onset[(onset['Onset'] != np.inf) & (onset['Onset'] > 0)]
    cf_freq = len(onset_alt) / len(onset)
    
    res = OR_Generate(clean_data)
    cf = [pheno, "REVEL75", gene_name, res['BETA'], res['SE'], len(alt)]
    
    if 'PAF' not in locals():
        PAF = pd.DataFrame([cf], columns=['Pheno', 'Category', 'Gene', 'Beta', 'SE', 'AltCount'])
    else:
        PAF = pd.concat([PAF, pd.DataFrame([cf], columns=['Pheno', 'Category', 'Gene', 'Beta', 'SE', 'AltCount'])])

    print(f"{PresentPheno} {gene_name} has finished")

# 保存最终结果
PAF.to_csv("REVEL75.csv", index=False)
