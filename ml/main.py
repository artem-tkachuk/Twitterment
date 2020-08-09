import pandas as pd
from numpy.random import RandomState

df = pd.read_csv('data/data.csv')

train = df.sample(frac=0.7, random_state=RandomState())
test = df.loc[~df.index.isin(train.index)]

train.to_csv('data/train.csv', index=False)
test.to_csv('data/test.csv', index=False)

