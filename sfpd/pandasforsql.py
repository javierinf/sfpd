import pandas as pd

df = pd.read_csv("/Users/javierinfantino/Documents/GitHub/sfpd/sfpd/sf_crime_reports.csv")

##print(df.isnull().sum())

print(df.resolution.unique() )

