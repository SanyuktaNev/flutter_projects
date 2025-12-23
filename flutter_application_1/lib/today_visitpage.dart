import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodayVisitPage extends StatefulWidget {
  const TodayVisitPage({super.key});

  @override
  State<TodayVisitPage> createState() => _TodayVisitPageState();
}

class _TodayVisitPageState extends State<TodayVisitPage> {
  List<Map<String, dynamic>> todayVisits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTodayVisits();
  }

  Future<void> loadTodayVisits() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/visits.json");

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> jsonData = json.decode(content);
        final allVisits = List<Map<String, dynamic>>.from(jsonData);

        final today = DateTime.now();
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

        todayVisits = allVisits.where((visit) {
          try {
            if (visit['userId'] != currentUserId) return false;
            if (visit['status'] != "completed") return false;

            final parts = visit['visitDate'].split('/');
            final visitDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );

            return visitDate.year == today.year &&
                visitDate.month == today.month &&
                visitDate.day == today.day;
          } catch (_) {
            return false;
          }
        }).toList();
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : todayVisits.isEmpty
            ? const Center(child: Text("No visits for today"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: todayVisits.length,
                itemBuilder: (_, index) {
                  final visit = todayVisits[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.purple),
                      title: Text(visit['name'] ?? ''),
                      subtitle: Text(
                        "${visit['mobile']}\n${visit['visitTime']}",
                      ),
                    ),
                  );
                },
              );
  }
}
