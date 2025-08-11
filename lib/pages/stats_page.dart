import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, simple placeholder UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress & Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            SizedBox(height: 20),
            Center(
              child: Text(
                '📊 Your Study Progress',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),

            // Total study time placeholder
            ListTile(
              leading: Icon(Icons.timer),
              title: Text('Total Study Time'),
              subtitle: Text('0 hours (will update soon)'),
            ),

            // Topics completed placeholder
            ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Topics Completed'),
              subtitle: Text('0 / 0'),
            ),

            // Mock test mistakes placeholder
            ListTile(
              leading: Icon(Icons.assignment_late),
              title: Text('Mock Test Mistakes'),
              subtitle: Text('No data yet'),
            ),

            SizedBox(height: 40),
            Center(child: Text('More stats coming soon...', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}
