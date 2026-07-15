import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_assistent/core/theme/app_colors.dart';
import 'package:study_assistent/features/history/presentation/providers/history_service_provider.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildNoteCard(context, ref, index, isDark);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Log note creation
          await ref.read(historyServiceProvider).logNoteActivity(
            noteTitle: 'New Note ${DateTime.now().millisecond}',
            action: 'Created',
          );
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New note created and logged to history!')),
            );
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, WidgetRef ref, int index, bool isDark) {
    final titles = [
      'Organic Chemistry Basics',
      'Calculus - Integration',
      'Modern History - WW2',
      'Data Structures in Java',
      'Economic Policies'
    ];
    
    final title = titles[index % titles.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          // Log opening note
          await ref.read(historyServiceProvider).logNoteActivity(
            noteTitle: title,
            action: 'Opened',
          );
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opened $title. Activity logged.')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Icon(Icons.more_horiz),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Last edited: ${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTag('Chemistry', Colors.blue),
                  const SizedBox(width: 8),
                  _buildTag('Science', Colors.purple),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
