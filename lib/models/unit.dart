import 'chapters.dart';

class Unit {
  String id;
  String name;
  List<Chapter> chapters;

  Unit({
    required this.id,
    required this.name,
    required this.chapters,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      name: json['name'],
      chapters: (json['chapters'] as List)
          .map((c) => Chapter.fromJson(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'chapters': chapters.map((c) => c.toJson()).toList(),
    };
  }
}
