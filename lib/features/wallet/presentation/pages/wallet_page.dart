import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/backend_config.dart';
import 'dart:convert';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  int _credits = 0;
  bool _isLoading = true;
  String? _errorMessage;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    try {
      // Check if backend is configured
      if (!BackendConfig().isConfigured) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Backend not configured. Credits feature unavailable.';
        });
        return;
      }

      final endpoint = ApiEndpoints.credits;
      if (endpoint == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Backend configuration error.';
        });
        return;
      }

      final response = await _apiClient.get('$endpoint/balance');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _credits = data['credits'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load credits.';
      });
    }
  }

  Future<void> _watchAd() async {
    // Check if backend is configured
    if (!BackendConfig().isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backend not configured'), backgroundColor: Colors.red),
      );
      return;
    }

    // Simulate watching an ad
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Watching Advertisement...'),
                Text('Reward: 2 Credits', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));
    Navigator.pop(context);

    try {
      final endpoint = ApiEndpoints.credits;
      if (endpoint == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backend configuration error'), backgroundColor: Colors.red),
        );
        return;
      }

      final response = await _apiClient.post('$endpoint/reward-ad', {});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _credits = data['totalCredits']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Congratulations! You earned 2 Credits.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reward credits'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _fetchBalance();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildBalanceCard(),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Earn Credits'),
                      const SizedBox(height: 16),
                      _buildAdRewardCard(),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Buy Credits'),
                      const SizedBox(height: 16),
                      _buildPricingGrid(),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Recent Transactions'),
                      const SizedBox(height: 16),
                      _buildTransactionList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 40),
              const SizedBox(width: 12),
              Text(
                '$_credits',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                ' Credits',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(curve: Curves.easeOutBack);
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAdRewardCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_circle_outline, color: Colors.orange, size: 32),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Watch Ad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Earn 2 Credits per ad', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _watchAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Watch'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildPricingGrid() {
    final packages = [
      {'credits': 50, 'price': '₹49'},
      {'credits': 150, 'price': '₹129'},
      {'credits': 500, 'price': '₹399'},
    ];

    return Row(
      children: packages.map((pkg) {
        return Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Column(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 30),
                    const SizedBox(height: 8),
                    Text('${pkg['credits']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Text('Credits', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Text(
                      pkg['price'] as String,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, i) {
        final txs = [
          {'title': 'Ad Reward', 'date': 'Today', 'amount': '+2', 'color': Colors.green},
          {'title': 'AI Assistant Usage', 'date': 'Yesterday', 'amount': '-1', 'color': Colors.red},
          {'title': 'Ad Reward', 'date': '2 days ago', 'amount': '+2', 'color': Colors.green},
        ];
        final tx = txs[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: (tx['color'] as Color).withOpacity(0.1),
            child: Icon(
              (tx['amount'] as String).startsWith('+') ? Icons.add : Icons.remove,
              color: tx['color'] as Color,
              size: 16,
            ),
          ),
          title: Text(tx['title'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(tx['date'] as String, style: const TextStyle(fontSize: 12)),
          trailing: Text(
            tx['amount'] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: tx['color'] as Color,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}
