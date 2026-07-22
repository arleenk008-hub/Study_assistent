import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_assistent/core/theme/app_colors.dart';
import 'package:study_assistent/features/auth/presentation/providers/auth_provider.dart';

class StudentEditProfilePage extends ConsumerStatefulWidget {
  const StudentEditProfilePage({super.key});

  @override
  ConsumerState<StudentEditProfilePage> createState() => _StudentEditProfilePageState();
}

class _StudentEditProfilePageState extends ConsumerState<StudentEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final updatedUser = user.copyWith(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    try {
      await ref.read(authControllerProvider.notifier).updateProfile(updatedUser);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
