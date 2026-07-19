import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:study_assistent/core/theme/app_colors.dart';
import 'package:study_assistent/features/auth/presentation/providers/auth_provider.dart';
import 'package:study_assistent/features/notes/domain/models/note.dart';
import 'package:study_assistent/features/notes/presentation/providers/notes_provider.dart';

class AddNotePage extends ConsumerStatefulWidget {
  const AddNotePage({super.key});

  @override
  ConsumerState<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends ConsumerState<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _uploadNote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Mocking upload delay
    await Future.delayed(const Duration(seconds: 2));

    final user = ref.read(authControllerProvider).value;
    
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      fileName: _selectedFile!.name,
      fileType: _getFileType(_selectedFile!.extension),
      createdAt: DateTime.now(),
      teacherId: user?.id ?? 'unknown',
      subject: _subjectController.text,
      fileUrl: 'mock_url_for_${_selectedFile!.name}',
    );

    ref.read(teacherNotesProvider.notifier).addNote(newNote);

    if (mounted) {
      setState(() => _isUploading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note uploaded successfully!')),
      );
    }
  }

  NoteFileType _getFileType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf': return NoteFileType.pdf;
      case 'doc':
      case 'docx': return NoteFileType.doc;
      case 'png':
      case 'jpg':
      case 'jpeg': return NoteFileType.image;
      default: return NoteFileType.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Notes'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Note Details',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.secondary,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Note Title',
                  hintText: 'e.g. Organic Chemistry Part 1',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g. Chemistry',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.book_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter a subject' : null,
              ),
              const SizedBox(height: 32),
              Text(
                'Select File',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.secondary,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedFile != null ? AppColors.primary : Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFile != null ? Icons.file_present : Icons.cloud_upload_outlined,
                        size: 48,
                        color: _selectedFile != null ? AppColors.primary : Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFile != null 
                            ? _selectedFile!.name 
                            : 'Tap to select PDF, Docs or Images',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedFile != null ? AppColors.primary : Colors.grey,
                          fontWeight: _selectedFile != null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (_selectedFile != null)
                        Text(
                          '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadNote,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isUploading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Upload to Students', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
