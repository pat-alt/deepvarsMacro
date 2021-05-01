import pandas as pd
from functools import reduce
from datetime import datetime
GDP = pd.read_csv('data_VAR/USA_GDP.csv')
CPI = pd.read_csv('data_VAR/US_CPI.csv')
Unemployment_rate = pd.read_csv('data_VAR/UE_US.csv')
Interest_rate = pd.read_csv('data_VAR/IR_US.csv')

frames = [GDP,CPI,Unemployment_rate,Interest_rate]
df_merged = reduce(lambda left,right: pd.merge(left,right,on=['DATE'],how='inner'), frames)
df_merged['DATE'] = df_merged.apply(lambda x: datetime.strptime(x.DATE, '%Y-%m-%d'), axis=1)


