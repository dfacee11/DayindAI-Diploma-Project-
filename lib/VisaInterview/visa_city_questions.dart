
class VisaCityQuestions {
  static List<String> get({required String cityId, required String type}) {
    if (cityId == 'astana') {
      return type == 'returner' ? _astanaReturner : _astanaFirstTime;
    }
    return type == 'returner' ? _almatyReturner : _almatyFirstTime;
  }

  static const _astanaFirstTime = [
    "Where will you work and as what position?",
    "Where are you studying and what is your major?",
    "What is your GPA? Are you happy with it?",
    "Do you have a hobby? Tell me about it.",
    "Have you been abroad before? Where did you go?",
    "Why did you choose this state for Work and Travel?",
    "What do you know about the state you are going to?",
    "What are your responsibilities at your workplace?",
    "What is your purpose of visiting the USA?",
    "What are your future career goals?",
    "Do you know your rights as a J-1 visa holder?",
    "What languages do you speak or learn?",
    "What will you do after returning from the USA?",
    "Where do your parents live? What do they do?",
    "Do you have relatives or friends in the USA?",
    "What is your favorite subject at university?",
    "When will you graduate?",
    "Tell me about your region or city.",
    "What other places do you want to visit in the US?",
    "What do you do in your leisure time?",
    "What kind of music do you listen to?",
    "What is your favorite movie?",
    "Are you a sportsman? What sport do you play?",
    "Where do you want to work in the future after graduation?",
    "How will this Work and Travel experience affect your future career?",
    "What did you do last summer?",
    "Which university do you attend and why did you choose it?",
  ];

  static const _astanaReturner = [
    "You participated in Work and Travel before. Where did you work?",
    "What did you enjoy most about your previous W&T experience?",
    "Did you travel after your program ended? Where did you go?",
    "Did you return home on time after your previous program?",
    "What will be different this time compared to your last visit?",
    "Where will you work this time and in what position?",
    "Why do you want to participate again?",
    "What did you learn from your last W&T experience?",
    "Did you have any issues with your previous employer?",
    "How has your previous W&T experience helped your career or studies?",
    "What do you plan to do differently this time?",
    "Have you stayed in touch with anyone from your previous program?",
  ];

  static const _almatyFirstTime = [
    "Where do you study and what is your major?",
    "Where are you going in the US?",
    "What is your position at work?",
    "What are your responsibilities?",
    "Did you work before? Tell me about your experience.",
    "What are your plans for the future?",
    "What will you do after graduation?",
    "Why do you want to go to the USA?",
    "Tell me about the Work and Travel program.",
    "What is your GPA?",
    "What are your career goals?",
    "What did you do last summer?",
    "Which year of study are you in?",
    "Why did you choose this speciality?",
    "Why did you choose this university?",
    "What will you do after returning from America?",
    "Do you have family or friends in the USA?",
    "What does your father or mother do for a living?",
    "What is your favorite film?",
    "What will be your job this summer?",
    "Tell me about your university.",
    "What kind of job do you want to find in the future?",
  ];

  static const _almatyReturner = [
    "This is not your first Work and Travel. Where did you work last time?",
    "Did you come back on time after your last program?",
    "What was the best part of your previous experience?",
    "Where will you work this time?",
    "Why are you participating again?",
    "What will be different this time?",
    "Did you have any problems during your last trip?",
    "How did your previous W&T experience change you?",
  ];
}