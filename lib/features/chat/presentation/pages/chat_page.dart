import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:study_assistent/core/theme/app_colors.dart';
import 'package:study_assistent/features/chat/presentation/providers/chat_ui_provider.dart';
import 'package:study_assistent/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:study_assistent/features/chat/domain/models/ai_chat_model.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatUIProvider.notifier).sendMessage(text);
      _textController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatUIProvider);
    final isTyping = ref.watch(isTypingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildAnimatedHeader(context, isDark),
          Expanded(
            child: messages.isEmpty ? _buildEmptyState(isDark) : _buildChatList(messages),
          ),
          if (isTyping) _buildTypingIndicator(isDark),
          if (messages.isEmpty) _buildSuggestedPrompts(isDark),
          _buildInputArea(context, isDark),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1E3A8A), const Color(0xFF1E1B4B)]
              : [AppColors.primary, const Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'StudyAI Assistant',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                    onPressed: () => _showClearChatDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2.seconds, color: Colors.white30)
                .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds, curve: Curves.easeInOut),
              const SizedBox(height: 10),
              const Text(
                'How can I help you study today?',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(List<AIChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return ChatBubble(
          message: messages[index],
          onLike: () => ref.read(chatUIProvider.notifier).likeMessage(messages[index].id),
          onDislike: () => ref.read(chatUIProvider.notifier).dislikeMessage(messages[index].id),
          onRegenerate: () => ref.read(chatUIProvider.notifier).sendMessage(messages[index].text),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.forum_rounded, size: 80, color: AppColors.primary.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            'The future of learning is here.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),
          _buildQuickActionCards(isDark),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildQuickActionCards(bool isDark) {
    final actions = [
      {'title': 'Solve Doubts', 'desc': 'Get step-by-step help', 'icon': Icons.help_outline, 'color': Colors.blue},
      {'title': 'Summarize', 'desc': 'Shorten long notes', 'icon': Icons.summarize_outlined, 'color': AppColors.secondary},
      {'title': 'Create Quiz', 'desc': 'Test your knowledge', 'icon': Icons.quiz_outlined, 'color': Colors.orange},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: actions.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 0,
            color: isDark ? AppColors.surfaceDark : Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: (a['color'] as Color).withOpacity(0.2)),
            ),
            child: ListTile(
              leading: Icon(a['icon'] as IconData, color: a['color'] as Color),
              title: Text(a['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(a['desc'] as String, style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () {
                _textController.text = "Can you help me ${a['title']!.toString().toLowerCase()}?";
              },
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSuggestedPrompts(bool isDark) {
    final prompts = [
      'Explain Photosynthesis',
      'Calculus formulas',
      'WW2 key dates',
      'Python loops guide',
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: prompts.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActionChip(
            label: Text(prompts[index], style: const TextStyle(fontSize: 12)),
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              _textController.text = prompts[index];
              _handleSend();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 12),
      child: Row(
        children: [
          const Text('AI is thinking', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8),
          const SizedBox(
            width: 12, height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Type your question...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat?'),
        content: const Text('This will delete all messages in this conversation.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(chatUIProvider.notifier).clearChat();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
