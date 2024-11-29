
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import pickle
import numpy as np 


class XGBoostScratch:
    def __init__(self, num_trees=100, max_depth=5, max_features=0.25, learning_rate=0.01, min_samples_split=2):
        self.num_trees = num_trees
        self.max_features = max_features
        self.max_depth = max_depth
        self.learning_rate = learning_rate
        self.min_samples_split = min_samples_split
        self.trees = []
        self.selected_features = []

    def _compute_residuals(self, y, y_pred):
        return y - y_pred

    def _select_features(self, X):
        """
        Randomly select a subset of features based on max_features.
        """
        total_features = X.shape[1]
        num_features = max(1, int(self.max_features * total_features))  # At least 1 feature
        return np.random.choice(total_features, num_features, replace=False)

    def _build_tree(self, X, residuals, depth):
        if depth >= self.max_depth or len(X) < self.min_samples_split:
            return np.mean(residuals)
    
        best_split = {}
        min_error = float('inf')
    
        # Select a random subset of features
        features = self._select_features(X)
        self.selected_features.append(features)  # Store selected features for reference
    
        for feature in features:
            thresholds = np.unique(X[:, feature])
            for threshold in thresholds:
                left_mask = X[:, feature] <= threshold
                right_mask = X[:, feature] > threshold
    
                # Skip invalid splits
                if not np.any(left_mask) or not np.any(right_mask):
                    continue
    
                left_residuals = residuals[left_mask]
                right_residuals = residuals[right_mask]
    
                if len(left_residuals) == 0 or len(right_residuals) == 0:
                    continue
    
                left_mean = np.mean(left_residuals)
                right_mean = np.mean(right_residuals)
    
                error = (np.sum((left_residuals - left_mean) ** 2) +
                         np.sum((right_residuals - right_mean) ** 2))
    
                if error < min_error:
                    min_error = error
                    best_split = {
                        "feature": feature,
                        "threshold": threshold,
                        "left": left_mean,
                        "right": right_mean
                    }
    
        # Handle cases where no valid split is found
        if not best_split:
            return np.mean(residuals)
    
        return best_split

    def _predict_tree(self, tree, x):
        if not isinstance(tree, dict):
            return tree
        feature = tree["feature"]
        threshold = tree["threshold"]

        if x[feature] <= threshold:
            return tree["left"]
        else:
            return tree["right"]

    def fit(self, X, y):
        self.initial_pred = np.mean(y)
        y_pred = np.full(y.shape, self.initial_pred)

        for _ in range(self.num_trees):
            residuals = self._compute_residuals(y, y_pred)
            tree = self._build_tree(X, residuals, 0)
            self.trees.append(tree)

            # Update predictions
            for i in range(len(X)):
                y_pred[i] += self.learning_rate * self._predict_tree(tree, X[i])

    def predict(self, X):
        y_pred = np.full(X.shape[0], self.initial_pred)
        for tree in self.trees:
            for i in range(len(X)):
                y_pred[i] += self.learning_rate * self._predict_tree(tree, X[i])
        return y_pred

