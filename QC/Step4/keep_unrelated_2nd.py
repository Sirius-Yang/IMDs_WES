import pandas as pd
import numpy as np

# 读取数据
data = pd.read_csv('~/UKB_WES_data/qcstep4/ukb_wes_chr_all_king_sample_qc.kin0', delimiter='\t')

# 重命名列
data.rename(columns={data.columns[1]: "ID1", data.columns[3]: "ID2", data.columns[7]: "Kinship"}, inplace=True)

# 筛选 kinship >= 0.0884 的行
data = data[data['Kinship'] >= 0.0884]

# 创建数组用于保存数据
x = np.zeros((len(data), 2))
data_only = pd.DataFrame(x, columns=['ID1', 'ID2'])

# 找到独立的组
continue_signal = True
while_cnt = 1
while continue_signal and len(data) > 0:
    print(while_cnt)
    while_cnt += 1
    print('length data:', len(data))

    # 汇总ID
    all_id = pd.concat([data['ID1'], data['ID2']])
    counts = all_id.value_counts()
    sum_df = pd.DataFrame({
        'all_id': counts.index,
        'Freq': counts.values
    }）
    sum_df.reset_index(inplace=True)
    sum_df.rename(columns={'index': 'all_id'}, inplace=True)

    # 判断是否继续
    if sum_df['Freq'].eq(1).all():
        data_only = data
        continue_signal = False
        break
    else:
        # 找到出现频次最高的ID
        freq_max = sum_df['Freq'].max()
        sum_max = sum_df[sum_df['Freq'] == freq_max]
        random = np.random.randint(0, len(sum_max))
        v1_d = sum_max.iloc[random]['all_id']

        # 删除同一ID的数据
        data_save = data[(data['ID1'] == v1_d) | (data['ID2'] == v1_d)]
        s_name1 = data_save['ID1'].values
        s_name2 = data_save['ID2'].values
        data = data[(data['ID1'] != v1_d) & (data['ID2'] != v1_d)]

        # 保存ID到数组
        pos = np.sum(x[:, 0] != 0)
        x[pos:pos+len(s_name1), 0] = s_name1
        x[pos:pos+len(s_name1), 1] = s_name2

# 提取有过多关联的样本的ID
data_only_id = data_only[['ID1', 'ID2']]
data_only_remove = pd.DataFrame(np.zeros((len(data_only_id), 1)), columns=['ID'])

for i in range(len(data_only_id)):
    random = np.random.randint(1, 3)
    data_only_remove.iloc[i, 0] = data_only_id.iloc[i, random - 1]

# 提取补充集
data_id = pd.read_csv('~/UKB_WES_data/qcstep4/ukb_wes_chr_all_king_sample_qc.kin0', delimiter='\t')
data_id = data_id[data_id['KINSHIP'] >= 0.0884]
data_id_all = pd.unique(pd.concat([data_id['IID1'], data_id['IID2']]))
related_sample_remove = np.setdiff1d(data_id_all, data_only_remove[0])

# 保存结果
result = pd.DataFrame(related_sample_remove, columns=['Related_Sample_Remove'])
result.to_csv('~/UKB_WES_data/qcstep4/keep_unrelated_wbs_2nd_related_sample_remove.txt', sep='\t', index=False, header=False)
