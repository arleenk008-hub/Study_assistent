import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _categoryController = ScrollController();

  void _scrollCategories(bool forward) {
    final double offset = _categoryController.offset + (forward ? 200 : -200);
    _categoryController.animateTo(
      offset.clamp(0.0, _categoryController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Categories', onSeeAll: () => context.push('/search')),
                  const SizedBox(height: 16),
                  _buildCategoriesWithScroll(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Live Classes', onSeeAll: () {}),
                  const SizedBox(height: 16),
                  _buildLiveClasses(context),
                  const SizedBox(height: 24),
                  _buildAIPromptCard(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Popular Teachers', onSeeAll: () => context.push('/search?filter=teachers')),
                  const SizedBox(height: 16),
                  _buildPopularTeachers(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Recent Notes', onSeeAll: () => context.push('/notes')),
                  const SizedBox(height: 16),
                  _buildRecentLearningList(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text('Ask AI', style: TextStyle(color: Colors.white)),
      ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, Aman!', 
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.secondary,
                    ),
                  ),
                  Text(
                    'Let\'s smash today\'s goals!', 
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => context.push('/notifications'), 
                icon: Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white : AppColors.secondary),
              ),
              IconButton(
                onPressed: () => context.push('/settings'), 
                icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : AppColors.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => context.push('/search'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 55,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              'Search courses, notes, teachers...', 
              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {required VoidCallback onSeeAll}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title, 
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.secondary,
          ),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }

  Widget _buildCategoriesWithScroll() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildCategories(context),
        Positioned(
          left: 0,
          child: _scrollButton(false),
        ),
        Positioned(
          right: 0,
          child: _scrollButton(true),
        ),
      ],
    );
  }

  Widget _scrollButton(bool forward) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(forward ? Icons.arrow_forward_ios : Icons.arrow_back_ios, size: 16),
        onPressed: () => _scrollCategories(forward),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 110,
      child: ListView.builder(
        controller: _categoryController,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: () => context.push('/search?category=${categories[i]['label']}'),
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 120,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: (categories[i]['color'] as Color).withOpacity(0.1),
                    child: Icon(categories[i]['icon'] as IconData, color: categories[i]['color'] as Color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categories[i]['label'] as String, 
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fade(delay: (i * 100).ms).slideX(),
      ),
    );
  }

  Widget _buildLiveClasses(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, i) => Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage('https://img.freepik.com/free-vector/digital-technology-background-with-abstract-geometric-shapes_1017-26615.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter, 
                end: Alignment.bottomCenter, 
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                  child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Advanced Physics: Quantum Mechanics', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Text(
                  'By Dr. Satish Kumar', 
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularTeachers(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, i) => InkWell(
          onTap: () => context.push('/teacher/T$i'),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=teacher'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Teacher ${i + 1}', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 13,
                    color: isDark ? Colors.white : AppColors.secondary,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    Text(
                      ' 4.9', 
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIPromptCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFF2D2B52), Color(0xFF3F3D56)]),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Revision Plan', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 4),
                Text(
                  'Get a personalized study schedule based on your performance.', 
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => context.push('/chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Generate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLearningList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, i) => Container(
          width: 200,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white, 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
              const Spacer(),
              Text(
                'Organic Chemistry...', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ), 
                maxLines: 1,
              ),
              Text(
                'Handwritten Notes', 
                style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 11),
              ),
              const SizedBox(height: 4),
              const Text(
                '₹199', 
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
