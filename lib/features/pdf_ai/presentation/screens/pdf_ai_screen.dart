import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:study_assistent/core/theme/app_theme.dart';

class PdfAiScreen extends StatefulWidget {
  const PdfAiScreen({super.key});

  @override
  State<PdfAiScreen> createState() => _PdfAiScreenState();
}

class _PdfAiScreenState extends State<PdfAiScreen> {
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
      // Simulate upload
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
        title: const Text('PDF AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildUploadZone(),
            const SizedBox(height: 32),
            if (_selectedFile != null) ...[
              _buildFileDetails(),
              const SizedBox(height: 32),
              _buildAiActions(),
            ] else if (!_isUploading) ...[
              _buildFeatureInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadZone() {
    return GestureDetector(
      onTap: _isUploading ? null : _pickFile,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isUploading)
              const CircularProgressIndicator()
            else ...[
              const Icon(Icons.cloud_upload_outlined, size: 64, color: AppTheme.primaryPurple),
              const SizedBox(height: 16),
              const Text(
                'Upload PDF Document',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Max size: 10MB',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildFileDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildAiActions() {
    final actions = [
      {'icon': Icons.summarize_outlined, 'label': 'Summarize', 'color': Colors.blue},
      {'icon': Icons.quiz_outlined, 'label': 'Generate Quiz', 'color': Colors.orange},
      {'icon': Icons.note_add_outlined, 'label': 'Generate Notes', 'color': Colors.green},
      {'icon': Icons.question_answer_outlined, 'label': 'Ask Questions', 'color': Colors.purple},
    ];

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Container(
            decoration: BoxDecoration(
              color: (action['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action['icon'] as IconData, color: action['color'] as Color),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: TextStyle(
                      color: action['color'] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (index * 100).ms).scale();
        },
      ),
    );
  }

  Widget _buildFeatureInfo() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildInfoItem(Icons.auto_awesome, 'AI analysis of any PDF content'),
        _buildInfoItem(Icons.lightbulb_outline, 'Extract key concepts instantly'),
        _buildInfoItem(Icons.translate, 'Translate PDF to any language'),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryPurple),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}
