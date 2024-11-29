import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.model_selection import KFold
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

import pickle
from Xgboost import XGBoostScratch

# Set random seed for reproducibility
np.random.seed(42)


def compute_metrics(y_true, y_pred):
    rmse = np.sqrt(mean_squared_error(y_true, y_pred))
    mae = mean_absolute_error(y_true, y_pred)
    r2 = r2_score(y_true, y_pred)
    mape = np.mean(np.abs((y_true - y_pred) / y_true)) * 100  # In percentage

    return {"rmse": rmse, "mae": mae, "r2": r2, "mape": mape}
  
# Columns to scale
columns_to_scale = ['ModelYear', 'Milage', 'EngineHorsepower']

# Load data
def tune_xgboost_with_cross_validation(X, y, max_depths, k=5):
    print("Initializing k-fold cross-validation for XGBoostScratch...")
    kf = KFold(n_splits=k, shuffle=True, random_state=42)
    best_depth = None
    best_rmse = float("inf")
    cross_val_results = {"fold_results": []}

    print(f"Total depth values to test: {len(max_depths)}")
    print(f"Number of folds: {k}")

    for max_depth in max_depths:
        print(f"\nEvaluating max_depth: {max_depth}")
        rmse_scores = []
        fold_num = 1

        for train_idx, val_idx in kf.split(X):
            # Split data into training and validation folds
            X_train, X_val = X[train_idx], X[val_idx]
            y_train, y_val = y[train_idx], y[val_idx]

            # Train the model
            model = XGBoostScratch(max_depth=max_depth)
            model.fit(X_train, y_train)
            print(f"    Model trained for max_depth={max_depth} on fold {fold_num}.")
            print(f"    Training set size: {X_train.shape[0]} samples, Validation set size: {X_val.shape[0]} samples.")

            # Predict and compute metrics
            y_pred = model.predict(X_val)
            metrics = compute_metrics(y_val, y_pred)
            rmse_scores.append(metrics["rmse"])

            print(f"    Metrics for fold {fold_num}: RMSE={metrics['rmse']:.4f}, MAE={metrics['mae']:.4f}, R²={metrics['r2']:.4f}, MAPE={metrics['mape']:.2f}%")

            # Store fold results
            cross_val_results["fold_results"].append(metrics)

            fold_num += 1

        # Average RMSE for this max_depth
        avg_rmse = np.mean(rmse_scores)
        print(f"  Average RMSE for max_depth={max_depth}: {avg_rmse:.4f}")

        # Update the best max_depth if this one is better
        if avg_rmse < best_rmse:
            print(f"  Max Depth {max_depth} is currently the best with Avg RMSE: {avg_rmse:.4f}")
            best_rmse = avg_rmse
            best_depth = max_depth

    print(f"\nBest max_depth found: {best_depth} with Avg RMSE: {best_rmse:.4f}")
    return best_depth, cross_val_results
print("Loading data...")
train_data = pd.read_csv('./Datasets/OnehotencodedData_Train.csv', index_col=0)

# Standardize specified columns
scaler = StandardScaler()
X_train_df = train_data.drop(columns=['price'])
X_train_df[columns_to_scale] = scaler.fit_transform(X_train_df[columns_to_scale])

# Prepare datasets
X_train = X_train_df.values
y = train_data['price'].values
y_train = np.log(y)
 
# Parameters for Scratch XGBoost
max_depths = [2,4,6,8] # List of max_depth values to iterate over
max_features = 0.25  # Keep max_features constant
num_trees = 100
learning_rate = 0.01

# Dictionary to store RMSE for each model
rmse_results = {}


# Perform k-fold cross-validation to tune max_depth

print("\nStarting cross-validation to tune max_depth for XGBoostScratch...")
best_depth, cv_results_xgb = tune_xgboost_with_cross_validation(X_train, y_train, max_depths)

# Train final model with the best max_depth
print(f"\nTraining final model with best max_depth: {best_depth}")

final_model = XGBoostScratch(
    num_trees=num_trees,
    max_depth=best_depth,
    max_features=max_features,
    learning_rate=learning_rate
)
final_model.fit(X_train, y_train)

model_pkl_file = "Save/SavedModels/XGB.pkl"
with open(model_pkl_file, 'wb') as file:
    pickle.dump(final_model, file)
print(f"Final XGBoost model saved to {model_pkl_file}")

model_pkl_file = "../FrontEnd/Save/SavedModels/XGB.pkl"
with open(model_pkl_file, 'wb') as file:
    pickle.dump(final_model, file)
print(f"Final XGBoost model saved to {model_pkl_file}")
