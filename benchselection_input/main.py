import numpy as np
import pandas as pd
from os import path

crafted_file = "crafted-times.csv"
industrial_file = "industrial-times.csv"

crafted = pd.read_csv(crafted_file, header=0)
industrial = pd.read_csv(industrial_file, header=0)

df = pd.concat([crafted, industrial])
df['Instances'] = df['Instances'].apply(lambda x: path.split(x)[1])

no_timeouts = df.query(
    'sinn != 900 & CCASat != 900 & clasp != 900 & lingeling != 900 & glucose != 900').copy(deep=True)

no_timeouts['Ave'] = no_timeouts.mean(axis=1)
under_ave = no_timeouts.query('Ave < 100')
print(under_ave)
