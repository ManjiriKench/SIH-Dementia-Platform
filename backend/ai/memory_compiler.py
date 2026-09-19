"""
memory_compiler.py
==================
Caregiver Personal Memory Bank Procedural Game Compiler for Smriti.

Converts raw caregiver uploads (family members, household routines, sacred places)
into playable, personalized cognitive activities (Face-Name Recall, Routine Ordering, Memory Match).
"""

import random
from typing import List, Dict, Any

CULTURAL_SYNTHETIC_NAMES = [
    "Meera", "Arup", "Nagen", "Pranita", "Bonti", "Bhaben", 
    "Devi", "Gautam", "Jyoti", "Hitesh", "Ananya", "Ramen"
]

CULTURAL_SYNTHETIC_ROUTINES = [
    {"step": 1, "task": "Wake up & wash face", "icon": "sunrise"},
    {"step": 2, "task": "Morning Assam tea", "icon": "cup"},
    {"step": 3, "task": "Blood pressure medicine", "icon": "pill"},
    {"step": 4, "task": "Water courtyard garden", "icon": "plant"},
    {"step": 5, "task": "Read morning newspaper", "icon": "book"},
    {"step": 6, "task": "Afternoon gentle rest", "icon": "bed"}
]


class PersonalMemoryCompiler:
    def __init__(self, seed: int = None):
        self.rng = random.Random(seed)

    def compile_face_recall_game(self, familiar_people: List[Dict[str, Any]], difficulty: int = 2) -> Dict[str, Any]:
        """
        Synthesizes a Face-Name association trial round.
        Options count scales with difficulty:
        - Level 1: 2 choices
        - Level 2: 3 choices
        - Level 3+: 4 choices
        """
        if not familiar_people:
            # Fallback mock person if none uploaded yet
            familiar_people = [{
                "person_id": "p_default",
                "name": "Meera",
                "relation": "Granddaughter",
                "photo_url": "assets/images/default_granddaughter.jpg",
                "audio_hint": "assets/audio/meera_voice.aac"
            }]

        target = self.rng.choice(familiar_people)
        correct_name = target["name"]
        
        # Number of choice options based on difficulty
        num_options = 2 if difficulty <= 1 else (3 if difficulty == 2 else 4)
        
        # Collect distractors from other people or synthetic names
        other_names = [p["name"] for p in familiar_people if p["name"] != correct_name]
        distractors = self.rng.sample(other_names, min(len(other_names), num_options - 1))
        
        # If not enough family members, backfill from cultural synthetic names
        while len(distractors) < num_options - 1:
            syn = self.rng.choice(CULTURAL_SYNTHETIC_NAMES)
            if syn != correct_name and syn not in distractors:
                distractors.append(syn)
                
        options = distractors + [correct_name]
        self.rng.shuffle(options)
        
        return {
            "game_type": "face_name_recall",
            "domain": "Memory",
            "difficulty": difficulty,
            "target_person_id": target.get("person_id", "p1"),
            "target_photo_url": target.get("photo_url", ""),
            "correct_name": correct_name,
            "relationship_tag": target.get("relation", "Family"),
            "audio_hint": target.get("audio_hint", ""),
            "options": options,
            "correct_index": options.index(correct_name)
        }

    def compile_routine_sequencing_game(self, daily_routines: List[Dict[str, Any]] = None, difficulty: int = 2) -> Dict[str, Any]:
        """
        Synthesizes a chronological routine sequencing puzzle.
        - Level 1-2: 3 steps
        - Level 3-4: 4 steps
        - Level 5: 5 steps
        """
        pool = daily_routines if (daily_routines and len(daily_routines) >= 3) else CULTURAL_SYNTHETIC_ROUTINES
        
        num_steps = 3 if difficulty <= 2 else (4 if difficulty <= 4 else 5)
        num_steps = min(num_steps, len(pool))
        
        # Select chronological slice
        selected_steps = sorted(pool[:num_steps], key=lambda x: x.get("step", 1))
        ground_truth_order = [s["task"] for s in selected_steps]
        
        # Shuffle for presentation
        shuffled_cards = list(selected_steps)
        self.rng.shuffle(shuffled_cards)
        
        return {
            "game_type": "routine_sequencing",
            "domain": "Executive_Function",
            "difficulty": difficulty,
            "num_steps": num_steps,
            "ground_truth_order": ground_truth_order,
            "shuffled_cards": shuffled_cards
        }

    def compile_memory_match_game(self, familiar_items: List[Dict[str, Any]] = None, difficulty: int = 2) -> Dict[str, Any]:
        """
        Synthesizes a card-flip memory match grid using familiar caregiver photos.
        - Level 1: 4 cards (2 pairs)
        - Level 2: 6 cards (3 pairs)
        - Level 3+: 8 cards (4 pairs)
        """
        num_pairs = 2 if difficulty <= 1 else (3 if difficulty == 2 else 4)
        
        if not familiar_items or len(familiar_items) < num_pairs:
            # Fallback items
            familiar_items = [
                {"id": "item_tea", "title": "Assam Tea Cup", "image_url": "assets/images/tea_cup.png"},
                {"id": "item_courtyard", "title": "Courtyard Well", "image_url": "assets/images/well.png"},
                {"id": "item_glasses", "title": "Reading Glasses", "image_url": "assets/images/glasses.png"},
                {"id": "item_gamusa", "title": "Traditional Gamusa", "image_url": "assets/images/gamusa.png"},
            ]
            
        chosen_items = self.rng.sample(familiar_items, num_pairs)
        
        # Create matching pair deck
        deck = []
        for item in chosen_items:
            deck.append({"card_id": f"{item['id']}_a", "pair_key": item['id'], "title": item['title'], "image_url": item['image_url']})
            deck.append({"card_id": f"{item['id']}_b", "pair_key": item['id'], "title": item['title'], "image_url": item['image_url']})
            
        self.rng.shuffle(deck)
        
        return {
            "game_type": "familiar_memory_match",
            "domain": "Memory",
            "difficulty": difficulty,
            "total_cards": len(deck),
            "total_pairs": num_pairs,
            "cards": deck
        }


# Singleton compiler instance
memory_compiler = PersonalMemoryCompiler()

if __name__ == "__main__":
    print("--- Testing Personal Memory Bank Compiler ---")
    mock_people = [
        {"person_id": "p1", "name": "Meera", "relation": "Granddaughter", "photo_url": "meera.jpg"},
        {"person_id": "p2", "name": "Arup", "relation": "Son", "photo_url": "arup.jpg"}
    ]
    face_round = memory_compiler.compile_face_recall_game(mock_people, difficulty=2)
    print("Face Recall Round:", face_round["correct_name"], "Options:", face_round["options"])
    
    routine_round = memory_compiler.compile_routine_sequencing_game(difficulty=2)
    print("Routine Sequencing Ground Truth:", routine_round["ground_truth_order"])
