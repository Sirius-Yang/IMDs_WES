import pandas as pd
import numpy as np

def OR_Generate(data):
    # 计算患病率
    prevalence = data[data['IF'] == 1].shape[0] / data.shape[0]
    
    # 计算携带突变的病例和对照的数量
    ac_case = data[(data['mutation'] == 1) & (data['IF'] == 1)].shape[0]
    ac_ctrl = data[(data['mutation'] == 1) & (data['IF'] == 0)].shape[0]
    
    # 计算病例的等位基因频率
    AF_case = ac_case / (2 * data[data['IF'] == 1].shape[0])
    
    # 计算总体的等位基因频率
    AF = (ac_case + ac_ctrl) / (2 * data.shape[0])
    
    # 计算beta和每个等位基因的beta
    beta = (2 * (AF_case - AF) * prevalence) / np.sqrt(2 * AF * (1 - AF) * prevalence * (1 - prevalence))
    twopq = 2 * AF * (1 - AF)
    beta_perallele = beta / np.sqrt(twopq)
    
    # 计算风险比（OR）
    OR = np.exp(beta_perallele)
    
    # 封装结果为字典
    result = {'OR': OR, 'SE': twopq, 'BETA': beta_perallele}
    return result

