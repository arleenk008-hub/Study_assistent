import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:study_assistent/core/theme/app_theme.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  bool _isFlipped = false;
  int _currentIndex = 0;

  final List<Map<String, String>> _flashcards = [
    {'question': 'What is Photosynthesis?', 'answer': 'The process by which green plants and some other organisms use sunlight to synthesize foods from carbon dioxide and water.'},
    {'question': 'What is the speed of light?', 'answer': 'Approximately 299,792,458 meters per second.'},
    {'question': 'Who wrote "Romeo and Juliet"?', 'answer': 'William Shakespeare.'},
  ];

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
      _isFlipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Card ${_currentIndex + 1}/${_flashcards.length}',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GestureDetector(
                onTap: _flipCard,
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: _isFlipped ? 180 : 0),
                  builder: (context, double value, child) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(value * 3.14159 / 180),
                      alignment: Alignment.center,
                      child: value < 90
                          ? _buildCardSide(
                              title: 'Question',
                              content: _flashcards[_currentIndex]['question']!,
                              color: Colors.white,
                              textColor: Colors.black,
                            )
                          : Transform(
                              transform: Matrix4.identity()..rotateY(3.14159),
                              alignment: Alignment.center,
                              child: _buildCardSide(
                                title: 'Answer',
                                content: _flashcards[_currentIndex]['answer']!,
                                color: AppTheme.primaryPurple,
                                textColor: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.close, Colors.red, 'Hard'),
                _buildActionButton(Icons.check, Colors.green, 'Easy'),
              ],
            ),
            const SizedBox(height: 40),
            TextButton.icon(
              onPressed: _nextCard,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Card'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide({
    required String title,
    required String content,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Icon(Icons.touch_app, color: textColor.withOpacity(0.3)),
          const SizedBox(height: 8),
          Text(
            'Tap to flip',
            style: TextStyle(color: textColor.withOpacity(0.3), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    ).animate().scale();
  }
}
