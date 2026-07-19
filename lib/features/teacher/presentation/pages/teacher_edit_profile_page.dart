import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_assistent/core/theme/app_colors.dart';
import 'package:study_assistent/features/auth/domain/models/user_model.dart';
import 'package:study_assistent/features/auth/presentation/providers/auth_provider.dart';

class TeacherEditProfilePage extends ConsumerStatefulWidget {
  const TeacherEditProfilePage({super.key});

  @override
  ConsumerState<TeacherEditProfilePage> createState() => _TeacherEditProfilePageState();
}

class _TeacherEditProfilePageState extends ConsumerState<TeacherEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _qualificationController;
  late TextEditingController _experienceController;
  late TextEditingController _bioController;
  
  // Pricing controllers
  late TextEditingController _chatPriceController;
  late TextEditingController _audioPriceController;
  late TextEditingController _livePriceController;
  late TextEditingController _oneToOnePriceController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    final metadata = user?.metadata ?? {};
    final pricing = metadata['pricing'] ?? {};

    _nameController = TextEditingController(text: user?.name);
    _qualificationController = TextEditingController(text: metadata['qualification']);
    _experienceController = TextEditingController(text: metadata['experience']?.toString());
    _bioController = TextEditingController(text: metadata['bio']);
    
    _chatPriceController = TextEditingController(text: pricing['chat']?.toString());
    _audioPriceController = TextEditingController(text: pricing['audioCall']?.toString());
    _livePriceController = TextEditingController(text: pricing['liveClass']?.toString());
    _oneToOnePriceController = TextEditingController(text: pricing['oneToOne']?.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _chatPriceController.dispose();
    _audioPriceController.dispose();
    _livePriceController.dispose();
    _oneToOnePriceController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final updatedUser = user.copyWith(
      name: _nameController.text,
      metadata: {
        ...user.metadata ?? {},
        'qualification': _qualificationController.text,
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'bio': _bioController.text,
        'pricing': {
          'chat': double.tryParse(_chatPriceController.text) ?? 0.0,
          'audioCall': double.tryParse(_audioPriceController.text) ?? 0.0,
          'liveClass': double.tryParse(_livePriceController.text) ?? 0.0,
          'oneToOne': double.tryParse(_oneToOnePriceController.text) ?? 0.0,
        }
      },
    );

    await ref.read(authControllerProvider.notifier).updateProfile(updatedUser);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            const Text('Basic Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            _buildField(_nameController, 'Display Name', Icons.person_outline),
            const SizedBox(height: 16),
            _buildField(_qualificationController, 'Qualification', Icons.school_outlined),
            const SizedBox(height: 16),
            _buildField(_experienceController, 'Experience (Years)', Icons.work_outline, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildField(_bioController, 'Professional Bio', Icons.description_outlined, maxLines: 3),
            const SizedBox(height: 32),
            const Text('Service Pricing (₹)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildField(_chatPriceController, 'Chat Fee', Icons.chat_outlined, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildField(_audioPriceController, 'Audio Call', Icons.call_outlined, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildField(_livePriceController, 'Live Class', Icons.videocam_outlined, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildField(_oneToOnePriceController, '1:1 Session', Icons.person_add_outlined, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, size: 20),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
