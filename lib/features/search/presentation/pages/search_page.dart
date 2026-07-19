import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/voice_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _voiceService = VoiceService();
  bool _isListening = false;
  List<Map<String, dynamic>> _filteredCategories = [];

  final List<Map<String, dynamic>> _allCategories = [
    {'icon': Icons.school_rounded, 'label': 'Academics', 'color': Colors.blue},
    {'icon': Icons.code_rounded, 'label': 'Programming & Coding', 'color': Colors.green},
    {'icon': Icons.assignment_rounded, 'label': 'Competitive Exams', 'color': Colors.orange},
    {'icon': Icons.translate_rounded, 'label': 'Languages', 'color': Colors.purple},
    {'icon': Icons.palette_rounded, 'label': 'Design & Creativity', 'color': Colors.pink},
    {'icon': Icons.business_center_rounded, 'label': 'Business & Finance', 'color': Colors.teal},
    {'icon': Icons.music_note_rounded, 'label': 'Music', 'color': Colors.indigo},
    {'icon': Icons.fitness_center_rounded, 'label': 'Health & Fitness', 'color': Colors.red},
    {'icon': Icons.psychology_rounded, 'label': 'AI & Technology', 'color': Colors.cyan},
    {'icon': Icons.auto_stories_rounded, 'label': 'Personal Development', 'color': Colors.amber},
    {'icon': Icons.storage_rounded, 'label': 'Data Science', 'color': Colors.deepOrange},
    {'icon': Icons.security_rounded, 'label': 'Cyber Security', 'color': Colors.blueGrey},
    {'icon': Icons.engineering_rounded, 'label': 'Engineering', 'color': Colors.redAccent},
    {'icon': Icons.medical_services_rounded, 'label': 'Medical Science', 'color': Colors.greenAccent},
    {'icon': Icons.history_edu_rounded, 'label': 'Arts & Humanities', 'color': Colors.brown},
    {'icon': Icons.spa_rounded, 'label': 'Yoga & Meditation', 'color': Colors.lightGreen},
    {'icon': Icons.record_voice_over_rounded, 'label': 'Public Speaking', 'color': Colors.deepPurple},
    {'icon': Icons.edit_note_rounded, 'label': 'Writing & Content', 'color': Colors.blueAccent},
    {'icon': Icons.account_balance_wallet_rounded, 'label': 'Stock Market', 'color': Colors.tealAccent},
    {'icon': Icons.camera_alt_rounded, 'label': 'Photography', 'color': Colors.blueGrey},
    {'icon': Icons.gamepad_rounded, 'label': 'Game Development', 'color': Colors.deepPurpleAccent},
    {'icon': Icons.rocket_launch_rounded, 'label': 'Entrepreneurship', 'color': Colors.orangeAccent},
    {'icon': Icons.language_rounded, 'label': 'Digital Marketing', 'color': Colors.lightBlueAccent},
    {'icon': Icons.biotech_rounded, 'label': 'Science & Research', 'color': Colors.lightBlue},
  ];

  @override
  void initState() {
    super.initState();
    _voiceService.init();
    _filteredCategories = _allCategories;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredCategories = _allCategories
          .where((cat) => cat['label']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _handleVoiceSearch() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _voiceService.startListening((text) {
        setState(() {
          _searchController.text = text;
          _isListening = false;
          _onSearchChanged(text);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Search subjects, teachers...',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 16),
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none, 
              color: _isListening ? Colors.red : AppColors.primary
            ),
            onPressed: _handleVoiceSearch,
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {
              _onSearchChanged(_searchController.text);
              FocusScope.of(context).unfocus();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              children: [
                Text(
                  _searchController.text.isEmpty ? 'Browse All Categories' : 'Search Results',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 22,
                    color: isDark ? Colors.white : AppColors.secondary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.list_rounded, size: 20, color: AppColors.primary.withOpacity(0.5)),
              ],
            ),
          ),
          Expanded(
            child: _filteredCategories.isEmpty 
              ? _buildNoResults(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _filteredCategories[index];
                    return _buildCategoryListItem(cat, isDark, index);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No categories found',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryListItem(Map<String, dynamic> cat, bool isDark, int index) {
    final color = cat['color'] as Color;
    return Container(
      key: ValueKey(cat['label']),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigation or filter logic
          debugPrint('Selected: ${cat['label']}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  cat['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded, 
                size: 14, 
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.3)
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms, delay: (index * 30).ms).slideX(begin: 0.1, end: 0);
  }
}
