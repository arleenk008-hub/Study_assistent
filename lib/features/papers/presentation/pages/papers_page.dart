import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class PapersPage extends StatelessWidget {
  const PapersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final exams = ['JEE', 'NEET', 'UPSC', 'SSC', 'Banking', 'Railway', 'CUET'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Year Papers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: exams.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(exams[i]),
                  onSelected: (val) {},
                  selected: i == 0,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, i) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.description, color: Colors.red),
            title: Text('JEE Main ${2023 - i} Paper - Shift 1'),
            subtitle: const Text('Mathematics, Physics, Chemistry'),
            trailing: IconButton(
              icon: const Icon(Icons.download_for_offline_outlined, color: AppColors.primary),
              onPressed: () {},
            ),
          ),
        ).animate().fade(delay: (i * 50).ms).slideX(),
      ),
    );
  }
}
