"""
adaptive_engine.py
==================
Dynamic Adaptive Difficulty Engine (DADE) Backend Service for Smriti.

Provides session evaluation, difficulty scaling, Cognitive Performance Index (CPI)
calculation, and human-readable clinical explanation trails for caregivers.
"""

import os
import pickle
import numpy as np
import pandas as pd

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.dirname(SCRIPT_DIR)
MODEL_PATH = os.path.join(BACKEND_DIR, "models", "dade_model.pkl")


class AdaptiveDifficultyEngine:
    def __init__(self, model_path: str = MODEL_PATH):
        self.model_path = model_path
        self.model = None
        self.features = [
            "accuracy",
            "avg_response_time_ms",
            "hint_count",
            "error_streak_max",
            "assigned_difficulty",
            "rounds_completed"
        ]
        self._load_model()

    def _load_model(self):
        if os.path.exists(self.model_path):
            with open(self.model_path, "rb") as f:
                payload = pickle.load(f)
                self.model = payload["model"]
                print(f"[DADE Engine] Loaded {payload.get('model_name', 'ML')} model (Accuracy: {payload['metrics']['test_accuracy'] * 100:.1f}%)")
        else:
            print(f"[DADE Engine WARNING] Model artifact not found at {self.model_path}. Using calibrated heuristic fallback.")

    def calculate_cpi(self, accuracy: float, avg_resp_ms: float, target_resp_sec: float, hint_count: int, error_streak: int) -> float:
        """
        Computes the Cognitive Performance Index (0-100).
        """
        resp_sec = avg_resp_ms / 1000.0
        acc_comp = accuracy * 0.45
        latency_ratio = min(resp_sec / max(target_resp_sec, 1.0), 3.0)
        latency_comp = max(0.0, 1.0 - (latency_ratio / 3.0)) * 0.25
        hint_comp = max(0.0, 1.0 - (hint_count / 4.0)) * 0.15
        streak_comp = max(0.0, 1.0 - (error_streak / 4.0)) * 0.15
        cpi = float(np.clip(100.0 * (acc_comp + latency_comp + hint_comp + streak_comp), 0.0, 100.0))
        return round(cpi, 1)

    def evaluate_session(self, telemetry: dict) -> dict:
        """
        Evaluates session telemetry and recommends the next difficulty tier.
        
        Input dictionary format:
        {
            "accuracy": 0.85,
            "avg_response_time_ms": 2100,
            "hint_count": 0,
            "error_streak_max": 1,
            "assigned_difficulty": 2,
            "rounds_completed": 8,
            "target_resp_sec": 2.5 (optional, default 2.5)
        }
        """
        acc = float(telemetry.get("accuracy", 0.70))
        resp_ms = float(telemetry.get("avg_response_time_ms", 3000))
        hints = int(telemetry.get("hint_count", 0))
        streak = int(telemetry.get("error_streak_max", 0))
        curr_diff = int(telemetry.get("assigned_difficulty", 2))
        rounds = int(telemetry.get("rounds_completed", 8))
        target_resp = float(telemetry.get("target_resp_sec", 2.5))

        cpi = self.calculate_cpi(acc, resp_ms, target_resp, hints, streak)

        # ML Model Prediction if available
        if self.model is not None:
            input_df = pd.DataFrame([{
                "accuracy": acc,
                "avg_response_time_ms": resp_ms,
                "hint_count": hints,
                "error_streak_max": streak,
                "assigned_difficulty": curr_diff,
                "rounds_completed": rounds
            }])[self.features]
            
            pred = int(self.model.predict(input_df)[0])
        else:
            # Fallback heuristic
            if cpi >= 75.0 and acc >= 0.80:
                pred = 1
            elif cpi < 48.0 or acc < 0.50:
                pred = -1
            else:
                pred = 0

        new_diff = int(np.clip(curr_diff + pred, 1, 5))

        # Generate Explainable Caregiver Reasoning
        if pred == 1:
            reason = f"Excellent flow state! Accuracy was {int(acc * 100)}% with brisk response latency ({int(resp_ms)}ms). Advancing to Level {new_diff} to sustain gentle engagement."
        elif pred == -1:
            reason = f"Mild friction observed (Accuracy {int(acc * 100)}%, {hints} hints used). Simplifying challenge to Level {new_diff} to protect confidence and prevent frustration."
        else:
            reason = f"Steady, stable performance (Accuracy {int(acc * 100)}%, CPI {cpi}). Maintaining Level {new_diff} for cognitive reinforcement."

        return {
            "cpi_score": cpi,
            "difficulty_adjustment": pred,
            "current_difficulty": curr_diff,
            "recommended_difficulty": new_diff,
            "clinical_reasoning": reason,
            "decision_metadata": {
                "accuracy_pct": int(acc * 100),
                "avg_response_ms": int(resp_ms),
                "hints_utilized": hints,
                "max_error_streak": streak,
                "model_evaluated": "LightGBM" if self.model is not None else "Deterministic Heuristic"
            }
        }


# Singleton engine instance
dade_engine = AdaptiveDifficultyEngine()

if __name__ == "__main__":
    # Test sample evaluation
    sample_session = {
        "accuracy": 0.88,
        "avg_response_time_ms": 1950,
        "hint_count": 0,
        "error_streak_max": 1,
        "assigned_difficulty": 2,
        "rounds_completed": 10
    }
    result = dade_engine.evaluate_session(sample_session)
    print("\n--- Test Sample Evaluation ---")
    for k, v in result.items():
        print(f"{k}: {v}")
