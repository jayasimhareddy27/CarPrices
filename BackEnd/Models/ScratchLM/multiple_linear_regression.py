import numpy as np


class MultipleLinearRegression:
    def __init__(self):
        self.coefficients = None

    def fit(self, X, y, alpha=100):
        # Add intercept term
        X = np.c_[np.ones(X.shape[0]), X]
        X_transpose = np.transpose(X)
        X_transpose_X = np.dot(X_transpose, X)
        regularization_term = alpha * np.identity(X_transpose_X.shape[0])  # Ridge regularization
        # Use np.linalg.solve instead of np.linalg.inv for stability and performance
        self.coefficients = np.linalg.solve(X_transpose_X + regularization_term, np.dot(X_transpose, y))
        print(f"Model fitted with alpha={alpha}")

    def predict(self, X):
        X = np.c_[np.ones(X.shape[0]), X]
        predictions = np.dot(X, self.coefficients)
        predictions[predictions < 0] = 0  # To prevent negative prices
        return predictions
