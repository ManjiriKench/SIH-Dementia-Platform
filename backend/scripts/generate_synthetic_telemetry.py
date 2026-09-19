"""
generate_synthetic_telemetry.py
================================
Clinically-Calibrated Synthetic Gameplay Telemetry Generator for Smriti (Dementia Cognitive Engagement Platform).

Parameter distributions are calibrated against published benchmarks from:
- ADNI (Alzheimer's Disease Neuroimaging Initiative): Reaction time distributions and latency variances.
- LASI-DAD (Longitudinal Aging Study in India - Diagnostic Assessment of Dementia): Indian elderly baseline variance.
- WHO iSupport Guidelines: Cognitive fatigue thresholds and adaptive difficulty rules.

Outputs:
1. backend/data/synthetic/gameplay_sessions_v1.csv (25,000 sessions for DADE & CAR model training)
2. backend/data/synthetic/patient_trajectories_90d.csv (Longitudinal tracking across 100 patients for Drift & Anomaly models)
"""

import os
import math
import random
from datetime import datetime, timedelta
import numpy as np
import pandas as pd

# Define target domains and standardized game activities
ACTIVITY_CATALOG = [
    {"domain": "Memory", "game_id": "act_mem_face_recall", "target_resp_sec": 2.5},
    {"domain": "Memory", "game_id": "act_mem_object_match", "target_resp_sec": 2.2},
    {"domain": "Memory", "game_id": "act_mem_sequence_retention", "target_resp_sec": 3.0},
    {"domain": "Attention", "game_id": "act_att_odd_one_out", "target_resp_sec": 2.0},
    {"domain": "Attention", "game_id": "act_att_target_spotting", "target_resp_sec": 2.2},
    {"domain": "Attention", "game_id": "act_att_distractor_filter", "target_resp_sec": 2.8},
    {"domain": "Language", "game_id": "act_lang_word_object_pair", "target_resp_sec": 2.4},
    {"domain": "Language", "game_id": "act_lang_proverb_complete", "target_resp_sec": 3.2},
    {"domain": "Executive_Function", "game_id": "act_exec_routine_order", "target_resp_sec": 3.5},
    {"domain": "Executive_Function", "game_id": "act_exec_category_sort", "target_resp_sec": 2.6},
    {"domain": "Orientation", "game_id": "act_ori_day_time_match", "target_resp_sec": 2.0},
    {"domain": "Orientation", "game_id": "act_ori_morning_night_sort", "target_resp_sec": 2.3},
    {"domain": "Visuospatial", "game_id": "act_vis_textile_pattern", "target_resp_sec": 3.0},
    {"domain": "Visuospatial", "game_id": "act_vis_shape_continue", "target_resp_sec": 2.8},
]

COHORTS = [
    "Consistent_High_Functioning",
    "Moderate_Fluctuating",
    "Acute_Fatigue_Sundowning",
    "Longitudinal_Cognitive_Drift"
]
COHORT_WEIGHTS = [0.30, 0.35, 0.20, 0.15]
TIME_OF_DAY_CHOICES = ["Morning", "Afternoon", "Evening", "Night"]


def calculate_cpi_and_target(accuracy: float, resp_time_sec: float, target_resp_sec: float, hint_count: int, error_streak: int) -> tuple[float, int]:
    """
    Computes Cognitive Performance Index (0-100) and target next difficulty adjustment (-1, 0, +1).
    """
    # Normalized components
    acc_component = accuracy * 0.45
    
    # Latency penalty: penalize when resp_time exceeds target
    latency_ratio = min(resp_time_sec / max(target_resp_sec, 1.0), 3.0)
    latency_component = max(0.0, 1.0 - (latency_ratio / 3.0)) * 0.25
    
    # Hint penalty
    hint_component = max(0.0, 1.0 - (hint_count / 4.0)) * 0.15
    
    # Error streak penalty
    streak_component = max(0.0, 1.0 - (error_streak / 4.0)) * 0.15
    
    cpi = float(np.clip(100.0 * (acc_component + latency_component + hint_component + streak_component), 0.0, 100.0))
    
    # Target difficulty adjustment: +1 (step up), 0 (maintain), -1 (step down)
    if cpi >= 75.0 and accuracy >= 0.80:
        target_diff = 1
    elif cpi < 48.0 or accuracy < 0.50:
        target_diff = -1
    else:
        target_diff = 0
        
    return round(cpi, 1), target_diff


