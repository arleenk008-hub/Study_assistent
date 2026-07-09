import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class PdfAiPage extends StatefulWidget {
  const PdfAiPage({super.key});

  @override
  State<PdfAiPage> createState() => _PdfAiPageState();
}

class _PdfAiPageState extends State<PdfAiPage> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _isUploading = true;
      });
      
      // Simulate upload/processing
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _selectedFile = result.files.first;
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI PDF Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedFile == null) _buildUploadPlaceholder() else _buildFileDetails(),
            const SizedBox(height: 32),
            if (_selectedFile != null) ...[
              Text(
                'AI Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                icon: Icons.summarize_outlined,
                title: 'Summarize PDF',
                subtitle: 'Get a concise summary of the entire document.',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.quiz_outlined,
                title: 'Generate Quiz',
                subtitle: 'Create MCQs and questions from this PDF.',
                color: Colors.purple,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.lightbulb_outline,
                title: 'Key Concepts',
                subtitle: 'Extract important formulas and definitions.',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.chat_bubble_outline,
                title: 'Chat with PDF',
                subtitle: 'Ask specific questions about the content.',
                color: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isUploading
              ? const CircularProgressIndicator()
              : const Icon(Icons.picture_as_pdf, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            _isUploading ? 'Analyzing Document...' : 'Upload PDF to Start',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text('Drag & drop or click to browse', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          if (!_isUploading)
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.add),
              label: const Text('Select PDF'),
            ),
        ],
      ).animate().fade().scale(),
    );
  }

  Widget _buildFileDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFile!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _selectedFile = null),
          ),
        ],
      ),
    ).animate().slideX();
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    ).animate().fade().slideY(begin: 0.1, end: 0);
  }
}
