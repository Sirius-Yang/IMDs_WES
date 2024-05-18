import pandas as pd
import numpy as np

# Using results from Related.sh to further select independent samples
data = pd.read_csv('~/UKB_WES_data/qcstep4/ukb_wes_chr_all_king_sample_qc.kin0', delimiter='\t')
data.rename(columns={data.columns[1]: "ID1", data.columns[3]: "ID2", data.columns[7]: "Kinship"}, inplace=True)
data = data[data['Kinship'] >= 0.0884]

# Randomly exclude ID with the largest number of relatives until every ID has only one pair of relative
continue_signal = True
while_cnt = 1
while continue_signal and len(data) > 0:
    print(while_cnt)
    while_cnt += 1
    print('length data:', len(data))

    all_id = pd.concat([data['ID1'], data['ID2']])
    sum_df = pd.DataFrame({
    	'all_id': counts.index,
    	'Freq': counts.values
    })

    if sum_df['Freq'].eq(1).all():
        continue_signal = False
        break
    else:
        freq_max = sum_df['Freq'].max()
        sum_max = sum_df[sum_df['Freq'] == freq_max]
        random = np.random.randint(0, len(sum_max))
        v1_d = sum_max.iloc[random]['all_id']
        data = data[(data['ID1'] != v1_d) & (data['ID2'] != v1_d)]

# Randomly exclude one ID from each relative pair
data_only_id = data[['ID1', 'ID2']]
data_only_remove = pd.DataFrame(np.zeros((len(data_only_id), 1)), columns=['ID'])

for i in range(len(data_only_id)):
    random = np.random.randint(0, 2)
    data_only_remove.iloc[i, 0] = data_only_id.iloc[i, random] # No relative left, indepentd IDs remained

# Get all of the IDs that has relative relationships and save the results to further excluded by plink
data_id = pd.read_csv('~/UKB_WES_data/qcstep4/ukb_wes_chr_all_king_sample_qc.kin0', delimiter='\t')
data_id = data_id[data_id['KINSHIP'] >= 0.0884]
data_id_all = pd.unique(pd.concat([data_id['IID1'], data_id['IID2']]))
related_sample_remove = np.setdiff1d(data_id_all, data_only_remove[0])

result = pd.DataFrame(related_sample_remove, columns=['Related_Sample_Remove'])
result.to_csv('~/UKB_WES_data/qcstep4/related_2nd_sample_remove.txt', sep='\t', index=False, header=False)
