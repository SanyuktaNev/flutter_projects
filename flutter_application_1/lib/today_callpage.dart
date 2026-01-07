import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodayCallPage extends StatefulWidget {
  const TodayCallPage({super.key});

  @override
  State<TodayCallPage> createState() => _TodayCallPageState();
}

class _TodayCallPageState extends State<TodayCallPage> {
  List<Map<String, dynamic>> todayCalls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTodayCalls();
  }

  Future<void> loadTodayCalls() async {
  setState(() => isLoading = true);

  final directory = await getApplicationDocumentsDirectory();
  final file = File("${directory.path}/calls.json");

  todayCalls = [];

  if (await file.exists()) {
    final content = await file.readAsString();
    if (content.isNotEmpty) {
      final List<dynamic> jsonData = json.decode(content);
      final allCalls = List<Map<String, dynamic>>.from(jsonData);

      final today = DateTime.now();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

      todayCalls = allCalls.where((call) {
        try {
          if (call['userId'] != currentUserId) return false;

          final parts = call['callDate'].split('/');
          final callDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );

          return callDate.year == today.year &&
              callDate.month == today.month &&
              callDate.day == today.day;
        } catch (_) {
          return false;
        }
      }).toList();

      // Sort by call time (HH:MM)
      todayCalls.sort((a, b) {
        try {
          final aTime = a['callTime']?.split(':') ?? ['0', '0'];
          final bTime = b['callTime']?.split(':') ?? ['0', '0'];
          final aDateTime = DateTime(today.year, today.month, today.day,
              int.parse(aTime[0]), int.parse(aTime[1]));
          final bDateTime = DateTime(today.year, today.month, today.day,
              int.parse(bTime[0]), int.parse(bTime[1]));
          return aDateTime.compareTo(bDateTime);
        } catch (_) {
          return 0;
        }
      });
    }
  }

  setState(() => isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : todayCalls.isEmpty
            ? const Center(child: Text("No calls for today"))
            :RefreshIndicator(
  onRefresh: loadTodayCalls,
  child: ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: todayCalls.length,
    itemBuilder: (_, index) {
      final call = todayCalls[index];
      return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Icon(
            Icons.call,
            color: (call['callOutcome'] == 'Connected')
                ? Colors.green
                : (call['callOutcome'] == 'Busy')
                    ? Colors.orange
                    : (call['callOutcome'] == 'Not Answered')
                        ? Colors.red
                        : Colors.purple,
            size: 40,
          ),
          title: Text(call['name'] ?? 'Unknown'),
          subtitle: Text("${call['mobile']}\n${call['callTime']}"),
        ),
      );
    },
  ),
);

  }
}
