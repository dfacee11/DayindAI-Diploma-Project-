import 'dart:math';

enum VisaCity { astana, almaty }

const _astanaQuestions = [
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
  "Have you participated in Work and Travel before?",
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

const _almatyQuestions = [
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
  "Is this your first time participating in Work and Travel?",
  "What is your favorite film?",
  "What will be your job this summer?",
  "Tell me about your university.",
  "What kind of job do you want to find in the future?",
];

extension VisaCityExt on VisaCity {
  String get displayName => this == VisaCity.astana ? "Астана" : "Алматы";
  String get flag        => this == VisaCity.astana ? "🏛️" : "🏔️";
  int    get minQ        => this == VisaCity.astana ? 6 : 3;
  int    get maxQ        => this == VisaCity.astana ? 9 : 5;

  List<String> get allQuestions =>
      this == VisaCity.astana ? _astanaQuestions : _almatyQuestions;

  List<String> getRandomQuestions() {
    final rng   = Random();
    final count = minQ + rng.nextInt(maxQ - minQ + 1);
    final list  = List<String>.from(allQuestions)..shuffle(rng);
    return list.take(count).toList();
  }
}