"""
test_ai_pipeline.py
===================
Automated test suite verifying the AI/ML pipeline for Smriti.
"""

import os
import json
import pytest
from app import app
from ai.adaptive_engine import dade_engine
from ai.safety_circuit import safety_circuit
from ai.memory_compiler import memory_compiler
from ai.session_recorder import session_recorder


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_home_endpoint(client):
    res = client.get("/")
    assert res.status_code == 200
    data = res.get_json()
    assert data["status"] == "success"
    assert "DADE" in data.get("ai_engine", "")


def test_activity_registry_endpoint(client):
    res = client.get("/api/ai/activities")
    assert res.status_code == 200
    data = res.get_json()
    assert data["status"] == "success"
    assert data["data"]["total_activities"] == 14
    assert len(data["data"]["domains"]) == 6


def test_dade_engine_step_up():
    telemetry = {
        "accuracy": 0.90,
        "avg_response_time_ms": 1800,
        "hint_count": 0,
        "error_streak_max": 0,
        "assigned_difficulty": 2,
        "rounds_completed": 10,
        "target_resp_sec": 2.5
    }
    result = dade_engine.evaluate_session(telemetry)
    assert result["cpi_score"] >= 75.0
    assert result["difficulty_adjustment"] == 1
    assert result["recommended_difficulty"] == 3
    assert "Advancing" in result["clinical_reasoning"]


def test_dade_engine_step_down():
    telemetry = {
        "accuracy": 0.40,
        "avg_response_time_ms": 5500,
        "hint_count": 3,
        "error_streak_max": 3,
        "assigned_difficulty": 3,
        "rounds_completed": 6,
        "target_resp_sec": 2.5
    }
    result = dade_engine.evaluate_session(telemetry)
    assert result["cpi_score"] < 50.0
    assert result["difficulty_adjustment"] == -1
    assert result["recommended_difficulty"] == 2
    assert "Simplifying" in result["clinical_reasoning"]


def test_safety_circuit_pre_session_agitation():
    result = safety_circuit.evaluate_pre_session_safety("Anxious")
    assert result["allow_cognitive_game"] is False
    assert result["recommended_mode"] == "Gentle_Connection"
    assert "suggested_activity" in result


def test_safety_circuit_mid_session_friction():
    result = safety_circuit.evaluate_mid_session_telemetry(
        current_error_streak=3,
        avg_latency_ms=9500,
        target_latency_sec=2.5
    )
    assert result["allow_cognitive_game"] is False
    assert result["recommended_mode"] == "Gentle_Connection"


def test_memory_compiler_face_recall():
    people = [
        {"name": "Meera", "relation": "Granddaughter"},
        {"name": "Arup", "relation": "Son"}
    ]
    trial = memory_compiler.compile_face_recall_game(people, difficulty=2)
    assert trial["game_type"] == "face_name_recall"
    assert trial["correct_name"] in [p["name"] for p in people]
    assert len(trial["options"]) == 3
    assert trial["correct_name"] in trial["options"]


def test_memory_compiler_routine_sequencing():
    trial = memory_compiler.compile_routine_sequencing_game(difficulty=2)
    assert trial["game_type"] == "routine_sequencing"
    assert trial["num_steps"] == 3
    assert len(trial["ground_truth_order"]) == 3
    assert len(trial["shuffled_cards"]) == 3


def test_session_sync_endpoint(client):
    telemetry = {
        "session_id": "SESS_TEST_PYTEST_SYNC",
        "patient_id": "PAT_PYTEST",
        "accuracy": 0.85,
        "avg_response_time_ms": 2000,
        "assigned_difficulty": 2,
        "rounds_completed": 8,
        "caregiver_observed_mood": "Engaged"
    }
    res = client.post("/api/ai/sync-session", json=telemetry)
    assert res.status_code == 200
    data = res.get_json()
    assert data["status"] == "success"
    
    # Check that file exists on laptop disk
    expected_file = os.path.join(session_recorder.output_dir, "SESS_TEST_PYTEST_SYNC.json")
    assert os.path.exists(expected_file)
    with open(expected_file, "r", encoding="utf-8") as f:
        content = json.load(f)
    assert content["session_id"] == "SESS_TEST_PYTEST_SYNC"
    assert "model_routing_breakdown" in content
    if os.path.exists(expected_file):
        os.remove(expected_file)

