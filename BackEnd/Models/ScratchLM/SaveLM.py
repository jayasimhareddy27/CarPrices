import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.model_selection import KFold 
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import StandardScaler
import pickle
from multiple_linear_regression import MultipleLinearRegression
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score



def compute_metrics(y_true, y_pred):
    rmse = np.sqrt(mean_squared_error(y_true, y_pred))
    mae = mean_absolute_error(y_true, y_pred)
    r2 = r2_score(y_true, y_pred)
    mape = np.mean(np.abs((y_true - y_pred) / y_true)) * 100  # In percentage

    return {"rmse": rmse, "mae": mae, "r2": r2, "mape": mape}

def tune_alpha_with_cross_validation(X, y, alpha_values, k=5):
    print("Initializing k-fold cross-validation for MultipleLinearRegression...")
    kf = KFold(n_splits=k, shuffle=True, random_state=42)
    best_alpha = None
    best_rmse = float("inf")
    cross_val_results = {"fold_results": []}

    print(f"Total alpha values to test: {len(alpha_values)}")
    print(f"Number of folds: {k}")

    for alpha in alpha_values:
        print(f"\nEvaluating alpha: {alpha}")
        fold_metrics = []
        fold_num = 1

        for train_idx, val_idx in kf.split(X):
            # Split data into training and validation folds
            X_train, X_val = X[train_idx], X[val_idx]
            y_train, y_val = y[train_idx], y[val_idx]

            # Train the model
            model = MultipleLinearRegression()
            model.fit(X_train, y_train, alpha=alpha)
            print(f"    Model trained for alpha={alpha} on fold {fold_num}.")
            print(f"    Training set size: {X_train.shape[0]} samples, Validation set size: {X_val.shape[0]} samples.")

            # Predict and compute metrics
            y_pred = model.predict(X_val)
            metrics = compute_metrics(y_val, y_pred)
            fold_metrics.append(metrics)

            print(f"    Metrics for fold {fold_num}: RMSE={metrics['rmse']:.4f}, MAE={metrics['mae']:.4f}, "
                  f"R²={metrics['r2']:.4f}, MAPE={metrics['mape']:.2f}%")

            fold_num += 1

        # Average RMSE for this alpha
        avg_rmse = np.mean([metrics["rmse"] for metrics in fold_metrics])
        print(f"  Average RMSE for alpha={alpha}: {avg_rmse:.4f}")

        # Store results for this alpha
        cross_val_results["fold_results"].append({"alpha": alpha, "fold_metrics": fold_metrics})

        # Update the best alpha if this one is better
        if avg_rmse < best_rmse:
            print(f"  Alpha {alpha} is currently the best with Avg RMSE: {avg_rmse:.4f}")
            best_rmse = avg_rmse
            best_alpha = alpha

    print(f"\nBest alpha found: {best_alpha} with Avg RMSE: {best_rmse:.4f}")
    return best_alpha, cross_val_results

np.random.seed(42)
columns_to_scale = ['ModelYear', 'Milage', 'EngineHorsepower']

# Load data
print("Loading data...")
train_data = pd.read_csv('./Datasets/OnehotencodedData_Train.csv', index_col=0)

# Standardize specified columns
scaler = StandardScaler()
X_train_df = train_data.drop(columns=['price'])
X_train_df[columns_to_scale] = scaler.fit_transform(X_train_df[columns_to_scale])



# Model ready datasets
X_train = X_train_df.values
y_train = train_data['price'].values
y_train = np.log(y_train)

# Split into training and validation sets

# Grid search over a logarithmic scale of alpha values
alpha_values = np.logspace(-4, 4, 20)  # Increased granularity for alpha values

print("Starting alpha tuning with Cross Validation...")
best_alpha, cv_results_lr  = tune_alpha_with_cross_validation(X_train, y_train, alpha_values)

# Train final model with the best alpha
print("Training final model with best alpha:", best_alpha)
final_model = MultipleLinearRegression()
final_model.fit(X_train, y_train, alpha=best_alpha)





# Save the model
model_pkl_file = "../FrontEnd/Save/SavedModels/LM.pkl"
with open(model_pkl_file, 'wb') as file:
    pickle.dump(final_model, file)
print(f"Model saved to {model_pkl_file}")

model_pkl_file = "Save/SavedModels/LM.pkl"
with open(model_pkl_file, 'wb') as file:
    pickle.dump(final_model, file)
print(f"Model saved to {model_pkl_file}")


# Save the column names to a text file
#train_columns = X_train_df.columns.tolist()
#with open("./Save/train_columns.txt", "w") as f:
#    for column in train_columns:
#        f.write(f"{column}\n")
#print("Training columns saved to train_columns.txt")

#with open("../FrontEnd/Save/train_columns.txt", "w") as f:
#    for column in train_columns:
#        f.write(f"{column}\n")
#print("Training columns saved to train_columns.txt")

