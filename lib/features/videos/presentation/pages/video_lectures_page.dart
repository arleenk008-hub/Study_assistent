import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:study_assistent/core/theme/app_colors.dart';
import 'package:study_assistent/features/history/presentation/providers/history_service_provider.dart';

class VideoLecturesPage extends ConsumerWidget {
  const VideoLecturesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> videos = [
      {'title': 'Quantum Mechanics - Part 1', 'duration': '45:00', 'teacher': 'Dr. Satish', 'thumbnail': 'https://img.freepik.com/free-vector/video-player-interface-design_23-2148408990.jpg'},
      {'title': 'Organic Chemistry Basics', 'duration': '32:15', 'teacher': 'Prof. Sharma', 'thumbnail': 'https://img.freepik.com/free-vector/modern-video-player-template_23-2147854617.jpg'},
      {'title': 'Calculus: Integration', 'duration': '58:40', 'teacher': 'Dr. Sarah', 'thumbnail': 'https://img.freepik.com/free-vector/gradient-technological-background_23-2148821966.jpg'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Video Lectures')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _playVideo(context, ref, video['title']),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(video['thumbnail'], height: 180, width: double.infinity, fit: BoxFit.cover),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                          child: Text(video['duration'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(video['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('by ${video['teacher']}', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fade(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }

  void _playVideo(BuildContext context, WidgetRef ref, String title) async {
    // Logic to open video player would go here.
    // For now, we simulate watching and log to history.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing $title... Activity logged to history.')),
    );

    await ref.read(historyServiceProvider).logVideoActivity(
      videoTitle: title,
      watchDuration: const Duration(minutes: 15), // Mocked duration
      completionPercentage: 35.0,
      isCompleted: false,
    );
  }
}
