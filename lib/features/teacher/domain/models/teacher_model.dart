class TeacherProfile {
  final String id;
  final String userId;
  final String name;
  final String qualification;
  final int experience;
  final List<String> subjects;
  final String bio;
  final List<String> languages;
  final Map<String, List<String>> availability;
  final TeacherPricing pricing;
  final double averageRating;
  final int totalReviews;
  final String? profilePicture;
  final List<TeacherReview> reviews;

  TeacherProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.qualification,
    required this.experience,
    required this.subjects,
    required this.bio,
    required this.languages,
    required this.availability,
    required this.pricing,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.profilePicture,
    this.reviews = const [],
  });

  factory TeacherProfile.mock() {
    return TeacherProfile(
      id: 't1',
      userId: 'u1',
      name: 'Dr. Sarah Wilson',
      qualification: 'PhD in Mathematics',
      experience: 12,
      subjects: ['Calculus', 'Algebra', 'Statistics'],
      bio: 'Helping students master complex mathematical concepts for over a decade.',
      languages: ['English', 'Spanish'],
      availability: {'Mon': ['10:00 AM', '02:00 PM'], 'Wed': ['11:00 AM']},
      pricing: TeacherPricing(chat: 10, audioCall: 25, liveClass: 50, oneToOne: 120),
      averageRating: 4.9,
      totalReviews: 156,
      profilePicture: 'https://i.pravatar.cc/150?u=sarah',
      reviews: [
        TeacherReview(
          studentName: 'Aman Deep',
          rating: 5,
          comment: 'Excellent teaching style!',
          date: DateTime.now().subtract(const Duration(days: 2)),
        )
      ],
    );
  }
}

class TeacherPricing {
  final double chat;
  final double audioCall;
  final double liveClass;
  final double oneToOne;

  TeacherPricing({
    required this.chat,
    required this.audioCall,
    required this.liveClass,
    required this.oneToOne,
  });
}

class TeacherReview {
  final String studentName;
  final double rating;
  final String comment;
  final DateTime date;

  TeacherReview({
    required this.studentName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
