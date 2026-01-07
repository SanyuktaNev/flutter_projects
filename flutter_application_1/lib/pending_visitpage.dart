import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendingVisitPage extends StatefulWidget {
  const PendingVisitPage({super.key});

  @override
  State<PendingVisitPage> createState() => _PendingVisitPageState();
}

class _PendingVisitPageState extends State<PendingVisitPage> {
  List<Map<String, dynamic>> pendingVisits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPendingVisits();
  }

  Future<void> loadPendingVisits() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/visits.json");

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final allVisits = List<Map<String, dynamic>>.from(json.decode(content));
        final today = DateTime.now();
        final todayDateOnly = DateTime(today.year, today.month, today.day);
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

        pendingVisits = allVisits.where((visit) {
          try {
            if (visit['userId'] != currentUserId) return false;
            if (visit['status'] != "scheduled") return false;

            final parts = visit['visitDate'].split('/');
            final visitDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );

            return visitDate.isAfter(todayDateOnly) ||
                visitDate.isAtSameMomentAs(todayDateOnly);
          } catch (_) {
            return false;
          }
        }).toList();
      }
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : pendingVisits.isEmpty
            ? const Center(child: Text("No pending visits"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingVisits.length,
                itemBuilder: (_, index) {
                  final visit = pendingVisits[index];
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.purple,
                        size: 40,
                      ),
                      title: Text(
                        visit['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Visit Date: ${visit['visitDate'] ?? '-'}"),
                          Text("Visit Time: ${visit['visitTime'] ?? '-'}"),
                          if (visit['postComment'] != null &&
                              visit['postComment'].toString().isNotEmpty)
                            Text("Comment: ${visit['postComment']}"),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}
