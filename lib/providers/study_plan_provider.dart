import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class StudyPlanProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> get subjects => _subjects;

  // Load subjects from DB
  Future<void> loadSubjects() async {
    _subjects = await _dbHelper.getSubjects();
    notifyListeners();
  }

  Future<void> addSubject(String name) async {
    await _dbHelper.insertSubject(name);
    await loadSubjects();
  }

  Future<void> updateSubject(int id, String name) async {
    await _dbHelper.updateSubject(id, name);
    await loadSubjects();
  }

  Future<void> deleteSubject(int id) async {
    await _dbHelper.deleteSubject(id);
    await loadSubjects();
  }

  // Similarly add units, chapters, topics handling methods
  // For now, start with subjects, then we can add more
}


  /// Import a small set of sample subjects/units/chapters to help evaluate the app.
  /// This function will only insert sample data if there are no subjects yet.
  Future<void> importSampleData() async {
    final current = await _dbHelper.getSubjects();
    if (current.isNotEmpty) return;
    // A compact sample dataset suited for premedical study (IOM/BPKIHS/CEE style)
    final samples = [
      {
        'name': 'Biology',
        'units': [
          {
            'name': 'Cell Biology',
            'chapters': [
              {'name': 'Cell Structure'},
              {'name': 'Membrane Transport'}
            ]
          },
          {
            'name': 'Genetics',
            'chapters': [
              {'name': 'Mendelian Genetics'},
              {'name': 'Molecular Genetics'}
            ]
          }
        ]
      },
      {
        'name': 'Chemistry',
        'units': [
          {
            'name': 'Physical Chemistry',
            'chapters': [
              {'name': 'Stoichiometry'},
              {'name': 'Thermochemistry'}
            ]
          },
          {
            'name': 'Organic Chemistry',
            'chapters': [
              {'name': 'Functional Groups'},
              {'name': 'Reaction Mechanisms'}
            ]
          }
        ]
      },
      {
        'name': 'Physics',
        'units': [
          {
            'name': 'Mechanics',
            'chapters': [
              {'name': 'Kinematics'},
              {'name': 'Dynamics'}
            ]
          }
        ]
      }
    ];

    for (final subj in samples) {
      int sid = await _dbHelper.insertSubject(subj['name'] as String);
      final units = subj['units'] as List<dynamic>;
      for (final u in units) {
        int uid = await _dbHelper.insertUnit(sid, u['name'] as String);
        final chapters = (u['chapters'] as List<dynamic>);
        for (final c in chapters) {
          await _dbHelper.insertChapter(uid, c['name'] as String, null, null, 2);
        }
      }
    }
    await loadSubjects();
  }
}
