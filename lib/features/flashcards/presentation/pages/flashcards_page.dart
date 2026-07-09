import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../../core/theme/app_colors.dart';
import '../../history/presentation/providers/history_service_provider.dart';

class FlashcardsPage extends ConsumerStatefulWidget {
  const FlashcardsPage({super.key});

  @override
  ConsumerState<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends ConsumerState<FlashcardsPage> {
  bool _isFlipped = false;
  int _currentIndex = 0;
  late DateTime _sessionStartTime;

  final List<Map<String, String>> _flashcards = [
    {'question': 'What is Photosynthesis?', 'answer': 'Process by which plants convert light energy into chemical energy.'},
    {'question': 'Newton\'s First Law', 'answer': 'An object stays at rest or in motion unless acted upon by a force.'},
    {'question': 'Capital of France', 'answer': 'Paris'},
  ];

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
      _isFlipped = false;
    });

    // If it's the last card, log the session
    if (_currentIndex == 0) {
      _logFlashcardSession();
    }
  }

  Future<void> _logFlashcardSession() async {
    await ref.read(historyServiceProvider).logNoteActivity(
      noteTitle: 'Flashcards Revision',
      action: 'Completed session of ${_flashcards.length} cards',
      startTime: _sessionStartTime,
      endTime: DateTime.now(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revision session saved to history!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _flashcards.length,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
            const SizedBox(height: 40),
            Text(
              'Card ${_currentIndex + 1} of ${_flashcards.length}',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isFlipped = !_isFlipped),
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: _isFlipped ? 180 : 0),
                  builder: (context, double value, child) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(value * 3.1415927 / 180),
                      alignment: Alignment.center,
                      child: value < 90
                          ? _buildCardSide('Question', _flashcards[_currentIndex]['question']!, AppColors.primary)
                          : Transform(
                              transform: Matrix4.identity()..rotateY(3.1415927),
                              alignment: Alignment.center,
                              child: _buildCardSide('Answer', _flashcards[_currentIndex]['answer']!, AppColors.secondary),
                            ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _nextCard,
                child: Text(_currentIndex == _flashcards.length - 1 ? 'Finish Session' : 'Next Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide(String title, String content, Color color) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 30,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
      borderGradient: LinearGradient(colors: [color.withOpacity(0.5), color.withOpacity(0.2)]),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 24),
            Text(content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
