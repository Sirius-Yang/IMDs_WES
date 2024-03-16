cd /home1/Huashan1/SiriusWhite/AIDs/VEP/REVEL
# > R 用REVEL_Clean.txt筛选一下自己的基因及位点得分

python3 #重新生成注释的groupfile
import pandas as pd; import numpy as ny; import os, csv
file_input = os.listdir(os.getcwd())
newfilelist = []
for i in range(len(file_input)):
     if file_input[i].startswith("LOFTEE_REVEL50"):
             newfilelist.append(file_input[i])
#假设都叫REVEL_XX.csv (eg: REVEL_75.csv，这里都是一些评分大于75的missense位点) ,包含四列：
# GENE  ID  type    score
# CD1D  chr1:xx:A:G missense    80 
          
for i in range(0,22):
    test = pd.read_csv(newfilelist[i],sep="\t")
    gene = list(set(test['Gene']))
    t = newfilelist[i].split("LOFTEE_REVEL25_chr")[1].split(".csv")[0]
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
    exec(f"data.to_csv('LOFTEE_REVEL25_chr{t}.csv',index=False, header=False)")
    print(i)

quit()

#然后用cat,tr将逗号变成\t分割，新的groupfile计算SAIGE step2得到beta

for i in range(0, 22):
    test = pd.read_csv(newfilelist[i], sep="\t")
    gene_set = set(test['Gene'])
    t = newfilelist[i].split("LOFTEE_REVEL50_chr")[1].split(".csv")[0]
    data_collection = []
    
    for gene in gene_set:
        gene_pattern = f'^{gene}$'
        data_subset = test[test['Gene'].str.contains(gene_pattern, na=False)]
        pos_data = [gene, 'var'] + data_subset['Pos'].tolist()
        effect_data = [gene, 'anno'] + data_subset['type'].tolist()
        data_collection.extend([pos_data, effect_data])
    
    data_df = pd.DataFrame(data_collection)
    data_df.to_csv(f'LOFTEE_REVEL50_chr{t}.csv', index=False, header=False)
    print(i)
