import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/voice_service.dart';

class SearchPage extends StatefulWidget {
  final String? initialCategory;
  const SearchPage({super.key, this.initialCategory});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _voiceService = VoiceService();
  bool _isListening = false;
  List<Map<String, dynamic>> _filteredCategories = [];
  String? _selectedMainCategory;

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
  ];

  @override
  void initState() {
    super.initState();
    _voiceService.init();
    _filteredCategories = _allCategories;
    
    if (widget.initialCategory != null) {
      _selectedMainCategory = widget.initialCategory;
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
          decoration: const InputDecoration(
            hintText: 'Search subjects, teachers...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: AppColors.primary),
            onPressed: _handleVoiceSearch,
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_selectedMainCategory != null) {
            setState(() => _selectedMainCategory = null);
            return false;
          }
          return true;
        },
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(child: _buildMainContent(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_selectedMainCategory != null)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _selectedMainCategory = null),
            ),
          Text(
            _selectedMainCategory ?? 'Categories',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDark) {
    if (_selectedMainCategory == 'Academics') {
      return _buildGroupedList(isDark, {
        'Schooling': ['Pre-Nursery', 'Nursery', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th', '5th'],
        'High School': ['6th', '7th', '8th', '9th', '10th', '+1', '+2'],
        'Higher Education': ['Diploma', 'Degree', 'Masters', 'PhD'],
      }, Icons.book_outlined, Colors.blue);
    } else if (_selectedMainCategory == 'Programming & Coding') {
      return _buildGroupedList(isDark, {
        'Languages': ['C Programming', 'Java', 'Python', 'C++', 'JavaScript', 'Kotlin', 'Dart', 'Swift (iOS)'],
        'Web & Frontend': ['HTML', 'CSS', 'React', 'Node.js', 'Web Development'],
        'Mobile & Backend': ['Flutter', 'Android Development', 'iOS Development', 'Firebase', 'APIs'],
        'Data & Tools': ['SQL & Databases', 'AI & Machine Learning', 'Data Science', 'Git & GitHub', 'DSA'],
        'Advanced': ['DevOps', 'Docker', 'Competitive Programming', 'Software Testing (QA)', 'System Design'],
      }, Icons.code_rounded, Colors.green);
    } else {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredCategories.length,
        itemBuilder: (context, index) => _buildCategoryItem(_filteredCategories[index], isDark),
      );
    }
  }

  Widget _buildGroupedList(bool isDark, Map<String, List<String>> groups, IconData icon, Color color) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: groups.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Text(entry.key.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ),
            ...entry.value.map((item) => _buildListItem(item, isDark, icon, color)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildListItem(String title, bool isDark, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: () {},
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> cat, bool isDark) {
    final label = cat['label'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(cat['icon'] as IconData, color: cat['color'] as Color),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => setState(() => _selectedMainCategory = label),
      ),
    );
  }

  void _onSearchChanged(String q) {
    setState(() => _filteredCategories = _allCategories.where((c) => c['label'].toString().toLowerCase().contains(q.toLowerCase())).toList());
  }

  void _handleVoiceSearch() async {}
}
