import 'dart:convert';
import 'unit.dart';

class Subject {
  String id;
  String name;
  List<Unit> units;

  Subject({
    required this.id,
    required this.name,
    required this.units,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      units: (json['units'] as List).map((u) => Unit.fromJson(u)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'units': units.map((u) => u.toJson()).toList(),
    };
  }
}