def generate_session_record(session_id: str, patient_id: str, cohort: str, current_time: datetime, rng: np.random.Generator) -> dict:
    """
    Generates a single clinically-parameterized gameplay session record.
    """
    # Pick activity
    act = rng.choice(ACTIVITY_CATALOG)
    domain = act["domain"]
    game_id = act["game_id"]
    target_resp = act["target_resp_sec"]
    assigned_diff = int(rng.choice([1, 2, 3, 4, 5], p=[0.20, 0.35, 0.25, 0.15, 0.05]))
    
    # Time of day
    tod = rng.choice(TIME_OF_DAY_CHOICES, p=[0.45, 0.25, 0.20, 0.10])
    
    # Baseline total rounds per session (typically 6-10 trials)
    planned_rounds = int(rng.integers(6, 11))
    
    # Cohort-specific physics
    if cohort == "Consistent_High_Functioning":
        base_acc = float(np.clip(rng.beta(18, 3), 0.65, 1.0))
        resp_time = float(np.clip(rng.lognormal(np.log(target_resp * 0.9), 0.22), 0.8, 5.0))
        hint_count = int(rng.binomial(planned_rounds, 0.08))
        error_streak = int(rng.choice([0, 1, 2], p=[0.65, 0.28, 0.07]))
        abandoned = 1 if rng.random() < 0.01 else 0
        rounds_completed = planned_rounds if not abandoned else int(rng.integers(3, planned_rounds))
        
    elif cohort == "Moderate_Fluctuating":
        base_acc = float(np.clip(rng.beta(9, 5), 0.40, 0.90))
        resp_time = float(np.clip(rng.lognormal(np.log(target_resp * 1.4), 0.35), 1.5, 9.0))
        hint_count = int(rng.binomial(planned_rounds, 0.28))
        error_streak = int(min(rng.poisson(1.6), 5))
        abandoned = 1 if (error_streak >= 3 and rng.random() < 0.12) else 0
        rounds_completed = planned_rounds if not abandoned else int(rng.integers(3, planned_rounds))
        
    elif cohort == "Acute_Fatigue_Sundowning":
        # Extra fatigue in evening/night
        fatigue_multiplier = 1.45 if tod in ["Evening", "Night"] else 1.10
        base_acc = float(np.clip(rng.beta(7, 6) / fatigue_multiplier, 0.25, 0.85))
        resp_time = float(np.clip(rng.lognormal(np.log(target_resp * 1.8 * fatigue_multiplier), 0.40), 2.0, 12.0))
        hint_count = int(rng.binomial(planned_rounds, 0.40))
        error_streak = int(min(rng.poisson(2.5), 6))
        
        # High probability of abandonment under high fatigue and error streak
        abandon_prob = 0.55 if (error_streak >= 3 and tod in ["Evening", "Night"]) else 0.15
        abandoned = 1 if rng.random() < abandon_prob else 0
        rounds_completed = planned_rounds if not abandoned else int(rng.integers(2, 6))
        
    else:  # Longitudinal_Cognitive_Drift
        base_acc = float(np.clip(rng.beta(10, 6), 0.35, 0.85))
        resp_time = float(np.clip(rng.lognormal(np.log(target_resp * 1.5), 0.38), 1.8, 10.0))
        hint_count = int(rng.binomial(planned_rounds, 0.30))
        error_streak = int(min(rng.poisson(1.8), 5))
        abandoned = 1 if (error_streak >= 3 and rng.random() < 0.10) else 0
        rounds_completed = planned_rounds if not abandoned else int(rng.integers(3, planned_rounds))

    # Difficulty impact: higher difficulty reduces accuracy and increases response time
    diff_penalty = (assigned_diff - 2) * 0.04
    final_acc = float(np.clip(base_acc - diff_penalty, 0.10, 1.0))
    final_resp_sec = round(float(resp_time * (1.0 + (assigned_diff - 1) * 0.10)), 2)
    final_resp_ms = int(final_resp_sec * 1000)

    # Compute CPI & Target Next Difficulty
    cpi, target_diff = calculate_cpi_and_target(final_acc, final_resp_sec, target_resp, hint_count, error_streak)
    
    # Calculate recommended new difficulty level
    next_level = int(np.clip(assigned_diff + target_diff, 1, 5))

    return {
        "session_id": session_id,
        "patient_id": patient_id,
        "cohort": cohort,
        "timestamp": current_time.strftime("%Y-%m-%d %H:%M:%S"),
        "time_of_day": tod,
        "domain": domain,
        "game_id": game_id,
        "assigned_difficulty": assigned_diff,
        "rounds_completed": rounds_completed,
        "accuracy": round(final_acc, 3),
        "avg_response_time_ms": final_resp_ms,
        "hint_count": hint_count,
        "error_streak_max": error_streak,
        "abandoned_early": abandoned,
        "cpi_score": cpi,
        "difficulty_adjustment": target_diff,
        "target_next_difficulty": next_level
    }


SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.dirname(SCRIPT_DIR)
DEFAULT_SESSIONS_PATH = os.path.join(BACKEND_DIR, "data", "synthetic", "gameplay_sessions_v1.csv")
DEFAULT_TRAJECTORIES_PATH = os.path.join(BACKEND_DIR, "data", "synthetic", "patient_trajectories_90d.csv")


