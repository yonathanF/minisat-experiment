import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

old_data_file = "1998-amdk6.csv"
new_data_file = "2019-intel.csv"

df_new = pd.read_csv(old_data_file)
df_new = df_new.loc[df_new.Sat != 'INDETERMINATE']
df_old = pd.read_csv(new_data_file)
df_old = df_old.loc[df_old.Sat != 'INDETERMINATE']


def plot_data(df_grouped, measure):
    fig, ax = plt.subplots(figsize=(8, 6))
    for option, df in df_grouped:
        temp = df.transform(np.sort).cumsum()
        temp['Index'] = range(1, len(temp) + 1)
        temp.plot(x='Index', y=measure, ax=ax, label=option)
    ax.set_ylabel(measure)
    ax.set_xlabel("Instances")
    ax.set_title("Change in %s" % measure)
    plt.legend()
    plt.show()


def plot_all(df):
    measured = ['Time', 'Memory', 'ConflictsPerSecond',
                'DecisionsPerSecond', 'PropagationsPerSecond']

    for measure in measured:
        selected = df[['Option', measure]].groupby(by=['Option'])
        plot_data(selected, measure)


# plot_all(df_new)
plot_all(df_old)

# sorted_df = df.transform(np.sort)
# cleaned = sorted_df.replace(time_out, np.nan)
# cum_summed = cleaned.cumsum()
# # .apply(np.log)  # TODO check this is okay

# cum_summed['Instances'] = np.arange(start=1, stop=num_instances+1)

# ax1 = cum_summed.plot.scatter(x='Instances',
# y='Solver1',
# c='DarkBlue')
# cum_summed.plot.scatter(x='Instances',
# y='Solver2',
# c='Red',
# ax=ax1)

# cum_summed.plot.scatter(x='Instances',
# y='Solver3',
# c='Green',
# ax=ax1)


# plt.show()
