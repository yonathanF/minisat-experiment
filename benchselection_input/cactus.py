import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

"""
Expect input in the form of 
         solver1, solver2, solver3
instance1  t1       t2        t3
instance2  t1       t2        t3
instance3
"""

num_instances = 100
time_out = 150

df = pd.DataFrame([np.random.exponential(size=3, scale=np.random.uniform(0.01, 0.001))*100 for _ in range(num_instances)],
                  columns=['Solver1', 'Solver2', 'Solver3'])

sorted_df = df.transform(np.sort)
cleaned = sorted_df.replace(time_out, np.nan)
cum_summed = cleaned.cumsum()
# .apply(np.log)  # TODO check this is okay

cum_summed['Instances'] = np.arange(start=1, stop=num_instances+1)

ax1 = cum_summed.plot.scatter(x='Instances',
                              y='Solver1',
                              c='DarkBlue')
cum_summed.plot.scatter(x='Instances',
                        y='Solver2',
                        c='Red',
                        ax=ax1)

cum_summed.plot.scatter(x='Instances',
                        y='Solver3',
                        c='Green',
                        ax=ax1)


plt.show()
