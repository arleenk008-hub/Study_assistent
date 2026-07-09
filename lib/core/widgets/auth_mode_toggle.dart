import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_mode_provider.dart';

/// Widget to toggle between mock and real authentication
/// Great for testing and debugging
class AuthModeToggle extends ConsumerWidget {
  final VoidCallback? onModeChanged;

  const AuthModeToggle({super.key, this.onModeChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authMode = ref.watch(authModeProvider);
    final notifier = ref.read(authModeProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border.all(color: Colors.blue[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  authMode == AuthMode.mock ? Icons.bug_report : Icons.cloud,
                  color: authMode == AuthMode.mock ? Colors.orange : Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Authentication Mode',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        authMode == AuthMode.mock
                            ? 'Testing with local mock data'
                            : 'Using real backend server',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: authMode == AuthMode.backend
                      ? null
                      : () async {
                          await notifier.useBackend();
                          onModeChanged?.call();
                        },
                  icon: const Icon(Icons.cloud),
                  label: const Text('Backend'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: authMode == AuthMode.backend
                          ? Colors.blue
                          : Colors.grey[300]!,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: authMode == AuthMode.mock
                      ? null
                      : () async {
                          await notifier.useMock();
                          onModeChanged?.call();
                        },
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Mock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        authMode == AuthMode.mock ? Colors.orange : Colors.grey[300],
                    foregroundColor: authMode == AuthMode.mock ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Debug panel showing info about mock auth
class MockAuthDebugPanel extends ConsumerWidget {
  const MockAuthDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authMode = ref.watch(authModeProvider);

    if (authMode != AuthMode.mock) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mock Mode Active',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '📝 Test Account:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Email: test@example.com',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
                Text(
                  'Password: password123',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  '🔐 OTP: 123456',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  'All user data is stored locally on your device.',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
