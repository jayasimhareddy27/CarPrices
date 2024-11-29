import pickle
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from Xgboost import XGBoostScratch

def predict_car_prices_XGB(test_data, model_pkl_file="Save/SavedModels/XGB.pkl", columns_file="Save/train_columns.txt"):
    # Load the saved model
    with open(model_pkl_file, 'rb') as file:
        ReadModel = pickle.load(file)
    
    # Define columns to scale and categorical columns
    columns_to_scale_Test = ["ModelYear", "Milage", "EngineHorsepower"]
    categorical_columns = ['brand', 'FuelType', 'Transmission', 'Accident', 'EngineTechnology', 'EngineSpecial', 'EngineConfiguration']
    
    # One-hot encode categorical columns and format for consistency
    test_data_encoded = pd.get_dummies(test_data, columns=categorical_columns, drop_first=True)    

    # Load expected column names from the text file
    with open(columns_file, "r") as f:
        train_columns = [line.strip() for line in f]
    
    # Reindex test data to match train data columns without 'price'
    test_data_encoded = test_data_encoded.reindex(columns=train_columns, fill_value=0)
    
    # Ensure boolean columns are converted to integers if any exist
    bool_columns = test_data_encoded.select_dtypes(include=['bool']).columns
    if not bool_columns.empty:
        test_data_encoded[bool_columns] = test_data_encoded[bool_columns].astype(int)
    
    # Standardize specified columns
    scaler = StandardScaler()
    test_data_encoded[columns_to_scale_Test] = scaler.fit_transform(test_data_encoded[columns_to_scale_Test])
    print(test_data_encoded)
    
    # Make predictions
    predictions = ReadModel.predict(test_data_encoded.values)
    predictions = np.exp(predictions)
    return predictions


