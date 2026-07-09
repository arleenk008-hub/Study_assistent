import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../history/presentation/providers/history_service_provider.dart';

class AssignmentsPage extends ConsumerWidget {
  const AssignmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final assignments = [
      {'title': 'Calculus HW #4', 'subject': 'Maths', 'deadline': 'Tomorrow', 'status': 'Pending'},
      {'title': 'Physics Lab Report', 'subject': 'Physics', 'deadline': 'In 2 days', 'status': 'Started'},
      {'title': 'Organic Compounds', 'subject': 'Chemistry', 'deadline': 'Completed', 'status': 'Submitted'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final item = assignments[index];
          final isSubmitted = item['status'] == 'Submitted';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isSubmitted ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                child: Icon(
                  isSubmitted ? Icons.check_circle_outline : Icons.assignment_outlined,
                  color: isSubmitted ? Colors.green : AppColors.primary,
                ),
              ),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item['subject']} • Deadline: ${item['deadline']}'),
              trailing: ElevatedButton(
                onPressed: isSubmitted ? null : () => _submitAssignment(context, ref, item['title']!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                ),
                child: Text(isSubmitted ? 'Done' : 'Submit'),
              ),
            ),
          ).animate().fade(delay: (index * 100).ms).slideX();
        },
      ),
    );
  }

  void _submitAssignment(BuildContext context, WidgetRef ref, String title) async {
    // Record to history
    await ref.read(historyServiceProvider).logAssignmentActivity(
      assignmentTitle: title,
      status: 'Submitted',
      submissionTime: DateTime.now(),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title submitted successfully!')),
      );
    }
  }
}
