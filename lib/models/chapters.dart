import 'topic.dart';

class Chapter {
  String id;
  String name;
  double minMarks;
  double maxMarks;
  int difficulty; // 1 = easy, 5 = very hard
  List<Topic> topics;

  Chapter({
    required this.id,
    required this.name,
    required this.minMarks,
    required this.maxMarks,
    required this.difficulty,
    required this.topics,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      name: json['name'],
      minMarks: json['minMarks'],
      maxMarks: json['maxMarks'],
      difficulty: json['difficulty'],
      topics: (json['topics'] as List)
          .map((t) => Topic.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minMarks': minMarks,
      'maxMarks': maxMarks,
      'difficulty': difficulty,
      'topics': topics.map((t) => t.toJson()).toList(),
    };
  }
}
