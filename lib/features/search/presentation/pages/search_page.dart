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

  @override
  void initState() {
    super.initState();
    _voiceService.init();
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
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Search JEE, NEET, Teachers...',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
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
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickFilters(isDark),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Trending Topics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: _buildResultsList(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(bool isDark) {
    final filters = ['Teachers', 'Notes', 'JEE', 'NEET', 'Courses'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActionChip(
            label: Text(filters[i]),
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            onPressed: () => _searchController.text = filters[i],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(bool isDark) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.search, color: Colors.grey),
          title: Text('Search suggestion for item $index'),
          onTap: () {},
        ).animate().fade(delay: (index * 50).ms);
      },
    );
  }
}
