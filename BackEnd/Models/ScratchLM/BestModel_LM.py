import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import StandardScaler
import pickle
from multiple_linear_regression import MultipleLinearRegression


def BestModel_CV(filename,best_alpha=0.01):
  np.random.seed(42)
  columns_to_scale = ['ModelYear', 'Milage', 'EngineHorsepower']
  print("Loading data...")
  
  train_data = pd.read_csv(filename, index_col=0)
  
  # Standardize specified columns
  scaler = StandardScaler()
  X_train_df = train_data.drop(columns=['price'])
  X_train_df[columns_to_scale] = scaler.fit_transform(X_train_df[columns_to_scale])

  # Model ready datasets
  X_train = X_train_df.values
  y_train = train_data['price'].values
  y_train = np.log(y_train)

  # Train final model with the best alpha
  print("Training final model with best alpha:", best_alpha)
  final_model = MultipleLinearRegression()
  final_model.fit(X_train, y_train, alpha=best_alpha)


