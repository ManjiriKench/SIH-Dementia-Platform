import os
import json
from flask import Flask, jsonify, request
from flask_cors import CORS

from ai.adaptive_engine import dade_engine
from ai.safety_circuit import safety_circuit
from ai.memory_compiler import memory_compiler
from ai.session_recorder import session_recorder

app = Flask(__name__)
CORS(app)

BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
REGISTRY_PATH = os.path.join(BACKEND_DIR, "data", "activity_registry.json")


@app.route("/")
def home():
    return jsonify({
        "status": "success",
        "message": "Dementia Assist backend is running",
        "ai_engine": "DADE & Safety Circuit Active"
    })


@app.route("/api/ai/activities", methods=["GET"])
def get_activities():
    """Returns the standardized 14-activity catalog across the 6 domains."""
    if os.path.exists(REGISTRY_PATH):
        with open(REGISTRY_PATH, "r", encoding="utf-8") as f:
            data = json.load(f)
        return jsonify({"status": "success", "data": data})
    return jsonify({"status": "error", "message": "Activity registry not found"}), 404


@app.route("/api/ai/evaluate-difficulty", methods=["POST"])
def evaluate_difficulty():
    """Evaluates session telemetry using the DADE LightGBM model."""
    telemetry = request.get_json() or {}
    result = dade_engine.evaluate_session(telemetry)
    return jsonify({"status": "success", "evaluation": result})


@app.route("/api/ai/safety-check", methods=["POST"])
def check_safety():
    """Evaluates pre-session caregiver mood or in-session behavioral friction."""
    payload = request.get_json() or {}
    if "caregiver_mood" in payload:
        result = safety_circuit.evaluate_pre_session_safety(payload["caregiver_mood"])
    else:
        streak = payload.get("error_streak", 0)
        latency = payload.get("avg_latency_ms", 2500)
        target = payload.get("target_latency_sec", 2.5)
        abandonments = payload.get("abandonment_count", 0)
        result = safety_circuit.evaluate_mid_session_telemetry(streak, latency, target, abandonments)
    return jsonify({"status": "success", "safety": result})


@app.route("/api/ai/compile-memory-game", methods=["POST"])
def compile_memory_game():
    """Compiles caregiver memories into a playable cognitive activity."""
    payload = request.get_json() or {}
    game_type = payload.get("game_type", "face_name_recall")
    difficulty = payload.get("difficulty", 2)
    
    if game_type == "face_name_recall":
        people = payload.get("familiar_people", [])
        trial = memory_compiler.compile_face_recall_game(people, difficulty)
    elif game_type == "routine_sequencing":
        routines = payload.get("daily_routines", None)
        trial = memory_compiler.compile_routine_sequencing_game(routines, difficulty)
    else:
        items = payload.get("familiar_items", None)
        trial = memory_compiler.compile_memory_match_game(items, difficulty)
        
    return jsonify({"status": "success", "trial": trial})


@app.route("/api/ai/sync-session", methods=["POST"])
def sync_session():
    """Ingests full 18-parameter session telemetry from mobile and saves <session_id>.json on laptop."""
    telemetry = request.get_json() or {}
    saved_record = session_recorder.record_and_save_session(telemetry)
    return jsonify({
        "status": "success",
        "message": f"Session persisted to backend/data/sessions/{saved_record['session_id']}.json",
        "session": saved_record
    })


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
