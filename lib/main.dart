import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/planner_page.dart';
import 'pages/stats_page.dart';
import 'providers/study_plan_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => StudyPlanProvider()..loadSubjects(),
      child: const StudyCraftApp(),
    ),
  );
}

class StudyCraftApp extends StatelessWidget {
  const StudyCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyCraft',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudyPlanProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('StudyCraft')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome to StudyCraft',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.playlist_add),
                label: const Text('Open Planner'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlannerPage()),
                  );
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.bar_chart),
                label: const Text('View Progress & Stats'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatsPage()),
                  );
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Import Sample Topics'),
                onPressed: () async {
                  await provider.importSampleData();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample data imported')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
