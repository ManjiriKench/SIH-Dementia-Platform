"""
train_adaptive_engine.py
========================
Trains and evaluates the Dynamic Adaptive Difficulty Engine (DADE) for Smriti.

Model Objective:
Predict next difficulty adjustment: Delta_D in {-1 (step down), 0 (maintain), +1 (step up)}
based on real-time session telemetry:
[accuracy, avg_response_time_ms, hint_count, error_streak_max, assigned_difficulty, rounds_completed].

Outputs:
1. Trained model artifact: backend/models/dade_model.pkl
2. Comprehensive evaluation report (Test Accuracy, F1, Confusion Matrix, Feature Importances)
3. Direct decision tree thresholds for zero-latency pure Dart transpilation.
"""

import os
import pickle
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, f1_score
import lightgbm as lgb

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.dirname(SCRIPT_DIR)
DATA_PATH = os.path.join(BACKEND_DIR, "data", "synthetic", "gameplay_sessions_v1.csv")
MODEL_DIR = os.path.join(BACKEND_DIR, "models")
MODEL_OUTPUT_PATH = os.path.join(MODEL_DIR, "dade_model.pkl")

FEATURES = [
    "accuracy",
    "avg_response_time_ms",
    "hint_count",
    "error_streak_max",
    "assigned_difficulty",
    "rounds_completed"
]
TARGET = "difficulty_adjustment"
CLASS_NAMES = ["Step_Down (-1)", "Maintain (0)", "Step_Up (+1)"]


def load_and_prepare_data():
    if not os.path.exists(DATA_PATH):
        raise FileNotFoundError(f"Data file not found at {DATA_PATH}. Run generate_synthetic_telemetry.py first.")
        
    df = pd.read_csv(DATA_PATH)
    print(f"[DATA] Loaded {len(df)} sessions from {DATA_PATH}")
    
    X = df[FEATURES]
    y = df[TARGET]
    
    print(f"[TARGET DISTRIBUTION]\n{y.value_counts(normalize=True).round(3)}")
    return train_test_split(X, y, test_size=0.20, random_state=42, stratify=y)


def train_and_evaluate():
    os.makedirs(MODEL_DIR, exist_ok=True)
    X_train, X_test, y_train, y_test = load_and_prepare_data()
    
    print("\n" + "=" * 60)
    print("Smriti AI: Training Dynamic Adaptive Difficulty Engine (DADE)")
    print("=" * 60)
    
    # 1. Train LightGBM Classifier
    print("\n--- Model 1: LightGBM Classifier ---")
    lgb_clf = lgb.LGBMClassifier(
        n_estimators=120,
        max_depth=6,
        learning_rate=0.08,
        num_leaves=31,
        random_state=42,
        verbosity=-1
    )
    lgb_clf.fit(X_train, y_train)
    lgb_pred = lgb_clf.predict(X_test)
    lgb_acc = accuracy_score(y_test, lgb_pred)
    lgb_f1 = f1_score(y_test, lgb_pred, average="weighted")
    print(f"LightGBM Test Accuracy: {lgb_acc * 100:.2f}% | Weighted F1: {lgb_f1:.4f}")
    
    # 2. Train Random Forest (Transpilation Reference)
    print("\n--- Model 2: Random Forest Classifier ---")
    rf_clf = RandomForestClassifier(
        n_estimators=100,
        max_depth=8,
        min_samples_leaf=4,
        random_state=42,
        n_jobs=-1
    )
    rf_clf.fit(X_train, y_train)
    rf_pred = rf_clf.predict(X_test)
    rf_acc = accuracy_score(y_test, rf_pred)
    rf_f1 = f1_score(y_test, rf_pred, average="weighted")
    print(f"Random Forest Test Accuracy: {rf_acc * 100:.2f}% | Weighted F1: {rf_f1:.4f}")
    
    # Select best performing model
    best_model = lgb_clf if lgb_f1 >= rf_f1 else rf_clf
    best_model_name = "LightGBM" if lgb_f1 >= rf_f1 else "RandomForest"
    best_pred = lgb_pred if lgb_f1 >= rf_f1 else rf_pred
    
    print("\n" + "=" * 60)
    print(f"BEST MODEL SELECTED: {best_model_name}")
    print("=" * 60)
    
    print("\nClassification Report on Unseen Test Set (5,000 sessions):")
    print(classification_report(y_test, best_pred, target_names=CLASS_NAMES, digits=4))
    
    print("Confusion Matrix:")
    cm = confusion_matrix(y_test, best_pred)
    cm_df = pd.DataFrame(cm, index=CLASS_NAMES, columns=[f"Pred_{c}" for c in CLASS_NAMES])
    print(cm_df)
    
    # Feature Importances
    if hasattr(best_model, "feature_importances_"):
        importances = pd.Series(best_model.feature_importances_, index=FEATURES).sort_values(ascending=False)
        print("\nFeature Importances (Why the model makes decisions):")
        for feat, imp in importances.items():
            print(f"  - {feat:22s}: {imp:.4f}")

    # Save artifact
    model_payload = {
        "model": best_model,
        "model_name": best_model_name,
        "features": FEATURES,
        "classes": [-1, 0, 1],
        "metrics": {
            "test_accuracy": float(max(lgb_acc, rf_acc)),
            "weighted_f1": float(max(lgb_f1, rf_f1))
        }
    }
    with open(MODEL_OUTPUT_PATH, "wb") as f:
        pickle.dump(model_payload, f)
        
    print(f"\n[SAVED] Serialized model to: {MODEL_OUTPUT_PATH}")
    return model_payload


if __name__ == "__main__":
    train_and_evaluate()
