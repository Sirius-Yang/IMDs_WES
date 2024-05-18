# Changing into the format that SAIGE could recognize
import pandas as pd; import numpy as ny; import os, csv
file_input = os.listdir(os.getcwd())
newfilelist = []
for i in range(len(file_input)):
     if file_input[i].startswith("plof_mis_chr"):
             newfilelist.append(file_input[i])

for i in range(0,22):
    test = pd.read_csv(newfilelist[i],sep="\t")
    gene = list(set(test['Gene']))
    t = newfilelist[i].split("plof_mis_chr")[1].split(".csv")[0]
    print(t)
    for j in range(len(gene)):
        listA = ['^',gene[j],'$']
        GENENAME = ''.join(listA)
        exec(f"data_{j} = test.loc[test['Gene'].str.contains(GENENAME)]") 
        exec(f"pos_{j} = [gene[j],'var'] + list(data_{j}.loc[:,'Pos'])")
        exec(f"effect_{j}= [gene[j],'anno'] + list(data_{j}.loc[:,'type'])")
    data = []
    for j in range(len(gene)):
        exec(f"data.append(pos_{j})")
        exec(f"data.append(effect_{j})")  
    data = pd.DataFrame(data)
    data.head
    exec(f"data.to_csv('SnpEff_gene_group_chr{t}.txt',index=False, header=False)")
    print(i)

quit()
