import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PastVisitPage extends StatefulWidget {
  const PastVisitPage({super.key});

  @override
  State<PastVisitPage> createState() => _PastVisitPageState();
}

class _PastVisitPageState extends State<PastVisitPage> {
  List<Map<String, dynamic>> pastVisits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPastVisits();
  }

  Future<void> loadPastVisits() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/visits.json");

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final allVisits = List<Map<String, dynamic>>.from(json.decode(content));
        final today = DateTime.now();
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

        pastVisits = allVisits.where((visit) {
          try {
            if (visit['userId'] != currentUserId) return false;
            if (visit['status'] != "completed") return false;

            final parts = visit['visitDate'].split('/');
            final visitDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));

            return visitDate.isBefore(today);
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
    return Scaffold(
      appBar: AppBar(title: const Text("Past Visits"), backgroundColor: Colors.purple),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pastVisits.isEmpty
              ? const Center(child: Text("No past visits found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pastVisits.length,
                  itemBuilder: (_, index) {
                    final visit = pastVisits[index];
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.location_on, color: Colors.purple, size: 40),
                        title: Text(visit['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Mobile: ${visit['mobile'] ?? '-'}"),
                            Text("Visit Date: ${visit['visitDate'] ?? '-'}"),
                            Text("Visit Time: ${visit['visitTime'] ?? '-'}"),
                            if (visit['postComment'] != null && visit['postComment'].toString().isNotEmpty)
                              Text("Comment: ${visit['postComment']}"),
                            if (visit['type'] != null)
                              Text("Type: ${visit['type']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
