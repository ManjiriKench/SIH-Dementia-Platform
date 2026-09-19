"""
safety_circuit.py
=================
The "No Game Today" Agitation & Cognitive Fatigue Safety Circuit for Smriti.

Compassionate interceptor ensuring that cognitive challenges are strictly paused
when patient agitation, exhaustion, or high friction is detected, transitioning
gracefully to non-scored calming connection activities (flute music, photo reminiscence).
"""

AGITATED_MOODS = {"Anxious", "Agitated", "Tired", "Withdrawn", "Irritated", "Restless"}
CALM_MODES = ["Calming_Music", "Photo_Reminiscence", "Caregiver_Chat"]

CALMING_ACTIVITIES = [
    {
        "type": "audio",
        "title": "Borgeet Flute Melody",
        "description": "Gentle traditional bamboo flute tunes designed to reduce sensory overload.",
        "duration_min": 10,
        "asset_url": "assets/audio/calm_flute.mp3"
    },
    {
        "type": "reminiscence",
        "title": "Family Photo Stroll",
        "description": "Non-demanding slideshow of familiar family portraits with gentle ambient music.",
        "duration_min": 8,
        "asset_url": "assets/images/memory_slideshow"
    },
    {
        "type": "caregiver_prompt",
        "title": "Gentle Tea & Walk",
        "description": "Suggestion for caregiver to pause technology and enjoy a warm beverage together.",
        "duration_min": 15
    }
]


class AgitationSafetyCircuit:
    def __init__(self):
        pass

    def evaluate_pre_session_safety(self, caregiver_observed_mood: str) -> dict:
        """
        Evaluates the patient's state prior to initiating cognitive games.
        If caregiver notes agitation or fatigue, the safety circuit triggers immediately.
        """
        if caregiver_observed_mood in AGITATED_MOODS:
            return {
                "allow_cognitive_game": False,
                "recommended_mode": "Gentle_Connection",
                "trigger_type": "pre_session_caregiver_mood",
                "observed_mood": caregiver_observed_mood,
                "suggested_activity": CALMING_ACTIVITIES[0],
                "message": f"Caregiver noted patient feels {caregiver_observed_mood.lower()}. Cognitive games are gently paused today. Enjoy peaceful connection instead.",
                "should_notify_caregiver": False  # Caregiver initiated this
            }
            
        return {
            "allow_cognitive_game": True,
            "recommended_mode": "Cognitive_Engagement",
            "trigger_type": "none",
            "message": "Patient is in a receptive state for gentle cognitive play."
        }

    def evaluate_mid_session_telemetry(self, current_error_streak: int, avg_latency_ms: float, target_latency_sec: float, abandonment_count_today: int = 0) -> dict:
        """
        Monitors ongoing gameplay trials in real-time.
        Triggers graceful session diversion if friction indicates rising agitation or fatigue.
        """
        target_ms = target_latency_sec * 1000.0
        is_latency_spiked = avg_latency_ms > (target_ms * 3.5)
        is_error_streak_high = current_error_streak >= 3
        is_repeated_abandonment = abandonment_count_today >= 2

        if is_repeated_abandonment:
            return {
                "allow_cognitive_game": False,
                "recommended_mode": "Gentle_Connection",
                "trigger_type": "repeated_abandonment",
                "suggested_activity": CALMING_ACTIVITIES[2],
                "message": "Multiple early exits detected today. Pausing challenge to keep interactions joyful and strain-free."
            }

        if is_error_streak_high and is_latency_spiked:
            return {
                "allow_cognitive_game": False,
                "recommended_mode": "Gentle_Connection",
                "trigger_type": "acute_friction_and_fatigue",
                "suggested_activity": CALMING_ACTIVITIES[1],
                "message": "You did wonderfully trying today! Let us take a peaceful break with our family photos."
            }

        return {
            "allow_cognitive_game": True,
            "recommended_mode": "Cognitive_Engagement",
            "trigger_type": "none",
            "message": "Session is progressing smoothly."
        }


# Singleton instance
safety_circuit = AgitationSafetyCircuit()

if __name__ == "__main__":
    print("--- Agitation Safety Circuit Test ---")
    res1 = safety_circuit.evaluate_pre_session_safety("Anxious")
    print("Pre-Session Test (Anxious):", res1["allow_cognitive_game"], "->", res1["message"])
    
    res2 = safety_circuit.evaluate_mid_session_telemetry(current_error_streak=3, avg_latency_ms=9500, target_latency_sec=2.5)
    print("Mid-Session Friction Test:", res2["allow_cognitive_game"], "->", res2["message"])
