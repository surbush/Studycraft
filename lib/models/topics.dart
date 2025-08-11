import 'subtopics.dart';

class Topic {
  String id;
  String name;
  bool completed;
  List<Subtopic> subtopics;

  Topic({
    required this.id,
    required this.name,
    required this.completed,
    required this.subtopics,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      name: json['name'],
      completed: json['completed'],
      subtopics: (json['subtopics'] as List)
          .map((s) => Subtopic.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'completed': completed,
      'subtopics': subtopics.map((s) => s.toJson()).toList(),
    };
  }
}
