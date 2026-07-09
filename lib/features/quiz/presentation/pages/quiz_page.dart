import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../history/presentation/providers/history_service_provider.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;
  late DateTime _quizStartTime;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the powerhouse of the cell?',
      'options': ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi Apparatus'],
      'correct': 1,
    },
    {
      'question': 'Which element has the chemical symbol "O"?',
      'options': ['Gold', 'Silver', 'Oxygen', 'Iron'],
      'correct': 2,
    },
    {
      'question': 'Who proposed the theory of relativity?',
      'options': ['Isaac Newton', 'Albert Einstein', 'Nikola Tesla', 'Galileo Galilei'],
      'correct': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _quizStartTime = DateTime.now();
  }

  void _handleAnswer(int index) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedAnswer = index;
      if (index == _questions[_currentQuestionIndex]['correct']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      _showResult();
    }
  }

  Future<void> _showResult() async {
    final submissionTime = DateTime.now();
    
    // Automatically record test to history
    await ref.read(historyServiceProvider).logTest(
      testName: 'General Science Quiz',
      start: _quizStartTime,
      submissionTime: submissionTime,
      score: _score.toDouble(),
      totalMarks: _questions.length.toDouble(),
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 80)
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            const Text(
              'Quiz Completed!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Score: $_score / ${_questions.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Quiz'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              question['question'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ).animate().fade().slideX(),
            const SizedBox(height: 40),
            ...List.generate(
              question['options'].length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildOption(index, question['options'][index], question['correct']),
              ),
            ),
            const Spacer(),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(_currentQuestionIndex == _questions.length - 1 ? 'Finish' : 'Next Question'),
              ).animate().fade().scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, String text, int correctIndex) {
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;
    Widget? trailing;

    if (_answered) {
      if (index == correctIndex) {
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
        trailing = const Icon(Icons.check_circle, color: Colors.green);
      } else if (index == _selectedAnswer) {
        borderColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.1);
        trailing = const Icon(Icons.cancel, color: Colors.red);
      }
    } else if (index == _selectedAnswer) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withOpacity(0.05);
    }

    return GestureDetector(
      onTap: () => _handleAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: index == _selectedAnswer ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
