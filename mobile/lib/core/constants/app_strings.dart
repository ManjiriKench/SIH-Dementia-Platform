/// Multilingual string dictionaries supporting English, Hindi, and Assamese.
class AppStrings {
  AppStrings._();

  static String currentLanguage = 'en'; // 'en', 'hi', 'as'

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Dementia Assist',
      'tagline': 'Gentle connection & daily cognitive joy',
      'role_caregiver': 'I am a Caregiver',
      'role_patient': 'Continue as Patient',
      'offline_note': 'Works completely offline. Activity data stays private.',
      'caregiver_present_q': 'Is a caregiver with you right now?',
      'yes_together': 'Yes, we are together',
      'no_independent': 'No, independent session',
      'todays_journey': "Today's Gentle Journey",
      'daily_greeting': 'Welcome back. Let us spend a peaceful moment together.',
      'spoken_help': 'Listen to instruction',
      'pause': 'Pause',
      'resume': 'Resume',
      'take_time': "That's okay. We can take our time.",
      'gentle_success': 'Wonderful effort today!',
      'together_mode': 'Together Mode',
      'hint_for_caregiver': 'Caregiver Prompt Guide',
      'voice_feedback_prompt': 'Tap microphone to speak your observation',
      'non_medical_disclaimer': 'These are supportive engagement trends, not a medical diagnosis or staging assessment.',
      'domain_memory': 'Remember',
      'domain_attention': 'Notice',
      'domain_language': 'Talk',
      'domain_executive': 'Plan & Sort',
      'domain_orientation': 'Today & Places',
      'domain_visuospatial': 'Explore & Match',
      'cg_domain_memory': 'Memory & Recognition',
      'cg_domain_attention': 'Attention & Focus',
      'cg_domain_language': 'Language & Communication',
      'cg_domain_executive': 'Executive Function',
      'cg_domain_orientation': 'Orientation & Context',
      'cg_domain_visuospatial': 'Visuospatial Skills',
    },
    'hi': {
      'app_title': 'स्मृति साथी',
      'tagline': 'सद्भाव, अपनत्व और दैनिक संज्ञान सहयोग',
      'role_caregiver': 'मैं देखभालकर्ता (केयरगिवर) हूँ',
      'role_patient': 'मरीज के रूप में आगे बढ़ें',
      'offline_note': 'बिना इंटरनेट के भी पूर्णतः सुरक्षित चलता है।',
      'caregiver_present_q': 'क्या देखभालकर्ता अभी आपके साथ हैं?',
      'yes_together': 'हाँ, हम साथ हैं',
      'no_independent': 'नहीं, अकेले कर रहे हैं',
      'todays_journey': 'आज का शांत सफर',
      'daily_greeting': 'नमस्ते! आइए मिलकर कुछ सुखद पल बिताएं।',
      'spoken_help': 'निर्देश सुनें',
      'pause': 'विराम',
      'resume': 'पुनः शुरू करें',
      'take_time': 'कोई जल्दी नहीं है, आराम से करें।',
      'gentle_success': 'बहुत सुंदर प्रयास!',
      'together_mode': 'साथ-साथ मोड',
      'hint_for_caregiver': 'केयरगिवर संकेत मार्गदर्शिका',
      'voice_feedback_prompt': 'माइक दबाकर अपनी बात रिकॉर्ड करें',
      'non_medical_disclaimer': 'यह केवल दैनिक गतिविधि और जुड़ाव का ब्योरा है, कोई चिकित्सकीय निदान नहीं।',
      'domain_memory': 'याद रखें',
      'domain_attention': 'ध्यान दें',
      'domain_language': 'बातचीत',
      'domain_executive': 'क्रम और व्यवस्था',
      'domain_orientation': 'आज का दिन और स्थान',
      'domain_visuospatial': 'मिलान और पहचान',
      'cg_domain_memory': 'स्मृति और पहचान',
      'cg_domain_attention': 'ध्यान और एकाग्रता',
      'cg_domain_language': 'भाषा और संवाद',
      'cg_domain_executive': 'कार्यकारी क्षमता',
      'cg_domain_orientation': 'समय व स्थान बोध',
      'cg_domain_visuospatial': 'दृश्य-स्थानिक कौशल',
    },
    'as': {
      'app_title': 'স্মৃতি সংগী',
      'tagline': 'মৰমৰ সান্নিধ্য আৰু দৈনন্দিন মানসিক সঁহাৰি',
      'role_caregiver': 'মই এজন শুশ্ৰূষাকাৰী (Caregiver)',
      'role_patient': 'অংশগ্ৰহণকাৰী হিচাপে আৰম্ভ কৰক',
      'offline_note': 'ইণ্টাৰনেট অবিহনে সম্পূৰ্ণ কাম কৰে। সকলো তথ্য নিজৰ ডিভাইচতে সুৰক্ষিত।',
      'caregiver_present_q': 'শুশ্ৰূষাকাৰী আপোনাৰ লগত উপস্থিত আছেনে?',
      'yes_together': 'হয়, আমি একেলগে আছোঁ',
      'no_independent': 'নহয়, অকলেই কৰিম',
      'todays_journey': 'আজিৰ শান্ত যাত্ৰা',
      'daily_greeting': 'স্বাগতম! আহক আমি একেলগে কেইটামান শান্তিপূৰ্ণ মুহূৰ্ত কটাওঁ।',
      'spoken_help': 'নিৰ্দেশনা শুনক',
      'pause': 'ৰওক',
      'resume': 'পুনৰ আৰম্ভ কৰক',
      'take_time': 'কোনো খৰখেদা নাই, শান্তভাৱে কৰক।',
      'gentle_success': 'বৰ সুন্দৰ প্ৰয়াস!',
      'together_mode': 'একত্ৰে খেলাৰ সুবিধা',
      'hint_for_caregiver': 'শুশ্ৰূষাকাৰীৰ বাবে সহায়ক ইঙ্গিত',
      'voice_feedback_prompt': 'কথা ক\'বলৈ মাইক্ৰ\'ফন স্পৰ্শ কৰক',
      'non_medical_disclaimer': 'এইয়া কেৱল দৈনন্দিন সঁহাৰি আৰু সংযোগৰ তথ্য, কোনো চিকিৎসাজনিত পৰীক্ষা নহয়।',
      'domain_memory': 'মনত পেলাওক',
      'domain_attention': 'মনোযোগ দিয়ক',
      'domain_language': 'কথোপকথন',
      'domain_executive': 'সজাই তোলক',
      'domain_orientation': 'আজিৰ দিন আৰু পৰিৱেশ',
      'domain_visuospatial': 'আকৃতি আৰু সন্ধান',
      'cg_domain_memory': 'স্মৃতি আৰু চিনাক্তকৰণ',
      'cg_domain_attention': 'মনোযোগ আৰু দৃষ্টি',
      'cg_domain_language': 'ভাষা আৰু যোগাযোগ',
      'cg_domain_executive': 'কাৰ্য্যকৰী ক্ষমতা',
      'cg_domain_orientation': 'সময় আৰু স্থানবোধ',
      'cg_domain_visuospatial': 'স্থান আৰু দৃশ্যগত দক্ষতা',
    },
  };

  static String get(String key) {
    return _localizedValues[currentLanguage]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static void setLanguage(String langCode) {
    if (_localizedValues.containsKey(langCode)) {
      currentLanguage = langCode;
    }
  }
}
