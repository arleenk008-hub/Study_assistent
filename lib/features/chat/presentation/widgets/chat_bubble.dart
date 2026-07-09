import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:study_assistent/core/theme/app_colors.dart';
import '../../domain/models/ai_chat_model.dart'; // Corrected relative path

class ChatBubble extends StatelessWidget {
  final AIChatMessage message;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onRegenerate;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onLike,
    required this.onDislike,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isAI = message.role == ChatRole.assistant;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAI) _buildAIAvatar(),
              const SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAI
                        ? (isDark ? AppColors.surfaceDark : Colors.grey[100])
                        : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isAI ? 4 : 20),
                      bottomRight: Radius.circular(isAI ? 20 : 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isAI
                              ? (isDark ? Colors.white : AppColors.textPrimary)
                              : Colors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('hh:mm a').format(message.timestamp),
                        style: TextStyle(
                          color: isAI ? Colors.grey : Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isAI) ...[
                const SizedBox(width: 12),
                _buildUserAvatar(),
              ],
            ],
          ),
          if (isAI) _buildAIActionButtons(context),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAIAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
    );
  }

  Widget _buildUserAvatar() {
    return const CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey,
      child: Icon(Icons.person, color: Colors.white, size: 18),
    );
  }

  Widget _buildAIActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 8),
      child: Row(
        children: [
          _IconButton(
            icon: Icons.copy_rounded,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
          _IconButton(
            icon: Icons.refresh_rounded,
            onPressed: onRegenerate,
          ),
          const SizedBox(width: 8),
          _IconButton(
            icon: message.isLiked ? Icons.thumb_up_alt : Icons.thumb_up_off_alt,
            color: message.isLiked ? AppColors.primary : null,
            onPressed: onLike,
          ),
          _IconButton(
            icon: message.isDisliked ? Icons.thumb_down_alt : Icons.thumb_down_off_alt,
            color: message.isDisliked ? Colors.red : null,
            onPressed: onDislike,
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _IconButton({required this.icon, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18, color: color ?? Colors.grey),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
