/// Central voice script library for all 8 SMRITI activities.
/// Used by Guide Mode to auto-narrate every step without the patient needing to tap.
class ActivityVoiceScripts {
  ActivityVoiceScripts._();

  // FAMILY MATCH & TELL
  static const familyMatchIntro = [
    'Let us play a warm family game together.',
    'Touch any card to turn it over. When you find a matching pair, I will share something beautiful about them.',
    'Take all the time you need. There is no hurry at all.',
  ];
  static const familyMatchFirstFlip =
      'A family card is here. Look carefully. Do you recognise them?';
  static String familyMatchOnMatch(String name) =>
      'Wonderful! You found $name. What a beautiful memory.';
  static String familyMatchFamiliarVoice(String name, String snippet) =>
      'A warm message from $name. $snippet';
  static const familyMatchNoMatch =
      'Not quite this time — but that is perfectly fine. Let us try again gently.';
  static const familyMatchHint =
      'Here is a gentle clue. Look at this card carefully.';
  static const familyMatchRound1Complete = [
    'You did it! You found every pair in the first round.',
    'Shall we try one more gentle round with another family member?',
  ];
  static const familyMatchComplete = [
    'You matched everyone today. What a wonderful memory.',
    'Thank you for sharing this warm journey through your family.',
  ];

  // LOOK & TALK
  static const lookAndTalkIntro = [
    'Let us look at some cherished photographs together.',
    'There are no right or wrong things to say. Just share whatever feels warm.',
    'I will read each memory prompt aloud for you.',
  ];
  static String lookAndTalkPhotoAppeared(String title) =>
      'Look at this photograph — $title. Take a peaceful moment together.';
  static String lookAndTalkSpeakPrompt(String prompt) => prompt;
  static const lookAndTalkBetweenPhotos =
      'What a lovely memory. When you are ready, let us look at the next one.';
  static const lookAndTalkAutoAdvance =
      'Let us gently move to the next photograph now.';
  static const lookAndTalkComplete = [
    'What a beautiful collection of memories today.',
    'Thank you for this peaceful, lovely time together.',
  ];

  // MUSIC & MEMORY
  static const musicAndMemoryIntro = [
    'Let us listen to some gentle, familiar melodies today.',
    'Just sit back and let the music carry you somewhere warm.',
    'I will share a gentle thought with each song.',
  ];
  static String musicAndMemorySongStarted(String songTitle) =>
      'Now listening to $songTitle. Close your eyes if you like.';
  static String musicAndMemoryPrompt(String prompt) => prompt;
  static const musicAndMemoryBetweenSongs =
      'What a lovely melody. Shall we listen to another one together?';
  static const musicAndMemoryComplete = [
    'What a beautiful musical journey today.',
    'Thank you for listening with me.',
  ];

  // REMEMBER & RECALL
  static const rememberRecallIntro = [
    'Let us play a gentle memory game with some familiar things.',
    'First, I will show you some objects to look at carefully.',
    'Take all the time you need — there is absolutely no rush.',
  ];
  static const rememberRecallMemorizePhase =
      'Look at these familiar things. Remember as many as you can. Take all the time you need.';
  static const rememberRecallRecallPhase =
      'Now, can you touch each thing you remember seeing? Do not worry if you miss some.';
  static String rememberRecallItemSelected(String name) =>
      'Yes! You remembered $name. Wonderful.';
  static const rememberRecallRoundComplete = [
    'Beautiful! You remembered so well.',
    'Let us try one more gentle round together.',
  ];
  static const rememberRecallComplete = [
    'You did a wonderful job remembering today.',
    'What a lovely, peaceful activity.',
  ];

  // BUILD THE DAY TOGETHER
  static const buildTheDayIntro = [
    'Let us arrange your beautiful day together.',
    'Can you put your daily activities in order from morning to evening?',
    'Tap on any card to move it. We will do this gently, together.',
  ];
  static const buildTheDayHint =
      'Think about what you do first thing in the morning. What is the very first step of your day?';
  static const buildTheDayCorrect = 'Yes! That is exactly right. Well done.';
  static const buildTheDayComplete = [
    'Perfect! Your beautiful day is arranged just right.',
    'Morning chai, quiet walks, and peaceful evenings — what a lovely routine.',
  ];

  // FAMILIAR OBJECT MATCH
  static const familiarObjectMatchIntro = [
    'Let us match some familiar things from your world.',
    'I will show you an object, and you find its matching pair.',
    'Touch the one that looks the same. Take all the time you like.',
  ];
  static const familiarObjectMatchCorrect = 'That is right! A perfect match.';
  static const familiarObjectMatchGentle =
      'That one does not quite match. Let us try another one gently.';
  static const familiarObjectMatchComplete = [
    'You matched every object today. How wonderful!',
    'What a lovely collection of familiar things.',
  ];

  // STORY FROM PHOTO
  static const storyFromPhotoIntro = [
    'Let us look at some beautiful photographs and share the stories they hold.',
    'You can say anything that comes to mind — a feeling, a name, a memory.',
    'Whatever you share is precious. There is no right or wrong way.',
  ];
  static String storyFromPhotoPrompt(String prompt) => prompt;
  static const storyFromPhotoEncouragement =
      'What a lovely thought. Every memory you share is so precious.';
  static const storyFromPhotoComplete = [
    'What beautiful stories you have shared today.',
    'Thank you for trusting me with these precious memories.',
  ];

  // ONBOARDING NARRATION
  static const onboardingPart1Intro = [
    'Welcome. I will guide you through setting up a gentle, personal profile.',
    'You can type your answers, or simply use the microphone to speak them.',
  ];
  static const onboardingPart1Name =
      'First, what is your loved one\'s name? You can type or use the mic.';
  static const onboardingPart1Age = 'What age range fits them best?';
  static const onboardingPart1Relationship =
      'And what is your relationship to them?';
  static const onboardingPart1Hometown =
      'Where do they call home? Their hometown or the place they grew up.';
  static const onboardingPart2Intro = [
    'Now let us talk about what your loved one enjoys.',
    'These preferences help us choose activities that feel comfortable and familiar.',
  ];
  static const onboardingPart2Music =
      'What kinds of music do they love? Choose as many as feel right.';
  static const onboardingPart2Calming =
      'What brings them comfort and peace? These will be woven into every activity.';
  static const onboardingPart3Intro = [
    'Almost done! Now let us capture their daily rhythm.',
    'Knowing their routine helps us suggest activities at the right time of day.',
  ];
  static const onboardingPart3Routine =
      'What does their day usually look like? Morning chai, afternoon walks, evening prayers?';
  static const onboardingComplete = [
    'Wonderful! The profile is all set.',
    'We are ready to create a joyful, personal experience just for your loved one.',
  ];

  // TODAY'S JOURNEY NARRATION
  static String todaysJourneyGreeting(String name) =>
      'Good day, $name. I am right here with you. Let us see what today holds for us.';
  static String todaysJourneyRecommendation(String activityTitle) =>
      'Today we have a lovely activity — $activityTitle. Whenever you are ready, touch the big button and we will begin together.';
  static const todaysJourneyNoGame =
      'Today, let us take a gentle rest. Some soothing music or cherished photographs — no games today. Just peace and warmth.';

  // ACTIVITY COMPLETION NARRATION
  static String completionGreeting(String activityTitle) =>
      'You did a wonderful job with $activityTitle today. What a peaceful, beautiful time.';
  static const completionFollowUp =
      'Your progress is saved safely. Rest whenever you are ready. There is no rush.';
  static const completionEncouragement =
      'Every moment you spend here is filled with warmth. You are truly doing beautifully.';
}
