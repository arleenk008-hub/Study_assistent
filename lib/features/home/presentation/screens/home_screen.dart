import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:study_assistent/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildSearchBar(context),
                const SizedBox(height: 30),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryBlue,
                      ),
                ),
                const SizedBox(height: 16),
                _buildQuickActionsGrid(context),
                const SizedBox(height: 30),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryBlue,
                      ),
                ),
                const SizedBox(height: 16),
                _buildRecentActivityList(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Alex!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'What do you want to learn today?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppTheme.primaryPurple),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '2',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search for courses, notes, etc.',
          icon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale();
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {'icon': Icons.chat_bubble_outline, 'label': 'Ask AI', 'color': Colors.blue, 'route': '/chat'},
      {'icon': Icons.note_alt_outlined, 'label': 'Notes', 'color': Colors.orange, 'route': '/notes'},
      {'icon': Icons.quiz_outlined, 'label': 'Quiz', 'color': Colors.green, 'route': '/quiz'},
      {'icon': Icons.library_books_outlined, 'label': 'MCQs', 'color': Colors.purple, 'route': '/mcqs'},
      {'icon': Icons.history_edu_outlined, 'label': 'Papers', 'color': Colors.red, 'route': '/papers'},
      {'icon': Icons.help_outline, 'label': 'Doubts', 'color': Colors.teal, 'route': '/doubts'},
      {'icon': Icons.style_outlined, 'label': 'Flashcards', 'color': Colors.pink, 'route': '/flashcards'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Planner', 'color': Colors.indigo, 'route': '/planner'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: () => context.push(action['route'] as String),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(action['icon'] as IconData, color: action['color'] as Color),
              ),
              const SizedBox(height: 8),
              Text(
                action['label'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (300 + index * 50).ms).scale();
      },
    );
  }

  Widget _buildRecentActivityList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description, color: AppTheme.primaryPurple),
            ),
            title: Text('Calculus Notes #${index + 1}'),
            subtitle: const Text('Last edited 2 hours ago'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ).animate().fadeIn(delay: (600 + index * 100).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryPurple,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'AI Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Library'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}
