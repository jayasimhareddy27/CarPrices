import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import pickle
from Xgboost import XGBoostScratch

# Set random seed for reproducibility
np.random.seed(42)

# Columns to scale
columns_to_scale = ['ModelYear', 'Milage', 'EngineHorsepower']

# Load data
print("Loading data...")
train_data = pd.read_csv('./Datasets/OnehotencodedData.csv', index_col=0)

# Standardize specified columns
scaler = StandardScaler()
X_train_df = train_data.drop(columns=['price'])
X_train_df[columns_to_scale] = scaler.fit_transform(X_train_df[columns_to_scale])

# Prepare datasets
X = X_train_df.values
y = train_data['price'].values
y = np.log(y)

# Split into training and validation sets
X_train, X_val, y_train, y_val = train_test_split(X, y, test_size=0.2, random_state=42)

# Parameters for Scratch XGBoost
max_depths = [1]  # List of max_depth values to iterate over
max_features = 0.25  # Keep max_features constant

# Dictionary to store RMSE for each model
rmse_results = {}

for max_depth in max_depths:
    print(f"Training Scratch XGBoost model with max_depth={max_depth}")
    scratch_xgb = XGBoostScratch(
        max_depth=max_depth,
        max_features=max_features
    )
    scratch_xgb.fit(X_train, y_train)
    
    # Validate the model
    y_val_pred = scratch_xgb.predict(X_val)
    val_rmse = np.sqrt(((y_val - y_val_pred) ** 2).mean())  # Calculate RMSE
    print(f"Validation RMSE for max_depth={max_depth}: {val_rmse:.4f}")
    
    # Store RMSE in the dictionary
    rmse_results[max_depth] = val_rmse
    
    # Save the model
    model_pkl_file = f"../FrontEnd/Save/SavedModels/XGBoost.pkl"
    with open(model_pkl_file, 'wb') as file:
        pickle.dump(scratch_xgb, file)  # Save the model using pickle
    print(f"Scratch XGBoost model with max_depth={max_depth} saved to {model_pkl_file}")

# Save the RMSE results to a text file
results_file = "RMSE_results.txt"
with open(results_file, "w") as file:
    for depth, rmse in rmse_results.items():
        file.write(f"Max Depth: {depth}, Validation RMSE: {rmse:.4f}\n")
print(f"RMSE results saved to {results_file}")

