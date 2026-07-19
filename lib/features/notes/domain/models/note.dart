enum NoteFileType { pdf, doc, image, other }

class Note {
  final String id;
  final String title;
  final String? content;
  final String? fileUrl;
  final String? fileName;
  final NoteFileType fileType;
  final DateTime createdAt;
  final List<String> tags;
  final String teacherId;
  final String? subject;

  Note({
    required this.id,
    required this.title,
    this.content,
    this.fileUrl,
    this.fileName,
    required this.fileType,
    required this.createdAt,
    this.tags = const [],
    required this.teacherId,
    this.subject,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileType: _parseFileType(json['fileType']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      tags: List<String>.from(json['tags'] ?? []),
      teacherId: json['teacherId'] ?? '',
      subject: json['subject'],
    );
  }

  static NoteFileType _parseFileType(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf': return NoteFileType.pdf;
      case 'doc':
      case 'docx': return NoteFileType.doc;
      case 'image':
      case 'png':
      case 'jpg':
      case 'jpeg': return NoteFileType.image;
      default: return NoteFileType.other;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileType': fileType.name,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'teacherId': teacherId,
      'subject': subject,
    };
  }
}