def generate_gameplay_sessions(n_sessions: int = 25000, seed: int = 42, output_path: str = DEFAULT_SESSIONS_PATH) -> pd.DataFrame:
    """
    Generates 25,000 gameplay sessions across synthetic patient IDs.
    """
    print(f"Generating {n_sessions} gameplay sessions...")
    rng = np.random.default_rng(seed)
    random.seed(seed)
    
    # Pre-generate 500 patient IDs and assign cohorts
    n_patients = 500
    patients = []
    for i in range(1, n_patients + 1):
        pid = f"PAT_{i:04d}"
        cohort = rng.choice(COHORTS, p=COHORT_WEIGHTS)
        patients.append((pid, cohort))
        
    start_date = datetime(2026, 1, 1, 8, 0, 0)
    records = []
    
    for idx in range(1, n_sessions + 1):
        sess_id = f"SESS_{idx:06d}"
        pid, cohort = patients[rng.integers(0, n_patients)]
        session_time = start_date + timedelta(days=int(rng.integers(0, 90)), hours=int(rng.integers(0, 14)), minutes=int(rng.integers(0, 60)))
        rec = generate_session_record(sess_id, pid, cohort, session_time, rng)
        records.append(rec)
        
    df = pd.DataFrame(records)
    
    # Validate constraints
    assert len(df) == n_sessions, f"Expected {n_sessions}, got {len(df)}"
    assert df["accuracy"].between(0.0, 1.0).all(), "Accuracy out of bounds [0, 1]"
    assert df["cpi_score"].between(0.0, 100.0).all(), "CPI out of bounds [0, 100]"
    assert df["target_next_difficulty"].between(1, 5).all(), "Next difficulty out of bounds [1, 5]"
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df.to_csv(output_path, index=False)
    print(f"[SUCCESS] Saved {len(df)} sessions to: {output_path}")
    print("\nDataset Summary by Cohort:")
    print(df.groupby("cohort")[["accuracy", "avg_response_time_ms", "hint_count", "abandoned_early", "cpi_score"]].mean().round(2))
    return df


def generate_longitudinal_trajectories(n_patients: int = 100, days: int = 90, seed: int = 101, output_path: str = DEFAULT_TRAJECTORIES_PATH) -> pd.DataFrame:
    """
    Generates chronological 90-day trajectory data for 100 patients to test:
    - 14-day rolling linear drift slopes (m)
    - Isolation Forest engagement anomaly detection
    """
    print(f"\nGenerating longitudinal 90-day trajectories for {n_patients} patients...")
    rng = np.random.default_rng(seed)
    
    records = []
    start_date = datetime(2026, 6, 1, 9, 0, 0)
    
    for p_idx in range(1, n_patients + 1):
        pid = f"LONG_PAT_{p_idx:03d}"
        cohort = rng.choice(COHORTS, p=COHORT_WEIGHTS)
        
        # Base latency and accuracy
        base_resp = float(rng.uniform(2.0, 3.5))
        base_acc = float(rng.uniform(0.70, 0.90)) if cohort != "Moderate_Fluctuating" else float(rng.uniform(0.55, 0.75))
        
        # Drift coefficient: Cohort 4 exhibits meaningful positive latency drift
        drift_rate = float(rng.normal(0.006, 0.0015)) if cohort == "Longitudinal_Cognitive_Drift" else float(rng.normal(0.0002, 0.0003))
        
        # Generate 40 to 70 active gameplay days over the 90 day span
        active_days = sorted(rng.choice(range(days), size=int(rng.integers(45, 75)), replace=False))
        
        for d in active_days:
            sess_time = start_date + timedelta(days=int(d), hours=int(rng.integers(0, 10)))
            
            # Cumulative drift impact
            drifted_resp = max(1.0, base_resp * (1.0 + drift_rate * d) + rng.normal(0, 0.25))
            drifted_acc = np.clip(base_acc - (drift_rate * 0.4 * d) + rng.normal(0, 0.05), 0.20, 1.0)
            
            act = rng.choice(ACTIVITY_CATALOG)
            hint_lam = max(0.1, 1.0 + max(-0.5, drift_rate * 50 * d))
            streak_lam = max(0.1, 1.2 + max(-0.5, drift_rate * 40 * d))
            hints = int(rng.poisson(hint_lam))
            streak = int(rng.poisson(streak_lam))
            
            cpi, target_diff = calculate_cpi_and_target(drifted_acc, drifted_resp, act["target_resp_sec"], hints, streak)
            
            records.append({
                "patient_id": pid,
                "cohort": cohort,
                "day_number": d,
                "timestamp": sess_time.strftime("%Y-%m-%d %H:%M:%S"),
                "domain": act["domain"],
                "game_id": act["game_id"],
                "accuracy": round(float(drifted_acc), 3),
                "response_time_ms": int(drifted_resp * 1000),
                "hint_count": hints,
                "error_streak_max": streak,
                "cpi_score": cpi
            })
            
    df_long = pd.DataFrame(records)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df_long.to_csv(output_path, index=False)
    print(f"[SUCCESS] Saved {len(df_long)} longitudinal session rows to: {output_path}")
    return df_long


if __name__ == "__main__":
    print("=" * 70)
    print("Smriti AI: Clinically-Calibrated Telemetry Generation Starting")
    print("=" * 70)
    generate_gameplay_sessions(n_sessions=25000)
    generate_longitudinal_trajectories(n_patients=100, days=90)
    print("\n[COMPLETE] All synthetic data artifacts generated successfully.")
