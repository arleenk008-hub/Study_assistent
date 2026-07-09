import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service_factory.dart';
import '../../data/services/auth_service_interface.dart';
import '../../../../core/network/backend_config.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;
  const OTPVerificationPage({super.key, required this.email});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _otpController = TextEditingController();
  late final AuthServiceInterface _authService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthServiceFactory.getAuthService();
  }

  Future<void> _handleVerify() async {
    if (_otpController.text.length < 6) return;

    setState(() => _isLoading = true);
    final result = await _authService.verifyOTP(widget.email, _otpController.text.trim());

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        context.go('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Verification failed'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBackendConfigured = BackendConfig().isConfigured;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Backend Configuration Status
            if (!isBackendConfigured)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  border: Border.all(color: Colors.orange[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Backend not configured. Verification unavailable.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            Text(
              'Enter the OTP sent to',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
            Text(
              widget.email,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _otpController,
              enabled: isBackendConfigured,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (isBackendConfigured && !_isLoading) ? _handleVerify : null,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isBackendConfigured ? 'Verify & Start Learning' : 'Verify (UNAVAILABLE)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
