"""
export_sample_session_jsons.py
==============================
Generates sample session JSON files in backend/data/sessions/
illustrating how the 18 telemetry parameters route into each AI model.

Run this script to immediately populate and inspect JSON files on your laptop.
"""

import os
import sys

# Ensure backend root is on sys.path
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.dirname(SCRIPT_DIR)
if BACKEND_DIR not in sys.path:
    sys.path.insert(0, BACKEND_DIR)

from ai.session_recorder import session_recorder

SAMPLE_SESSIONS = [
    {
        "session_id": "SESS_0001_HIGH_PERFORMER",
        "patient_id": "PAT_001_ASHA",
        "cohort": "Consistent_High_Functioning",
        "timestamp": "2026-09-16 09:30:00",
        "time_of_day": "Morning",
        "domain": "Memory",
        "game_id": "act_mem_face_recall",
        "interaction_mode": "Cognitive_Together",
        "assigned_difficulty": 2,
        "rounds_completed": 8,
        "accuracy": 0.90,
        "avg_response_time_ms": 1850,
        "hint_count": 0,
        "error_streak_max": 1,
        "abandoned_early": 0,
        "caregiver_observed_mood": "Engaged"
    },
    {
        "session_id": "SESS_0002_STRUGGLING",
        "patient_id": "PAT_001_ASHA",
        "cohort": "Moderate_Fluctuating",
        "timestamp": "2026-09-16 14:15:00",
        "time_of_day": "Afternoon",
        "domain": "Executive_Function",
        "game_id": "act_exec_routine_order",
        "interaction_mode": "Independent",
        "assigned_difficulty": 3,
        "rounds_completed": 6,
        "accuracy": 0.45,
        "avg_response_time_ms": 5200,
        "hint_count": 3,
        "error_streak_max": 3,
        "abandoned_early": 0,
        "caregiver_observed_mood": "Calm"
    },
    {
        "session_id": "SESS_0003_AGITATION_PRE_CIRCUIT",
        "patient_id": "PAT_001_ASHA",
        "cohort": "Acute_Fatigue_Sundowning",
        "timestamp": "2026-09-16 18:45:00",
        "time_of_day": "Evening",
        "domain": "Orientation",
        "game_id": "act_ori_morning_night_sort",
        "interaction_mode": "Together_Mode",
        "assigned_difficulty": 2,
        "rounds_completed": 2,
        "accuracy": 0.50,
        "avg_response_time_ms": 4800,
        "hint_count": 1,
        "error_streak_max": 2,
        "abandoned_early": 1,
        "caregiver_observed_mood": "Anxious"
    },
    {
        "session_id": "SESS_0004_MID_SESSION_FATIGUE",
        "patient_id": "PAT_001_ASHA",
        "cohort": "Acute_Fatigue_Sundowning",
        "timestamp": "2026-09-16 20:10:00",
        "time_of_day": "Night",
        "domain": "Attention",
        "game_id": "act_att_odd_one_out",
        "interaction_mode": "Independent",
        "assigned_difficulty": 2,
        "rounds_completed": 4,
        "accuracy": 0.35,
        "avg_response_time_ms": 9400,
        "hint_count": 4,
        "error_streak_max": 4,
        "abandoned_early": 1,
        "caregiver_observed_mood": "Tired"
    }
]


def export_all():
    print("=" * 65)
    print("Smriti AI: Exporting Sample Session JSON Files to Laptop Directory")
    print("=" * 65)
    
    saved_paths = []
    for sample in SAMPLE_SESSIONS:
        result = session_recorder.record_and_save_session(sample)
        saved_paths.append(result["session_id"])
        print(f"[+] Created: backend/data/sessions/{result['session_id']}.json")
        print(f"    |-- CPI Score: {result['cpi_score']} | Adjustment: {result['difficulty_adjustment']} | Allow Game: {result['model_routing_breakdown']['model_2_safety_circuit']['outputs_generated']['allow_cognitive_game']}")
        
    print("\n[SUCCESS] All session JSON files created successfully in:")
    print(session_recorder.output_dir)


if __name__ == "__main__":
    export_all()
