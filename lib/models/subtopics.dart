class Subtopic {
  String id;
  String name;
  bool completed;

  Subtopic({
    required this.id,
    required this.name,
    required this.completed,
  });

  factory Subtopic.fromJson(Map<String, dynamic> json) {
    return Subtopic(
      id: json['id'],
      name: json['name'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'completed': completed,
    };
  }
}
