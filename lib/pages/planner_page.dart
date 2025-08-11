import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final DBHelper db = DBHelper();

  List<Map<String, dynamic>> subjects = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => loading = true);

    subjects = await db.getSubjects();

    // For each subject, load units, chapters, topics nested
    for (var subject in subjects) {
      final units = await db.getUnits(subject['id']);
      subject['units'] = units;

      for (var unit in units) {
        final chapters = await db.getChapters(unit['id']);
        unit['chapters'] = chapters;

        for (var chapter in chapters) {
          final topics = await db.getTopics(chapter['id']);
          chapter['topics'] = topics;
        }
      }
    }

    setState(() => loading = false);
  }

  // Dialog to add/edit Subject, Unit, Chapter, Topic
  Future<String?> _showTextInputDialog({
    required String title,
    required String label,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(labelText: label),
          controller: controller,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
  }

  // Dialog for Chapter details: marks range & difficulty
  Future<Map<String, dynamic>?> _showChapterDetailsDialog({
    String? initialName,
    double? initialMinMarks,
    double? initialMaxMarks,
    int? initialDifficulty,
  }) async {
    final nameController = TextEditingController(text: initialName ?? '');
    final minController = TextEditingController(text: initialMinMarks?.toString() ?? '');
    final maxController = TextEditingController(text: initialMaxMarks?.toString() ?? '');
    int difficulty = initialDifficulty ?? 3;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(initialName == null ? 'Add Chapter' : 'Edit Chapter'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Chapter Name'),
                  ),
                  TextField(
                    controller: minController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min Marks (optional)'),
                  ),
                  TextField(
                    controller: maxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max Marks (optional)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Difficulty:'),
                      Expanded(
                        child: Slider(
                          value: difficulty.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: difficulty.toString(),
                          onChanged: (val) => setState(() => difficulty = val.round()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final minMarks = double.tryParse(minController.text.trim());
                  final maxMarks = double.tryParse(maxController.text.trim());
                  if (name.isEmpty) return;
                  Navigator.pop(context, {
                    'name': name,
                    'minMarks': minMarks,
                    'maxMarks': maxMarks,
                    'difficulty': difficulty,
                  });
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  // Dialog for Topic importance and completion
  Future<Map<String, dynamic>?> _showTopicDetailsDialog({
    String? initialName,
    int? initialImportance,
    bool? initialCompleted,
  }) async {
    final nameController = TextEditingController(text: initialName ?? '');
    int importance = initialImportance ?? 2;
    bool completed = initialCompleted ?? false;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(initialName == null ? 'Add Topic' : 'Edit Topic'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Topic Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: importance,
                  decoration: const InputDecoration(labelText: 'Importance'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Low')),
                    DropdownMenuItem(value: 2, child: Text('Medium')),
                    DropdownMenuItem(value: 3, child: Text('High')),
                  ],
                  onChanged: (val) => setState(() => importance = val ?? 2),
                ),
                Row(
                  children: [
                    const Text('Completed:'),
                    Checkbox(
                      value: completed,
                      onChanged: (val) => setState(() => completed = val ?? false),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(context, {
                    'name': name,
                    'importance': importance,
                    'completed': completed,
                  });
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  // Add Subject
  Future<void> _addSubject() async {
    final name = await _showTextInputDialog(title: 'Add Subject', label: 'Subject Name');
    if (name == null || name.isEmpty) return;

    await db.insertSubject(name);
    await _loadSubjects();
  }

  // Add Unit
  Future<void> _addUnit(Map<String, dynamic> subject) async {
    final name = await _showTextInputDialog(title: 'Add Unit', label: 'Unit Name');
    if (name == null || name.isEmpty) return;

    await db.insertUnit(subject['id'], name);
    await _loadSubjects();
  }

  // Add Chapter
  Future<void> _addChapter(Map<String, dynamic> unit) async {
    final result = await _showChapterDetailsDialog();
    if (result == null) return;

    await db.insertChapter(
      unit['id'],
      result['name'],
      result['minMarks'],
      result['maxMarks'],
      result['difficulty'],
    );
    await _loadSubjects();
  }

  // Add Topic
  Future<void> _addTopic(Map<String, dynamic> chapter) async {
    final result = await _showTopicDetailsDialog();
    if (result == null) return;

    await db.insertTopic(
      chapter['id'],
      result['name'],
      completed: result['completed'] ? 1 : 0,
      importance: result['importance'],
    );
    await _loadSubjects();
  }

  // Edit Subject
  Future<void> _editSubject(Map<String, dynamic> subject) async {
    final name = await _showTextInputDialog(title: 'Edit Subject', label: 'Subject Name', initialValue: subject['name']);
    if (name == null || name.isEmpty) return;

    await db.updateSubject(subject['id'], name);
    await _loadSubjects();
  }

  // Edit Unit
  Future<void> _editUnit(Map<String, dynamic> unit) async {
    final name = await _showTextInputDialog(title: 'Edit Unit', label: 'Unit Name', initialValue: unit['name']);
    if (name == null || name.isEmpty) return;

    await db.updateUnit(unit['id'], name);
    await _loadSubjects();
  }

  // Edit Chapter
  Future<void> _editChapter(Map<String, dynamic> chapter) async {
    final result = await _showChapterDetailsDialog(
      initialName: chapter['name'],
      initialMinMarks: chapter['min_marks'],
      initialMaxMarks: chapter['max_marks'],
      initialDifficulty: chapter['difficulty'],
    );
    if (result == null) return;

    await db.updateChapter(
      chapter['id'],
      result['name'],
      result['minMarks'],
      result['maxMarks'],
      result['difficulty'],
    );
    await _loadSubjects();
  }

  // Edit Topic
  Future<void> _editTopic(Map<String, dynamic> topic) async {
    final result = await _showTopicDetailsDialog(
      initialName: topic['name'],
      initialImportance: topic['importance'],
      initialCompleted: topic['completed'] == 1,
    );
    if (result == null) return;

    await db.updateTopic(
      topic['id'],
      result['name'],
      result['completed'] ? 1 : 0,
      result['importance'],
    );
    await _loadSubjects();
  }

  // Delete confirmation dialog
  Future<bool> _confirmDelete(String type, String name) async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete $type'),
            content: Text('Are you sure you want to delete "$name"? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
        )) ??
        false;
  }

  // Delete handlers
  Future<void> _deleteSubject(Map<String, dynamic> subject) async {
    if (await _confirmDelete('Subject', subject['name'])) {
      await db.deleteSubject(subject['id']);
      await _loadSubjects();
    }
  }

  Future<void> _deleteUnit(Map<String, dynamic> unit) async {
    if (await _confirmDelete('Unit', unit['name'])) {
      await db.deleteUnit(unit['id']);
      await _loadSubjects();
    }
  }

  Future<void> _deleteChapter(Map<String, dynamic> chapter) async {
    if (await _confirmDelete('Chapter', chapter['name'])) {
      await db.deleteChapter(chapter['id']);
      await _loadSubjects();
    }
  }

  Future<void> _deleteTopic(Map<String, dynamic> topic) async {
    if (await _confirmDelete('Topic', topic['name'])) {
      await db.deleteTopic(topic['id']);
      await _loadSubjects();
    }
  }

  // Widget for topics list
  Widget _buildTopicsList(List<dynamic> topics) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return ListTile(
          leading: Checkbox(
            value: topic['completed'] == 1,
            onChanged: (val) async {
              await db.updateTopic(
                topic['id'],
                topic['name'],
                val == true ? 1 : 0,
                topic['importance'],
              );
              await _loadSubjects();
            },
          ),
          title: Text(topic['name']),
          subtitle: Text('Importance: ${_importanceText(topic['importance'])}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () => _editTopic(topic)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteTopic(topic)),
            ],
          ),
        );
      },
    );
  }

  // Helpers for importance text
  String _importanceText(int importance) {
    switch (importance) {
      case 1:
        return 'Low';
      case 3:
        return 'High';
      case 2:
      default:
        return 'Medium';
    }
  }

  // Widget for chapters list
  Widget _buildChaptersList(List<dynamic> chapters) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return ExpansionTile(
          key: PageStorageKey('chapter_${chapter['id']}'),
          title: Text(chapter['name']),
          subtitle: Text(
              'Marks: ${chapter['min_marks'] ?? '-'} - ${chapter['max_marks'] ?? '-'}, Difficulty: ${chapter['difficulty'] ?? '-'}'),
          children: [
            _buildTopicsList(chapter['topics'] ?? []),
            ButtonBar(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Topic'),
                  onPressed: () => _addTopic(chapter),
                ),
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _editChapter(chapter)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteChapter(chapter)),
              ],
            )
          ],
        );
      },
    );
  }

  // Widget for units list
  Widget _buildUnitsList(List<dynamic> units) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        return ExpansionTile(
          key: PageStorageKey('unit_${unit['id']}'),
          title: Text(unit['name']),
          children: [
            _buildChaptersList(unit['chapters'] ?? []),
            ButtonBar(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Chapter'),
                  onPressed: () => _addChapter(unit),
                ),
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _editUnit(unit)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteUnit(unit)),
              ],
            )
          ],
        );
      },
    );
  }

  // Widget for subjects list
  Widget _buildSubjectsList() {
    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return ExpansionTile(
          key: PageStorageKey('subject_${subject['id']}'),
          title: Text(subject['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          children: [
            _buildUnitsList(subject['units'] ?? []),
            ButtonBar(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Unit'),
                  onPressed: () => _addUnit(subject),
                ),
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _editSubject(subject)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSubject(subject)),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
              ? Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Subject'),
                    onPressed: _addSubject,
                  ),
                )
              : _buildSubjectsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubject,
        child: const Icon(Icons.add),
        tooltip: 'Add Subject',
      ),
    );
  }
}
